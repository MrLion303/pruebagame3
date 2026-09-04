/// =========================================================
/// GAME OVER - CONGELACIÓN DE 1 SEGUNDO
/// =========================================================

if (
    variable_global_exists("gameover_death_freeze_active")
    &&
    global.gameover_death_freeze_active
)
{
    movimiento =
        false;

    image_speed =
        0;

    hspeed =
        0;

    vspeed =
        0;

    speed =
        0;

    exit;
}


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

    // =====================================================
    // HIELO / HIELO AZUL
    // =====================================================
    //
    // Si scr_player_ice_update() devuelve true,
    // el terreno de hielo se encargó por completo del
    // movimiento de este frame.
    //
    // Si devuelve false, usamos el movimiento normal
    // original del juego.
    // =====================================================

    var _ice_handled =
        scr_player_ice_update(
            _vel,
            _key_right,
            _key_left,
            _key_up,
            _key_down
        );


    if (!_ice_handled)
    {
            // =====================================================
            // MOVIMIENTO CON COLISIÓN PRECISA POR PÍXEL
            // =====================================================
            //
            // Antes se comprobaba directamente:
            //
            //     x + _vel
            //     y + _vel
            //
            // Eso hacía que caminar (4 px) y correr (6 px)
            // pudieran detenerse a distancias diferentes de la
            // misma pared.
            //
            // Ahora cada uno de esos píxeles se comprueba
            // individualmente.
            // =====================================================


            // =====================================================
            // DERECHA
            // =====================================================

            if (_key_right)
            {
                direccion = "derecha";
                face = RIGHT;


                // =================================================
                // ¿HAY UNA RAMPA EN EL RECORRIDO DE ESTE FRAME?
                // =================================================
                //
                // Las rampas necesitan conservar la lógica antigua:
                //
                //     mover _vel horizontalmente
                //     +
                //     buscar corrección vertical hasta _vel
                //
                // Si las procesamos 1 píxel por vez, la subida se
                // vuelve muchísimo más lenta.
                // =================================================

                var _ramp_path =
                    false;


                for (
                    var _probe = 1;
                    _probe <= _vel;
                    _probe++
                )
                {
                    if (
                        place_meeting(
                            x + _probe,
                            y,
                            colision_rampa
                        )
                    )
                    {
                        _ramp_path =
                            true;

                        break;
                    }
                }


                // =================================================
                // RAMPA - MOVIMIENTO A VELOCIDAD COMPLETA
                // =================================================

                if (_ramp_path)
                {
                    var _max_slope =
                        _vel;


                    if (
                        !place_meeting(
                            x + _vel,
                            y,
                            colision
                        )
                    )
                    {
                        x +=
                            _vel;

                        movimiento =
                            true;
                    }
                    else
                    {
                        var _sloped =
                            false;


                        // Subir.
                        for (
                            var _i = 1;
                            _i <= _max_slope;
                            _i++
                        )
                        {
                            if (
                                !place_meeting(
                                    x + _vel,
                                    y - _i,
                                    colision
                                )
                            )
                            {
                                y -=
                                    _i;

                                x +=
                                    _vel;

                                movimiento =
                                    true;

                                _sloped =
                                    true;

                                break;
                            }
                        }


                        // Bajar.
                        if (!_sloped)
                        {
                            for (
                                var _i = 1;
                                _i <= _max_slope;
                                _i++
                            )
                            {
                                if (
                                    !place_meeting(
                                        x + _vel,
                                        y + _i,
                                        colision
                                    )
                                )
                                {
                                    y +=
                                        _i;

                                    x +=
                                        _vel;

                                    movimiento =
                                        true;

                                    _sloped =
                                        true;

                                    break;
                                }
                            }
                        }
                    }
                }


                // =================================================
                // PARED NORMAL - PRECISIÓN PÍXEL POR PÍXEL
                // =================================================

                else
                {
                    for (
                        var _step = 0;
                        _step < _vel;
                        _step++
                    )
                    {
                        if (
                            !place_meeting(
                                x + 1,
                                y,
                                colision
                            )
                        )
                        {
                            x +=
                                1;

                            movimiento =
                                true;
                        }
                        else
                        {
                            break;
                        }
                    }
                }
            }


            // =====================================================
            // IZQUIERDA
            // =====================================================

            if (_key_left)
            {
                direccion = "izquierda";
                face = LEFT;


                var _ramp_path =
                    false;


                for (
                    var _probe = 1;
                    _probe <= _vel;
                    _probe++
                )
                {
                    if (
                        place_meeting(
                            x - _probe,
                            y,
                            colision_rampa
                        )
                    )
                    {
                        _ramp_path =
                            true;

                        break;
                    }
                }


                // =================================================
                // RAMPA - MOVIMIENTO A VELOCIDAD COMPLETA
                // =================================================

                if (_ramp_path)
                {
                    var _max_slope =
                        _vel;


                    if (
                        !place_meeting(
                            x - _vel,
                            y,
                            colision
                        )
                    )
                    {
                        x -=
                            _vel;

                        movimiento =
                            true;
                    }
                    else
                    {
                        var _sloped =
                            false;


                        // Subir.
                        for (
                            var _i = 1;
                            _i <= _max_slope;
                            _i++
                        )
                        {
                            if (
                                !place_meeting(
                                    x - _vel,
                                    y - _i,
                                    colision
                                )
                            )
                            {
                                y -=
                                    _i;

                                x -=
                                    _vel;

                                movimiento =
                                    true;

                                _sloped =
                                    true;

                                break;
                            }
                        }


                        // Bajar.
                        if (!_sloped)
                        {
                            for (
                                var _i = 1;
                                _i <= _max_slope;
                                _i++
                            )
                            {
                                if (
                                    !place_meeting(
                                        x - _vel,
                                        y + _i,
                                        colision
                                    )
                                )
                                {
                                    y +=
                                        _i;

                                    x -=
                                        _vel;

                                    movimiento =
                                        true;

                                    _sloped =
                                        true;

                                    break;
                                }
                            }
                        }
                    }
                }


                // =================================================
                // PARED NORMAL - PRECISIÓN PÍXEL POR PÍXEL
                // =================================================

                else
                {
                    for (
                        var _step = 0;
                        _step < _vel;
                        _step++
                    )
                    {
                        if (
                            !place_meeting(
                                x - 1,
                                y,
                                colision
                            )
                        )
                        {
                            x -=
                                1;

                            movimiento =
                                true;
                        }
                        else
                        {
                            break;
                        }
                    }
                }
            }


            // =====================================================
            // ARRIBA
            // =====================================================

            if (_key_up)
            {
                direccion = "arriba";
                face = UP;


                for (var _step = 0; _step < _vel; _step++)
                {
                    if (!place_meeting(x, y - 1, colision))
                    {
                        y -= 1;
                        movimiento = true;
                    }
                    else
                    {
                        break;
                    }
                }
            }


            // =====================================================
            // ABAJO
            // =====================================================

            if (_key_down)
            {
                direccion = "abajo";
                face = DOWN;


                for (var _step = 0; _step < _vel; _step++)
                {
                    if (!place_meeting(x, y + 1, colision))
                    {
                        y += 1;
                        movimiento = true;
                    }
                    else
                    {
                        break;
                    }
                }
            }
    }

    
