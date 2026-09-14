/// =========================================================
/// OBJ_BATALLA_UI
/// DRAW GUI END - NUEVO
/// =========================================================
///
/// CREA ESTE EVENTO:
///
///     Draw -> Draw GUI End
///
/// Se ejecuta DESPUÉS del Draw GUI normal de la batalla.
///
/// Aquí viven:
///
///     - Espada Certera
///     - Multi-barras
///     - Aro Cargado
///
/// =========================================================

if (room != bbs)
{
    exit;
}


var _mods =
    instance_exists(
        obj_batalla_attack_mods
    )
    ?
    instance_find(
        obj_batalla_attack_mods,
        0
    )
    :
    noone;


// =========================================================
// ALPHA DE LA BATALLA
// =========================================================

var _alpha_final =
    1;


if (
    variable_instance_exists(
        id,
        "alpha_aparicion"
    )
)
{
    _alpha_final *=
        alpha_aparicion;
}


if (
    variable_instance_exists(
        id,
        "alpha_salida"
    )
)
{
    _alpha_final *=
        alpha_salida;
}


if (instance_exists(obj_transicion_bbs))
{
    _alpha_final *=
        obj_transicion_bbs.image_alpha;
}


_alpha_final =
    clamp(
        _alpha_final,
        0,
        1
    );


var _s =
    2;


// =========================================================
// BOTONES PRINCIPALES - FRAMES CORREGIDOS
// =========================================================
//
// Frame 0:
//     normal / ya elegiste una acción.
//
// Frame 1:
//     SOLO mientras estás decidiendo en el menú principal y
//     ese botón es el seleccionado.
//
// Frame 2:
//     ITEM o TOY sin ningún recurso disponible.
//
// Draw GUI normal todavía dibuja sus botones. Los redibujamos
// aquí al final para imponer el frame correcto sin tener que
// reemplazar el enorme Draw GUI principal.
// =========================================================

var _has_item =
    false;


if (
    instance_exists(obj_player)
    &&
    variable_instance_exists(
        obj_player,
        "inventory"
    )
)
{
    for (
        var _bi = 0;
        _bi < array_length(
            obj_player.inventory
        );
        _bi++
    )
    {
        var _bk =
            obj_player.inventory[_bi];


        if (
            _bk != -1
            &&
            _bk != undefined
            &&
            variable_global_exists(
                "item_db"
            )
        )
        {
            var _bd =
                global.item_db[$ _bk];


            if (
                _bd != undefined
                &&
                (
                    !variable_struct_exists(
                        _bd,
                        "tipo"
                    )
                    ||
                    _bd.tipo == "consumible"
                )
            )
            {
                _has_item =
                    true;

                break;
            }
        }
    }
}


var _has_toy =
    false;


if (
    variable_global_exists(
        "toy_inventory"
    )
    &&
    is_array(
        global.toy_inventory
    )
)
{
    for (
        var _bt = 0;
        _bt < array_length(
            global.toy_inventory
        );
        _bt++
    )
    {
        var _tk =
            global.toy_inventory[_bt];


        if (
            _tk != -1
            &&
            _tk != undefined
            &&
            variable_global_exists(
                "toy_db"
            )
            &&
            global.toy_db[$ _tk]
            !=
            undefined
        )
        {
            _has_toy =
                true;

            break;
        }
    }
}


var _main_action_deciding =
    (
        !en_menu_fight
        &&
        !en_seleccion_enemigo
        &&
        !en_menu_inventario
        &&
        !en_menu_toys
        &&
        (
            !variable_instance_exists(
                id,
                "en_resultado_ataque"
            )
            ||
            !en_resultado_ataque
        )
        &&
        !attack_timing_active
        &&
        !attack_timing_stopped
        &&
        !attack_feedback_active
    );


if (instance_exists(obj_batalla_controller))
{
    _main_action_deciding =
        _main_action_deciding
        &&
        obj_batalla_controller.fase_actual
        ==
        FASE_BATALLA.JUGADOR_MENU;
}


