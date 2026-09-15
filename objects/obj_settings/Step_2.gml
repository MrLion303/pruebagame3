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


    // =====================================================
    // SILICIO - VIENTO / EXPULSIÓN / REINCORPORACIÓN
    // =====================================================
    //
    // Si Silicio toca una corriente:
    //
    //     - el follower normal NO puede moverlo;
    //     - el abanico lo expulsa completamente;
    //     - queda separado del grupo;
    //     - al detenerse Maya y comenzar a caminar de nuevo,
    //       Silicio hace catch-up y se reincorpora.
    //
    // scr_fan_silicio_detach_update() devuelve TRUE mientras
    // debe consumir el follower normal.
    // =====================================================

    var _fan_silicio_consumed =
        false;


    if (
        !_platform_recovering
        &&
        instance_exists(obj_player)
        &&
        scr_party_has(
            "silicio"
        )
    )
    {
        var _fan_player =
            instance_find(
                obj_player,
                0
            );


        var _fan_silicio =
            scr_party_get_instance(
                "silicio"
            );


        if (
            _fan_silicio != noone
            &&
            instance_exists(_fan_silicio)
        )
        {
            _fan_silicio_consumed =
                scr_fan_silicio_detach_update(
                    _fan_silicio,
                    _fan_player
                );
        }
    }


    // Durante el rescate del vacío, Begin Step mueve a Maya y
    // Silicio manualmente. El follower no debe pisar esa animación.
    //
    // Tampoco debe ejecutarse mientras el viento tiene a Silicio
    // desprendido o reincorporándose.
    if (
        !_platform_recovering
        &&
        !_fan_silicio_consumed
    )
    {
        scr_platformer_party_follow_update();
    }


    // =====================================================
    // SILICIO - SPRITE AÉREO QUIETO
    // =====================================================
    //
    // Igual que Maya:
    //
    // mientras Silicio está en el aire, el sprite de salto / aire
    // se queda fijo en el frame 0.
    //
    // IMPORTANTE:
    // esto corre DESPUÉS de scr_platformer_party_follow_update(),
    // que es quien selecciona el sprite correcto de Silicio.
    // Así no cambiamos qué sprite usa; solamente evitamos que sus
    // frames avancen mientras no está tocando suelo.
    // =====================================================

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


// =========================================================
// SILICIO - BLOQUEO VISUAL FINAL DE VIENTO
// =========================================================
//
// Última garantía del frame.
//
// Si está desprendido por un ventilador, ningún sistema que haya
// corrido antes puede dejarlo con frames de caminar avanzando.
// =========================================================

if (
    variable_global_exists(
        "platformer_active"
    )
    &&
    global.platformer_active
    &&
    scr_party_has(
        "silicio"
    )
)
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
        &&
        !(
            variable_instance_exists(
                _fan_final_silicio,
                "fan_rejoin_active"
            )
            &&
            _fan_final_silicio.fan_rejoin_active
            &&
            variable_instance_exists(
                _fan_final_silicio,
                "platform_sil_grounded"
            )
            &&
            _fan_final_silicio.platform_sil_grounded
        )
    )
    {
        _fan_final_silicio.image_index =
            0;

        _fan_final_silicio.image_speed =
            0;

        _fan_final_silicio.movimiento =
            false;
    }
}
