/// =========================================================
/// OBJ_PLAYER
/// END STEP COMPLETO
/// =========================================================
///
/// DASH ANIMADO V2
///
/// - Distancia aumentada a 48 px.
/// - NO teletransporta.
/// - Se mueve durante varios frames.
/// - Permite diagonal.
/// - La diagonal se normaliza para que no recorra más
///   distancia que horizontal/vertical.
/// - Deja afterimages detrás.
/// - Habilidad Dash O Zapatos Rápidos.
/// - Conserva stamina, HUD y colisiones.
/// =========================================================


// =========================================================
// RUNTIME DEL DASH ANIMADO
// =========================================================

if (
    !variable_instance_exists(
        id,
        "dash_anim_active"
    )
)
{
    dash_anim_active =
        false;

    dash_anim_remaining =
        0;

    dash_anim_dir_x =
        0;

    dash_anim_dir_y =
        0;

    dash_anim_accum_x =
        0;

    dash_anim_accum_y =
        0;


    // 48 px totales / 6 px por frame = aprox. 8 frames.
    // A 30 FPS son aprox. 0.27 segundos.
    dash_anim_speed =
        6;

    dash_anim_total_distance =
        48;


    dash_anim_prev_puede_moverse =
        true;
}


// =========================================================
// PLATAFORMERO
// =========================================================

var _dash_platformer =
    (
        variable_global_exists(
            "platformer_active"
        )
        &&
        global.platformer_active
    );


// =========================================================
// CAPTURAR SPACE ANTES DEL DASH VIEJO
// =========================================================
//
// scr_player_abilities_end_step() todavía contiene el Dash
// instantáneo antiguo.
//
// Capturamos SPACE y lo limpiamos antes de llamar esa función.
// Así conserva Sigilo, stamina, HUD y recarga, pero NO puede
// ejecutar el teletransporte viejo.
// =========================================================

var _dash_pressed =
    false;


if (!_dash_platformer)
{
    _dash_pressed =
        keyboard_check_pressed(
            vk_space
        );


    if (_dash_pressed)
    {
        keyboard_clear(
            vk_space
        );
    }
}


// Mientras el Dash animado está activo, no permitir que la
// recarga de stamina avance.
if (dash_anim_active)
{
    dash_used_this_frame =
        true;
}


// =========================================================
// SISTEMA ACTUAL DE HABILIDADES
// =========================================================

scr_player_abilities_end_step(
    id
);


// =========================================================
// INTENTAR COMENZAR DASH
// =========================================================

