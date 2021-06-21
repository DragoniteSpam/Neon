Update = function() {
    if (Game.player.tutorial.running) return;
    if (!Game.player.running) {
        self.enabled = false;
    } else {
        self.enabled = true;
        self.text = "Total score: " + string(Game.player.score);
    }
};