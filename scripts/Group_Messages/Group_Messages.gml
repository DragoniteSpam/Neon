function ui_create_message(message, buttons, list = Game.ui_dynamic, delay = 0) {
    var background = instance_create_depth(room_width / 2, room_height / 2, UI_LAYER - 100, UIText);
    background.text = message;
    background.image_xscale = 3;
    background.x -= background.sprite_width / 2;
    background.y -= background.sprite_height / 2;
    background.shade = true;
    ds_list_add(list, background);
    
    var n = array_length(buttons);
    var off = 0;
    switch (n) {
        case 1:     off = 0;        break;
        case 2:     off = 72;       break;
        case 3:     off = 144;      break;
    }
    
    for (var i = 0; i < n; i++) {
        var button = instance_create_depth(room_width / 2 - off + 144 * i, background.y + background.sprite_height + 32, UI_LAYER - 200, UIButton);
        button.delay = 0;
        button.x -= button.sprite_width / 2;
        button.image_yscale = 0.5;
        button.text = buttons[i].message;
        button.OnClick = method(button, buttons[i].click);
        button.elevated_interaction = true;
        button.index = i;
        ds_list_add(list, button);
    }
    
    return background;
}

function ui_clear_dynamic_messages() {
    for (var i = 0, n = ds_list_size(Game.ui_dynamic); i < n; i++) {
        instance_destroy(Game.ui_dynamic[| i]);
    }
    ds_list_clear(Game.ui_dynamic);
}

function ui_clear_tutorial_messages() {
    for (var i = 0, n = ds_list_size(Game.ui_tutorial); i < n; i++) {
        instance_destroy(Game.ui_tutorial[| i]);
    }
    ds_list_clear(Game.ui_tutorial);
}