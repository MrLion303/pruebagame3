/// =========================================================
/// OBJ_PLATFORMER_WARP
/// STEP
/// =========================================================
///
/// Interacción con Z / Enter.
///
/// Flujo:
//
///     1. Cambia global.platformer_active.
///     2. Crea obj_warp.
///     3. obj_warp hace la transición y room_goto.
///     4. Maya aparece en target_x / target_y.
/// =========================================================

if (
    !active
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


// No iniciar otro warp mientras ya hay uno.
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
)
{
    exit;
}


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
// DISTANCIA
// =========================================================

var _p =
    instance_find(
        obj_player,
        0
    );


var _px =
    (
        _p.bbox_left
        +
        _p.bbox_right
    )
    *
    0.5;


var _py =
    (
        _p.bbox_top
        +
        _p.bbox_bottom
    )
    *
    0.5;


if (
    point_distance(
        _px,
        _py,
        x,
        y
    )
    >
    interaction_distance
)
{
    exit;
}


// =========================================================
// Z / ENTER
// =========================================================

if (
    !keyboard_check_pressed(
        ord("Z")
    )
    &&
    !keyboard_check_pressed(
        vk_enter
    )
)
{
    exit;
}


// Consumir la pulsación.
keyboard_clear(
    ord("Z")
);


keyboard_clear(
    vk_enter
);


interaction_locked =
    true;


// =========================================================
// CAMBIAR MODO
// =========================================================

scr_platformer_set_mode(
    platformer_enable
);


if (
    platformer_enable
    &&
    instance_exists(obj_player)
)
{
    var _pp =
        instance_find(
            obj_player,
            0
        );


    _pp.platform_facing =
        (
            platformer_start_facing < 0
            ?
            -1
            :
            1
        );
}


// =========================================================
// CREAR TRANSICIÓN UNIVERSAL
// =========================================================

var _warp =
    instance_create_depth(
        0,
        0,
        -9999,
        obj_warp
    );


_warp.target_x =
    target_x;


_warp.target_y =
    target_y;


_warp.target_rm =
    target_room;


_warp.target_face =
    target_face;


_warp.target_music =
    target_music;


_warp.keep_music =
    keep_music;


// Este warp no necesita iniciar cinemática automáticamente.
_warp.target_cutscene =
    "";


_warp.target_cutscene_once =
    true;
