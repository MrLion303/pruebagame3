/// =========================================================
/// OBJ_BUTTONS
/// CREATE
/// =========================================================


// =========================================================
// SPRITE DE IDIOMA
// =========================================================

_sprite_spanish =
    sprite_index;


image_index =
    0;


image_speed =
    0;


image_alpha =
    0;


// =========================================================
// LOCALIZACIÓN
// =========================================================

scr_loc_init();


if (scr_language_is_english())
{
    sprite_index =
        spr_buttons_english;
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
// TRANSICIÓN DE NUEVO JUEGO
// =========================================================

newgame_transition_active =
    false;


// 0 = nada
// 1 = cubrir pantalla
// 2 = esperando Room Start
// 3 = descubrir pantalla

newgame_transition_phase =
    0;


newgame_transition_progress =
    0;


newgame_transition_speed =
    0.04;


// =========================================================
// DESTINO
// =========================================================

newgame_room =
    pasillo_school;


newgame_x =
    668;


newgame_y =
    194;