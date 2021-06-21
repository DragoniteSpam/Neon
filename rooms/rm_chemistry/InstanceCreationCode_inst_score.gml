special = false;

Update = function() {
    if (!special && Game.player.tutorial.running) return;
    if (!Game.player.running) {
        self.enabled = false;
    } else {
        self.enabled = true;
        self.text = "Score: " + string(Game.player.molecule.Score());
    }
};