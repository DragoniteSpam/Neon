var xx = 32;
var yy = 32;

for (var i = 0; i < array_length(board); i++) {
    for (var j = 0; j < array_length(board[i]); j++) {
        board[i][j].draw(xx + 130 * i, yy + 130 * j);
    }
}