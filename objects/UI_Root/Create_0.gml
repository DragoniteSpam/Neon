// this doesn't get rendered, although you can use it as an
// anchor point for other stuff

Update = function() {
    
};

Render = function() {
    
};

draw_shade = function() {
    if (!self.shade) return;
    draw_set_alpha(0.5);
    draw_rectangle_colour(0, 0, window_get_width(), window_get_height(), c_black, c_black, c_black, c_black, false);
    draw_set_alpha(1);
};