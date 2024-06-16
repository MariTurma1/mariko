import math

def print_board(board):
    print(" " + board[0] + " | " + board[1] + " | " + board[2])
    print("---+---+---")
    print(" " + board[3] + " | " + board[4] + " | " + board[5])
    print("---+---+---")
    print(" " + board[6] + " | " + board[7] + " | " + board[8])

def check_win(board):
    win_conditions = [
        (0, 1, 2), (3, 4, 5), (6, 7, 8),  # Rows
        (0, 3, 6), (1, 4, 7), (2, 5, 8),  # Columns
        (0, 4, 8), (2, 4, 6)              # Diagonals
    ]
    for condition in win_conditions:
        if board[condition[0]] == board[condition[1]] == board[condition[2]] != " ":
            return board[condition[0]]
    if " " not in board:
        return "Draw"
    return False

def minimax(board, depth, is_maximizing):
    winner = check_win(board)
    if winner == "X":
        return -1
    if winner == "O":
        return 1
    if winner == "Draw":
        return 0

    if is_maximizing:
        best_score = -math.inf
        for i in range(9):
            if board[i] == " ":
                board[i] = "O"
                score = minimax(board, depth + 1, False)
                board[i] = " "
                best_score = max(score, best_score)
        return best_score
    else:
        best_score = math.inf
        for i in range(9):
            if board[i] == " ":
                board[i] = "X"
                score = minimax(board, depth + 1, True)
                board[i] = " "
                best_score = min(score, best_score)
        return best_score

def ai_move(board):
    best_score = -math.inf
    move = None
    for i in range(9):
        if board[i] == " ":
            board[i] = "O"
            score = minimax(board, 0, False)
            board[i] = " "
            if score > best_score:
                best_score = score
                move = i
    return move

def game():
    board = [" "] * 9
    print("AI's turn")
    ai_move_index = ai_move(board)
    board[ai_move_index] = "O"
    print_board(board)
    
    while True:
        while True:
            try:
                user_move_index = int(input("Enter your move (1-9): ")) - 1
                if user_move_index not in range(9) or board[user_move_index] != " ":
                    raise ValueError
                break
            except ValueError:
                print("Invalid move, try again.")
        
        board[user_move_index] = "X"
        print("Your turn")
        print_board(board)
        result = check_win(board)
        if result:
            if result == "Draw":
                print("It's a draw!")
            else:
                print("You win!")
            break
        
        ai_move_index = ai_move(board)
        board[ai_move_index] = "O"
        print("AI's turn")
        print_board(board)
        result = check_win(board)
        if result:
            if result == "Draw":
                print("It's a draw!")
            else:
                print("AI wins!")
            break

if __name__ == "__main__":
    game()


# Tic-Tac-Toe is a classic two-player game played on a 3x3 grid. Players take turns marking spaces with either "X" or "O". The objective is to be the first to get three of your marks in a row, either horizontally, vertically, or diagonally. If all nine spaces are filled and no player has achieved three in a row, the game results in a draw. Given its simplicity, Tic-Tac-Toe can be implemented as an adversarial game with two agents, where one can ensure optimal play to never l
# A function, print_board(board), is used to display the current state of the board. This function prints the board in a human-readable format, showing the positions of "X" and "O".
# The minimax algorithm is a recursive algorithm used to determine the optimal move in two-player games. It operates by simulating all possible moves and their consequences, ensuring that the AI makes the best possible move to either win or avoid losing.
