/// =========================================================
/// OBJ_HOJA_PROBLEMA - STEP
/// =========================================================

// Aplicar sprite personalizado del mundo.
if (
    sheet_world_sprite != -1
    &&
    sprite_exists(
        sheet_world_sprite
    )
    &&
    sprite_index
    !=
    sheet_world_sprite
)
{
    sprite_index =
        sheet_world_sprite;


    image_index =
        0;
}


if (!interaction_enabled)
{
    exit;
}


if (instance_exists(obj_hoja_problema_ui))
{
    exit;
}


if (!instance_exists(obj_player))
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
    instance_exists(obj_menu_manager)
    ||
    instance_exists(obj_pauser)
)
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


if (
    !scr_problem_sheet_facing_object(
        _p,
        id,
        interaction_distance,
        interaction_axis_tolerance
    )
)
{
    exit;
}


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


var _ui =
    instance_create_depth(
        0,
        0,
        -200000,
        obj_hoja_problema_ui
    );


if (
    _ui != noone
    &&
    instance_exists(_ui)
)
{
    _ui.sheet_config_id =
        sheet_config_id;


    _ui.source_sheet =
        id;


    _ui.sheet_initialized =
        false;
}


keyboard_clear(
    ord("Z")
);


keyboard_clear(
    vk_enter
);
