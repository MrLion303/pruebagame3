// =========================================================
// OBJ_MENU_MANAGER
// BLOQUEO DE GAME OVER
// =========================================================
//
// C y Ctrl no pueden abrir el menú:
//
// - durante el segundo de congelación al morir;
// - mientras estamos en la room game_over;
// - mientras obj_game_over_texto sigue haciendo el fade
//   blanco de regreso a la partida guardada.
//
// Al terminar el fade, obj_game_over_texto se destruye y
// este bloqueo desaparece automáticamente.
// =========================================================

var _bloqueo_game_over =
(
    (
        variable_global_exists(
            "gameover_death_freeze_active"
        )
        &&
        global.gameover_death_freeze_active
    )
    ||
    room == game_over
    ||
    instance_exists(
        obj_game_over_texto
    )
);


if (_bloqueo_game_over)
{
    state =
        MENU_STATE.CLOSED;


    keyboard_clear(
        ord("C")
    );


    keyboard_clear(
        vk_control
    );


    exit;
}



// =========================================================
// BLOQUEAR MENÚ DURANTE CINEMÁTICAS
// =========================================================

if (
    variable_global_exists("cutscene_active")
    &&
    global.cutscene_active
)
{
    state =
        MENU_STATE.CLOSED;

    exit;
}

// --- BLOQUEO TOTAL DE APERTURA E INTERACCIÓN EN ROOMS ESPECÍFICAS ---
var _room_actual = room_get_name(room);
if (_room_actual == "bbs" || _room_actual == "rm_title") {
    state = MENU_STATE.CLOSED; 
    exit; 
}

// =========================================================
// RESTAURAR DATOS PERSISTENTES AL CAMBIAR DE ROOM/BATALLA
// =========================================================
if (variable_global_exists("equipment_inventory")) {
    equipment = global.equipment_inventory;
}

if (instance_exists(obj_player)) {
    // CORRECCIÓN: El menú lee lo que el jugador tiene cargado
    global.equipped_arma = obj_player.equipo_arma;
    global.equipped_armadura = obj_player.equipo_armadura;
}

// Abrir menú principal con C o Ctrl
if (state == MENU_STATE.CLOSED) {
    // BLOQUEO: Solo permitir abrir si el menú de guardado NO está abierto
    if (!instance_exists(obj_save_menu)) {
        if (keyboard_check_pressed(ord("C")) || keyboard_check_pressed(vk_control)) {
            if (!instance_exists(obj_textbox)) {
                state = MENU_STATE.MAIN;
                main_index = 0;
                inventory_tab_focus = false;
                audio_play_sound(snd_menumove, 10, false);
            }
        }
    }
    exit;
}