var _victory_keep_selected =
    variable_instance_exists(
        id,
        "en_dialogo_victoria_final"
    )
    &&
    en_dialogo_victoria_final
    &&
    _mods != noone
    &&
    instance_exists(
        _mods
    );


var _button_selected_for_draw =
    _victory_keep_selected
    ?
    clamp(
        _mods.last_action_button,
        0,
        3
    )
    :
    opcion_seleccionada;


var _btn_scale =
    1.310613
    *
    _s;


var _btn_x =
    [
        132.371,
        177.0,
        221.0769,
        265.0
    ];


for (
    var _b = 0;
    _b < 4;
    _b++
)
{
    var _spr_btn =
        opciones[_b];


    var _btn_frame =
        0;


    var _btn_blend =
        c_white;


    var _disabled =
        (
            _b == 1
            &&
            !_has_item
        )
        ||
        (
            _b == 2
            &&
            !_has_toy
        );


    // Durante el diálogo final de XP/SO conservamos el frame 1
    // del ÚLTIMO botón utilizado, aunque Item/Toy se hayan vaciado.
    if (
        _victory_keep_selected
        &&
        _button_selected_for_draw
        ==
        _b
    )
    {
        _btn_frame =
            1;
    }
    else if (_disabled)
    {
        // Frame 2 = gris/deshabilitado cuando el sprite ya tiene
        // el tercer frame añadido por el usuario.
        if (
            sprite_get_number(
                _spr_btn
            )
            >=
            3
        )
        {
            _btn_frame =
                2;
        }
        else
        {
            _btn_frame =
                0;

            _btn_blend =
                make_color_rgb(
                    110,
                    110,
                    110
                );
        }
    }
    else if (
        _main_action_deciding
        &&
        _button_selected_for_draw
        ==
        _b
    )
    {
        _btn_frame =
            1;
    }


    draw_sprite_ext(
        _spr_btn,
        _btn_frame,
        _btn_x[_b]
        *
        _s,
        192
        *
        _s,
        _btn_scale,
        _btn_scale,
        0,
        _btn_blend,
        _alpha_final
    );
}


// =========================================================
// A PARTIR DE AQUÍ SOLO HAY EFECTOS ESPECIALES DE ATAQUE
// =========================================================

if (
    _mods == noone
    ||
    !instance_exists(
        _mods
    )
    ||
    !_mods.action_active
)
{
    draw_set_alpha(1);
    draw_set_color(c_white);
    exit;
}


// =========================================================
// CAJA NORMAL DE ATAQUE
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


var _box_center_x =
    _box_left
    +
    (_box_w * 0.5);


var _box_center_y =
    _box_top
    +
    (_box_h * 0.5);


// =========================================================
// ESPADA CERTERA
// =========================================================
//
// El Draw GUI normal acaba de dibujar la barra estándar.
//
// Dibujamos encima EL MISMO sprite/frame/posición,
// pero ensanchado horizontalmente.
//
// Resultado visual: una única barra realmente más ancha.
// =========================================================

if (
    _mods.custom_mode == ""
    &&
    _mods.current_mode == "lineal"
    &&
    _mods.current_bar_xscale > 1.0001
    &&
    (
        attack_timing_active
        ||
        attack_timing_stopped
    )
)
{
    var _bar_scale_y =
        attack_bar_scale_base
        *
        _s;


    var _bar_scale_x =
        _bar_scale_y
        *
        _mods.current_bar_xscale;


    var _bar_center_gui =
        attack_bar_x
        *
        _s;


    var _bar_draw_x =
        _bar_center_gui
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
        _box_center_y
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
                attack_bar_anim_index
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
        _alpha_final
    );
}


// =========================================================
// MULTI-BARRAS
// =========================================================
//
// El target estándar ya existe debajo.
//
// Dibujamos todas las barras a la vez, separadas y saliendo
// del mismo lado.
// =========================================================

