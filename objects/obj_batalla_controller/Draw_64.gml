/// =========================================================
/// OBJ_BATALLA_CONTROLLER
/// DRAW GUI
/// =========================================================
///
/// Dibuja directamente el parry junto al enemigo atacante.
///
/// spr_diana:
///     diana fija de 128x128.
///
/// spr_diana_aro:
///     se usa para dibujar DOS aros de 128x128 que se
///     encogen simultáneamente hacia el centro.
///
/// La diana:
/// - siempre aparece a la IZQUIERDA del enemigo;
/// - usa un tamaño final menor que antes;
/// - entra creciendo desde casi cero;
/// - sale encogiéndose hasta desaparecer.
///
/// PARRY VÁLIDO:
///     hay que acertar LOS DOS aros.
///     Cada uno cuenta con radio > 1 px y <= 14 px.
///
/// El centro mide 2x2. En cuanto el aro llega a un radio
/// de 1 px o menos, ya está tocando ese centro y falla.
/// =========================================================

if (!parry_waiting)
{
    exit;
}


// =========================================================
// SEGURIDAD
// =========================================================

if (
    parry_pending_enemy_idx < 0
    ||
    parry_pending_enemy_idx >= array_length(enemigos)
)
{
    exit;
}


if (
    !sprite_exists(spr_diana)
    ||
    !sprite_exists(spr_diana_aro)
)
{
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);

    if (variable_global_exists("font_main"))
    {
        draw_set_font(global.font_main);
    }

    draw_text_color(
        display_get_gui_width() * 0.5,
        display_get_gui_height() * 0.5,
        "PARRY: falta spr_diana o spr_diana_aro",
        c_red,
        c_red,
        c_red,
        c_red,
        1
    );

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    exit;
}


// =========================================================
// MISMA DISTRIBUCIÓN DE ENEMIGOS QUE OBJ_BATALLA_UI
// =========================================================

var _s = 2;
var _gw = display_get_gui_width();
var _gh = display_get_gui_height();

var _total = array_length(enemigos);
var _idx = parry_pending_enemy_idx;
var _enemy = enemigos[_idx];

var _screen_center_x = (320 * _s) * 0.5;
var _enemy_x = _screen_center_x;
var _enemy_y = 75 * _s;


if (_total == 2)
{
    if (_idx == 0)
    {
        _enemy_x = _screen_center_x - (50 * _s);
    }
    else if (_idx == 1)
    {
        _enemy_x = _screen_center_x + (50 * _s);
    }
}
else if (_total >= 3)
{
    if (_idx == 0)
    {
        _enemy_x = _screen_center_x - (75 * _s);
    }
    else if (_idx == 1)
    {
        _enemy_x = _screen_center_x;
    }
    else if (_idx == 2)
    {
        _enemy_x = _screen_center_x + (75 * _s);
    }
}


// =========================================================
// TAMAÑO DEL ENEMIGO
// =========================================================

var _enemy_scale =
    variable_struct_exists(_enemy, "escala_sprite")
    ?
    _enemy.escala_sprite
    :
    2.0;


var _enemy_half_w = 0;

if (
    variable_struct_exists(_enemy, "sprite")
    &&
    sprite_exists(_enemy.sprite)
)
{
    _enemy_half_w =
        sprite_get_width(_enemy.sprite)
        *
        _enemy_scale
        *
        _s
        *
        0.5;
}


// =========================================================
// ESCALA ANIMADA DE LA DIANA
// =========================================================
//
// parry_diana_final_scale = 0.60:
//     la diana final mide 76.8x76.8 px.
//
// parry_visual_factor:
//     0.08 -> 1 durante entrada.
//     1 -> 0 durante salida.
// =========================================================

var _visual_factor =
    clamp(
        parry_visual_factor,
        0,
        1
    );


var _diana_scale =
    parry_diana_final_scale
    *
    _visual_factor;


// =========================================================
// POSICIÓN: SIEMPRE A LA IZQUIERDA DEL ENEMIGO
// =========================================================
//
// La posición del CENTRO se calcula usando el tamaño FINAL.
// Así la diana crece sobre el mismo punto y no se desliza
// mientras hace la animación de aparición.
// =========================================================

var _diana_final_half =
    64
    *
    parry_diana_final_scale;


