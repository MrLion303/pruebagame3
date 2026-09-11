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
/// PLATAFORMERO V5
/// =========================================================
//
// 1. Actualizar party.
// 2. Aplicar visual plataformero de Silicio.
// 3. Detectar curación de Maya.
// 4. Mantener HP global sincronizado.
// 5. Ordenar depths.
// =========================================================

scr_party_update();


if (
    variable_global_exists(
        "platformer_active"
    )
    &&
    global.platformer_active
)
{
    scr_platformer_party_visual_update();
}


// =========================================================
// HUD TEMPORAL DE CURACIÓN
// =========================================================
//
// Al usar un consumible desde el menú plataformero,
// obj_menu_manager cierra el menú inmediatamente.
//
// Detectamos aquí el aumento real de HP y dejamos la caja
// de vida visible durante 90 frames = 3 segundos.
//
// También guardamos el aumento REAL:
//
// Ejemplo:
//
//     75 / 80
//     Manzana +20
//
// solo recupera 5:
//
//     +5
//
// no +20.
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


    // Mantener esta referencia sincronizada siempre.
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
