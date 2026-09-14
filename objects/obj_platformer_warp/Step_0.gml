/// =========================================================
/// OBJ_PLATFORMER_WARP - STEP
/// =========================================================

scr_platformer_init();

prompt_visible =
    false;


if (!interaction_enabled)
{
    exit;
}


if (transitioning)
{
    exit;
}


if (!instance_exists(obj_player))
{
    exit;
}


if (target_room == noone)
{
    exit;
}


var _p =
    instance_find(
        obj_player,
        0
    );


if (
    _p == noone
    ||
    !instance_exists(_p)
)
{
    exit;
}


// =========================================================
// BLOQUEOS DE INTERACCIÓN
// =========================================================

if (
    variable_global_exists(
        "cutscene_active"
    )
    &&
    global.cutscene_active
)
{
    exit;
}


if (
    instance_exists(
        obj_textbox
    )
    ||
    instance_exists(
        obj_save_menu
    )
    ||
    instance_exists(
        obj_menu_manager
    )
    ||
    instance_exists(
        obj_pauser
    )
    ||
    instance_exists(
        obj_hoja_problema_ui
    )
)
{
    exit;
}


// =========================================================
// HITBOX FÍSICA / CENTRO DE MAYA
// =========================================================

var _player_left =
    _p.bbox_left;


var _player_top =
    _p.bbox_top;


var _player_right =
    _p.bbox_right;


var _player_bottom =
    _p.bbox_bottom;


// En modo plataformero usar su rectángulo físico real.
if (
    global.platformer_active
    &&
    variable_instance_exists(
        _p,
        "platform_hit_left"
    )
)
{
    _player_left =
        _p.x
        +
        _p.platform_hit_left;


    _player_top =
        _p.y
        +
        _p.platform_hit_top;


    _player_right =
        _p.x
        +
        _p.platform_hit_right;


    _player_bottom =
        _p.y
        +
        _p.platform_hit_bottom;
}


var _player_center_x =
    (
        _player_left
        +
        _player_right
    )
    *
    0.5;


var _player_center_y =
    (
        _player_top
        +
        _player_bottom
    )
    *
    0.5;


var _warp_center_x =
    (
        bbox_left
        +
        bbox_right
    )
    *
    0.5;


var _warp_center_y =
    (
        bbox_top
        +
        bbox_bottom
    )
    *
    0.5;


// =========================================================
// DIRECCIÓN REAL DE MAYA
// =========================================================

var _face =
    _p.face;


if (
    global.platformer_active
    &&
    variable_instance_exists(
        _p,
        "platform_facing"
    )
)
{
    _face =
        (
            _p.platform_facing < 0
            ?
            LEFT
            :
            RIGHT
        );
}


// =========================================================
// MUY CERCA + DIRECTAMENTE MIRANDO AL TRIGGER
// =========================================================
//
// La distancia se mide DESDE EL BORDE de Maya hasta el borde
// del trigger, no entre centros.
//
// Así un trigger grande sigue requiriendo estar pegado a él.
//
// =========================================================

var _facing_ok =
    false;


var _forward_gap =
    999999;


switch (_face)
{
    case RIGHT:
        _forward_gap =
            bbox_left
            -
            _player_right;


        _facing_ok =
            (
                _warp_center_x
                >
                _player_center_x
                &&
                abs(
                    _warp_center_y
                    -
                    _player_center_y
                )
                <=
                interaction_x_margin
            );
        break;


    case LEFT:
        _forward_gap =
            _player_left
            -
            bbox_right;


        _facing_ok =
            (
                _warp_center_x
                <
                _player_center_x
                &&
                abs(
                    _warp_center_y
                    -
                    _player_center_y
                )
                <=
                interaction_x_margin
            );
        break;


    case DOWN:
        _forward_gap =
            bbox_top
            -
            _player_bottom;


        _facing_ok =
            (
                _warp_center_y
                >
                _player_center_y
                &&
                abs(
                    _warp_center_x
                    -
                    _player_center_x
                )
                <=
                interaction_x_margin
            );
        break;


    case UP:
        _forward_gap =
            _player_top
            -
            bbox_bottom;


        _facing_ok =
            (
                _warp_center_y
                <
                _player_center_y
                &&
                abs(
                    _warp_center_x
                    -
                    _player_center_x
                )
                <=
                interaction_x_margin
            );
        break;
}


var _near =
    (
        _forward_gap
        >=
        -2
        &&
        _forward_gap
        <=
        interaction_distance
    );


if (
    !_facing_ok
    ||
    !_near
)
{
    exit;
}


// =========================================================
// PROMPT
// =========================================================

prompt_visible =
    show_prompt;


// =========================================================
// CONFIRMAR
// =========================================================

var _confirm =
    keyboard_check_pressed(
        ord("Z")
    )
    ||
    keyboard_check_pressed(
        vk_enter
    );


if (!_confirm)
{
    exit;
}


transitioning =
    true;


scr_platformer_request_room_mode(
    target_room,
    target_platformer,
    target_x,
    target_y,
    target_facing
);