// Cerrar menú o retroceder con X o Shift
if (keyboard_check_pressed(ord("X")) || keyboard_check_pressed(vk_shift)) {
    if (state == MENU_STATE.MAIN) {
        state = MENU_STATE.CLOSED;
    } else if (
        state == MENU_STATE.INVENTORY
        || state == MENU_STATE.EQUIP_MENU
        || state == MENU_STATE.CLAVE_MENU
    ) {
        // Dentro de un inventario: X vuelve primero a las pestañas.
        // Desde las pestañas: X vuelve al menú principal.
        if (inventory_tab_focus) {
            state = MENU_STATE.MAIN;
            inventory_tab_focus = false;
        } else {
            // Al volver desde un inventario a las pestañas,
            // olvidar por completo el slot en el que estábamos.
            //
            // Así, si después confirmamos esta misma pestaña,
            // siempre entraremos desde su PRIMER slot.
            switch (state)
            {
                case MENU_STATE.INVENTORY:
                    inv_x = 0;
                    inv_y = 0;
                    inv_scroll = 0;
                    break;

                case MENU_STATE.EQUIP_MENU:
                    equip_x = 0;
                    equip_y = 0;
                    equip_scroll = 0;
                    break;

                case MENU_STATE.CLAVE_MENU:
                    clave_x = 0;
                    clave_y = 0;
                    clave_scroll = 0;
                    break;
            }

            inventory_tab_focus = true;
        }
    } else if (state == MENU_STATE.ITEM_ACTION) {
        state = MENU_STATE.INVENTORY;
    } else if (state == MENU_STATE.ITEM_INFO) {
        state = MENU_STATE.ITEM_ACTION;
    } else if (state == MENU_STATE.ITEM_DROP_CONFIRM) {
        state = MENU_STATE.ITEM_ACTION;
    } 
    // Retrocesos para TOYS
    else if (state == MENU_STATE.TOY_MENU) {
        state = MENU_STATE.MAIN;
    } else if (state == MENU_STATE.TOY_ACTION) {
        state = MENU_STATE.TOY_MENU;
    } else if (state == MENU_STATE.TOY_INFO) {
        state = MENU_STATE.TOY_ACTION;
    } else if (state == MENU_STATE.TOY_DROP_CONFIRM) {
        state = MENU_STATE.TOY_ACTION;
    }
    // Retrocesos para EQUIP
    else if (state == MENU_STATE.EQUIP_ACTION) {
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

// =========================================================
// PESTAÑAS INV / EQUIP / CLAVE
// =========================================================
//
// Al abrir INV desde el menú principal, SIEMPRE empezamos aquí.
//
// Mientras inventory_tab_focus == true:
//
//     IZQUIERDA / DERECHA
//         Cambian la pestaña y actualizan inmediatamente la
//         vista previa del inventario correspondiente.
//
//     Z / ENTER
//         Confirman la pestaña actual y recién entonces se
//         habilita la navegación de su inventario.
//
//     X / SHIFT
//         El bloque de retroceso de arriba vuelve a MAIN.
//
// No se utiliza WASD en ningún punto del menú de pausa.
// =========================================================

var _inventory_root_state =
(
    state == MENU_STATE.INVENTORY
    ||
    state == MENU_STATE.EQUIP_MENU
    ||
    state == MENU_STATE.CLAVE_MENU
);


if (
    _inventory_root_state
    &&
    inventory_tab_focus
)
{
    var _tab_moved = false;


    if (keyboard_check_pressed(vk_right))
    {
        inventory_tab =
            (inventory_tab + 1) % 3;

        _tab_moved =
            true;
    }


    if (keyboard_check_pressed(vk_left))
    {
        inventory_tab =
            (inventory_tab - 1 + 3) % 3;

        _tab_moved =
            true;
    }


    // Cambiar el STATE aquí solo sirve para que Draw GUI
    // enseñe en vivo el contenido de la pestaña señalada.
    // El inventario sigue bloqueado mientras focus == true.
    if (_tab_moved)
    {
        switch (inventory_tab)
        {
            case 0:
                state =
                    MENU_STATE.INVENTORY;

                // La vista previa de cada pestaña siempre parte
                // también desde el primer slot.
                inv_x = 0;
                inv_y = 0;
                inv_scroll = 0;
                break;


            case 1:
                state =
                    MENU_STATE.EQUIP_MENU;

                equipment =
                    global.equipment_inventory;

                equip_x = 0;
                equip_y = 0;
                equip_scroll = 0;
                break;


            case 2:
                state =
                    MENU_STATE.CLAVE_MENU;

                clave_x = 0;
                clave_y = 0;
                clave_scroll = 0;
                break;
        }


        audio_play_sound(
            snd_menumove,
            10,
            false
        );
    }


    // Confirmar pestaña.
    // A partir del siguiente frame las flechas controlarán
    // la cuadrícula/lista del inventario elegido.
    if (
        keyboard_check_pressed(ord("Z"))
        ||
        keyboard_check_pressed(vk_enter)
    )
    {
        // Cada vez que se confirma una pestaña entramos a su
        // inventario desde cero. Nunca recordamos el slot de
        // una visita anterior.
        switch (inventory_tab)
        {
            case 0:
                inv_x = 0;
                inv_y = 0;
                inv_scroll = 0;
                state = MENU_STATE.INVENTORY;
                break;

            case 1:
                equip_x = 0;
                equip_y = 0;
                equip_scroll = 0;
                equipment = global.equipment_inventory;
                state = MENU_STATE.EQUIP_MENU;
                break;

            case 2:
                clave_x = 0;
                clave_y = 0;
                clave_scroll = 0;
                state = MENU_STATE.CLAVE_MENU;
                break;
        }

        inventory_tab_focus =
            false;

        audio_play_sound(
            snd_menumove,
            10,
            false
        );
    }


    exit;
}


// Lógica de navegación principal y submenús
switch (state) {
    case MENU_STATE.MAIN:
        var _moved_main = false;
        if (keyboard_check_pressed(vk_down)) {
            main_index = (main_index + 1) % array_length(main_options);
            _moved_main = true;
        }
        if (keyboard_check_pressed(vk_up)) {
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
                    // Entrar primero a la barra de pestañas.
                    // INV se muestra como vista previa, pero la cuadrícula
                    // todavía NO acepta navegación hasta confirmar con Z/Enter.
                    state = MENU_STATE.INVENTORY;
                    inventory_tab = 0;
                    inventory_tab_focus = true;
                    inv_x = 0; inv_y = 0; inv_scroll = 0;
                    break;
                case 1: // TOYS
                    state = MENU_STATE.TOY_MENU;
                    toy_x = 0; toy_y = 0; toy_scroll = 0;
                    toy_action_index = 0;
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
        inventory_tab = 0;

        var _moved_inv = false;
        if (keyboard_check_pressed(vk_right)) {
            inv_x = (inv_x + 1) % 3;
            _moved_inv = true;
        }
        if (keyboard_check_pressed(vk_left)) {
            inv_x = (inv_x - 1 + 3) % 3;
            _moved_inv = true;
        }
        if (keyboard_check_pressed(vk_down)) {
            if (inv_y < 2) {
                inv_y++;
                _moved_inv = true;
            } else if (inv_scroll < 1) { 
                inv_scroll++;
                _moved_inv = true;
            }
        }
        if (keyboard_check_pressed(vk_up)) {
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
        if (keyboard_check_pressed(vk_right)) {
            action_index = (action_index + 1) % array_length(action_options);
            _moved_ia = true;
        }
        if (keyboard_check_pressed(vk_left)) {
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
                var item_data = variable_struct_get(global.item_db, current_item_key);
                
                switch (action_index) {
                    case 0: // Usar
                        if (item_data != undefined &&
                            variable_struct_exists(item_data, "tipo") &&
                            item_data.tipo == "consumible" &&
                            variable_struct_exists(item_data, "efecto")) {
                            item_data.efecto();
                            obj_player.inventory[slot_index] = -1;
                            state = MENU_STATE.CLOSED;
                        } else {
                            if (audio_is_playing(snd_error)) audio_stop_sound(snd_error);
                            audio_play_sound(snd_error, 10, false);
                        }
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
        if (keyboard_check_pressed(vk_right) || keyboard_check_pressed(vk_left)) {
            drop_confirm_index = (drop_confirm_index + 1) % 2;
            audio_play_sound(snd_menumove, 10, false);
        }
        if (keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(vk_enter)) {
            audio_play_sound(snd_menumove, 10, false);
            var slot_index = (inv_y + inv_scroll) * 3 + inv_x;
            
            if (instance_exists(obj_player) && slot_index < array_length(obj_player.inventory)) {
                var current_item_key = obj_player.inventory[slot_index];
                var item_data = variable_struct_get(global.item_db, current_item_key);
                var item_name = (item_data != undefined) ? item_data.nombre : scr_loc_src("objeto");
                
                if (drop_confirm_index == 0) {
                    obj_player.inventory[slot_index] = -1;
                    state = MENU_STATE.CLOSED;
                    var _textbox = instance_create_layer(x, y, layer, obj_textbox);
                    _textbox.text = [scr_locf("Has tirado {item}.", { item: scr_loc(item_name) })];
                    _textbox.page_number = array_length(_textbox.text);
                } else {
                    state = MENU_STATE.INVENTORY;
                }
            }
        }
        break;

    // --- LÓGICA PARA TOYS (30 slots) ---
    case MENU_STATE.TOY_MENU:
        var _moved_toy = false;

        if (keyboard_check_pressed(vk_right)) {
            toy_x = (toy_x + 1) % 3;
            _moved_toy = true;
        }
        if (keyboard_check_pressed(vk_left)) {
            toy_x = (toy_x - 1 + 3) % 3;
            _moved_toy = true;
        }
        if (keyboard_check_pressed(vk_down)) {
            if (toy_y < 2) {
                toy_y++;
                _moved_toy = true;
            } else if (toy_scroll < 7) {
                toy_scroll++;
                _moved_toy = true;
            }
        }
        if (keyboard_check_pressed(vk_up)) {
            if (toy_y > 0) {
                toy_y--;
                _moved_toy = true;
            } else if (toy_scroll > 0) {
                toy_scroll--;
                _moved_toy = true;
            }
        }

        if (_moved_toy) {
            audio_play_sound(snd_menumove, 10, false);
        }

        if (keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(vk_enter)) {
            var _toy_slot = (toy_y + toy_scroll) * 3 + toy_x;

            if (variable_global_exists("toy_inventory") &&
                _toy_slot >= 0 &&
                _toy_slot < array_length(global.toy_inventory) &&
                global.toy_inventory[_toy_slot] != -1 &&
                variable_global_exists("toy_db") &&
                variable_struct_get(global.toy_db, global.toy_inventory[_toy_slot]) != undefined) {

                toy_action_index = 0;
                audio_play_sound(snd_menumove, 10, false);
                state = MENU_STATE.TOY_ACTION;
            } else {
                if (audio_is_playing(snd_error)) audio_stop_sound(snd_error);
                audio_play_sound(snd_error, 10, false);
            }
        }
        break;

    case MENU_STATE.TOY_ACTION:
        var _moved_ta = false;

        if (keyboard_check_pressed(vk_right)) {
            toy_action_index = (toy_action_index + 1) % 3;
            _moved_ta = true;
        }
        if (keyboard_check_pressed(vk_left)) {
            toy_action_index = (toy_action_index - 1 + 3) % 3;
            _moved_ta = true;
        }

        if (_moved_ta) audio_play_sound(snd_menumove, 10, false);

        if (keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(vk_enter)) {
            var _toy_slot = (toy_y + toy_scroll) * 3 + toy_x;

            if (variable_global_exists("toy_inventory") &&
                _toy_slot >= 0 &&
                _toy_slot < array_length(global.toy_inventory)) {

                var _toy_key = global.toy_inventory[_toy_slot];
                var _toy_data = (variable_global_exists("toy_db") && _toy_key != -1 && _toy_key != undefined)
                    ? variable_struct_get(global.toy_db, _toy_key)
                    : undefined;

                if (_toy_data != undefined) {
                    if (toy_action_index == 0) {
                        var _textbox_toy = instance_create_layer(x, y, layer, obj_textbox);
                        _textbox_toy.text = [scr_loc("Los toys se usan durante una batalla.")];
                        _textbox_toy.page_number = array_length(_textbox_toy.text);
                        state = MENU_STATE.CLOSED;
                    }
                    else if (toy_action_index == 1) {
                        state = MENU_STATE.TOY_DROP_CONFIRM;
                        toy_drop_confirm_index = 1;
                    }
                    else {
                        state = MENU_STATE.TOY_INFO;
                    }

                    audio_play_sound(snd_menumove, 10, false);
                } else {
                    if (audio_is_playing(snd_error)) audio_stop_sound(snd_error);
                    audio_play_sound(snd_error, 10, false);
                }
            }
        }
        break;

    case MENU_STATE.TOY_INFO:
        if (keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(vk_enter)) {
            audio_play_sound(snd_menumove, 10, false);
            state = MENU_STATE.TOY_ACTION;
        }
        break;

    case MENU_STATE.TOY_DROP_CONFIRM:
        if (keyboard_check_pressed(vk_right) ||
            keyboard_check_pressed(vk_left)) {
            toy_drop_confirm_index = (toy_drop_confirm_index + 1) % 2;
            audio_play_sound(snd_menumove, 10, false);
        }

        if (keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(vk_enter)) {
            audio_play_sound(snd_menumove, 10, false);

            var _toy_slot = (toy_y + toy_scroll) * 3 + toy_x;

            if (variable_global_exists("toy_inventory") &&
                _toy_slot >= 0 &&
                _toy_slot < array_length(global.toy_inventory)) {

                var _toy_key = global.toy_inventory[_toy_slot];
                var _toy_data = (variable_global_exists("toy_db") && _toy_key != -1 && _toy_key != undefined)
                    ? variable_struct_get(global.toy_db, _toy_key)
                    : undefined;
                var _toy_name = (_toy_data != undefined) ? _toy_data.nombre : scr_loc_src("toy");

                if (toy_drop_confirm_index == 0) {
                    global.toy_inventory[_toy_slot] = -1;
                    state = MENU_STATE.CLOSED;

                    var _textbox = instance_create_layer(x, y, layer, obj_textbox);
                    _textbox.text = [scr_locf("Has tirado {item}.", { item: scr_loc(_toy_name) })];
                    _textbox.page_number = array_length(_textbox.text);
                } else {
                    state = MENU_STATE.TOY_MENU;
                }
            }
        }
        break;

    // --- LÓGICA PARA EQUIP (51 slots) ---
    case MENU_STATE.EQUIP_MENU:
        inventory_tab = 1;

        var _moved_eq = false;
        if (keyboard_check_pressed(vk_right)) {
            equip_x = (equip_x + 1) % 3;
            _moved_eq = true;
        }
        if (keyboard_check_pressed(vk_left)) {
            equip_x = (equip_x - 1 + 3) % 3;
            _moved_eq = true;
        }
        if (keyboard_check_pressed(vk_down)) {
            if (equip_y < 2) {
                equip_y++;
                _moved_eq = true;
            } else if (equip_scroll < max_equip_scroll) { 
                equip_scroll++;
                _moved_eq = true;
            }
        }
        if (keyboard_check_pressed(vk_up)) {
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
        if (keyboard_check_pressed(vk_right)) {
            equip_action_index = (equip_action_index + 1) % array_length(equip_action_options);
            _moved_ea = true;
        }
        if (keyboard_check_pressed(vk_left)) {
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
            var eq_data = variable_struct_get(global.equip_db, eq_key);
            
            switch (equip_action_index) {
                case 0: // Equipar
                    if (eq_data != undefined) {
                        var _p = obj_player;
                        var eq_name = eq_data.nombre;
                        
                        if (eq_data.tipo == "arma") {
                            var _arma_vieja = _p.equipo_arma;
                            _p.equipo_arma = eq_key;
                            global.equipped_arma = eq_key;

                            if (_arma_vieja != -1) {
                                global.equipment_inventory[eq_slot] = _arma_vieja;
                            } else {
                                global.equipment_inventory[eq_slot] = -1;
                            }
                            equipment = global.equipment_inventory;
                        } 
                        else if (eq_data.tipo == "armadura") {
                            var _armadura_vieja = _p.equipo_armadura;
                            _p.equipo_armadura = eq_key;
                            global.equipped_armadura = eq_key;

                            if (_armadura_vieja != -1) {
                                global.equipment_inventory[eq_slot] = _armadura_vieja;
                            } else {
                                global.equipment_inventory[eq_slot] = -1;
                            }
                            equipment = global.equipment_inventory;
                        }
                        
                        audio_play_sound(snd_equip, 10, false);
                        
                        state = MENU_STATE.CLOSED;
                        var _textbox = instance_create_layer(x, y, layer, obj_textbox);
                        _textbox.text = [scr_locf("Se equipo {item}.", { item: scr_loc(eq_name) })];
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
        if (keyboard_check_pressed(vk_right) || keyboard_check_pressed(vk_left)) {
            drop_confirm_index = (drop_confirm_index + 1) % 2;
            audio_play_sound(snd_menumove, 10, false);
        }
        if (keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(vk_enter)) {
            audio_play_sound(snd_menumove, 10, false);
            var eq_slot = (equip_y + equip_scroll) * 3 + equip_x;
            var eq_key = equipment[eq_slot];
            var eq_data = variable_struct_get(global.equip_db, eq_key);
            var eq_name = (eq_data != undefined) ? eq_data.nombre : scr_loc_src("equipamiento");
            
            if (drop_confirm_index == 0) {
                global.equipment_inventory[eq_slot] = -1;
                equipment = global.equipment_inventory;
                state = MENU_STATE.CLOSED;
                var _textbox = instance_create_layer(x, y, layer, obj_textbox);
                _textbox.text = [scr_locf("Has tirado {item}.", { item: scr_loc(eq_name) })];
                _textbox.page_number = array_length(_textbox.text);
            } else {
                state = MENU_STATE.EQUIP_MENU;
            }
        }
        break;

    // --- LÓGICA PARA OBJETOS CLAVE ---
    case MENU_STATE.CLAVE_MENU:
        inventory_tab = 2;

        scr_inventarios_data();

        if (!variable_global_exists("itemclave_db"))
        {
            src_itemclave_data();
        }

        // CLAVE tiene exactamente 15 espacios:
        // 5 filas x 3 columnas.
        var _clave_total =
            15;

        var _clave_rows =
            5;

        var _clave_max_scroll =
            2;


        clave_scroll =
            clamp(
                clave_scroll,
                0,
                _clave_max_scroll
            );


        var _moved_clave =
            false;


        if (
            keyboard_check_pressed(vk_right)
        )
        {
            clave_x =
                (clave_x + 1) % 3;

            _moved_clave =
                true;
        }


        if (
            keyboard_check_pressed(vk_left)
        )
        {
            clave_x =
                (clave_x - 1 + 3) % 3;

            _moved_clave =
                true;
        }


        if (
            keyboard_check_pressed(vk_down)
        )
        {
            if (clave_y < 2)
            {
                clave_y++;

                _moved_clave =
                    true;
            }
            else if (
                clave_scroll
                <
                _clave_max_scroll
            )
            {
                clave_scroll++;

                _moved_clave =
                    true;
            }
        }


        if (
            keyboard_check_pressed(vk_up)
        )
        {
            if (clave_y > 0)
            {
                clave_y--;

                _moved_clave =
                    true;
            }
            else if (clave_scroll > 0)
            {
                clave_scroll--;

                _moved_clave =
                    true;
            }
        }


        if (_moved_clave)
        {
            audio_play_sound(
                snd_menumove,
                10,
                false
            );
        }


        // =================================================
        // INTERACTUAR CON SLOT
        // =================================================
        //
        // Los objetos clave no se usan ni se tiran desde
        // este menú. Z/Enter sobre uno ocupado solo confirma
        // la selección; sobre uno vacío reproduce snd_error,
        // igual que INV / TOYS / EQUIP.
        // =================================================

        if (
            keyboard_check_pressed(ord("Z"))
            ||
            keyboard_check_pressed(vk_enter)
        )
        {
            var _clave_slot =
                (clave_y + clave_scroll) * 3 + clave_x;

            var _clave_id =
                -1;

            if (
                _clave_slot >= 0
                &&
                _clave_slot < 15
                &&
                _clave_slot < array_length(
                    global.itemclave_inventory
                )
            )
            {
                _clave_id =
                    global.itemclave_inventory[_clave_slot];
            }


            var _clave_valida =
                (
                    _clave_id != -1
                    &&
                    !is_undefined(_clave_id)
                    &&
                    is_string(_clave_id)
                    &&
                    variable_struct_exists(
                        global.itemclave_db,
                        _clave_id
                    )
                );


            if (_clave_valida)
            {
                audio_play_sound(
                    snd_menumove,
                    10,
                    false
                );
            }
            else
            {
                if (audio_is_playing(snd_error))
                {
                    audio_stop_sound(snd_error);
                }

                audio_play_sound(
                    snd_error,
                    10,
                    false
                );
            }
        }


        break;


    // --- LÓGICA PARA CONFIG ---
    case MENU_STATE.CONFIG_MENU:
        var _moved_cfg = false;
        if (keyboard_check_pressed(vk_right) || 
            keyboard_check_pressed(vk_left)) {
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
        
        if (keyboard_check_pressed(vk_down)) {
            config_index = min(config_index + 1, max_cfg_index);
            _moved_cfg_act = true;
        }
        if (keyboard_check_pressed(vk_up)) {
            config_index = max(config_index - 1, 0);
            _moved_cfg_act = true;
        }
        if (_moved_cfg_act) {
            audio_play_sound(snd_menumove, 10, false);
        }
        
        if (config_tab == 0) {
            if (config_index == 0) { 
                var _vol_changed = false;
                if (keyboard_check(vk_right)) {
                    master_volume = min(master_volume + 0.02, 1.0);
                    audio_master_gain(master_volume);
                    _vol_changed = true;
                }
                if (keyboard_check(vk_left)) {
                    master_volume = max(master_volume - 0.02, 0.0);
                    audio_master_gain(master_volume);
                    _vol_changed = true;
                }
                if (_vol_changed && !audio_is_playing(snd_menumove)) {
                    audio_play_sound(snd_menumove, 10, false);
                }
            }
            else if (config_index == 1) { 
                if (keyboard_check_pressed(vk_right) || 
                    keyboard_check_pressed(vk_left) ||
                    keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(vk_enter)) {
                    fullscreen_enabled = !fullscreen_enabled;
                    window_set_fullscreen(fullscreen_enabled);
                    audio_play_sound(snd_menumove, 10, false);
                }
            }
            else if (config_index == 2) { 
                if (keyboard_check_pressed(vk_right) || 
                    keyboard_check_pressed(vk_left) ||
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
        if (keyboard_check_pressed(vk_right) || keyboard_check_pressed(vk_left)) {
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
