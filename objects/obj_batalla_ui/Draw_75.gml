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

if (
    room != bbs
    ||
    !instance_exists(
        obj_batalla_attack_mods
    )
)
{
    exit;
}


var _mods =
    instance_find(
        obj_batalla_attack_mods,
        0
    );


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
    exit;
}


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
    // TAPAR CAJA / TARGET DE LA UI NORMAL
    // -----------------------------------------------------

    draw_set_color(
        c_black
    );


    draw_set_alpha(
        _alpha_final
    );


    draw_rectangle(
        _box_left - 5,
        _box_top - 16,
        _box_left + _box_w + 5,
        _box_top + max(_box_h, 128) + 16,
        false
    );


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
