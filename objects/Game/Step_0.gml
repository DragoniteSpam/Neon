for (var i = 0, n =array_length(self.player.board); i < n; i++) {
    self.player.board[i].step(window_mouse_get_x(), window_mouse_get_y());
}