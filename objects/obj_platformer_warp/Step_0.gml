/// =========================================================
/// OBJ_PLATFORMER_WARP
/// STEP COMPLETO
/// =========================================================
///
/// PARA ACTIVARSE:
///
///     1. Maya debe tocar la zona FIJA 20x20 del centro.
///     2. Maya debe estar mirando directamente al objeto.
///     3. Debe pulsar Z o Enter.
///     4. No debe haber un menú/cinemática bloqueando.
///
/// La transición y el cambio de modo los realiza el sistema
/// oficial actual:
//
///     scr_platformer_warp_activate(id)
///
/// =========================================================

scr_platformer_init();


prompt_visible =
    false;


// =========================================================
// ESTADO DEL OBJETO
// =========================================================

if (
    !active
    ||
    !interaction_enabled
    ||
    interaction_locked
)
{
    exit;
}


if (
    target_room == noone
    ||
    target_room == -1
)
{
    exit;
}


if (!instance_exists(obj_player))
{
    exit;
}


// No crear dos transiciones a la vez.
if (instance_exists(obj_warp))
{
    exit;
}


// =========================================================
// BLOQUEOS
// =========================================================

if (
    variable_global_exists(
        "gameover_death_freeze_active"
    )
    &&
    global.gameover_death_freeze_active
)
{
    exit;
}


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
    instance_exists(obj_textbox)
    ||
    instance_exists(obj_save_menu)
    ||
    instance_exists(obj_pauser)
    ||
    instance_exists(obj_hoja_problema_ui)
)
{
    exit;
}


// obj_menu_manager puede existir durante gameplay.
//
// SOLO debe bloquear el warp si el menú realmente está abierto.
if (
    instance_exists(obj_menu_manager)
    &&
    obj_menu_manager.state
    !=
    MENU_STATE.CLOSED
)
{
    exit;
}


// =========================================================
// PLAYER
// =========================================================

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
// HITBOX REAL DE MAYA
// =========================================================

var _player_left =
    _p.bbox_left;


var _player_top =
    _p.bbox_top;


var _player_right =
    _p.bbox_right;


var _player_bottom =
    _p.bbox_bottom;


// En modo plataformero usamos su rectángulo físico propio.
if (
    global.platformer_active
    &&
    variable_instance_exists(
        _p,
        "platform_hit_left"
    )
    &&
    variable_instance_exists(
        _p,
        "platform_hit_top"
    )
    &&
    variable_instance_exists(
        _p,
        "platform_hit_right"
    )
    &&
    variable_instance_exists(
        _p,
        "platform_hit_bottom"
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


// =========================================================
// CENTRO DEL WARP
// =========================================================
//
// El área de interacción NO depende del tamaño del sprite.
//
// Si existe sprite usamos el centro real de su bbox para que
// la zona quede visualmente centrada sobre el objeto.
//
// =========================================================

var _warp_center_x =
    x;


var _warp_center_y =
    y;


if (
    sprite_index != -1
    &&
    sprite_exists(sprite_index)
)
{
    _warp_center_x =
        (
            bbox_left
            +
            bbox_right
        )
        *
        0.5;


    _warp_center_y =
        (
            bbox_top
            +
            bbox_bottom
        )
        *
        0.5;
}


// =========================================================
// ZONA FIJA 20x20
// =========================================================

var _half_size =
    max(
        1,
        interaction_size
        *
        0.5
    );


var _zone_left =
    _warp_center_x
    -
    _half_size;


var _zone_right =
    _warp_center_x
    +
    _half_size;


var _zone_top =
    _warp_center_y
    -
    _half_size;


var _zone_bottom =
    _warp_center_y
    +
    _half_size;


// No exigimos que el CENTRO de Maya entre dentro de la zona.
//
// Basta con que su hitbox real toque el rectángulo 20x20.
var _touching =
(
    _player_right
    >=
    _zone_left

    &&

    _player_left
    <=
    _zone_right

    &&

    _player_bottom
    >=
    _zone_top

    &&

    _player_top
    <=
    _zone_bottom
);


if (!_touching)
{
    exit;
}


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
// MIRAR DIRECTAMENTE AL OBJETO
// =========================================================

var _dx =
    _warp_center_x
    -
    _player_center_x;


var _dy =
    _warp_center_y
    -
    _player_center_y;


var _facing_ok =
    false;


switch (_face)
{
    case RIGHT:
        _facing_ok =
        (
            _dx > 0
            &&
            abs(_dy)
            <=
            _half_size
        );
        break;


    case LEFT:
        _facing_ok =
        (
            _dx < 0
            &&
            abs(_dy)
            <=
            _half_size
        );
        break;


    case DOWN:
        _facing_ok =
        (
            _dy > 0
            &&
            abs(_dx)
            <=
            _half_size
        );
        break;


    case UP:
        _facing_ok =
        (
            _dy < 0
            &&
            abs(_dx)
            <=
            _half_size
        );
        break;
}


if (!_facing_ok)
{
    exit;
}


// =========================================================
// PROMPT
// =========================================================

prompt_visible =
    show_prompt;


// =========================================================
// INPUT
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


// =========================================================
// ACTIVAR
// =========================================================
//
// Esta función:
//
//     - bloquea esta instancia;
//     - deja pendiente platformer_enable;
//     - crea obj_warp;
//     - configura target_room/x/y/face;
//     - conserva o cambia música;
//     - aplica el modo al llegar a la room destino.
//
// =========================================================

if (
    scr_platformer_warp_activate(
        id
    )
)
{
    keyboard_clear(
        ord("Z")
    );


    keyboard_clear(
        vk_enter
    );
}
