// --- BLOQUEO TOTAL DE APERTURA E INTERACCIÓN EN ROOMS ESPECÍFICAS ---
var _room_actual = room_get_name(room);
if (_room_actual == "bbs" || _room_actual == "rm_title") {
    state = MENU_STATE.CLOSED; 
    exit; 
}

// Abrir menú principal con C o Ctrl
if (state == MENU_STATE.CLOSED) {
    if (keyboard_check_pressed(ord("C")) || keyboard_check_pressed(vk_control)) {
        if (!instance_exists(obj_textbox)) {
            state = MENU_STATE.MAIN;
            main_index = 0;
            audio_play_sound(snd_menumove, 10, false);
        }
    }
    exit;
}

// Cerrar menú o retroceder con X o Shift
if (keyboard_check_pressed(ord("X")) || keyboard_check_pressed(vk_shift)) {
    if (state == MENU_STATE.MAIN) {
        state = MENU_STATE.CLOSED;
    } else if (state == MENU_STATE.INVENTORY) {
        state = MENU_STATE.MAIN;
    } else if (state == MENU_STATE.ITEM_ACTION) {
        state = MENU_STATE.INVENTORY;
    } else if (state == MENU_STATE.ITEM_INFO) {
        state = MENU_STATE.ITEM_ACTION;
    } else if (state == MENU_STATE.ITEM_DROP_CONFIRM) {
        state = MENU_STATE.ITEM_ACTION;
    } 
    // Retrocesos para EQUIP
    else if (state == MENU_STATE.EQUIP_MENU) {
        state = MENU_STATE.MAIN;
    } else if (state == MENU_STATE.EQUIP_ACTION) {
        state = MENU_STATE.EQUIP_MENU;
    } else if (state == MENU_STATE.EQUIP_INFO) {
        state = MENU_STATE.EQUIP_ACTION;
    } else if (state == MENU_STATE.EQUIP_DROP_CONFIRM) {
        state = MENU_STATE.EQUIP_ACTION;
    }
    // Retrocesos para CONFIG
    else if (state == MENU_STATE.CONFIG_MENU) {
        state = MENU_STATE.MAIN;
    } else if (state == MENU_STATE.CONFIG_ACTION) {
        state = MENU_STATE.CONFIG_MENU;
        config_index = -1; 
    }
    // Retrocesos para STAD y CERRAR
    else if (state == MENU_STATE.INFO_MENU) {
        state = MENU_STATE.MAIN;
    } else if (state == MENU_STATE.GAME_CLOSE_CONFIRM) {
        state = MENU_STATE.MAIN;
    }
    audio_play_sound(snd_menumove, 10, false);
    exit;
}

