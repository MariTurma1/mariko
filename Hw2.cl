/*
 *  The scanner definition for COOL.
 */

/* ----- Declarations begin: */
%{
#include <cool-parse.h>
#include <stringtab.h>
#include <utilities.h>
#include <string>

#define yylval cool_yylval
#define yylex  cool_yylex

#define MAX_STR_CONST 1025
#define YY_NO_UNPUT   /* keep g++ happy */

extern FILE *fin; /* we read from this file */

#undef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
    if ( (result = fread( (char*)buf, sizeof(char), max_size, fin)) < 0) \
        YY_FATAL_ERROR( "read() in flex scanner failed");

char string_buf[MAX_STR_CONST]; /* to assemble string constants */
char *string_buf_ptr;

static int comment_layer = 0;

extern int curr_lineno;
extern int verbose_flag;

extern YYSTYPE cool_yylval;

%}

/* ----- Declarations end. */


/* ----- Definitions begin: */

DARROW          =>
DIGIT           [0-9]
%Start          COMMENTS
%Start          INLINE_COMMENTS
%Start          STRING

/* ----- Definitions end. */


 /* ----- Rules begin: */
%%

 /* Nested comments */
<INITIAL,COMMENTS,INLINE_COMMENTS>"(*" {
    comment_layer++;
    BEGIN COMMENTS;
}

<COMMENTS>[^\n(*]* { }

<COMMENTS>[()*] { }

<COMMENTS>"*)" {
    comment_layer--;
    if (comment_layer == 0) {
        BEGIN 0;
    }
}

<COMMENTS><<EOF>> {
    yylval.error_msg = "EOF in comment";
    BEGIN 0;
    return ERROR;
}

"*)" {
    yylval.error_msg = "Unmatched *)";
    return ERROR;
}

 /* ===============
  * inline comments
  * ===============
  */

 /* if seen "--", start inline comment */
<INITIAL>"--" { BEGIN INLINE_COMMENTS; }

 /* any character other than '\n' is a nop in inline comments */ 
<INLINE_COMMENTS>[^\n]* { }

 /* if seen '\n' in inline comment, the comment ends */
<INLINE_COMMENTS>\n {
    curr_lineno++;
    BEGIN 0;
}

 /* =========
  * STR_CONST
  * =========
  * String constants (C syntax)
  * Escape sequence \c is accepted for all characters c. Except for 
  * \n \t \b \f, the result is c.
  */

 /* if seen '\"', start string */
<INITIAL>(\") {
    BEGIN STRING;
    yymore();
}

 /* Cannot read '\\' '\"' '\n' */
<STRING>[^\\\"\n]* { yymore(); }

 /* normal escape characters, not \n */
<STRING>\\[^\n] { yymore(); }

 /* seen a '\\' at the end of a line, the string continues */
<STRING>\\\n {
    curr_lineno++;
    yymore();
}

 /* meet EOF in the middle of a string, error */
<STRING><<EOF>> {
    yylval.error_msg = "EOF in string constant";
    BEGIN 0;
    yyrestart(yyin);
    return ERROR;
}

 /* meet a '\n' in the middle of a string without a '\\', error */
<STRING>\n {
    yylval.error_msg = "Unterminated string constant";
    BEGIN 0;
    curr_lineno++;
    return ERROR;
}

 /* meet a "\\0"??? */
<STRING>\\0 {
    yylval.error_msg = "Unterminated string constant";
    BEGIN 0;
    //curr_lineno++;
    return ERROR;
}

 /* string ends, we need to deal with some escape characters */
<STRING>\" {
    std::string input(yytext, yyleng);

    // remove the '\"'s on both sizes.
    input = input.substr(1, input.length() - 2);

    std::string output = "";
    std::string::size_type pos;
    
    if (input.find_first_of('\0')!= std::string::npos) {
        yylval.error_msg = "String contains null character";
        BEGIN 0;
        return ERROR;    
    }

    while ((pos = input.find_first_of("\\"))!= std::string::npos) {
        output += input.substr(0, pos);

        switch (input[pos + 1]) {
        case 'b':
            output += "\b";
            break;
        case 't':
            output += "\t";
            break;
        case 'n':
            output += "\n";
            break;
        case 'f':
            output += "\f";
            break;
        default:
            output += input[pos + 1];
            break;
        }

        input = input.substr(pos + 2, input.length() - 2);
    }

    output += input;

    if (output.length
