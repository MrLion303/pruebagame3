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
/// PLATAFORMERO V8 + VIENTO RPG AUTORITATIVO
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


    if (!_platform_recovering)
    {
        scr_fan_platformer_party_follow_update();
    }


    // Silicio aéreo: frame fijo.
    if (instance_exists(obj_silicio))
    {
        var _silicio_air =
            instance_find(
                obj_silicio,
                0
            );


        if (
            _silicio_air != noone
            &&
            instance_exists(_silicio_air)
            &&
            scr_party_has(
                "silicio"
            )
            &&
            variable_instance_exists(
                _silicio_air,
                "platform_sil_grounded"
            )
            &&
            !_silicio_air.platform_sil_grounded
        )
        {
            _silicio_air.image_index =
                0;


            _silicio_air.image_speed =
                0;
        }
    }
}
else
{
    // Limpiar historial del follower plataformero.
    scr_platformer_party_follow_leave();


    // =====================================================
    // RPG - VIENTO DE SILICIO EN EL MISMO FLUJO DEL FOLLOWER
    // =====================================================
    //
    // Antes:
    //     scr_party_update();
    //
    // y obj_silicio limpiaba fan_detached fuera del plataformero.
    // Por eso el arreglo anterior NO podía funcionar en el RPG.
    //
    // Ahora:
    //
    //     1. guardamos dónde estaba Silicio;
    //     2. si ya está bajo viento, suspendemos su follower;
    //     3. scr_party_update() actualiza a Maya/ruta/otros miembros;
    //     4. si Silicio estaba normal, escaneamos su movimiento real;
    //     5. al tocar aire, el viento toma autoridad autónoma.
    // =====================================================

    var _fan_rpg_player =
        noone;


    if (instance_exists(obj_player))
    {
        _fan_rpg_player =
            instance_find(
                obj_player,
                0
            );
    }


    var _fan_rpg_silicio =
        noone;


    if (scr_party_has("silicio"))
    {
        _fan_rpg_silicio =
            scr_party_get_instance(
                "silicio"
            );
    }


    var _fan_rpg_old_x =
        0;

    var _fan_rpg_old_y =
        0;


    if (
        _fan_rpg_silicio != noone
        &&
        instance_exists(_fan_rpg_silicio)
    )
    {
        _fan_rpg_old_x =
            _fan_rpg_silicio.x;

        _fan_rpg_old_y =
            _fan_rpg_silicio.y;


        scr_fan_rpg_before_party_update(
            _fan_rpg_silicio
        );
    }


    scr_party_update();


    // Reobtener por si scr_party_update() creó/reasignó la instancia.
    if (scr_party_has("silicio"))
    {
        var _fan_rpg_after_silicio =
            scr_party_get_instance(
                "silicio"
            );


        if (
            _fan_rpg_after_silicio != noone
            &&
            instance_exists(_fan_rpg_after_silicio)
        )
        {
            // Si antes no existía, no hay trayectoria antigua que
            // escanear: usar su posición actual como origen.
            if (
                _fan_rpg_silicio == noone
                ||
                !instance_exists(_fan_rpg_silicio)
            )
            {
                _fan_rpg_old_x =
                    _fan_rpg_after_silicio.x;

                _fan_rpg_old_y =
                    _fan_rpg_after_silicio.y;
            }


            scr_fan_rpg_after_party_update(
                _fan_rpg_after_silicio,
                _fan_rpg_player,
                _fan_rpg_old_x,
                _fan_rpg_old_y
            );
        }
    }
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


// =========================================================
// GARANTÍA VISUAL FINAL DEL VIENTO
// =========================================================

if (scr_party_has("silicio"))
{
    var _fan_final_silicio =
        scr_party_get_instance(
            "silicio"
        );


    if (
        _fan_final_silicio != noone
        &&
        instance_exists(_fan_final_silicio)
        &&
        variable_instance_exists(
            _fan_final_silicio,
            "fan_detached"
        )
        &&
        _fan_final_silicio.fan_detached
    )
    {
        var _fan_final_rejoin =
            variable_instance_exists(
                _fan_final_silicio,
                "fan_rejoin_active"
            )
            &&
            _fan_final_silicio.fan_rejoin_active;


        if (!_fan_final_rejoin)
        {
            _fan_final_silicio.movimiento =
                false;

            _fan_final_silicio.image_speed =
                0;
        }


        if (_platform_party)
        {
            if (
                variable_instance_exists(
                    _fan_final_silicio,
                    "platform_sil_move_x"
                )
            )
            {
                _fan_final_silicio.platform_sil_move_x =
                    0;
            }


            if (
                variable_instance_exists(
                    _fan_final_silicio,
                    "platform_sil_move_y"
                )
            )
            {
                _fan_final_silicio.platform_sil_move_y =
                    0;
            }
        }
    }
}