var _gap = 8 * _s;
var _margin = 6 * _s;


var _diana_x =
    _enemy_x
    -
    _enemy_half_w
    -
    _gap
    -
    _diana_final_half;


// Se mantiene a la izquierda. Solo limitamos el borde para
// que no desaparezca fuera del GUI.
_diana_x =
    max(
        _margin + _diana_final_half,
        _diana_x
    );


var _diana_y =
    clamp(
        _enemy_y,
        _margin + _diana_final_half,
        _gh - _margin - _diana_final_half
    );


// =========================================================
// DIBUJAR DIANA
// =========================================================
//
// Compensamos el origin para que el centro visual quede
// exactamente en _diana_x / _diana_y aunque el sprite no
// tenga el origin configurado en 64,64.
// =========================================================

var _dw = sprite_get_width(spr_diana);
var _dh = sprite_get_height(spr_diana);


var _diana_draw_x =
    _diana_x
    +
    (
        sprite_get_xoffset(spr_diana)
        -
        (_dw * 0.5)
    )
    *
    _diana_scale;


var _diana_draw_y =
    _diana_y
    +
    (
        sprite_get_yoffset(spr_diana)
        -
        (_dh * 0.5)
    )
    *
    _diana_scale;


draw_set_alpha(1);
draw_set_color(c_white);


draw_sprite_ext(
    spr_diana,
    0,
    _diana_draw_x,
    _diana_draw_y,
    _diana_scale,
    _diana_scale,
    0,
    c_white,
    1
);


// =========================================================
// DIBUJAR LOS DOS AROS
// =========================================================
//
// Aro 1:
//     empieza en radio 64.
//
// Aro 2:
//     empieza más afuera, en radio 88.
//
// Ambos se encogen al mismo tiempo. Al acertar un aro deja
// de dibujarse. Hay que acertar los dos para bloquear daño.
// =========================================================

var _rw = sprite_get_width(spr_diana_aro);
var _rh = sprite_get_height(spr_diana_aro);


// ---------------------------------------------------------
// ARO 2 - SE DIBUJA PRIMERO POR SER EL EXTERIOR
// ---------------------------------------------------------

if (!parry_ring_2_hit)
{
    var _ring_2_ratio =
        max(
            0,
            parry_ring_2_radius_px
            /
            parry_ring_source_radius_px
        );


    var _ring_2_scale =
        parry_diana_final_scale
        *
        _visual_factor
        *
        _ring_2_ratio;


    var _ring_2_draw_x =
        _diana_x
        +
        (
            sprite_get_xoffset(spr_diana_aro)
            -
            (_rw * 0.5)
        )
        *
        _ring_2_scale;


    var _ring_2_draw_y =
        _diana_y
        +
        (
            sprite_get_yoffset(spr_diana_aro)
            -
            (_rh * 0.5)
        )
        *
        _ring_2_scale;


    draw_sprite_ext(
        spr_diana_aro,
        0,
        _ring_2_draw_x,
        _ring_2_draw_y,
        _ring_2_scale,
        _ring_2_scale,
        0,
        c_white,
        1
    );
}


// ---------------------------------------------------------
// ARO 1 - EL PRIMERO QUE HAY QUE ACERTAR
// ---------------------------------------------------------

if (!parry_ring_1_hit)
{
    var _ring_1_ratio =
        max(
            0,
            parry_ring_1_radius_px
            /
            parry_ring_source_radius_px
        );


    var _ring_1_scale =
        parry_diana_final_scale
        *
        _visual_factor
        *
        _ring_1_ratio;


    var _ring_1_draw_x =
        _diana_x
        +
        (
            sprite_get_xoffset(spr_diana_aro)
            -
            (_rw * 0.5)
        )
        *
        _ring_1_scale;


    var _ring_1_draw_y =
        _diana_y
        +
        (
            sprite_get_yoffset(spr_diana_aro)
            -
            (_rh * 0.5)
        )
        *
        _ring_1_scale;


    draw_sprite_ext(
        spr_diana_aro,
        0,
        _ring_1_draw_x,
        _ring_1_draw_y,
        _ring_1_scale,
        _ring_1_scale,
        0,
        c_white,
        1
    );
}


draw_set_alpha(1);
draw_set_color(c_white);
