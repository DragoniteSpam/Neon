function Element(name, symbol, number, valence, electro, class) constructor {
    self.name = name;
    self.symbol = symbol;
    self.number = number;
    self.valence = valence;
    self.electro = electro;
    self.class = class;
    
    self.sprite = spr_card;
    
    function draw(x, y, mouseover) {
        var width = sprite_get_height(self.sprite);
        var height = sprite_get_width(self.sprite);
        draw_sprite(self.sprite, 1, x, y);
        draw_sprite_ext(self.sprite, 0, x, y, 1, 1, 0, self.class.color, 1);
        if (mouseover) {
            draw_sprite_ext(self.sprite, 2, x, y, 1, 1, 0, self.class.color, 1);
        }
        draw_set_valign(fa_middle);
        draw_set_halign(fa_center);
        draw_set_font(fnt_neon);
        draw_text_colour(x + width / 2, y + height / 2, self.symbol, c_black, c_black, c_black, c_black, 1);
        draw_set_font(fnt_neon_small);
        draw_text_colour(x + width / 2, y + height - 20, self.number, c_black, c_black, c_black, c_black, 1);
        draw_set_halign(fa_right);
        if (self.electro != undefined) {
            draw_text_colour(x + width - 20, y + 20, string(self.electro), c_black, c_black, c_black, c_black, 1);
        } else {
            draw_text_colour(x + width - 20, y + 20, "x" + string(self.number), c_black, c_black, c_black, c_black, 1);
        }
    }
}

function Class(name, color) constructor {
    self.name = name;
    self.color = color;
}

function ElementCard(x, y, element) constructor {
    self.x = x;
    self.y = y;
    self.element = element;
    
    self.mouseover = false;
    
    function draw() {
        self.element.draw(self.x, self.y, self.mouseover);
    }
    
    function mouse(mx, my) {
        var x1 = self.x;
        var y1 = self.y;
        var x2 = sprite_get_width(self.element.sprite);
        var y2 = sprite_get_height(self.element.sprite);
        if (point_in_rectangle(mx, my, x1, y1, x2, y2)) {
            self.mouseover = true;
        } else {
            self.mouseover = false;
        }
    }
}