if (_mods.custom_mode == "multi")
{
    // -----------------------------------------------------
    // REDIBUJAR TARGET SOBRE TODO
    // -----------------------------------------------------

    var _target_scale_x =
        attack_target_xscale_base
        *
        _s;


    var _target_scale_y =
        attack_target_yscale_base
        *
        _s;


    var _target_center_x =
        attack_bar_center_x
        *
        _s;


    var _target_draw_x =
        _target_center_x
        +
        (
            sprite_get_xoffset(
                spr_target_bbs
            )
            -
            (
                sprite_get_width(
                    spr_target_bbs
                )
                *
                0.5
            )
        )
        *
        _target_scale_x;


    var _target_draw_y =
        _box_center_y
        +
        (
            sprite_get_yoffset(
                spr_target_bbs
            )
            -
            (
                sprite_get_height(
                    spr_target_bbs
                )
                *
                0.5
            )
        )
        *
        _target_scale_y;


    draw_sprite_ext(
        spr_target_bbs,
        0,
        _target_draw_x,
        _target_draw_y,
        _target_scale_x,
        _target_scale_y,
        0,
        c_white,
        _alpha_final
    );


    // -----------------------------------------------------
    // BARRAS
    // -----------------------------------------------------

    var _multi_scale_y =
        attack_bar_scale_base
        *
        _s;


    var _multi_scale_x =
        _multi_scale_y
        *
        _mods.current_bar_xscale;


    var _multi_frame =
        clamp(
            floor(
                attack_bar_anim_index
            ),
            0,
            sprite_get_number(
                spr_barra_bbs
            )
            -
            1
        );


    for (
        var _i = 0;
        _i < _mods.multi_count;
        _i++
    )
    {
        // Barras que todavía están FUERA del textbox no se
        // dibujan. Así visualmente emergen desde su orilla una
        // tras otra, aunque internamente ya se estén moviendo.
        var _inside_box =
            (
                _mods.multi_positions[_i]
                >=
                _mods.multi_min_x
            )
            &&
            (
                _mods.multi_positions[_i]
                <=
                _mods.multi_max_x
            );


        if (!_inside_box)
        {
            continue;
        }


        var _bar_center =
            _mods.multi_positions[_i]
            *
            _s;


        var _draw_x =
            _bar_center
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
            _multi_scale_x;


        var _draw_y =
            _box_center_y
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
            _multi_scale_y;


        var _a =
            _mods.multi_done[_i]
            ?
            0.55
            :
            1.0;


        draw_sprite_ext(
            spr_barra_bbs,
            _multi_frame,
            _draw_x,
            _draw_y,
            _multi_scale_x,
            _multi_scale_y,
            0,
            c_white,
            _alpha_final
            *
            _a
        );
    }


    draw_set_alpha(1);
    draw_set_color(c_white);

    exit;
}


// =========================================================
// ARO CARGADO
// =========================================================
//
// FASE 1:
//     el textbox horizontal se encoge SUAVEMENTE.
//
// FASE 2:
//     al terminar la animación aparece la diana 128x128.
//     EN ESE MISMO MOMENTO empieza la ventana de tiempo.
//
// Durante todo el modo circle, el target normal queda tapado.
// =========================================================

