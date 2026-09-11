/// =========================================================
/// OBJ_PLATFORMER_WARP
/// CREATE
/// =========================================================
///
/// ENTRADA:
///     platformer_enable = true
///     Z / Enter.
///
/// SALIDA:
///     platformer_enable = false
///     golpe melee.
/// =========================================================

target_room =
    noone;


target_x =
    0;


target_y =
    0;


target_face =
    DOWN;


target_music =
    -1;


keep_music =
    false;


// true = entrar.
// false = salir.
platformer_enable =
    true;


// 1 derecha.
// -1 izquierda.
platformer_start_facing =
    1;


active =
    true;


// Solo para la entrada con Z / Enter.
interaction_distance =
    48;


interaction_locked =
    false;


// Fallback de hitbox para poder golpear un trigger sin sprite.
attack_hitbox_half_width =
    16;


attack_hitbox_half_height =
    24;
