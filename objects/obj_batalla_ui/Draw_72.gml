/// =========================================================
/// OBJ_BATALLA_UI
/// DRAW BEGIN - COMPLETO
/// =========================================================
///
/// 1) Evita el crash por enemigos sin anim_index.
/// 2) Centra verticalmente el retrato del hablante en el
///    textbox de batalla.
///
/// Para el punto 2 se usa el objeto auxiliar:
///
///     obj_batalla_ui_visual_fix
///
/// Ese objeto restaura el origen original del sprite en
/// Draw GUI End, así el cambio SOLO afecta al dibujo de la
/// batalla y no a los diálogos normales.
/// =========================================================


// =========================================================
// BLINDAJE DE DATOS DE ENEMIGOS
// =========================================================

if (
    variable_instance_exists(
        id,
        "enemigos"
    )
    &&
    is_array(
        enemigos
    )
)
{
    var _enemy_count =
        array_length(
            enemigos
        );


    for (
        var _enemy_i = 0;
        _enemy_i < _enemy_count;
        _enemy_i++
    )
    {
        var _enemy_data =
            enemigos[
                _enemy_i
            ];


        if (!is_struct(_enemy_data))
        {
            continue;
        }


        if (
            !variable_struct_exists(
                _enemy_data,
                "anim_index"
            )
        )
        {
            variable_struct_set(
                _enemy_data,
                "anim_index",
                0
            );
        }


        if (
            !variable_struct_exists(
                _enemy_data,
                "shake_timer"
            )
        )
        {
            variable_struct_set(
                _enemy_data,
                "shake_timer",
                0
            );
        }


        if (
            !variable_struct_exists(
                _enemy_data,
                "derrotado"
            )
        )
        {
            variable_struct_set(
                _enemy_data,
                "derrotado",
                false
            );
        }


        enemigos[
            _enemy_i
        ] =
            _enemy_data;
    }
}


// =========================================================
// OBJETO AUXILIAR PARA RESTAURAR EL ORIGEN DEL RETRATO
// =========================================================

var _head_fix_obj =
    asset_get_index(
        "obj_batalla_ui_visual_fix"
    );


var _head_fix =
    noone;


if (_head_fix_obj != -1)
{
    if (
        instance_number(
            _head_fix_obj
        )
        <=
        0
    )
    {
        // Se crea en este frame, pero NO modificamos todavía
        // ningún sprite. A partir del siguiente frame el
        // restaurador ya existe con seguridad.
        instance_create_depth(
            0,
            0,
            -100000000,
            _head_fix_obj
        );
    }
    else
    {
        _head_fix =
            instance_find(
                _head_fix_obj,
                0
            );
    }
}


// =========================================================
// CENTRAR RETRATO DE BATALLA EN Y
// =========================================================
//
// El Draw GUI original usa:
//
//     X = (14 + 10) * 2
//     Y = (125 + 10) * 2
//     escala = 1.35 * 2
//
// En vez de reemplazar el enorme Draw GUI principal,
// ajustamos TEMPORALMENTE el origen Y del sprite para que el
// centro de su bounding box coincida con el centro del
// textbox. El helper restaura el origen al acabar el GUI.
// =========================================================

var _battle_head_visible =
    (
        room == bbs
        &&
        _head_fix != noone
        &&
        instance_exists(
            _head_fix
        )
        &&
        variable_instance_exists(
            id,
            "head_visible"
        )
        &&
        head_visible
        &&
        variable_instance_exists(
            id,
            "head_sprite"
        )
        &&
        head_sprite != noone
        &&
        head_sprite != -1
        &&
        sprite_exists(
            head_sprite
        )
        &&
        variable_instance_exists(
            id,
            "text_to_draw"
        )
        &&
        string_length(
            text_to_draw
        )
        >
        0
        &&
        variable_instance_exists(
            id,
            "draw_char"
        )
        &&
        draw_char
        >
        0
        &&
        (
            !variable_instance_exists(
                id,
                "en_seleccion_enemigo"
            )
            ||
            !en_seleccion_enemigo
        )
        &&
        (
            !variable_instance_exists(
                id,
                "en_menu_fight"
            )
            ||
            !en_menu_fight
        )
        &&
        (
            !variable_instance_exists(
                id,
                "en_modo_info"
            )
            ||
            !en_modo_info
        )
        &&
        (
            !variable_instance_exists(
                id,
                "en_menu_inventario"
            )
            ||
            !en_menu_inventario
        )
        &&
        (
            !variable_instance_exists(
                id,
                "en_menu_toys"
            )
            ||
            !en_menu_toys
        )
    );


if (_battle_head_visible)
{
    // Por seguridad, si quedó una restauración pendiente de
    // un frame anterior, restaurarla antes de guardar datos
    // nuevos.
    if (
        variable_instance_exists(
            _head_fix,
            "restore_pending"
        )
        &&
        _head_fix.restore_pending
        &&
        variable_instance_exists(
            _head_fix,
            "restore_sprite"
        )
        &&
        _head_fix.restore_sprite != -1
        &&
        sprite_exists(
            _head_fix.restore_sprite
        )
    )
    {
        sprite_set_offset(
            _head_fix.restore_sprite,
            _head_fix.restore_xoffset,
            _head_fix.restore_yoffset
        );


        _head_fix.restore_pending =
            false;
    }


    var _head =
        head_sprite;


    var _original_xoffset =
        sprite_get_xoffset(
            _head
        );


    var _original_yoffset =
        sprite_get_yoffset(
            _head
        );


    var _s =
        2;


    var _textbox_top =
        125
        *
        _s;


    var _textbox_height =
        sprite_get_height(
            spr_bbs_textbox
        )
        *
        _s;


    var _textbox_center_y =
        _textbox_top
        +
        (_textbox_height * 0.5);


    var _head_draw_y =
        (125 + 10)
        *
        _s;


    var _head_scale =
        1.35
        *
        _s;


    var _head_bbox_center =
        (
            sprite_get_bbox_top(
                _head
            )
            +
            sprite_get_bbox_bottom(
                _head
            )
        )
        *
        0.5;


    // Queremos:
    //
    // draw_y
    // + (bbox_center - nuevo_origen_y) * escala
    // = centro_del_textbox
    var _new_yoffset =
        _head_bbox_center
        -
        (
            (
                _textbox_center_y
                -
                _head_draw_y
            )
            /
            _head_scale
        );


    _new_yoffset =
        round(
            _new_yoffset
        );


    // Guardar los datos ORIGINALES en el helper.
    _head_fix.restore_pending =
        true;


    _head_fix.restore_sprite =
        _head;


    _head_fix.restore_xoffset =
        _original_xoffset;


    _head_fix.restore_yoffset =
        _original_yoffset;


    // Modificar únicamente para el Draw GUI de este frame.
    sprite_set_offset(
        _head,
        _original_xoffset,
        _new_yoffset
    );
}
