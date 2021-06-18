Update = function() {
    if (!Game.player.running) {
        self.enabled = false;
    } else {
        self.enabled = true;
        self.text = "Score: " + string(Game.player.molecule.Score());
    }
};