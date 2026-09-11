/// =========================================================
/// OBJ_BATALLA_ATTACK_MODS
/// STEP - NUEVO
/// =========================================================
/// Ataque circular cargable:
/// nueva pulsación Z/Enter -> mantener -> aro crece -> soltar.
/// Tiempo limitado.
/// =========================================================

if (
    room != bbs
    ||
    !circle_active
)
{
    exit;
}

if (!f_refresh_refs())
{
    circle_active = false;
    exit;
}

circle_timer++;

var _pressed =
    keyboard_check_pressed(ord("Z"))
    ||
    keyboard_check_pressed(vk_enter);

var _held =
    keyboard_check(ord("Z"))
    ||
    keyboard_check(vk_enter);


if (
    !circle_started
    &&
    _pressed
)
{
    circle_started = true;
}


if (
    circle_started
    &&
    _held
)
{
    circle_radius =
        min(
            circle_radius_max,
            circle_radius + circle_speed
        );
}


// Soltar después de empezar resuelve el golpe.
if (
    circle_started
    &&
    !_held
)
{
    f_resolve_circle();
    exit;
}


// Tiempo agotado.
if (circle_timer >= circle_limit)
{
    f_resolve_circle();
    exit;
}
