function Element(name, symbol, number, valence, shell_size, electro, class) constructor {
    self.name = name;
    self.symbol = symbol;
    self.number = number;
    self.valence = valence;
    self.shell_size = shell_size;
    self.electro = electro;
    self.class = class;
    self.valid = true;
    
    self.sprite = spr_card;
    self.radius = (self.number == undefined) ? 0 : (12 * (1 + sqrt(self.number)));
    
    function draw(x, y, mouseover, used) {
        var width = sprite_get_height(self.sprite);
        var height = sprite_get_width(self.sprite);
        var c = used ? c_used : self.class.color;
        draw_sprite(self.sprite, 1, x, y);
        draw_sprite_ext(self.sprite, 0, x, y, 1, 1, 0, c, 1);
        if (mouseover) {
            draw_sprite_ext(self.sprite, 2, x, y, 1, 1, 0, c_black, 1);
        }
        draw_set_valign(fa_middle);
        draw_set_halign(fa_center);
        draw_set_font(fnt_neon);
        draw_text_colour(x + width / 2, y + height / 2, self.symbol, c_black, c_black, c_black, c_black, 1);
        draw_set_font(fnt_neon_small);
        if (self.number != undefined) {
            draw_text_colour(x + width / 2, y + height - 20, self.number, c_black, c_black, c_black, c_black, 1);
        }
        if (self.electro != undefined) {
            draw_set_halign(fa_right);
            draw_text_colour(x + width - 20, y + 20, string(self.electro), c_black, c_black, c_black, c_black, 1);
            draw_set_halign(fa_left);
            draw_text_colour(x + 20, y + 20, string(self.valence) + "/" + string(self.shell_size), c_black, c_black, c_black, c_black, 1);
        } else if (self.number != undefined) {
            draw_set_halign(fa_center);
            draw_text_colour(x + width / 2, y + 20, "x" + string(self.number), c_black, c_black, c_black, c_black, 1);
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
    self.used = false;
    self.interactive = true;
    self.special_disable = false;
    
    self.OnClick = function() {
    }
    
    function draw() {
        self.element.draw(self.x, self.y, self.mouseover, self.used);
    }
    
    function step(mx, my) {
        var x1 = self.x;
        var y1 = self.y;
        var x2 = x1 + sprite_get_width(self.element.sprite);
        var y2 = y1 + sprite_get_height(self.element.sprite);
        if (self.interactive && self.element.valid && !Game.blocked() && point_in_rectangle(mx, my, x1, y1, x2, y2)) {
            self.mouseover = true;
            if (mouse_check_button_pressed(mb_left)) {
                self.OnClick();
                if (Game.player.molecule.Add(self.element) != BondStatusCodes.INVALID) {
                    self.used = true;
                } else {
                    Game.player.time *= WRONGNESS_PENALTY;
                }
            }
        } else {
            self.mouseover = false;
        }
    }
}