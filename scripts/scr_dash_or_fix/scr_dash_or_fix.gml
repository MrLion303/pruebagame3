/// =========================================================
/// SCR_DASH_OR_FIX
/// NUEVO SCRIPT
/// =========================================================
///
/// Dash desbloqueado por:
///
///     habilidad "dash"
///         O
///     armadura con permite_dash_mapa
///
/// No requiere ambas.
///
/// NO usa instance_exists(obj_pauser) como bloqueo.
/// =========================================================

function scr_player_try_dash_or_fix(_p)
{
    if (
        _p == noone
        ||
        !instance_exists(
            _p
        )
    )
    {
        return false;
    }


    scr_player_abilities_init(
        _p
    );


    // =====================================================
    // DESBLOQUEO: HABILIDAD O ZAPATOS
    // =====================================================

    var _has_ability =
        scr_habilidad_tiene(
            "dash"
        );


    var _has_shoes =
        scr_player_has_dash_armor(
            _p
        );


    if (
        !_has_ability
        &&
        !_has_shoes
    )
    {
        return false;
    }


    // =====================================================
    // INPUT / STAMINA / PELIGRO
    // =====================================================

    if (
        !keyboard_check_pressed(
            vk_space
        )
        ||
        _p.dash_stamina
        <
        _p.dash_cost
        ||
        !scr_player_dash_danger_active(
            _p
        )
    )
    {
        return false;
    }


    // =====================================================
    // BLOQUEOS REALES
    // =====================================================

    if (
        room == bbs
        ||
        room == game_over
        ||
        scr_cutscene_world_locked()
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
        ||
        !variable_instance_exists(
            _p,
            "puede_moverse"
        )
        ||
        !_p.puede_moverse
    )
    {
        return false;
    }


    if (
        variable_global_exists(
            "platformer_active"
        )
        &&
        global.platformer_active
    )
    {
        return false;
    }


    // =====================================================
    // DIRECCIÓN
    // =====================================================

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
            _p.facing_direction
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


    if (
        _dx == 0
        &&
        _dy == 0
    )
    {
        return false;
    }


    // =====================================================
    // MOVER PIXEL A PIXEL
    // =====================================================

    var _start_x =
        _p.x;

    var _start_y =
        _p.y;


    for (
        var _i = 0;
        _i < _p.dash_distance;
        _i++
    )
    {
        var _nx =
            _p.x
            +
            _dx;


        var _ny =
            _p.y
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


        _p.x =
            _nx;

        _p.y =
            _ny;
    }


    // Pegado completamente a una pared:
    // no gastar stamina por un dash de 0 px.
    if (
        _p.x == _start_x
        &&
        _p.y == _start_y
    )
    {
        return false;
    }


    // =====================================================
    // COSTE
    // =====================================================

    _p.movimiento =
        true;


    _p.dash_stamina =
        max(
            0,
            _p.dash_stamina
            -
            _p.dash_cost
        );


    _p.dash_recharge_frames =
        0;


    _p.dash_hud_hold =
        30;


    _p.dash_used_this_frame =
        true;


    if (
        _p.dash_stamina
        <=
        0
    )
    {
        _p.dash_zero_lock =
            true;
    }


    // Persistencia inmediata.
    scr_habilidades_init();


    global.inventory_data.dash_stamina =
        _p.dash_stamina;


    global.inventory_data.dash_recharge_frames =
        _p.dash_recharge_frames;


    // Evitar que el sistema viejo reutilice el mismo Space.
    keyboard_clear(
        vk_space
    );


    return true;
}
