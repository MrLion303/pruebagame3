if (
    variable_global_exists("gameover_death_freeze_active")
    &&
    global.gameover_death_freeze_active
)
{
    exit;
}


/// =========================================================
/// OBJ_SETTINGS
/// END STEP
/// PLATAFORMERO V7
/// =========================================================
///
/// RPG:
///     scr_party_update()
///
/// PLATAFORMERO:
///     scr_platformer_party_follow_update()
/// =========================================================


// =========================================================
// PARTY
// =========================================================

var _platform_party =
    (
        variable_global_exists(
            "platformer_active"
        )
        &&
        global.platformer_active
    );


if (_platform_party)
{
    var _platform_recovering =
        false;


    if (instance_exists(obj_player))
    {
        var _platform_party_player =
            instance_find(
                obj_player,
                0
            );


        _platform_recovering =
            variable_instance_exists(
                _platform_party_player,
                "platform_void_recover_active"
            )
            &&
            _platform_party_player.platform_void_recover_active;
    }


    // Durante el rescate del vacío, Begin Step mueve a Maya y
    // Silicio manualmente. El follower no debe pisar esa animación.
    if (!_platform_recovering)
    {
        scr_platformer_party_follow_update();
    }
}
else
{
    // Limpiar historial plataformero y volver a preparar
    // correctamente el historial RPG.
    scr_platformer_party_follow_leave();


    scr_party_update();
}


// =========================================================
// FADE DE SILICIO
// =========================================================

if (instance_exists(obj_player))
{
    scr_silicio_visibility_update(
        instance_find(
            obj_player,
            0
        )
    );
}


// =========================================================
// DIÁLOGO AL USAR CONSUMIBLE DESDE EL INVENTARIO
// =========================================================

scr_item_use_dialog_update();


// =========================================================
// HUD TEMPORAL DE CURACIÓN
// =========================================================

if (
    !variable_global_exists(
        "platformer_heal_hud_timer"
    )
)
{
    global.platformer_heal_hud_timer =
        0;
}


if (
    !variable_global_exists(
        "platformer_heal_hud_duration"
    )
)
{
    global.platformer_heal_hud_duration =
        90;
}


if (
    !variable_global_exists(
        "platformer_heal_amount"
    )
)
{
    global.platformer_heal_amount =
        0;
}


if (
    !variable_global_exists(
        "platformer_hp_track_last"
    )
)
{
    global.platformer_hp_track_last =
        -1;
}


if (instance_exists(obj_player))
{
    var _p =
        instance_find(
            obj_player,
            0
        );


    var _hp_now =
        _p.hp;


    if (global.platformer_hp_track_last < 0)
    {
        global.platformer_hp_track_last =
            _hp_now;
    }


    if (
        variable_global_exists(
            "platformer_active"
        )
        &&
        global.platformer_active
        &&
        _hp_now
        >
        global.platformer_hp_track_last
    )
    {
        global.platformer_heal_amount =
            _hp_now
            -
            global.platformer_hp_track_last;


        global.platformer_heal_hud_timer =
            global.platformer_heal_hud_duration;
    }


    global.platformer_hp_track_last =
        _hp_now;


    global.player_hp_current =
        _hp_now;
}
else
{
    global.platformer_hp_track_last =
        -1;
}


if (global.platformer_heal_hud_timer > 0)
{
    global.platformer_heal_hud_timer--;
}
else
{
    global.platformer_heal_hud_timer =
        0;


    global.platformer_heal_amount =
        0;
}


scr_depth_sort_update();
