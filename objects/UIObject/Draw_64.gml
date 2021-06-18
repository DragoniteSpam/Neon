// the default UI object just draws text

if (!self.enabled) return;

self.image_speed = 0;
var x1 = x;
var y1 = y;
var x2 = x + sprite_width;
var y2 = y + sprite_height;
var xt = x + sprite_width / 2;
var yt = y + sprite_height / 2;

draw_sprite_stretched(sprite_index, 0, x, y, sprite_width, sprite_height);
draw_sprite_stretched(sprite_index, 1, x, y, sprite_width, sprite_height);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text_ext_colour(xt, yt, self.text, -1, sprite_width, c_black, c_black, c_black, c_black, 1);