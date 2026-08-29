/// =========================================================
/// OBJ_BUTTONS
/// DRAW
/// =========================================================
//
// Queremos que los botones sigan viéndose mientras
// spr_transition se cierra sobre el menú.
//
// FASE 1 = seguimos en el título y la transición
//          todavía está cubriendo la pantalla.
//
// Después del cambio de habitación ya no dibujamos
// los botones.
// =========================================================

if (
    !newgame_transition_active
    ||
    newgame_transition_phase == 1
)
{
    draw_self();
}