// Lógica de navegación principal y submenús
switch (state) {
    case MENU_STATE.MAIN:
        var _moved_main = false;
        if (keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"))) {
            main_index = (main_index + 1) % array_length(main_options);
            _moved_main = true;
        }
        if (keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W"))) {
            main_index = (main_index - 1 + array_length(main_options)) % array_length(main_options);
            _moved_main = true;
        }
        if (_moved_main) {
            audio_play_sound(snd_menumove, 10, false);
        }
        
        if (keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(vk_enter)) {
            audio_play_sound(snd_menumove, 10, false);
            switch (main_index) {
                case 0: // INV
                    state = MENU_STATE.INVENTORY;
                    inv_x = 0; inv_y = 0; inv_scroll = 0;
                    break;
                case 1: // EQUIP
                    state = MENU_STATE.EQUIP_MENU;
                    equip_x = 0; equip_y = 0; equip_scroll = 0;
                    break;
                case 2: // STAD
                    state = MENU_STATE.INFO_MENU;
                    break;
                case 3: // CONFIG
                    state = MENU_STATE.CONFIG_MENU;
                    config_tab = 0;
                    config_index = -1; 
                    break;
                case 4: // CERRAR
                    state = MENU_STATE.GAME_CLOSE_CONFIRM;
                    close_confirm_index = 1;
                    break;
            }
        }
        break;
        
    case MENU_STATE.INVENTORY:
        var _moved_inv = false;
        if (keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D"))) {
            inv_x = (inv_x + 1) % 3;
            _moved_inv = true;
        }
        if (keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A"))) {
            inv_x = (inv_x - 1 + 3) % 3;
            _moved_inv = true;
        }
        if (keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"))) {
            if (inv_y < 2) {
                inv_y++;
                _moved_inv = true;
            } else if (inv_scroll < 1) { 
                inv_scroll++;
                _moved_inv = true;
            }
        }
        if (keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W"))) {
            if (inv_y > 0) {
                inv_y--;
                _moved_inv = true;
            } else if (inv_scroll > 0) {
                inv_scroll--;
                _moved_inv = true;
            }
        }
        if (_moved_inv) {
            audio_play_sound(snd_menumove, 10, false);
        }
        
        if (keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(vk_enter)) {
            var index = (inv_y + inv_scroll) * 3 + inv_x;
            if (instance_exists(obj_player) && index < array_length(obj_player.inventory)) {
                if (obj_player.inventory[index] != -1) {
                    audio_play_sound(snd_menumove, 10, false);
                    state = MENU_STATE.ITEM_ACTION;
                    action_index = 0;
                } else {
                    if (audio_is_playing(snd_error)) audio_stop_sound(snd_error);
                    audio_play_sound(snd_error, 10, false);
                }
            }
        }
        break;
        
    case MENU_STATE.ITEM_ACTION:
        var _moved_ia = false;
        if (keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D"))) {
            action_index = (action_index + 1) % array_length(action_options);
            _moved_ia = true;
        }
        if (keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A"))) {
            action_index = (action_index - 1 + array_length(action_options)) % array_length(action_options);
            _moved_ia = true;
        }
        if (_moved_ia) {
            audio_play_sound(snd_menumove, 10, false);
        }
        
        if (keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(vk_enter)) {
            audio_play_sound(snd_menumove, 10, false);
            var slot_index = (inv_y + inv_scroll) * 3 + inv_x;
            
            if (instance_exists(obj_player) && slot_index < array_length(obj_player.inventory)) {
                var current_item_key = obj_player.inventory[slot_index];
                var item_data = global.item_db[$ current_item_key];
                
                switch (action_index) {
                    case 0: // Usar
                        if (item_data != undefined && item_data.efecto != undefined) {
                            item_data.efecto();
                            obj_player.inventory[slot_index] = -1;
                        }
                        state = MENU_STATE.CLOSED;
                        break;
                    case 1: // Tirar
                        state = MENU_STATE.ITEM_DROP_CONFIRM;
                        drop_confirm_index = 1;
                        break;
                    case 2: // Info
                        state = MENU_STATE.ITEM_INFO;
                        break;
                }
            }
        }
        break;
        
    case MENU_STATE.ITEM_INFO:
        if (keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(vk_enter)) {
            audio_play_sound(snd_menumove, 10, false);
            state = MENU_STATE.ITEM_ACTION;
        }
        break;
        
    case MENU_STATE.ITEM_DROP_CONFIRM:
        if (keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D")) || keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A"))) {
            drop_confirm_index = (drop_confirm_index + 1) % 2;
            audio_play_sound(snd_menumove, 10, false);
        }
        if (keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(vk_enter)) {
            audio_play_sound(snd_menumove, 10, false);
            var slot_index = (inv_y + inv_scroll) * 3 + inv_x;
            
            if (instance_exists(obj_player) && slot_index < array_length(obj_player.inventory)) {
                var current_item_key = obj_player.inventory[slot_index];
                var item_data = global.item_db[$ current_item_key];
                var item_name = (item_data != undefined) ? item_data.nombre : "objeto";
                
                if (drop_confirm_index == 0) {
                    obj_player.inventory[slot_index] = -1;
                    state = MENU_STATE.CLOSED;
                    var _textbox = instance_create_layer(x, y, layer, obj_textbox);
                    _textbox.text = ["Has tirado " + item_name + "."];
                    _textbox.page_number = array_length(_textbox.text);
                } else {
                    state = MENU_STATE.INVENTORY;
                }
            }
        }
        break;

    // --- LÓGICA PARA EQUIP (50 slots) ---
    case MENU_STATE.EQUIP_MENU:
        var _moved_eq = false;
        if (keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D"))) {
            equip_x = (equip_x + 1) % 3;
            _moved_eq = true;
        }
        if (keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A"))) {
            equip_x = (equip_x - 1 + 3) % 3;
            _moved_eq = true;
        }
        if (keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"))) {
            if (equip_y < 2) {
                equip_y++;
                _moved_eq = true;
            } else if (equip_scroll < max_equip_scroll) { 
                equip_scroll++;
                _moved_eq = true;
            }
        }
        if (keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W"))) {
            if (equip_y > 0) {
                equip_y--;
                _moved_eq = true;
            } else if (equip_scroll > 0) {
                equip_scroll--;
                _moved_eq = true;
            }
        }
        if (_moved_eq) {
            audio_play_sound(snd_menumove, 10, false);
        }
        
        if (keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(vk_enter)) {
            var eq_index = (equip_y + equip_scroll) * 3 + equip_x;
            if (eq_index < array_length(equipment) && equipment[eq_index] != -1) {
                audio_play_sound(snd_menumove, 10, false);
                state = MENU_STATE.EQUIP_ACTION;
                equip_action_index = 0;
            } else {
                if (audio_is_playing(snd_error)) {
                    audio_stop_sound(snd_error);
                }
                audio_play_sound(snd_error, 10, false);
            }
        }
        break;
        
    case MENU_STATE.EQUIP_ACTION:
        var _moved_ea = false;
        if (keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D"))) {
            equip_action_index = (equip_action_index + 1) % array_length(equip_action_options);
            _moved_ea = true;
        }
        if (keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A"))) {
            equip_action_index = (equip_action_index - 1 + array_length(equip_action_options)) % array_length(equip_action_options);
            _moved_ea = true;
        }
        if (_moved_ea) {
            audio_play_sound(snd_menumove, 10, false);
        }
        
        if (keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(vk_enter)) {
            audio_play_sound(snd_menumove, 10, false);
            var eq_slot = (equip_y + equip_scroll) * 3 + equip_x;
            var eq_key = equipment[eq_slot];
            var eq_data = global.equip_db[$ eq_key];
            
            switch (equip_action_index) {
                case 0: // Equipar
                    if (eq_data != undefined) {
                        var _p = obj_player;
                        var eq_name = eq_data.nombre;
                        
                        if (eq_data.tipo == "arma") {
                            var _arma_vieja = _p.equipo_arma;
                            _p.equipo_arma = eq_key; 
                            
                            if (_arma_vieja != -1) {
                                equipment[eq_slot] = _arma_vieja; 
                            } else {
                                equipment[eq_slot] = -1; 
                            }
                        } 
                        else if (eq_data.tipo == "armadura") {
                            var _armadura_vieja = _p.equipo_armadura;
                            _p.equipo_armadura = eq_key; 
                            
                            if (_armadura_vieja != -1) {
                                equipment[eq_slot] = _armadura_vieja; 
                            } else {
                                equipment[eq_slot] = -1; 
                            }
                        }
                        
                        audio_play_sound(snd_equip, 10, false);
                        
                        state = MENU_STATE.CLOSED;
                        var _textbox = instance_create_layer(x, y, layer, obj_textbox);
                        _textbox.text = ["Se equipo " + eq_name + "."];
                        _textbox.page_number = array_length(_textbox.text);
                    } else {
                        state = MENU_STATE.CLOSED;
                    }
                    break;
                case 1: // Tirar
                    state = MENU_STATE.EQUIP_DROP_CONFIRM;
                    drop_confirm_index = 1;
                    break;
                case 2: // Info
                    state = MENU_STATE.EQUIP_INFO;
                    break;
            }
        }
        break;
        
    case MENU_STATE.EQUIP_INFO:
        if (keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(vk_enter)) {
            audio_play_sound(snd_menumove, 10, false);
            state = MENU_STATE.EQUIP_ACTION;
        }
        break;
        
    case MENU_STATE.EQUIP_DROP_CONFIRM:
        if (keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D")) || keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A"))) {
            drop_confirm_index = (drop_confirm_index + 1) % 2;
            audio_play_sound(snd_menumove, 10, false);
        }
        if (keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(vk_enter)) {
            audio_play_sound(snd_menumove, 10, false);
            var eq_slot = (equip_y + equip_scroll) * 3 + equip_x;
            var eq_key = equipment[eq_slot];
            var eq_data = global.equip_db[$ eq_key];
            var eq_name = (eq_data != undefined) ? eq_data.nombre : "equipamiento";
            
            if (drop_confirm_index == 0) {
                equipment[eq_slot] = -1;
                state = MENU_STATE.CLOSED;
                var _textbox = instance_create_layer(x, y, layer, obj_textbox);
                _textbox.text = ["Has tirado " + eq_name + "."];
                _textbox.page_number = array_length(_textbox.text);
            } else {
                state = MENU_STATE.EQUIP_MENU;
            }
        }
        break;

    // --- LÓGICA PARA CONFIG ---
    case MENU_STATE.CONFIG_MENU:
        var _moved_cfg = false;
        if (keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D")) || 
            keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A"))) {
            config_tab = (config_tab + 1) % 2;
            _moved_cfg = true;
        }
        if (_moved_cfg) {
            audio_play_sound(snd_menumove, 10, false);
        }
        
        if (keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(vk_enter)) {
            audio_play_sound(snd_menumove, 10, false);
            config_index = 0; 
            state = MENU_STATE.CONFIG_ACTION;
        }
        break;
        
    case MENU_STATE.CONFIG_ACTION:
        var _moved_cfg_act = false;
        var max_cfg_index = (config_tab == 0) ? 3 : 0; 
        
        if (keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"))) {
            config_index = min(config_index + 1, max_cfg_index);
            _moved_cfg_act = true;
        }
        if (keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W"))) {
            config_index = max(config_index - 1, 0);
            _moved_cfg_act = true;
        }
        if (_moved_cfg_act) {
            audio_play_sound(snd_menumove, 10, false);
        }
        
        if (config_tab == 0) {
            if (config_index == 0) { 
                var _vol_changed = false;
                if (keyboard_check(vk_right) || keyboard_check(ord("D"))) {
                    master_volume = min(master_volume + 0.02, 1.0);
                    audio_master_gain(master_volume);
                    _vol_changed = true;
                }
                if (keyboard_check(vk_left) || keyboard_check(ord("A"))) {
                    master_volume = max(master_volume - 0.02, 0.0);
                    audio_master_gain(master_volume);
                    _vol_changed = true;
                }
                if (_vol_changed && !audio_is_playing(snd_menumove)) {
                    audio_play_sound(snd_menumove, 10, false);
                }
            }
            else if (config_index == 1) { 
                if (keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D")) || 
                    keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A")) ||
                    keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(vk_enter)) {
                    fullscreen_enabled = !fullscreen_enabled;
                    window_set_fullscreen(fullscreen_enabled);
                    audio_play_sound(snd_menumove, 10, false);
                }
            }
            else if (config_index == 2) { 
                if (keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D")) || 
                    keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A")) ||
                    keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(vk_enter)) {
                    global.autocorrer_enabled = !global.autocorrer_enabled;
                    audio_play_sound(snd_menumove, 10, false);
                }
            }
            else if (config_index == 3 && (keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(vk_enter))) { 
                audio_play_sound(snd_menumove, 10, false);
                state = MENU_STATE.MAIN;
            }
        }
        break;
        
    case MENU_STATE.GAME_CLOSE_CONFIRM:
        if (keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D")) || keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A"))) {
            close_confirm_index = (close_confirm_index + 1) % 2;
            audio_play_sound(snd_menumove, 10, false);
        }
        if (keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(vk_enter)) {
            audio_play_sound(snd_menumove, 10, false);
            if (close_confirm_index == 0) {
                game_end();
            } else {
                state = MENU_STATE.MAIN;
            }
        }
        break;
}