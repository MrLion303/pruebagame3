/// =========================================================
/// OBJ_BUTTONS_CONTINUE
/// DRAW
/// =========================================================
//
// Igual que obj_buttons:
//
// Mientras la transición se está cerrando en el título,
// los botones permanecen visibles.
//
// spr_transition se dibuja encima mediante Draw GUI,
// así que irán siendo cubiertos naturalmente.
// =========================================================

if (
    !newgame_transition_active
    ||
    newgame_transition_phase == 1
)
{
    draw_self();
}