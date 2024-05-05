#include <iostream>
#include <string>
#include <regex>
#include <vector>

using namespace std;

// Token types
enum TokenType {
    NUMBER,
    PLUS,
    MINUS,
    TIMES,
    DIVIDE,
    LPAREN,
    RPAREN,
    EOF_TOKEN
};

// Token structure
struct Token {
    TokenType type;
    string value;
};

// Lexer function
vector<Token> lex(const string& input) {
    vector<Token> tokens;
    regex numberRegex("[0-9]+");
    regex plusRegex("\\+");
    regex minusRegex("-");
    regex timesRegex("\\*");
    regex divideRegex("/");
    regex lparenRegex("\\(");
    regex rparenRegex("\\)");

    smatch match;
    string::const_iterator searchStart = input.begin();

    while (regex_search(searchStart, input.end(), match, numberRegex)) {
        Token token;
        token.type = NUMBER;
        token.value = match.str();
        tokens.push_back(token);
        searchStart = match.suffix().first;
    }

    searchStart = input.begin();
    while (regex_search(searchStart, input.end(), match, plusRegex)) {
        Token token;
        token.type = PLUS;
        token.value = match.str();
        tokens.push_back(token);
        searchStart = match.suffix().first;
    }

    searchStart = input.begin();
    while (regex_search(searchStart, input.end(), match, minusRegex)) {
        Token token;
        token.type = MINUS;
        token.value = match.str();
        tokens.push_back(token);
        searchStart = match.suffix().first;
    }

    searchStart = input.begin();
    while (regex_search(searchStart, input.end(), match, timesRegex)) {
        Token token;
        token.type = TIMES;
        token.value = match.str();
        tokens.push_back(token);
        searchStart = match.suffix().first;
    }

    searchStart = input.begin();
    while (regex_search(searchStart, input.end(), match, divideRegex)) {
        Token token;
        token.type = DIVIDE;
        token.value = match.str();
        tokens.push_back(token);
        searchStart = match.suffix().first;
    }

    searchStart = input.begin();
    while (regex_search(searchStart, input.end(), match, lparenRegex)) {
        Token token;
        token.type = LPAREN;
        token.value = match.str();
        tokens.push_back(token);
        searchStart = match.suffix().first;
    }

    searchStart = input.begin();
    while (regex_search(searchStart, input.end(), match, rparenRegex)) {
        Token token;
        token.type = RPAREN;
        token.value = match.str();
        tokens.push_back(token);
        searchStart = match.suffix().first;
    }

    Token eofToken;
    eofToken.type = EOF_TOKEN;
    tokens.push_back(eofToken);

    return tokens;
}

// Parser function
int parse(const vector<Token>& tokens) {
    int result = 0;
    int tokenIndex = 0;

    // Expr -> Term (( "+" | "-" ) Term)*
    result = parseTerm(tokens, tokenIndex);

    while (tokenIndex < tokens.size() && (tokens[tokenIndex].type == PLUS || tokens[tokenIndex].type == MINUS)) {
        TokenType opType = tokens[tokenIndex].type;
        tokenIndex++;

        int termResult = parseTerm(tokens, tokenIndex);

        if (opType == PLUS) {
            result += termResult;
        } else {
            result -= termResult;
        }
    }

    return result;
}

int parseTerm(const vector<Token>& tokens, int& tokenIndex) {
    int result = 0;

    // Term -> Factor (( "*" | "/" ) Factor)*
    result = parseFactor(tokens, tokenIndex);

    while (tokenIndex < tokens.size() && (tokens[tokenIndex].type == TIMES || tokens[tokenIndex].type == DIVIDE)) {
        TokenType opType = tokens[tokenIndex].type;
        tokenIndex++;

        int factorResult = parseFactor(tokens, tokenIndex);

        if (opType == TIMES) {
            result *= factorResult;
        } else {
            result /= factorResult;
        }
    }

    return result;
}

int parseFactor(const vector<Token>& tokens, int& tokenIndex) {
    int result = 0;

    // Factor -> "(" Expr ")" | Number
    if (tokens[tokenIndex].type == LPAREN) {
        tokenIndex++;

        result = parse(tokens);

        if (tokens[tokenIndex].type!= RPAREN) {
            cerr << "Error: expected ')'" << endl;
            exit(1);
        }

        tokenIndex++;
    } else {
        result = stoi(tokens[tokenIndex].value);
        tokenIndex++;
    }

    return result;
}

int main() {
    string input;
    cout << "Enter an arithmetic
