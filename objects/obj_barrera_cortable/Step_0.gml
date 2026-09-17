/// =========================================================
/// OBJ_BARRERA_CORTABLE
/// STEP COMPLETO
/// =========================================================


// =========================================================
// INICIALIZACIÓN DE SEGURIDAD
// =========================================================

if (!barrera_inicializada)
{
    if (
        !scr_tijeras_barrera_init(
            id
        )
    )
    {
        exit;
    }
}


// =========================================================
// MANTENER LA MÁSCARA BASE 20x20
// =========================================================
//
// Aunque sprite_index sea el sprite visual de lianas/cables/
// cuerdas, mask_index siempre conserva el sprite de colisión.
//
// image_xscale / image_yscale también afectan esta máscara,
// por lo que una barrera escalada tiene una colisión escalada.
// =========================================================

if (
    sprite_colision != -1
    &&
    sprite_colision != noone
    &&
    sprite_exists(sprite_colision)
)
{
    mask_index =
        sprite_colision;
}


// =========================================================
// FADE OUT DESPUÉS DEL CORTE
// =========================================================

if (cortando)
{
    image_alpha =
        max(
            0,
            image_alpha - fade_velocidad
        );


    if (image_alpha <= 0)
    {
        instance_destroy();
    }


    exit;
}


// =========================================================
// COLISIÓN REAL INVISIBLE
// =========================================================
//
// El proxy copia la máscara base, posición, escala y ángulo.
// Por eso el sprite visual puede ser completamente distinto sin
// modificar el tamaño real de la barrera.
// =========================================================

if (
    collision_proxy == noone
    ||
    !instance_exists(
        collision_proxy
    )
)
{
    collision_proxy =
        scr_puzzle_collision_proxy_create(
            id
        );
}


scr_puzzle_collision_proxy_sync(
    id,
    collision_proxy
);


// =========================================================
// ¿SE PUEDE INTERACTUAR CON EL MUNDO?
// =========================================================

if (!scr_tijeras_world_interaction_allowed())
{
    exit;
}


if (!instance_exists(obj_player))
{
    exit;
}


// SIEMPRE Z O ENTER.
var _confirm =
    keyboard_check_pressed(ord("Z"))
    ||
    keyboard_check_pressed(vk_enter);


if (!_confirm)
{
    exit;
}


var _player =
    instance_find(
        obj_player,
        0
    );


if (
    _player == noone
    ||
    !instance_exists(_player)
)
{
    exit;
}


var _front_barrier =
    scr_tijeras_find_barrier_in_front(
        _player
    );


// Solo la barrera más cercana realmente situada enfrente de
// Maya consume la interacción.
if (_front_barrier != id)
{
    exit;
}


// =========================================================
// YA TIENES LAS TIJERAS -> CORTAR
// =========================================================
//
// Las Tijeras Jardín son una habilidad PASIVA. No se seleccionan,
// no se usan desde CLAVE y no se consumen.
// =========================================================

if (
    scr_itemclave_tiene(
        "tijeras_jardin"
    )
)
{
    scr_tijeras_barrera_begin_cut(
        id
    );

    exit;
}


// =========================================================
// NO TIENES LAS TIJERAS -> DIÁLOGO PERSONALIZABLE
// =========================================================
//
// El texto se elige en Creation Code con:
//
//     dialogo_sin_tijeras = "olvido_importante";
//
// o cualquiera de los IDs de scr_notijeras_dialogos.
// =========================================================

scr_notijeras_dialogos(
    dialogo_sin_tijeras,
    tipo_barrera
);
