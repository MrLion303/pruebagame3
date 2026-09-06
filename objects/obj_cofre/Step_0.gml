
// =========================================================
// OBJ_COFRE
// STEP
// =========================================================


// =========================================================
// SINCRONIZAR PROXY DE COLISIÓN
// =========================================================

if (
    variable_instance_exists(
        id,
        "cofre_collision_proxy"
    )
    &&
    cofre_collision_proxy != noone
    &&
    instance_exists(cofre_collision_proxy)
)
{
    cofre_collision_proxy.x =
        x;

    cofre_collision_proxy.y =
        y;

    cofre_collision_proxy.sprite_index =
        sprite_index;

    cofre_collision_proxy.mask_index =
        sprite_index;

    cofre_collision_proxy.image_index =
        image_index;

    cofre_collision_proxy.image_xscale =
        image_xscale;

    cofre_collision_proxy.image_yscale =
        image_yscale;

    cofre_collision_proxy.image_angle =
        image_angle;

    cofre_collision_proxy.visible =
        false;
}


// Ya hay un cofre abierto.
if (instance_exists(obj_cofre_ui))
{
    exit;
}


// No hay jugador.
if (!instance_exists(obj_player))
{
    exit;
}


// Menú de guardado abierto.
if (instance_exists(obj_save_menu))
{
    exit;
}


// Textbox abierto.
if (instance_exists(obj_textbox))
{
    exit;
}


// Menú de pausa abierto.
if (instance_exists(obj_menu_manager))
{
    if (
        obj_menu_manager.state
        !=
        MENU_STATE.CLOSED
    )
    {
        exit;
    }
}


// =========================================================
// CONFIRMAR
// =========================================================

var _confirm =
    keyboard_check_pressed(ord("Z"))
    ||
    keyboard_check_pressed(vk_enter);


if (!_confirm)
{
    exit;
}


// =========================================================
// JUGADOR
// =========================================================

var _p =
    instance_find(
        obj_player,
        0
    );


// Centro del jugador.
var _px =
    (_p.bbox_left + _p.bbox_right)
    *
    0.5;

var _py =
    (_p.bbox_top + _p.bbox_bottom)
    *
    0.5;


// Centro del cofre.
var _cx =
    (bbox_left + bbox_right)
    *
    0.5;

var _cy =
    (bbox_top + bbox_bottom)
    *
    0.5;


var _dx =
    _cx - _px;

var _dy =
    _cy - _py;


// Distancia real hasta el BORDE del sprite del cofre.
//
// Como ahora el cofre sí bloquea físicamente, medir de
// centro a centro podría impedir abrir sprites grandes.
// Usamos el punto más cercano de su bbox para conservar la
// distancia de interacción de 20 px independientemente del
// tamaño visual del cofre.
var _nearest_chest_x =
    clamp(
        _px,
        bbox_left,
        bbox_right
    );

var _nearest_chest_y =
    clamp(
        _py,
        bbox_top,
        bbox_bottom
    );


var _dist =
    point_distance(
        _px,
        _py,
        _nearest_chest_x,
        _nearest_chest_y
    );


if (_dist > interaccion_distancia)
{
    exit;
}


// =========================================================
// COMPROBAR QUE LO ESTÁ MIRANDO
//
// 0 derecha
// 1 izquierda
// 2 abajo
// 3 arriba
// =========================================================

var _mirando =
    false;


switch (_p.facing_direction)
{
    case 0:

        _mirando =
            (
                _dx > 0
                &&
                abs(_dy)
                <=
                interaccion_tolerancia
            );

        break;


    case 1:

        _mirando =
            (
                _dx < 0
                &&
                abs(_dy)
                <=
                interaccion_tolerancia
            );

        break;


    case 2:

        _mirando =
            (
                _dy > 0
                &&
                abs(_dx)
                <=
                interaccion_tolerancia
            );

        break;


    case 3:

        _mirando =
            (
                _dy < 0
                &&
                abs(_dx)
                <=
                interaccion_tolerancia
            );

        break;
}


if (!_mirando)
{
    exit;
}


// =========================================================
// ABRIR
// =========================================================

_p.puede_moverse =
    false;


audio_play_sound(
    snd_menumove,
    10,
    false
);


instance_create_depth(
    0,
    0,
    -99999,
    obj_cofre_ui
);
