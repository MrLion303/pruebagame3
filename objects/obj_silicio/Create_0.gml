/// =========================================================
/// OBJ_SILICIO
/// CREATE
/// =========================================================

party_id =
    "silicio";

character_name =
    "Silicio";


// =========================================================
// SPRITES - CAMINATA 0..3; ABAJO TIENE FRAME 4 ESPECIAL
// =========================================================

party_sprite_down =
    spr_silicio_abajo;

party_sprite_up =
    spr_silicio_arriba;

party_sprite_right =
    spr_silicio_derecha;

party_sprite_left =
    spr_silicio_izquierda;


// =========================================================
// SPRITES PARA CINEMÁTICAS
// =========================================================
//
// Permite que:
//     cs_move_to("silicio", ...)
// cambie automáticamente su dirección y conserve animación.
// =========================================================

cutscene_sprite_down =
    spr_silicio_abajo;

cutscene_sprite_up =
    spr_silicio_arriba;

cutscene_sprite_right =
    spr_silicio_derecha;

cutscene_sprite_left =
    spr_silicio_izquierda;


// Animación manual del party system.
party_walk_anim_speed =
    0.22;

party_anim_accum =
    0;


// Mantener unos frames la caminata cuando recibe
// movimientos muy cortos / intermitentes.
party_anim_hold =
    0;

party_anim_hold_max =
    6;

party_anim_was_moving =
    false;


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



// =========================================================
// TERRENOS ESPECIALES - PARTY
// =========================================================
//
// spr_silicio_abajo:
//
//     frames 0..3 = caminar normal
//     frame 4     = deslizamiento hacia abajo EXCLUSIVO
// =========================================================

party_ice_tap_timer =
    0;

party_ice_tap_duration =
    4;

party_ice_tap_frame =
    0;
