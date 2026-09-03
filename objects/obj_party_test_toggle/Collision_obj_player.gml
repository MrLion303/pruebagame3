/// =========================================================
/// OBJ_PARTY_TEST_TOGGLE
/// COLLISION WITH obj_player
/// =========================================================
//
// PRIMER TOQUE:
//     spawnea obj_silicio EXACTAMENTE sobre Maya
//     y lo mete a la party.
//
// SEGUNDO TOQUE:
//     lo saca de la party y destruye la instancia.
//
// Usa la Collision Mask REAL del trigger.
// =========================================================


if (trigger_locked)
{
    exit;
}


trigger_locked =
    true;


scr_party_init();


var _p =
    other;


// =========================================================
// YA ESTÁ EN PARTY -> QUITAR Y DESTRUIR
// =========================================================

if (
    scr_party_has(
        target_party_id
    )
)
{
    var _removed =
        scr_party_leave(
            target_party_id,
            true
        );


    if (_removed)
    {
        // Limpiar el recorrido para que la próxima vez
        // Silicio empiece exactamente desde Maya.
        global.party_history =
            [];

        global.party_history_room =
            -1;

        global.party_room_dirty =
            true;


        show_debug_message(
            "[PARTY TEST] SILICIO DESACTIVADO"
        );
    }
    else
    {
        show_debug_message(
            "[PARTY TEST] ERROR AL DESACTIVAR SILICIO"
        );
    }


    exit;
}


// =========================================================
// LIMPIAR CUALQUIER SILICIO SUELTO DE UNA PRUEBA ANTERIOR
// =========================================================

var _old_count =
    instance_number(
        obj_silicio
    );


for (
    var _i = _old_count - 1;
    _i >= 0;
    _i--
)
{
    var _old =
        instance_find(
            obj_silicio,
            _i
        );


    if (
        _old != noone
        &&
        instance_exists(_old)
    )
    {
        instance_destroy(
            _old
        );
    }
}


// =========================================================
// SPAWNEAR EXACTAMENTE DONDE ESTÁ MAYA
// =========================================================

var _silicio =
    noone;


if (
    layer_get_id(
        "Instances"
    )
    !=
    -1
)
{
    _silicio =
        instance_create_layer(
            _p.x,
            _p.y,
            "Instances",
            obj_silicio
        );
}
else
{
    _silicio =
        instance_create_depth(
            _p.x,
            _p.y,
            _p.depth + 1,
            obj_silicio
        );
}


// Seguridad.
if (
    _silicio == noone
    ||
    !instance_exists(
        _silicio
    )
)
{
    show_debug_message(
        "[PARTY TEST] NO SE PUDO CREAR obj_silicio"
    );

    exit;
}


// =========================================================
// CONFIGURAR ID Y UNIR
// =========================================================

_silicio.party_id =
    "silicio";


var _joined =
    scr_party_join_actor(
        _silicio,
        "silicio"
    );


if (!_joined)
{
    instance_destroy(
        _silicio
    );


    show_debug_message(
        "[PARTY TEST] FALLO scr_party_join_actor"
    );

    exit;
}


// =========================================================
// MUY IMPORTANTE:
// COMENZAR UN BUFFER NUEVO EN LA POSICIÓN ACTUAL DE MAYA
// =========================================================
//
// Esto garantiza:
//
//     al activar:
//     Silicio.x == Maya.x
//     Silicio.y == Maya.y
//
// y a partir del siguiente movimiento empieza a reproducir
// las posiciones antiguas.
// =========================================================

global.party_history =
    [];

global.party_history_room =
    -1;

global.party_room_dirty =
    true;


scr_party_seed_history();


// =========================================================
// FORZAR SUPERPOSICIÓN VISUAL REAL
// =========================================================
//
// NO igualamos x/y porque los Origins pueden ser distintos.
// Igualamos el centro de los PIES.
// =========================================================

scr_party_apply_direction(
    _silicio,
    _p.face
);


scr_party_place_feet(
    _silicio,
    scr_party_feet_x(_p),
    scr_party_feet_y(_p)
);


_silicio.image_index =
    0;

_silicio.image_speed =
    0;


show_debug_message(
    "[PARTY TEST] SILICIO SPAWNEADO Y ACTIVADO"
);
