/// =========================================================
/// OBJ_BATALLA_ATTACK_MODS
/// DRAW GUI COMPLETO
/// =========================================================
///
/// 1) Dibuja la barra horizontalmente ensanchada de armas
///    como Espada Certera.
///
/// 2) Dibuja el ataque circular SIEMPRE encima de la UI.
/// =========================================================

if (room != bbs)
    exit;


if (!f_refresh_refs())
    exit;


var _ui =
    ui_ref;


var _s =
    2;


// =========================================================
// ALPHA DE LA UI DE BATALLA
// =========================================================

var _alpha =
    1;


if (
    variable_instance_exists(
        _ui,
        "alpha_aparicion"
    )
)
{
    _alpha *=
        _ui.alpha_aparicion;
}


if (
    variable_instance_exists(
        _ui,
        "alpha_salida"
    )
)
{
    _alpha *=
        _ui.alpha_salida;
}


if (instance_exists(obj_transicion_bbs))
{
    _alpha *=
        obj_transicion_bbs.image_alpha;
}


_alpha =
    clamp(
        _alpha,
        0,
        1
    );


// =========================================================
// BARRA ENSANCHADA - ESPADA CERTERA
// =========================================================
//
// obj_batalla_ui sigue dibujando su barra normal.
//
// Encima dibujamos exactamente el MISMO frame y posición,
// pero estirado solo en X.
//
// Como coincide píxel a píxel en el centro, visualmente se ve
// como una única barra más ancha.
// =========================================================

if (
    current_mode == "lineal"
    &&
    current_bar_xscale > 1.0001
    &&
    (
        _ui.attack_timing_active
        ||
        _ui.attack_timing_stopped
    )
)
{
    var _attack_box_top =
        125
        *
        _s;


    var _attack_box_h =
        sprite_get_height(
            spr_bbs_textbox
        )
        *
        _s;


    var _attack_center_y =
        _attack_box_top
        +
        (_attack_box_h * 0.5);


    var _bar_scale_y =
        _ui.attack_bar_scale_base
        *
        _s;


    var _bar_scale_x =
        _bar_scale_y
        *
        current_bar_xscale;


    var _bar_center_x =
        _ui.attack_bar_x
        *
        _s;


    var _bar_draw_x =
        _bar_center_x
        +
        (
            sprite_get_xoffset(
                spr_barra_bbs
            )
            -
            (
                sprite_get_width(
                    spr_barra_bbs
                )
                *
                0.5
            )
        )
        *
        _bar_scale_x;


    var _bar_draw_y =
        _attack_center_y
        +
        (
            sprite_get_yoffset(
                spr_barra_bbs
            )
            -
            (
                sprite_get_height(
                    spr_barra_bbs
                )
                *
                0.5
            )
        )
        *
        _bar_scale_y;


    var _bar_frame =
        clamp(
            floor(
                _ui.attack_bar_anim_index
            ),
            0,
            sprite_get_number(
                spr_barra_bbs
            )
            -
            1
        );


    draw_sprite_ext(
        spr_barra_bbs,
        _bar_frame,
        _bar_draw_x,
        _bar_draw_y,
        _bar_scale_x,
        _bar_scale_y,
        0,
        c_white,
        _alpha
    );
}


// =========================================================
// ATAQUE CIRCULAR
// =========================================================

if (!circle_active)
{
    draw_set_alpha(1);
    draw_set_color(c_white);
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
        draw_set_font(global.font_main);

    draw_text_color(
        320,
        301,
        "Falta spr_diana o spr_diana_aro",
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
// CENTRO EXACTO DEL TEXTBOX DE ATAQUE
// =========================================================
//
// Caja:
//     X = 14 * 2
//     Y = 125 * 2
//     ancho = 51 * 5.666667 * 2
//     alto  = 51 * 2
//
// La diana queda centrada DENTRO de esa caja.
// =========================================================

var _box_left =
    14
    *
    _s;


var _box_top =
    125
    *
    _s;


var _box_w =
    sprite_get_width(
        spr_bbs_textbox
    )
    *
    5.666667
    *
    _s;


var _box_h =
    sprite_get_height(
        spr_bbs_textbox
    )
    *
    _s;


var _cx =
    _box_left
    +
    (_box_w * 0.5);


var _cy =
    _box_top
    +
    (_box_h * 0.5);


// 128 * 0.60 = 76.8 px.
// Cabe de sobra dentro del textbox de 102 px de alto.
var _target_scale =
    0.60;


// =========================================================
// DIANA FIJA
// =========================================================

var _dw =
    sprite_get_width(
        spr_diana
    );


var _dh =
    sprite_get_height(
        spr_diana
    );


var _dx =
    _cx
    +
    (
        sprite_get_xoffset(
            spr_diana
        )
        -
        (_dw * 0.5)
    )
    *
    _target_scale;


var _dy =
    _cy
    +
    (
        sprite_get_yoffset(
            spr_diana
        )
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
    _alpha
);


// =========================================================
// ARO CARGABLE
// =========================================================
//
// Cuando circle_radius == circle_radius_target,
// el aro coincide exactamente con la diana.
// =========================================================

var _ratio =
    max(
        0.01,
        circle_radius
        /
        max(
            1,
            circle_radius_target
        )
    );


var _ring_scale =
    _target_scale
    *
    _ratio;


var _rw =
    sprite_get_width(
        spr_diana_aro
    );


var _rh =
    sprite_get_height(
        spr_diana_aro
    );


var _rx =
    _cx
    +
    (
        sprite_get_xoffset(
            spr_diana_aro
        )
        -
        (_rw * 0.5)
    )
    *
    _ring_scale;


var _ry =
    _cy
    +
    (
        sprite_get_yoffset(
            spr_diana_aro
        )
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
    _alpha
);


// =========================================================
// INDICADOR DE TIEMPO
// =========================================================
//
// Antes de empezar a cargar no corre ningún tiempo.
// =========================================================

var _time_ratio =
    1;


if (circle_started)
{
    _time_ratio =
        1
        -
        clamp(
            circle_timer
            /
            max(
                1,
                circle_limit
            ),
            0,
            1
        );
}


var _bar_w =
    90;


var _bar_h =
    4;


var _bar_x1 =
    _cx
    -
    (_bar_w * 0.5);


var _bar_y1 =
    _box_top
    +
    _box_h
    -
    8;


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
    _bar_x1
    +
    (_bar_w * _time_ratio),
    _bar_y1
    +
    _bar_h,
    false
);


draw_set_color(c_white);
draw_set_alpha(1);
