/// =========================================================
/// OBJ_PLAYER
/// END STEP COMPLETO
/// =========================================================
///
/// 1) Ejecuta el sistema actual de Sigilo / stamina.
/// 2) Si el Dash viejo no ocurrió, prueba AQUÍ MISMO un Dash
///    corregido.
/// 3) Dash se desbloquea con:
///
///        habilidad "dash"
///              O
///        Zapatos Rápidos
///
/// 4) El peligro se toma del FX REAL del mapa y también de
///    los rangos geométricos de los enemigos.
/// =========================================================

scr_player_abilities_end_step(
    id
);


// =========================================================
// DASH DIRECTO CORREGIDO
// =========================================================
//
// Si el sistema viejo ya hizo dash, no repetimos.
// =========================================================

if (
    !variable_instance_exists(
        id,
        "dash_used_this_frame"
    )
    ||
    !dash_used_this_frame
)
{
    scr_player_abilities_init(
        id
    );


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
    // PELIGRO REAL
    // -----------------------------------------------------

    var _dash_danger =
        false;


    // 1) Exactamente el mismo estado que oscurece el mapa.
    if (
        instance_exists(
            obj_mapa_combate_fx
        )
    )
    {
        var _fx =
            instance_find(
                obj_mapa_combate_fx,
                0
            );


        if (
            _fx != noone
            &&
            variable_instance_exists(
                _fx,
                "danger_active"
            )
            &&
            _fx.danger_active
        )
        {
            _dash_danger =
                true;
        }
    }


    // 2) Failsafe geométrico para enemigos normales/de ruta.
    if (!_dash_danger)
    {
        var _map_enemy_count =
            instance_number(
                obj_enemigo_mapa_parent
            );


        for (
            var _de = 0;
            _de < _map_enemy_count;
            _de++
        )
        {
            var _enemy =
                instance_find(
                    obj_enemigo_mapa_parent,
                    _de
                );


            if (
                _enemy == noone
                ||
                !instance_exists(
                    _enemy
                )
            )
            {
                continue;
            }


            var _enemy_range =
                -1;


            if (
                variable_instance_exists(
                    _enemy,
                    "rango_ataque"
                )
            )
            {
                _enemy_range =
                    max(
                        _enemy_range,
                        _enemy.rango_ataque
                    );
            }


            if (
                variable_instance_exists(
                    _enemy,
                    "rango_peligro"
                )
            )
            {
                _enemy_range =
                    max(
                        _enemy_range,
                        _enemy.rango_peligro
                    );
            }


            if (
                _enemy_range >= 0
                &&
                point_distance(
                    x,
                    y,
                    _enemy.x,
                    _enemy.y
                )
                <=
                _enemy_range
            )
            {
                _dash_danger =
                    true;

                break;
            }
        }
    }


    // 3) Enemigos del mapa que persiguen e inician BBS.
    if (!_dash_danger)
    {
        var _bbs_enemy_count =
            instance_number(
                obj_enemigo_batalla_mapa_parent
            );


        for (
            var _be = 0;
            _be < _bbs_enemy_count;
            _be++
        )
        {
            var _bbs_enemy =
                instance_find(
                    obj_enemigo_batalla_mapa_parent,
                    _be
                );


            if (
                _bbs_enemy == noone
                ||
                !instance_exists(
                    _bbs_enemy
                )
            )
            {
                continue;
            }


            if (
                variable_instance_exists(
                    _bbs_enemy,
                    "alerta_activa"
                )
                &&
                _bbs_enemy.alerta_activa
            )
            {
                _dash_danger =
                    true;

                break;
            }


            if (
                variable_instance_exists(
                    _bbs_enemy,
                    "rango_persecucion"
                )
                &&
                point_distance(
                    x,
                    y,
                    _bbs_enemy.x,
                    _bbs_enemy.y
                )
                <=
                _bbs_enemy.rango_persecucion
            )
            {
                _dash_danger =
                    true;

                break;
            }
        }
    }


    // -----------------------------------------------------
    // ¿SE PUEDE INTENTAR?
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
            &&
            !(
                variable_global_exists(
                    "platformer_active"
                )
                &&
                global.platformer_active
            )
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
        &&
        keyboard_check_pressed(
            vk_space
        )
    )
    {
        // ---------------------------------------------
        // DIRECCIÓN
        // ---------------------------------------------

        var _dx =
            0;

        var _dy =
            0;


        if (
            keyboard_check(
                vk_right
            )
            &&
            !keyboard_check(
                vk_left
            )
        )
        {
            _dx =
                1;
        }
        else if (
            keyboard_check(
                vk_left
            )
            &&
            !keyboard_check(
                vk_right
            )
        )
        {
            _dx =
                -1;
        }
        else if (
            keyboard_check(
                vk_up
            )
            &&
            !keyboard_check(
                vk_down
            )
        )
        {
            _dy =
                -1;
        }
        else if (
            keyboard_check(
                vk_down
            )
            &&
            !keyboard_check(
                vk_up
            )
        )
        {
            _dy =
                1;
        }
        else
        {
            switch (
                facing_direction
            )
            {
                case 0:
                    _dx = 1;
                    break;

                case 1:
                    _dx = -1;
                    break;

                case 2:
                    _dy = 1;
                    break;

                case 3:
                    _dy = -1;
                    break;
            }
        }


        // ---------------------------------------------
        // MOVIMIENTO PIXEL A PIXEL
        // ---------------------------------------------

        var _dash_start_x =
            x;

        var _dash_start_y =
            y;


        for (
            var _di = 0;
            _di < dash_distance;
            _di++
        )
        {
            var _nx =
                x
                +
                _dx;

            var _ny =
                y
                +
                _dy;


            if (
                place_meeting(
                    _nx,
                    _ny,
                    colision
                )
            )
            {
                break;
            }


            x =
                _nx;

            y =
                _ny;
        }


        // Solo gastar stamina si realmente avanzó.
        if (
            x != _dash_start_x
            ||
            y != _dash_start_y
        )
        {
            movimiento =
                true;

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


        keyboard_clear(
            vk_space
        );
    }
}


// =========================================================
// PLATAFORMERO
// =========================================================

if (
    variable_global_exists(
        "platformer_active"
    )
    &&
    global.platformer_active
)
{
    scr_platformer_player_apply_sprite();
}
