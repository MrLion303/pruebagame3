/// =========================================================
/// OBJ_SIGILO_FX
/// DRAW - NUEVO
/// =========================================================
///
/// Oscurece toda la cámara excepto un círculo alrededor
/// de Maya. Al ser Draw normal, NO oscurece interfaces GUI.
/// =========================================================

if (
    sigilo_anim <= 0
    ||
    !instance_exists(
        obj_player
    )
)
{
    exit;
}


var _cam =
    view_camera[0];


if (_cam == -1)
{
    exit;
}


var _p =
    instance_find(
        obj_player,
        0
    );


if (_p == noone)
{
    exit;
}


// Centro visual aproximado del jugador.
var _cx =
    (
        _p.bbox_left
        +
        _p.bbox_right
    )
    *
    0.5;


var _cy =
    (
        _p.bbox_top
        +
        _p.bbox_bottom
    )
    *
    0.5;


// Cámara.
var _cam_x =
    camera_get_view_x(
        _cam
    );


var _cam_y =
    camera_get_view_y(
        _cam
    );


var _cam_w =
    camera_get_view_width(
        _cam
    );


var _cam_h =
    camera_get_view_height(
        _cam
    );


// Radio exterior suficientemente grande para cubrir cualquier
// esquina visible de la cámara.
var _outer_radius =
    max(
        point_distance(
            _cx,
            _cy,
            _cam_x,
            _cam_y
        ),

        point_distance(
            _cx,
            _cy,
            _cam_x + _cam_w,
            _cam_y
        ),

        point_distance(
            _cx,
            _cy,
            _cam_x,
            _cam_y + _cam_h
        ),

        point_distance(
            _cx,
            _cy,
            _cam_x + _cam_w,
            _cam_y + _cam_h
        )
    )
    +
    64;


var _inner_radius =
    max(
        1,
        sigilo_radio_luz
    );


var _edge_radius =
    _inner_radius
    +
    max(
        1,
        sigilo_borde_suave
    );


var _t =
    clamp(
        sigilo_anim,
        0,
        1
    );


// Smoothstep.
var _ease =
    _t
    *
    _t
    *
    (
        3
        -
        (2 * _t)
    );


var _alpha =
    clamp(
        sigilo_oscuridad
        *
        _ease,
        0,
        1
    );


draw_set_color(
    c_white
);


draw_set_alpha(
    1
);


// =========================================================
// BORDE SUAVE
// =========================================================
//
// En el radio interior alpha = 0.
// 16 px más afuera llega a la oscuridad completa.
// =========================================================

draw_primitive_begin(
    pr_trianglestrip
);


for (
    var _i = 0;
    _i <= sigilo_segmentos;
    _i++
)
{
    var _ang =
        (_i / sigilo_segmentos)
        *
        360;


    var _edge_x =
        _cx
        +
        lengthdir_x(
            _edge_radius,
            _ang
        );


    var _edge_y =
        _cy
        +
        lengthdir_y(
            _edge_radius,
            _ang
        );


    var _inner_x =
        _cx
        +
        lengthdir_x(
            _inner_radius,
            _ang
        );


    var _inner_y =
        _cy
        +
        lengthdir_y(
            _inner_radius,
            _ang
        );


    draw_vertex_color(
        _edge_x,
        _edge_y,
        c_black,
        _alpha
    );


    draw_vertex_color(
        _inner_x,
        _inner_y,
        c_black,
        0
    );
}


draw_primitive_end();


// =========================================================
// RESTO DEL ENTORNO
// =========================================================

draw_primitive_begin(
    pr_trianglestrip
);


for (
    var _j = 0;
    _j <= sigilo_segmentos;
    _j++
)
{
    var _ang2 =
        (_j / sigilo_segmentos)
        *
        360;


    var _outer_x =
        _cx
        +
        lengthdir_x(
            _outer_radius,
            _ang2
        );


    var _outer_y =
        _cy
        +
        lengthdir_y(
            _outer_radius,
            _ang2
        );


    var _edge_x2 =
        _cx
        +
        lengthdir_x(
            _edge_radius,
            _ang2
        );


    var _edge_y2 =
        _cy
        +
        lengthdir_y(
            _edge_radius,
            _ang2
        );


    draw_vertex_color(
        _outer_x,
        _outer_y,
        c_black,
        _alpha
    );


    draw_vertex_color(
        _edge_x2,
        _edge_y2,
        c_black,
        _alpha
    );
}


draw_primitive_end();


draw_set_alpha(
    1
);


draw_set_color(
    c_white
);