if (
    !dash_anim_active
    &&
    _dash_pressed
    &&
    !_dash_platformer
)
{
    // -----------------------------------------------------
    // DESBLOQUEO: HABILIDAD O ZAPATOS
    // -----------------------------------------------------

    var _dash_has_ability =
        scr_habilidad_tiene(
            "dash"
        );


    var _dash_has_shoes =
        (
            (
                variable_instance_exists(
                    id,
                    "equipo_armadura"
                )
                &&
                equipo_armadura
                ==
                "zapatos_rapidos"
            )
            ||
            scr_player_has_dash_armor(
                id
            )
        );


    var _dash_unlocked =
        (
            _dash_has_ability
            ||
            _dash_has_shoes
        );


    // -----------------------------------------------------
    // PELIGRO
    // -----------------------------------------------------

    var _dash_danger =
        false;


    // Primero usar exactamente el estado del FX de peligro.
    if (
        instance_exists(
            obj_mapa_combate_fx
        )
    )
    {
        var _dash_fx =
            instance_find(
                obj_mapa_combate_fx,
                0
            );


        if (
            _dash_fx != noone
            &&
            variable_instance_exists(
                _dash_fx,
                "danger_active"
            )
            &&
            _dash_fx.danger_active
        )
        {
            _dash_danger =
                true;
        }
    }


    // Respaldo del sistema normal.
    if (!_dash_danger)
    {
        _dash_danger =
            scr_player_dash_danger_active(
                id
            );
    }


    // -----------------------------------------------------
    // MUNDO DISPONIBLE
    // -----------------------------------------------------

    var _dash_world_ok =
        (
            room != bbs
            &&
            room != game_over
            &&
            !scr_cutscene_world_locked()
            &&
            !instance_exists(
                obj_save_menu
            )
            &&
            !instance_exists(
                obj_transicion_bbs
            )
            &&
            (
                !instance_exists(
                    obj_menu_manager
                )
                ||
                obj_menu_manager.state
                ==
                MENU_STATE.CLOSED
            )
            &&
            variable_instance_exists(
                id,
                "puede_moverse"
            )
            &&
            puede_moverse
        );


    if (
        _dash_unlocked
        &&
        _dash_danger
        &&
        _dash_world_ok
        &&
        dash_stamina
        >=
        dash_cost
    )
    {
        // =================================================
        // DIRECCIÓN 8-DIRECCIONAL
        // =================================================
        //
        // Leemos X e Y por separado.
        //
        // Ejemplo:
        //     DERECHA + ARRIBA
        //     -> (1, -1)
        //
        // Después normalizamos:
        //     -> (0.707, -0.707)
        //
        // Así diagonal NO obtiene distancia extra.
        // =================================================

        var _raw_x =
            0;

        var _raw_y =
            0;


        var _right =
            keyboard_check(
                vk_right
            );

        var _left =
            keyboard_check(
                vk_left
            );

        var _up =
            keyboard_check(
                vk_up
            );

        var _down =
            keyboard_check(
                vk_down
            );


        if (_right && !_left)
        {
            _raw_x =
                1;
        }
        else if (_left && !_right)
        {
            _raw_x =
                -1;
        }


        if (_down && !_up)
        {
            _raw_y =
                1;
        }
        else if (_up && !_down)
        {
            _raw_y =
                -1;
        }


        // Si no mantiene ninguna flecha, usar facing.
        if (
            _raw_x == 0
            &&
            _raw_y == 0
        )
        {
            switch (
                facing_direction
            )
            {
                case 0:
                    _raw_x =
                        1;
                    break;

                case 1:
                    _raw_x =
                        -1;
                    break;

                case 2:
                    _raw_y =
                        1;
                    break;

                case 3:
                    _raw_y =
                        -1;
                    break;
            }
        }


        var _dir_len =
            point_distance(
                0,
                0,
                _raw_x,
                _raw_y
            );


        if (_dir_len > 0)
        {
            dash_anim_dir_x =
                _raw_x
                /
                _dir_len;

            dash_anim_dir_y =
                _raw_y
                /
                _dir_len;


            dash_anim_accum_x =
                0;

            dash_anim_accum_y =
                0;


            dash_anim_remaining =
                dash_anim_total_distance;

            dash_anim_active =
                true;


            // =============================================
            // SPRITE / FACING
            // =============================================
            //
            // En diagonal usamos el sprite horizontal si hay
            // componente X. El movimiento real sigue siendo
            // diagonal.
            // =============================================

            if (_raw_x > 0)
            {
                face =
                    RIGHT;

                facing_direction =
                    0;

                direccion =
                    "derecha";

                sprite_index =
                    pendejo_derecha;
            }
            else if (_raw_x < 0)
            {
                face =
                    LEFT;

                facing_direction =
                    1;

                direccion =
                    "izquierda";

                sprite_index =
                    pendejo_izquierda;
            }
            else if (_raw_y > 0)
            {
                face =
                    DOWN;

                facing_direction =
                    2;

                direccion =
                    "abajo";

                sprite_index =
                    pendejo_abajo;
            }
            else
            {
                face =
                    UP;

                facing_direction =
                    3;

                direccion =
                    "arriba";

                sprite_index =
                    pendejo_arriba;
            }


            // =============================================
            // BLOQUEAR MOVIMIENTO RPG NORMAL
            // =============================================

            dash_anim_prev_puede_moverse =
                puede_moverse;

            puede_moverse =
                false;


            // =============================================
            // STAMINA
            // =============================================

            dash_stamina =
                max(
                    0,
                    dash_stamina
                    -
                    dash_cost
                );


            dash_recharge_frames =
                0;

            dash_hud_hold =
                30;

            dash_used_this_frame =
                true;


            if (
                dash_stamina
                <=
                0
            )
            {
                dash_zero_lock =
                    true;
            }


            scr_habilidades_init();


            global.inventory_data.dash_stamina =
                dash_stamina;


            global.inventory_data.dash_recharge_frames =
                dash_recharge_frames;
        }
    }
}


// =========================================================
// ACTUALIZAR DASH ACTIVO
// =========================================================

