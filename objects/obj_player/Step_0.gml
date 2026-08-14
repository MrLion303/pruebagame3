// Reiniciar movimiento
movimiento = false;

// Comprobación segura del estado del menú
var _menu_abierto = false;
if (instance_exists(obj_menu_manager)) {
    if (obj_menu_manager.state != MENU_STATE.CLOSED) {
        _menu_abierto = true;
    }
}

// === CONDICIÓN MAESTRA DE MOVIMIENTO ===
if (!instance_exists(obj_pauser) && !instance_exists(obj_textbox) && !_menu_abierto && !instance_exists(obj_transicion_bbs) && room != bbs && puede_moverse)
{
    // Lógica exacta de Auto-correr
    var _vel = 4;
    var _auto_run_active = (variable_global_exists("autocorrer_enabled") && global.autocorrer_enabled);
    var _tecla_lenta = (keyboard_check(ord("X")) || keyboard_check(vk_shift));
    
    if (_auto_run_active)
    {
        if (_tecla_lenta) { _vel = 4; } else { _vel = 6; }
    }
    else
    {
        if (_tecla_lenta) { _vel = 6; } else { _vel = 4; }
    }

    // Derecha
    if (keyboard_check(vk_right))
    {
        direccion = "derecha";
        face = RIGHT;
        var _max_slope = _vel; 
        if (!place_meeting(x + _vel, y, colision)) {
            x += _vel;
            movimiento = true;
        } else {
            var _sloped = false;
            for (var _i = 1; _i <= _max_slope; _i++) {
                if (!place_meeting(x + _vel, y - _i, colision)) { y -= _i; x += _vel; movimiento = true; _sloped = true; break; }
            }
            if (!_sloped) {
                for (var _i = 1; _i <= _max_slope; _i++) {
                    if (!place_meeting(x + _vel, y + _i, colision)) { y += _i; x += _vel; movimiento = true; _sloped = true; break; }
                }
            }
        }
    }

    // Izquierda
    if (keyboard_check(vk_left))
    {
        direccion = "izquierda";
        face = LEFT;
        var _max_slope = _vel;
        if (!place_meeting(x - _vel, y, colision)) {
            x -= _vel;
            movimiento = true;
        } else {
            var _sloped = false;
            for (var _i = 1; _i <= _max_slope; _i++) {
                if (!place_meeting(x - _vel, y - _i, colision)) { y -= _i; x -= _vel; movimiento = true; _sloped = true; break; }
            }
            if (!_sloped) {
                for (var _i = 1; _i <= _max_slope; _i++) {
                    if (!place_meeting(x - _vel, y + _i, colision)) { y += _i; x -= _vel; movimiento = true; _sloped = true; break; }
                }
            }
        }
    }

    // Arriba
    if (keyboard_check(vk_up))
    {
        direccion = "arriba";
        face = UP;
        if (!place_meeting(x, y - _vel, colision)) {
            y -= _vel;
            movimiento = true;
        }
    }

    // Abajo
    if (keyboard_check(vk_down))
    {
        direccion = "abajo";
        face = DOWN;
        if (!place_meeting(x, y + _vel, colision)) {
            y += _vel;
            movimiento = true;
        }
    }
    
    // --- COMBATE POR TURNOS: CORREGIDO Y BLINDADO ---
    if (keyboard_check_pressed(ord("Z"))) {
        var _xx = x;
        var _yy = y;
        
        switch(facing_direction) {
            case 0: _xx += 20; break; // Derecha
            case 1: _xx -= 20; break; // Izquierda
            case 2: _yy += 20; break; // Abajo
            case 3: _yy -= 20; break; // Arriba
        }
        
        // Usamos asset_get_index para asegurar que GameMaker busque el objeto por su nombre como recurso global sin confundirlo con variable
        var _target = instance_place(_xx, _yy, asset_get_index("obj_padre_enemy"));
        
        // Si por alguna razón asset_get_index falla, intentamos una segunda opción segura buscando por el nombre del objeto directo usando id
        if (_target == noone) {
            // Buscamos colisión genérica en esa posición exacta con el objeto
            _target = instance_position(_xx, _yy, asset_get_index("obj_padre_enemy"));
        }
        
        if (_target != noone && _target != self) {
            // Guardar posición para regresar después
            global.return_x = x;
            global.return_y = y;
            global.return_room = room;
            
            // Pasar datos del enemigo y del jugador a globales
            if (variable_instance_exists(_target, "enemigo_id")) {
                global.battle_enemy_id = _target.enemigo_id;
            } else {
                global.battle_enemy_id = 0; // Valor por defecto por seguridad
            }
            
            global.player_hp_current = hp;
            
            // Ir a la room de batalla
            room_goto(bbs);
        }
    }
}
else
{
    movimiento = false;
}

// Aplicar dirección del warp
switch(face)
{
    case RIGHT: direccion = "derecha"; break;
    case LEFT:  direccion = "izquierda"; break;
    case UP:    direccion = "arriba"; break;
    case DOWN:  direccion = "abajo"; break;
}

// Cambiar sprite
switch (direccion)
{
    case "derecha":   sprite_index = pendejo_derecha; break;
    case "izquierda": sprite_index = pendejo_izquierda; break;
    case "arriba":    sprite_index = pendejo_arriba; break;
    case "abajo":     sprite_index = pendejo_abajo; break;
}

// Quieto
if (!movimiento)
{
    image_index = 0;
}

// Keep track of direction facing
if (sprite_index == pendejo_abajo) { facing_direction = 2; }
if (sprite_index == pendejo_arriba) { facing_direction = 3; }
if (sprite_index == pendejo_derecha) { facing_direction = 0; }
if (sprite_index == pendejo_izquierda) { facing_direction = 1; }