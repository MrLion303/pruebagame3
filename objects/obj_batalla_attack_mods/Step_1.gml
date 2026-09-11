/// =========================================================
/// OBJ_BATALLA_ATTACK_MODS
/// BEGIN STEP - NUEVO
/// =========================================================

if (room != bbs)
{
    instance_destroy();
    exit;
}

f_prepare_attack();

if (!f_refresh_refs())
    exit;

var _ui = ui_ref;


// =========================================================
// Z SOLO DESPUÉS DE PASAR EL CENTRO
// =========================================================

if (
    hit_prepared
    &&
    current_after_center
    &&
    current_mode == "lineal"
    &&
    _ui.attack_timing_active
)
{
    var _ya_paso =
        (
            _ui.attack_bar_direction > 0
            &&
            _ui.attack_bar_x > _ui.attack_bar_center_x
        )
        ||
        (
            _ui.attack_bar_direction < 0
            &&
            _ui.attack_bar_x < _ui.attack_bar_center_x
        );

    if (!_ya_paso)
    {
        keyboard_clear(ord("Z"));
        keyboard_clear(vk_enter);
    }
}


// =========================================================
// TOY ENEMIGO: FORZAR MISS DEL JUGADOR
// =========================================================

if (
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
    _ui.attack_timing_stopped = false;
    _ui.attack_stop_timer = 0;

    _ui.f_resolver_timing_ataque(true);

    _ui.attack_feedback_active = true;
    _ui.attack_feedback_timer = 0;
}
