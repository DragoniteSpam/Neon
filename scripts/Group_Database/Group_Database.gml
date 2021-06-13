function Element(name, symbol, number, valence, oxidation, class) constructor {
    self.name = name;
    self.symbol = symbol;
    self.number = number;
    self.valence = valence;
    self.oxidation = oxidation;
    self.class = class;
    
    self.sprite = spr_card;
    
    function draw(x, y) {
        var width = sprite_get_height(self.sprite);
        var height = sprite_get_width(self.sprite);
        draw_sprite(self.sprite, 1, x, y);
        draw_sprite_ext(self.sprite, 0, x, y, 1, 1, 0, self.class.color, 1);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_text(x + width / 2, y + height / 2, self.symbol);
    }
}

function Class(name, color) constructor {
    self.name = name;
    self.color = color;
}