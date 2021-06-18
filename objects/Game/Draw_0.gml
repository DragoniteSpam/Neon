for (var i = 0; i < array_length(self.board); i++) {
    for (var j = 0; j < array_length(self.board[i]); j++) {
        self.board[i][j].draw();
    }
    
    self.molecule.draw(room_width * 3 / 4, room_height / 2);
}