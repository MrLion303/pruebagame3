/// =========================================================
/// OBJ_BATALLA_ATTACK_MODS
/// DRAW GUI - NUEVO
/// =========================================================

if (
    room != bbs
    ||
    !circle_active
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
    exit;
}


var _gw = display_get_gui_width();
var _gh = display_get_gui_height();

var _cx = _gw * 0.5;
var _cy = _gh * 0.70;

var _target_scale = 0.72;


// Diana.
var _dw = sprite_get_width(spr_diana);
var _dh = sprite_get_height(spr_diana);

var _dx =
    _cx
    +
    (
        sprite_get_xoffset(spr_diana)
        -
        (_dw * 0.5)
    )
    *
    _target_scale;

var _dy =
    _cy
    +
    (
        sprite_get_yoffset(spr_diana)
        -
        (_dh * 0.5)
    )
    *
    _target_scale;

draw_set_alpha(1);
draw_set_color(c_white);

draw_sprite_ext(
    spr_diana,
    0,
    _dx,
    _dy,
    _target_scale,
    _target_scale,
    0,
    c_white,
    1
);


// Aro creciente.
// Cuando circle_radius == circle_radius_target, el aro
// coincide visualmente con la diana.
var _ratio =
    max(
        0.01,
        circle_radius
        /
        max(1, circle_radius_target)
    );

var _ring_scale =
    _target_scale * _ratio;

var _rw = sprite_get_width(spr_diana_aro);
var _rh = sprite_get_height(spr_diana_aro);

var _rx =
    _cx
    +
    (
        sprite_get_xoffset(spr_diana_aro)
        -
        (_rw * 0.5)
    )
    *
    _ring_scale;

var _ry =
    _cy
    +
    (
        sprite_get_yoffset(spr_diana_aro)
        -
        (_rh * 0.5)
    )
    *
    _ring_scale;

draw_sprite_ext(
    spr_diana_aro,
    0,
    _rx,
    _ry,
    _ring_scale,
    _ring_scale,
    0,
    c_white,
    1
);


// Pequeña barra de tiempo.
var _time_ratio =
    1
    -
    clamp(
        circle_timer
        /
        max(1, circle_limit),
        0,
        1
    );

var _bar_w = 90;
var _bar_h = 4;
var _bar_x1 = _cx - (_bar_w * 0.5);
var _bar_y1 = _cy + 58;

draw_set_color(c_black);

draw_rectangle(
    _bar_x1 - 1,
    _bar_y1 - 1,
    _bar_x1 + _bar_w + 1,
    _bar_y1 + _bar_h + 1,
    false
);

draw_set_color(c_white);

draw_rectangle(
    _bar_x1,
    _bar_y1,
    _bar_x1 + (_bar_w * _time_ratio),
    _bar_y1 + _bar_h,
    false
);

draw_set_color(c_white);
draw_set_alpha(1);
