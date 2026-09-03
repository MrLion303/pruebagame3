// Reiniciar movimiento
movimiento = false;

// Comprobación segura del estado del menú
var _menu_abierto = false;
if (instance_exists(obj_menu_manager)) {
    if (obj_menu_manager.state != MENU_STATE.CLOSED) {
        _menu_abierto = true;
    }
}
// NUEVO: Si el menú de guardado existe, lo marcamos como menú abierto para frenar al jugador
if (instance_exists(obj_save_menu)) {
    _menu_abierto = true;
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

    // --- LECTURA DE TECLAS CON ANULACIÓN DE OPUESTOS ---
    var _key_right = keyboard_check(vk_right);
    var _key_left  = keyboard_check(vk_left);
    var _key_up    = keyboard_check(vk_up);
    var _key_down  = keyboard_check(vk_down);
    
    // Si se presionan teclas opuestas al mismo tiempo, se anulan mutuamente
    if (_key_right && _key_left) { _key_right = false; _key_left = false; }
    if (_key_up && _key_down)    { _key_up = false; _key_down = false; }

    // Derecha
    if (_key_right)
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
    if (_key_left)
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
    if (_key_up)
    {
        direccion = "arriba";
        face = UP;
        if (!place_meeting(x, y - _vel, colision)) {
            y -= _vel;
            movimiento = true;
        }
    }

    // Abajo
    if (_key_down)
    {
        direccion = "abajo";
        face = DOWN;
        if (!place_meeting(x, y + _vel, colision)) {
            y += _vel;
            movimiento = true;
        }
    }
    
// --- SONIDO DE CAMINAR ---
    if (movimiento) {
        paso_timer -= 1;
        
        if (paso_timer <= 0) {
            audio_stop_sound(snd_step1); // Evita que se superpongan los audios
            audio_play_sound(snd_step1, 0, false);
            
            // Redujimos los valores para que suene más rápido
            if (_vel == 6) {
                paso_timer = 10; // Antes era 12 (Corriendo)
            } else {
                paso_timer = 14; // Antes era 16 (Caminando normal)
            }
        }
    } else {
        // Reiniciamos el timer para que al volver a moverse, el sonido suene inmediatamente
        paso_timer = 0; 
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
        
        var _target = instance_place(_xx, _yy, asset_get_index("obj_padre_enemy"));
        
        if (_target == noone) {
            _target = instance_position(_xx, _yy, asset_get_index("obj_padre_enemy"));
        }
        
        if (_target != noone && _target != self) {
            global.return_x = x;
            global.return_y = y;
            global.return_room = room;
            
            if (variable_instance_exists(_target, "enemigo_id")) {
                global.battle_enemy_id = _target.enemigo_id;
            } else {
                global.battle_enemy_id = 0; 
            }
            
            global.player_hp_current = hp;
            
            room_goto(bbs);
        }
    }
}
else
{
    movimiento = false;
}

// =========================================================
// ESTADO CINEMÁTICO
// =========================================================

var _cs_sprite_override =
    variable_instance_exists(
        id,
        "cutscene_sprite_override_active"
    )
    &&
    cutscene_sprite_override_active;


var _cs_motion =
    variable_instance_exists(
        id,
        "cutscene_motion_active"
    )
    &&
    cutscene_motion_active;


// =========================================================
// APLICAR DIRECCIÓN
// =========================================================

switch (face)
{
    case RIGHT:
        direccion = "derecha";
        break;

    case LEFT:
        direccion = "izquierda";
        break;

    case UP:
        direccion = "arriba";
        break;

    case DOWN:
        direccion = "abajo";
        break;
}


// =========================================================
// SPRITE
// =========================================================

if (_cs_sprite_override)
{
    sprite_index =
        cutscene_sprite_override;
}
else
{
    switch (direccion)
    {
        case "derecha":
            sprite_index =
                pendejo_derecha;
            break;

        case "izquierda":
            sprite_index =
                pendejo_izquierda;
            break;

        case "arriba":
            sprite_index =
                pendejo_arriba;
            break;

        case "abajo":
            sprite_index =
                pendejo_abajo;
            break;
    }
}


// =========================================================
// QUIETO
// =========================================================
//
// No reseteamos image_index mientras una cinemática
// está controlando la animación.
// =========================================================

if (
    !movimiento
    &&
    !_cs_motion
    &&
    !_cs_sprite_override
)
{
    image_index =
        0;
}


// =========================================================
// FACING
// =========================================================

if (sprite_index == pendejo_abajo)
{
    facing_direction = 2;
}


if (sprite_index == pendejo_arriba)
{
    facing_direction = 3;
}


if (sprite_index == pendejo_derecha)
{
    facing_direction = 0;
}


if (sprite_index == pendejo_izquierda)
{
    facing_direction = 1;
}
