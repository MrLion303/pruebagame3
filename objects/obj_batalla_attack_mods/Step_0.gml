/// =========================================================
/// OBJ_BATALLA_ATTACK_MODS
/// STEP COMPLETO
/// =========================================================
/// ATAQUE CIRCULAR CARGABLE
///
/// La diana permanece visible SIN límite mientras espera
/// que el jugador empiece.
///
/// 1) Pulsar y mantener Z / Enter:
///        comienza a crecer el aro.
///
/// 2) Soltar:
///        resuelve.
///
/// 3) El límite de tiempo empieza SOLO después de iniciar.
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
    circle_active =
        false;

    exit;
}


var _pressed =
    keyboard_check_pressed(
        ord("Z")
    )
    ||
    keyboard_check_pressed(
        vk_enter
    );


var _held =
    keyboard_check(
        ord("Z")
    )
    ||
    keyboard_check(
        vk_enter
    );


// =========================================================
// EMPEZAR CARGA
// =========================================================

if (
    !circle_started
    &&
    (
        _pressed
        ||
        _held
    )
)
{
    circle_started =
        true;

    circle_timer =
        0;
}


// =========================================================
// CARGANDO
// =========================================================

if (
    circle_started
    &&
    _held
)
{
    circle_timer++;


    circle_radius =
        min(
            circle_radius_max,
            circle_radius
            +
            circle_speed
        );
}


// =========================================================
// SOLTAR
// =========================================================

if (
    circle_started
    &&
    !_held
)
{
    f_resolve_circle();
    exit;
}


// =========================================================
// TIEMPO AGOTADO
// =========================================================

if (
    circle_started
    &&
    circle_timer >= circle_limit
)
{
    f_resolve_circle();
    exit;
}
