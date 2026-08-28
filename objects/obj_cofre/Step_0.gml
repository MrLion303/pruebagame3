// =========================================================
// OBJ_COFRE
// STEP
// =========================================================


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


var _dist =
    point_distance(
        _px,
        _py,
        _cx,
        _cy
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