if (dash_anim_active)
{
    // Si el mundo toma control, cancelar Dash.
    var _dash_abort =
        (
            room == bbs
            ||
            room == game_over
            ||
            scr_cutscene_world_locked()
            ||
            instance_exists(
                obj_transicion_bbs
            )
            ||
            instance_exists(
                obj_save_menu
            )
            ||
            (
                instance_exists(
                    obj_menu_manager
                )
                &&
                obj_menu_manager.state
                !=
                MENU_STATE.CLOSED
            )
        );


    if (_dash_abort)
    {
        dash_anim_active =
            false;

        dash_anim_remaining =
            0;

        dash_anim_dir_x =
            0;

        dash_anim_dir_y =
            0;

        dash_anim_accum_x =
            0;

        dash_anim_accum_y =
            0;


        if (
            scr_cutscene_world_locked()
            ||
            instance_exists(
                obj_transicion_bbs
            )
            ||
            room == bbs
            ||
            room == game_over
        )
        {
            puede_moverse =
                false;
        }
        else
        {
            puede_moverse =
                dash_anim_prev_puede_moverse;
        }
    }
    else
    {
        dash_used_this_frame =
            true;

        movimiento =
            true;


        // =================================================
        // AFTERIMAGE
        // =================================================

        var _ghost =
            instance_create_depth(
                x,
                y,
                depth + 1,
                obj_dash_afterimage
            );


        if (_ghost != noone)
        {
            _ghost.ghost_sprite =
                sprite_index;

            _ghost.ghost_frame =
                image_index;

            _ghost.ghost_xscale =
                image_xscale;

            _ghost.ghost_yscale =
                image_yscale;

            _ghost.ghost_angle =
                image_angle;

            _ghost.ghost_blend =
                image_blend;

            _ghost.ghost_dir_x =
                dash_anim_dir_x;

            _ghost.ghost_dir_y =
                dash_anim_dir_y;
        }


        // =================================================
        // RECORRIDO DE ESTE FRAME
        // =================================================
        //
        // Cada unidad representa 1 px de distancia ESCALAR.
        // En diagonal, los acumuladores distribuyen esa
        // distancia entre X e Y sin hacer el Dash más largo.
        // =================================================

        var _units_this_frame =
            min(
                dash_anim_speed,
                dash_anim_remaining
            );


        var _moved_this_frame =
            false;


        for (
            var _dash_unit = 0;
            _dash_unit < _units_this_frame;
            _dash_unit++
        )
        {
            dash_anim_accum_x +=
                dash_anim_dir_x;

            dash_anim_accum_y +=
                dash_anim_dir_y;


            var _move_x =
                0;

            var _move_y =
                0;


            if (dash_anim_accum_x >= 1)
            {
                _move_x =
                    1;

                dash_anim_accum_x -=
                    1;
            }
            else if (dash_anim_accum_x <= -1)
            {
                _move_x =
                    -1;

                dash_anim_accum_x +=
                    1;
            }


            if (dash_anim_accum_y >= 1)
            {
                _move_y =
                    1;

                dash_anim_accum_y -=
                    1;
            }
            else if (dash_anim_accum_y <= -1)
            {
                _move_y =
                    -1;

                dash_anim_accum_y +=
                    1;
            }


            var _axis_moved =
                false;


            // X por separado.
            if (_move_x != 0)
            {
                if (
                    !place_meeting(
                        x + _move_x,
                        y,
                        colision
                    )
                )
                {
                    x +=
                        _move_x;

                    _axis_moved =
                        true;
                }
            }


            // Y por separado.
            if (_move_y != 0)
            {
                if (
                    !place_meeting(
                        x,
                        y + _move_y,
                        colision
                    )
                )
                {
                    y +=
                        _move_y;

                    _axis_moved =
                        true;
                }
            }


            if (_axis_moved)
            {
                _moved_this_frame =
                    true;
            }


            dash_anim_remaining--;
        }


        // Maya sí se ve animada durante el impulso.
        image_speed =
            0.35;


        // =================================================
        // FINAL
        // =================================================

        if (
            dash_anim_remaining
            <=
            0
            ||
            !_moved_this_frame
        )
        {
            dash_anim_active =
                false;

            dash_anim_remaining =
                0;

            dash_anim_dir_x =
                0;

            dash_anim_dir_y =
                0;

            dash_anim_accum_x =
                0;

            dash_anim_accum_y =
                0;


            puede_moverse =
                dash_anim_prev_puede_moverse;


            walk_anim_hold =
                max(
                    walk_anim_hold,
                    3
                );
        }
    }
}


// =========================================================
// PLATAFORMERO
// =========================================================

if (_dash_platformer)
{
    scr_platformer_player_apply_sprite();
}
