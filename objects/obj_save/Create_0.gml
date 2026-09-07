/// =========================================================
/// OBJ_SAVE
/// CREATE
/// =========================================================


// =========================================================
// ROOM AUTOMÁTICA
// =========================================================
//
// YA NO EXISTE:
//
//     room_to_save = global.rm1;
//
// No necesitas indicar ninguna habitación.
//
// scr_guardar_juego() guarda directamente:
//
//     room
//
// por lo que el punto guardará automáticamente la room
// en la que se encuentra el jugador al momento de guardar.
// =========================================================


// =========================================================
// DIÁLOGO DEL PUNTO DE GUARDADO
// =========================================================
//
// Creation Code puede sobrescribir esto:
//
//     save_dialogue_id = "escuela";
//
// Si no hay Creation Code, se utiliza:
//
//     "default"
//
// =========================================================

save_dialogue_id =
    "default";


// =========================================================
// ID OPCIONAL DEL "SOLO UNA VEZ"
// =========================================================
//
// SOLO se utiliza para diálogos con:
//
//     repeatable: false
//
// Si está vacío, el sistema genera automáticamente una ID
// única usando:
//
//     room + x + y
//
// Por tanto normalmente NO tienes que escribir nada aquí
// ni en Creation Code.
//
// Si quisieras que dos puntos distintos compartan el mismo
// estado de "ya visto", podrías poner manualmente:
//
//     save_dialogue_once_id = "intro_guardado_escuela";
//
// =========================================================

save_dialogue_once_id =
    "";


// =========================================================
// ESTADO INTERNO
// =========================================================

save_waiting_dialogue =
    false;

save_dialogue_textbox =
    noone;


// =========================================================
// COLISIÓN DEL TAMAÑO DEL SPRITE
// =========================================================
//
// obj_save sigue siendo un objeto independiente, pero crea
// una instancia invisible de `colision` con exactamente su
// mismo sprite/máscara, escala y ángulo.
//
// Así el sistema normal de movimiento del player lo trata
// como obstáculo sin tener que cambiar Parent.
// =========================================================

collision_proxy =
    scr_puzzle_collision_proxy_create(
        id
    );


// Forzar que la máscara física sea exactamente la del sprite
// visible de obj_save, aunque el objeto tuviera un mask_index
// personalizado configurado en el editor.
if (
    collision_proxy != noone
    &&
    instance_exists(collision_proxy)
)
{
    collision_proxy.sprite_index =
        sprite_index;

    collision_proxy.mask_index =
        sprite_index;
}


// =========================================================
// DEPTH SORT
// =========================================================

scr_depth_sort_register(
    id
);
