function ui_create_message(message, buttons) {
    var background = instance_create_depth(room_width / 2, room_height / 2, UI_LAYER - 100, UIText);
    background.text = message;
    background.image_xscale = 2;
    background.x -= background.sprite_width / 2;
    background.y -= background.sprite_height / 2;
    background.shade = true;
    ds_list_add(Game.ui_dynamic, background);
    
    for (var i = 0, n = array_length(buttons); i < n; i++) {
        var button = instance_create_depth(room_width / 2, background.y + background.sprite_height + 32, UI_LAYER - 200, UIButton);
        button.x -= button.sprite_width / 2;
        button.image_yscale = 0.5;
        button.text = buttons[i].message;
        button.OnClick = buttons[i].click;
        button.elevated_interaction = true;
        ds_list_add(Game.ui_dynamic, button);
    }
}