if (_mods.custom_mode == "circle")
{
    // -----------------------------------------------------
    // BORRAR LA CAJA NORMAL SIN DEJAR UN RECTÁNGULO NEGRO
    // -----------------------------------------------------
    //
    // Draw GUI normal ya dibujó el textbox horizontal y el
    // target. Antes los tapábamos con un rectángulo negro más
    // grande que la caja, de ahí el bloque negro visible.
    //
    // Ahora restauramos SOLO el trozo correspondiente del
    // application_surface (la escena sin GUI) y encima dibujamos
    // la caja animada. Así detrás se ve el fondo real de batalla.
    // -----------------------------------------------------

    if (
        surface_exists(
            application_surface
        )
    )
    {
        var _gui_w =
            max(
                1,
                display_get_gui_width()
            );


        var _gui_h =
            max(
                1,
                display_get_gui_height()
            );


        var _app_w =
            surface_get_width(
                application_surface
            );


        var _app_h =
            surface_get_height(
                application_surface
            );


        var _source_scale_x =
            _app_w
            /
            _gui_w;


        var _source_scale_y =
            _app_h
            /
            _gui_h;


        var _src_x =
            _box_left
            *
            _source_scale_x;


        var _src_y =
            _box_top
            *
            _source_scale_y;


        var _src_w =
            _box_w
            *
            _source_scale_x;


        var _src_h =
            _box_h
            *
            _source_scale_y;


        draw_surface_part_ext(
            application_surface,
            _src_x,
            _src_y,
            _src_w,
            _src_h,
            _box_left,
            _box_top,
            1 / _source_scale_x,
            1 / _source_scale_y,
            c_white,
            1
        );
    }
    else
    {
        // Fallback únicamente si application_surface estuviera
        // desactivada. Se limita al tamaño EXACTO del textbox.
        draw_set_color(
            c_black
        );


        draw_set_alpha(
            _alpha_final
        );


        draw_rectangle(
            _box_left,
            _box_top,
            _box_left + _box_w,
            _box_top + _box_h,
            false
        );
    }


    // -----------------------------------------------------
    // ANIMACIÓN DE TAMAÑO
    // -----------------------------------------------------

    var _intro_t =
        clamp(
            _mods.circle_intro_progress,
            0,
            1
        );


    // Ease-out cúbico: rápido al principio, suave al llegar.
    var _intro_ease =
        1
        -
        power(
            1 - _intro_t,
            3
        );


    var _circle_size =
        128;


    var _animated_w =
        lerp(
            _box_w,
            _circle_size,
            _intro_ease
        );


    var _animated_h =
        lerp(
            _box_h,
            _circle_size,
            _intro_ease
        );


    var _animated_x =
        _box_center_x
        -
        (_animated_w * 0.5);


    var _animated_y =
        _box_center_y
        -
        (_animated_h * 0.5);


    draw_set_color(
        c_white
    );


    draw_sprite_stretched(
        spr_bbs_textbox,
        0,
        _animated_x,
        _animated_y,
        _animated_w,
        _animated_h
    );


    // -----------------------------------------------------
    // LA DIANA SOLO APARECE CUANDO LA CAJA TERMINÓ
    // -----------------------------------------------------
    // Ese instante coincide con circle_ready=true y con el
    // inicio del cronómetro del ataque.
    // -----------------------------------------------------

    if (_mods.circle_ready)
    {
        draw_sprite_ext(
            spr_diana,
            0,
            _box_center_x,
            _box_center_y,
            1,
            1,
            0,
            c_white,
            _alpha_final
        );


        // -------------------------------------------------
        // ARO CARGABLE
        // -------------------------------------------------

        var _ring_scale =
            max(
                0.01,
                _mods.circle_radius
                /
                max(
                    1,
                    _mods.circle_radius_target
                )
            );


        draw_sprite_ext(
            spr_diana_aro,
            0,
            _box_center_x,
            _box_center_y,
            _ring_scale,
            _ring_scale,
            0,
            c_white,
            _alpha_final
        );


        // -------------------------------------------------
        // BARRA DE TIEMPO
        // -------------------------------------------------
        // Empieza a vaciarse INMEDIATAMENTE al aparecer la
        // diana, no al empezar a mantener Z.
        // -------------------------------------------------

        var _time_ratio =
            1
            -
            clamp(
                _mods.circle_timer
                /
                max(
                    1,
                    _mods.circle_limit
                ),
                0,
                1
            );


        var _time_w =
            90;


        var _time_h =
            4;


        var _circle_box_y =
            _box_center_y
            -
            (_circle_size * 0.5);


        var _time_x =
            _box_center_x
            -
            (_time_w * 0.5);


        var _time_y =
            _circle_box_y
            +
            _circle_size
            -
            9;


        draw_set_color(
            c_black
        );


        draw_rectangle(
            _time_x - 1,
            _time_y - 1,
            _time_x + _time_w + 1,
            _time_y + _time_h + 1,
            false
        );


        draw_set_color(
            c_white
        );


        draw_rectangle(
            _time_x,
            _time_y,
            _time_x
            +
            (_time_w * _time_ratio),
            _time_y
            +
            _time_h,
            false
        );
    }
}


draw_set_alpha(1);
draw_set_color(c_white);
