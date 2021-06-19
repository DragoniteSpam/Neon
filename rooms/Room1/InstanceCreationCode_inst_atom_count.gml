Update = function() {
    if (!Game.player.running) {
        self.enabled = false;
    } else {
        self.enabled = true;
        self.text = "Atoms remaining: " + string(Game.player.AtomsRemaining());
    }
};