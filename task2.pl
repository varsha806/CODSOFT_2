% Define the initial empty board
initial_board([e,e,e,e,e,e,e,e,e]).

% Define the player symbols
player(x).
player(o).

% Define the winning combinations
winning_combination([A,A,A,_,_,_,_,_,_]).
winning_combination([_,_,_,A,A,A,_,_,_]).
winning_combination([_,_,_,_,_,_,A,A,A]).
winning_combination([A,_,_,A,_,_,A,_,_]).
winning_combination([_,A,_,_,A,_,_,A,_]).
winning_combination([_,_,A,_,_,A,_,_,A]).
winning_combination([A,_,_,_,A,_,_,_,A]).
winning_combination([_,_,A,_,A,_,A,_,_]).

% Check if a player has won
has_won(Board, Player) :-
    member(Combination, [
        [0, 1, 2], [3, 4, 5], [6, 7, 8], % Rows
        [0, 3, 6], [1, 4, 7], [2, 5, 8], % Columns
        [0, 4, 8], [2, 4, 6]             % Diagonals
    ]),
    maplist(nth0_check(Board, Player), Combination).

nth0_check(Board, Player, Index) :-
    nth0(Index, Board, Player).

% Check if the board is full
board_full(Board) :-
    \+ member(e, Board).

% Make a move on the board
make_move(Board, Index, Player, NewBoard) :-
    nth0(Index, Board, e),
    replace(Board, Index, Player, NewBoard).

% Replace an element in a list
replace([_|T], 0, X, [X|T]).
replace([H|T], I, X, [H|R]) :-
    I > 0,
    I1 is I - 1,
    replace(T, I1, X, R).

% Evaluate the board
evaluate(Board, Score) :-
    (has_won(Board, x) -> Score = 1 ;
     has_won(Board, o) -> Score = -1 ;
     Score = 0).

% Minimax algorithm
minimax(Board, Player, BestMove, BestScore) :-
    (board_full(Board) ->
        BestMove = -1, evaluate(Board, BestScore)
    ;
        findall(Index, nth0(Index, Board, e), Moves),
        (Player = x ->
            find_best_move(Moves, Board, Player, -100, BestMove, BestScore)
        ;
            find_best_move(Moves, Board, Player, 100, BestMove, BestScore)
        )
    ).

% Find the best move for the current player
find_best_move([], _, _, CurrentBestScore, _, CurrentBestScore).
find_best_move([Move|Moves], Board, Player, CurrentBestScore, BestMove, BestScore) :-
    make_move(Board, Move, Player, NewBoard),
    next_player(Player, NextPlayer),
    minimax(NewBoard, NextPlayer, _, OpponentScore),
    Score is -OpponentScore,
    (Player = x ->
        (Score > CurrentBestScore ->
            find_best_move(Moves, Board, Player, Score, Move, BestScore)
        ;
            find_best_move(Moves, Board, Player, CurrentBestScore, BestMove, BestScore)
        )
    ;
        (Score < CurrentBestScore ->
            find_best_move(Moves, Board, Player, Score, Move, BestScore)
        ;
            find_best_move(Moves, Board, Player, CurrentBestScore, BestMove, BestScore)
        )
    ).

% Determine the next player
next_player(x, o).
next_player(o, x).

% Play the game
play :-
    initial_board(Board),
    play_game(Board, x).

% Play the game loop
play_game(Board, Player) :-
    print_board(Board),
    (has_won(Board, x) ->
        write('X wins!'), nl
    ;
     has_won(Board, o) ->
        write('O wins!'), nl
    ;
     board_full(Board) ->
        write('It\'s a draw!'), nl
    ;
     Player = x ->
        write('Your move (0-8): '), read(Move),
        (make_move(Board, Move, x, NewBoard) ->
            play_game(NewBoard, o)
        ;
            write('Invalid move!'), nl,
            play_game(Board, x)
        )
    ;
        write('AI is making a move...'), nl,
        minimax(Board, o, BestMove, _),
        make_move(Board, BestMove, o, NewBoard),
        play_game(NewBoard, x)
    ).

% Print the board
print_board([A,B,C,D,E,F,G,H,I]) :-
    format('~w | ~w | ~w~n', [A,B,C]),
    format('--+---+--~n'),
    format('~w | ~w | ~w~n', [D,E,F]),
    format('--+---+--~n'),
    format('~w | ~w | ~w~n', [G,H,I]).
