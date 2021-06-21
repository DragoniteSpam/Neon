if (self.player.tutorial.running) {
    draw_sprite(spr_adam, 0, room_width / 2, room_height * 2 / 5);
    draw_sprite(spr_face, 0, room_width / 2, room_height * 2 / 5);
}

if (room == rm_title) {
    draw_set_font(fnt_title);
    draw_set_colour(c_blue);
    draw_text(room_width / 2, room_height / 3, "CHEMISTRY GAME");
}