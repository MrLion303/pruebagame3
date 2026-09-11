/// =========================================================
/// OBJ_PLATFORMER_WARP
/// STEP
/// =========================================================
///
/// ENTRADA:
///     Z / Enter.
///
/// SALIDA:
///     este Step no la activa;
///     se activa golpeando el trigger con el melee.
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


// La salida solamente responde al ataque melee.
if (!platformer_enable)
{
    exit;
}


if (!instance_exists(obj_player))
{
    exit;
}


if (instance_exists(obj_warp))
{
    exit;
}


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


keyboard_clear(
    ord("Z")
);


keyboard_clear(
    vk_enter
);


// El cambio de modo queda pendiente hasta target_room.
scr_platformer_warp_activate(
    id
);
