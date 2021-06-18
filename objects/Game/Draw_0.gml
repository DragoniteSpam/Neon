for (var i = 0, n =array_length(self.player.board); i < n; i++) {
    self.player.board[i].draw();
}

self.player.molecule.draw(room_width * 3 / 4, room_height / 2);