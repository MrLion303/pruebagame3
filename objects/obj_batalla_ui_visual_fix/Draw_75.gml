/// =========================================================
/// OBJ_BATALLA_UI_VISUAL_FIX
/// DRAW GUI END COMPLETO
/// =========================================================
///
/// Corrige SOLAMENTE el retrato grande del hablante dentro
/// del cuadro principal de diálogo de batalla.
///
/// NO modifica:
///
///     spr_bbs_prota_head
///     ni su posición al lado del HP.
///
/// Ya no se cambia sprite_set_offset(), por lo que las dos
/// cabezas son completamente independientes.
/// =========================================================


// =========================================================
// COMPATIBILIDAD CON LA VERSIÓN ANTERIOR
// =========================================================

if (
    variable_instance_exists(
        id,
        "restore_pending"
    )
    &&
    restore_pending
)
{
    if (
        variable_instance_exists(
            id,
            "restore_sprite"
        )
        &&
        restore_sprite != -1
        &&
        sprite_exists(
            restore_sprite
        )
    )
    {
        sprite_set_offset(
            restore_sprite,
            restore_xoffset,
            restore_yoffset
        );
    }


    restore_pending =
        false;
}


// =========================================================
// SOLO EN BATALLA
// =========================================================

if (
    room != bbs
    ||
    !instance_exists(
        obj_batalla_ui
    )
)
{
    instance_destroy();
    exit;
}


var _ui =
    instance_find(
        obj_batalla_ui,
        0
    );


if (
    _ui == noone
    ||
    !instance_exists(
        _ui
    )
)
{
    exit;
}


// =========================================================
// ¿HAY RETRATO DE DIÁLOGO ACTIVO?
// =========================================================

var _show_head =
    (
        variable_instance_exists(
            _ui,
            "head_visible"
        )
        &&
        _ui.head_visible
        &&
        variable_instance_exists(
            _ui,
            "head_sprite"
        )
        &&
        _ui.head_sprite != noone
        &&
        _ui.head_sprite != -1
        &&
        sprite_exists(
            _ui.head_sprite
        )
        &&
        variable_instance_exists(
            _ui,
            "text_to_draw"
        )
        &&
        string_length(
            _ui.text_to_draw
        )
        >
        0
        &&
        variable_instance_exists(
            _ui,
            "draw_char"
        )
        &&
        _ui.draw_char > 0
        &&
        (
            !variable_instance_exists(
                _ui,
                "en_seleccion_enemigo"
            )
            ||
            !_ui.en_seleccion_enemigo
        )
        &&
        (
            !variable_instance_exists(
                _ui,
                "en_menu_fight"
            )
            ||
            !_ui.en_menu_fight
        )
        &&
        (
            !variable_instance_exists(
                _ui,
                "en_modo_info"
            )
            ||
            !_ui.en_modo_info
        )
        &&
        (
            !variable_instance_exists(
                _ui,
                "en_menu_inventario"
            )
            ||
            !_ui.en_menu_inventario
        )
        &&
        (
            !variable_instance_exists(
                _ui,
                "en_menu_toys"
            )
            ||
            !_ui.en_menu_toys
        )
    );


if (!_show_head)
{
    exit;
}


// =========================================================
// ALPHA DE LA UI
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
// CUADRO PRINCIPAL
// =========================================================

var _s =
    2;


var _box_left =
    14
    *
    _s;


var _box_top =
    125
    *
    _s;


var _box_height =
    sprite_get_height(
        spr_bbs_textbox
    )
    *
    _s;


var _box_bottom =
    _box_top
    +
    _box_height;


var _box_center_y =
    _box_top
    +
    (_box_height * 0.5);


// =========================================================
// TAPAR SOLAMENTE LA COPIA VIEJA DE LA CABEZA
// =========================================================

var _erase_left =
    _box_left
    +
    4;


var _erase_right =
    (14 + 63)
    *
    _s;


var _erase_top =
    _box_top
    +
    4;


var _erase_bottom =
    _box_bottom
    -
    4;


draw_set_alpha(
    _alpha
);


draw_set_color(
    c_black
);


draw_rectangle(
    _erase_left,
    _erase_top,
    _erase_right,
    _erase_bottom,
    false
);


// =========================================================
// REDIBUJAR EL RETRATO CENTRADO VERTICALMENTE
// =========================================================

var _head =
    _ui.head_sprite;


var _head_scale =
    1.35
    *
    _s;


// =========================================================
// CENTRADO Y UNIVERSAL DEL RETRATO
// =========================================================
//
// Ya NO usamos bbox_top/bbox_bottom porque el bounding box
// puede cambiar entre retratos y depende de los píxeles no
// transparentes / configuración de máscara.
//
// Todos los retratos se centran usando LA ALTURA COMPLETA DEL
// SPRITE y su origen Y.
//
// Matemáticamente:
//
//     centro visual del sprite
//     = draw_y + (alto/2 - yoffset) * escala
//
// Queremos que sea exactamente igual a:
//
//     centro Y del cuadro de diálogo
//
// Por eso cualquier cabeza, tenga el origen que tenga, queda
// centrada en la misma coordenada Y.
// =========================================================

var _head_image_center =
    sprite_get_height(
        _head
    )
    *
    0.5;


var _head_yoffset =
    sprite_get_yoffset(
        _head
    );


var _head_draw_x =
    (14 + 10)
    *
    _s;


var _head_draw_y =
    _box_center_y
    -
    (
        (
            _head_image_center
            -
            _head_yoffset
        )
        *
        _head_scale
    );


draw_sprite_ext(
    _head,
    0,
    _head_draw_x,
    _head_draw_y,
    _head_scale,
    _head_scale,
    0,
    c_white,
    _alpha
);


draw_set_alpha(
    1
);


draw_set_color(
    c_white
);
