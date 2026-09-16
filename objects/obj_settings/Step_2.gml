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
    // PARTY PLATAFORMERO + VIENTO DE SILICIO
    // =====================================================
    //
    // scr_fan_platformer_party_follow_update() envuelve el
    // follower original.
    //
    // Fuera del viento:
    //     funciona exactamente el follower normal.
    //
    // Cuando Silicio toca la corriente:
    //     el mismo wrapper intercepta el primer píxel de contacto
    //     y entra al ciclo tipo obj_deslizamiento_abajo:
    //
    //         wind_follow
    //         wind_exit
    //         wind_wait_gap
    //         normal
    //
    // Así no existen dos sistemas distintos moviendo a Silicio
    // en el mismo frame.
    // =====================================================

    if (!_platform_recovering)
    {
        scr_fan_platformer_party_follow_update();
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
// Mientras el estado especial del abanico tenga a Silicio:
//     - no avanza ningún frame;
//     - no queda una animación de caminar heredada;
//     - el movimiento físico del viento no cuenta como caminar.
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
    )
    {
        _fan_final_silicio.platform_sil_move_x =
            0;


        _fan_final_silicio.platform_sil_move_y =
            0;


        _fan_final_silicio.movimiento =
            false;


        _fan_final_silicio.image_index =
            0;


        _fan_final_silicio.image_speed =
            0;
    }
}
