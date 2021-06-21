Update = function() {
    if (!Game.player.running) {
        self.enabled = false;
    } else {
        self.enabled = true;
        self.text = "Time: " + string(ceil(Game.player.time));
    }
};