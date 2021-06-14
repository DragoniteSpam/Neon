for (var i = 0; i < array_length(board); i++) {
    for (var j = 0; j < array_length(board[i]); j++) {
        board[i][j].step(window_mouse_get_x(), window_mouse_get_y());
    }
}