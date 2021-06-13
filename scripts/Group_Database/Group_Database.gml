function Element(name, symbol, number, valence, oxidation) constructor {
    self.name = name;
    self.symbol = symbol;
    self.number = number;
    self.valence = valence;
    self.oxidation = oxidation;
    
    function draw(x, y) {
        draw_sprite(spr_card, 1, x, y);
        draw_sprite_ext(spr_card, 0, x, y, 1, 1, 0, c_red, 1);
    }
}