// --- SONIDO DE CAMINAR ---
//
// Sobre hielo Maya está resbalándose, no caminando.
//
    if (
        movimiento
        &&
        !ice_anim_lock
    ) {
        paso_timer -= 1;

        if (paso_timer <= 0) {
            audio_stop_sound(snd_step1);
            audio_play_sound(snd_step1, 0, false);

            if (_vel == 6) {
                paso_timer = 10;
            } else {
                paso_timer = 14;
            }
        }
    } else {
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
// ANIMACIÓN DE CAMINAR SIN "PASO EXTRA" AL DETENERSE
// =========================================================
//
// OBJETIVO:
//
// MOVIÉNDOSE:
//     la animación avanza normalmente.
//
// ACABA DE PARARSE:
//     se CONGELA inmediatamente en el frame actual.
//     NO sigue avanzando por su cuenta.
//
// VUELVE A TOCAR UNA FLECHA:
//     mostramos claramente otro frame de caminata.
//
// QUIETO UN MOMENTO:
//     vuelve al frame 0.
//
// Esto mantiene visibles los movimientos cortos sin que Maya
// parezca caminar un paso adicional después de detenerse.
// =========================================================

if (
    !variable_instance_exists(
        id,
        "walk_anim_hold"
    )
)
{
    walk_anim_hold =
        0;
}


if (
    !variable_instance_exists(
        id,
        "walk_anim_hold_max"
    )
)
{
    walk_anim_hold_max =
        6;
}


if (
    !variable_instance_exists(
        id,
        "walk_anim_was_moving"
    )
)
{
    walk_anim_was_moving =
        false;
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
// ANIMACIÓN NORMAL DEL PLAYER
// =========================================================
//
// No tocar image_speed si una cinemática controla el sprite.
// =========================================================

if (
    !_cs_motion
    &&
    !_cs_sprite_override
)
{
    // =====================================================
    // HIELO AZUL
    // =====================================================
    //
    // Siempre idle mientras se desliza.
    // =====================================================

    if (ice_on_blue)
    {
        image_speed =
            0;

        image_index =
            0;

        ice_normal_tap_timer =
            0;

        walk_anim_hold =
            0;

        walk_anim_was_moving =
            false;
    }


    // =====================================================
    // HIELO NORMAL
    // =====================================================
    //
    // Una NUEVA pulsación de flecha produce una pequeña
    // reacción visual.
    //
    // keyboard_check_pressed() solamente es true el primer
    // frame de la pulsación, así que mantener la flecha NO
    // mantiene ni reinicia la animación.
    // =====================================================

    else if (ice_on_normal)
    {
        image_speed =
            0;


        var _ice_tap =
            keyboard_check_pressed(vk_right)
            ||
            keyboard_check_pressed(vk_left)
            ||
            keyboard_check_pressed(vk_up)
            ||
            keyboard_check_pressed(vk_down);


        if (_ice_tap)
        {
            var _ice_frames =
                sprite_get_number(
                    sprite_index
                );


            if (_ice_frames > 1)
            {
                ice_normal_tap_frame++;


                if (
                    ice_normal_tap_frame <= 0
                    ||
                    ice_normal_tap_frame >= _ice_frames
                )
                {
                    ice_normal_tap_frame =
                        1;
                }


                image_index =
                    ice_normal_tap_frame;


                ice_normal_tap_timer =
                    ice_normal_tap_duration;
            }
        }


        // Mantener brevemente el frame de reacción.
        if (ice_normal_tap_timer > 0)
        {
            ice_normal_tap_timer--;
        }
        else
        {
            // Luego volver a idle aunque Maya siga
            // deslizándose por inercia.
            image_index =
                0;
        }


        walk_anim_hold =
            0;

        walk_anim_was_moving =
            false;
    }


    // =====================================================
    // SUELO NORMAL
    // =====================================================

    else if (movimiento)
    {
        ice_normal_tap_timer =
            0;

        // -------------------------------------------------
        // EMPEZÓ UN NUEVO "TAP"
        // -------------------------------------------------
        //
        // Un solo frame de movimiento puede ser demasiado
        // corto para que GameMaker alcance a cambiar el
        // subimage automáticamente.
        //
        // Si veníamos quietos, avanzamos UN frame manual.
        // Así cada toque corto sí se ve caminando.
        // -------------------------------------------------

        if (!walk_anim_was_moving)
        {
            var _frames =
                sprite_get_number(
                    sprite_index
                );


            if (_frames > 1)
            {
                var _next_frame =
                    floor(
                        image_index
                    )
                    +
                    1;


                // Evitar que un nuevo tap caiga directamente
                // al frame 0 (idle).
                if (_next_frame >= _frames)
                {
                    _next_frame =
                        1;
                }


                image_index =
                    clamp(
                        _next_frame,
                        1,
                        _frames - 1
                    );
            }
        }


        // Volver a permitir la animación normal del sprite.
        image_speed =
            1;


        walk_anim_hold =
            walk_anim_hold_max;
    }
    else
    {
        ice_normal_tap_timer =
            0;

        // =================================================
        // QUIETO: CONGELAR
        // =================================================
        //
        // ESTA es la corrección principal.
        //
        // El sprite deja de avanzar en el MISMO frame en que
        // Maya deja de moverse.
        // =================================================

        image_speed =
            0;


        if (walk_anim_hold > 0)
        {
            walk_anim_hold--;
        }


        // Cuando ya pasó el margen entre taps:
        // idle real.
        if (walk_anim_hold <= 0)
        {
            image_index =
                0;
        }
    }
}


// Guardar para detectar inicio de movimiento del próximo frame.
walk_anim_was_moving =
    (
        movimiento
        &&
        !ice_anim_lock
    );


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
