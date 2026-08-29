/// =========================================================
/// OBJ_BUTTONS_CONTINUE
/// CREATE
/// =========================================================

_sprite_spanish =
    sprite_index;


image_index =
    0;


image_speed =
    0;


image_alpha =
    0;


// =========================================================
// IDIOMA
// =========================================================

scr_loc_init();


if (scr_language_is_english())
{
    sprite_index =
        spr_buttons_continue_english;
}
else
{
    sprite_index =
        _sprite_spanish;
}


image_index =
    0;


image_speed =
    0;


// =========================================================
// TRANSICIÓN NUEVO JUEGO
// =========================================================

newgame_transition_active =
    false;


newgame_transition_phase =
    0;


newgame_transition_progress =
    0;


newgame_transition_speed =
    0.04;


newgame_room =
    pasillo_school;


newgame_x =
    668;


newgame_y =
    194;