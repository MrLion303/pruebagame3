/// =========================================================
/// OBJ_BATALLA_ATTACK_MODS
/// BEGIN STEP COMPLETO
/// =========================================================
///
/// Ya NO existe la confirmación tardía.
/// =========================================================

if (room != bbs)
{
    instance_destroy();
    exit;
}


f_prepare_attack();


if (!f_refresh_refs())
    exit;


var _ui =
    ui_ref;


// =========================================================
// TOY ENEMIGO: FORZAR MISS DEL JUGADOR
// =========================================================
//
// En golpes intermedios de una cadena, End Step los resuelve
// inmediatamente al detener la barra.
//
// Aquí solo necesitamos interceptar el golpe FINAL / único
// justo antes de que obj_batalla_ui aplique el daño.
// =========================================================

if (
    chain_active
    &&
    hit_prepared
    &&
    current_mode == "lineal"
    &&
    current_force_miss
    &&
    _ui.attack_timing_stopped
    &&
    _ui.attack_stop_timer <= 1
)
{
    f_resolve_current_hit(
        true
    );

    exit;
}
