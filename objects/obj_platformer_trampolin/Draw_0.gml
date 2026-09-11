/// =========================================================
/// OBJ_PLATFORMER_TRAMPOLIN
/// DRAW
/// =========================================================

if (
    sprite_index != -1
    &&
    sprite_exists(sprite_index)
)
{
    draw_self();
}
else
{
    draw_set_color(
        c_white
    );


    draw_rectangle(
        x - trampoline_half_width,
        y,
        x + trampoline_half_width,
        y + trampoline_height,
        false
    );


    draw_set_color(
        c_white
    );
}
