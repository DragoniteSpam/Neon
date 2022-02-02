// the default UI object just draws text

if (!self.enabled) return;

self.draw_shade();

self.image_speed = 0;
var x1 = x;
var y1 = y;
var x2 = x + sprite_width;
var y2 = y + sprite_height;
var xt = x + sprite_width / 2;
var yt = y + sprite_height / 2;

var mouseover = (!Game.blocked() || self.elevated_interaction) && point_in_rectangle(window_mouse_get_x(), window_mouse_get_y(), x1, y1, x2, y2);

draw_sprite_stretched_ext(sprite_index, 0, x, y, sprite_width, sprite_height, mouseover ? c_hover : c_white, 1);
draw_sprite_stretched_ext(sprite_index, 1, x, y, sprite_width, sprite_height, mouseover ? c_hover : c_white, 1);
draw_sprite_stretched_ext(sprite_index, 2, x, y, sprite_width, sprite_height, c_black, 1);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_font(fnt_neon_medium);
draw_text_ext_colour(xt, yt, self.text, -1, sprite_width, c_black, c_black, c_black, c_black, 1);

if (!self.interactive || !mouseover) return;

if (self.delay <= 0 && mouse_check_button_pressed(mb_left)) {
    self.OnClick();
}