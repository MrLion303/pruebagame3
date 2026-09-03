/// =========================================================
/// OBJ_SILICIO
/// CREATE
/// =========================================================

party_id =
    "silicio";

character_name =
    "Silicio";


// =========================================================
// SPRITES - TODOS DE 4 FRAMES
// =========================================================

party_sprite_down =
    spr_silicio_abajo;

party_sprite_up =
    spr_silicio_arriba;

party_sprite_right =
    spr_silicio_derecha;

party_sprite_left =
    spr_silicio_izquierda;


// Animación manual del party system.
party_walk_anim_speed =
    0.22;

party_anim_accum =
    0;


// =========================================================
// ESTADO INICIAL
// =========================================================

face =
    DOWN;

facing_direction =
    2;

direccion =
    "abajo";

movimiento =
    false;


sprite_index =
    spr_silicio_abajo;

image_index =
    0;

// La animación la maneja manualmente scr_party_system.
image_speed =
    0;


// =========================================================
// PARTY
// =========================================================

party_member =
    false;

party_follow_suspended =
    false;

party_rejoin =
    false;

party_hidden_by_system =
    false;


// =========================================================
// NPC
// =========================================================

text_id =
    "silicio";
