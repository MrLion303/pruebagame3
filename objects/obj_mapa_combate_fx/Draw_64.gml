/// =========================================================
/// OBJ_MAPA_COMBATE_FX
/// DRAW GUI COMPLETO
/// =========================================================
///
/// Mantiene el sistema actual de oscuridad/HUD.
///
/// ARREGLO:
/// La copia roja de Maya ya NO usa directamente sprite_index
/// y la escala sin modificar. Ahora usa exactamente el sprite,
/// frame, posición y escala que obj_player (o el Dash) dibujó
/// ese mismo frame.
///
/// Por eso coincide con:
/// - escala 39/28;
/// - anclaje a los pies;
/// - agachada +15 px;
/// - sprites Target;
/// - sprites de plataforma;
/// - Dash.
/// =========================================================


// =========================================================
// SIN PLAYER NO HAY NADA QUE DIBUJAR
// =========================================================

if (
    !instance_exists(
        obj_player
    )
)
{
    exit;
}


// =========================================================
// CÁMARA / GUI
// =========================================================

var _cam =
    view_camera[0];


if (_cam == -1)
{
    exit;
}


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


var _gui_w =
    display_get_gui_width();


var _gui_h =
    display_get_gui_height();


if (
    _cam_w <= 0
    ||
    _cam_h <= 0
)
{
    exit;
}


var _sx =
    _gui_w
    /
    _cam_w;


var _sy =
    _gui_h
    /
    _cam_h;


// =========================================================
// COPIA SEGURA PARA LOS BLOQUES with()
// =========================================================

fx_cam_x =
    _cam_x;


fx_cam_y =
    _cam_y;


fx_scale_x =
    _sx;


fx_scale_y =
    _sy;


// =========================================================
// PLAYER
// =========================================================

var _p =
    instance_find(
        obj_player,
        0
    );


// =========================================================
// EFECTO DE PELIGRO DEL MAPA
// =========================================================

if (fx_anim > 0)
{
    var _fx_t =
        clamp(
            fx_anim,
            0,
            1
        );


    var _fx_ease =
        _fx_t
        *
        _fx_t
        *
        (
            3
            -
            (2 * _fx_t)
        );


    // =====================================================
    // OSCURECER ENTORNO
    // =====================================================

    draw_set_alpha(
        clamp(
            oscuridad_base
            *
            _fx_ease,
            0,
            1
        )
    );


    draw_set_color(
        c_black
    );


    draw_rectangle(
        0,
        0,
        _gui_w,
        _gui_h,
        false
    );


    draw_set_alpha(
        1
    );


    draw_set_color(
        c_white
    );


    fx_ease_actual =
        _fx_ease;


    // =====================================================
    // MAYA - COPIA ROJA DEL VISUAL REAL
    // =====================================================

    var _red_sprite =
        _p.sprite_index;


    var _red_frame =
        _p.image_index;


    var _red_world_x =
        _p.x;


    var _red_world_y =
        _p.y;


    var _red_xscale =
        _p.image_xscale;


    var _red_yscale =
        _p.image_yscale;


    var _red_angle =
        _p.image_angle;


    var _red_alpha =
        _p.image_alpha;


    var _has_visual_cache =
        (
            variable_instance_exists(
                _p,
                "maya_visual_valid"
            )
            &&
            _p.maya_visual_valid
            &&
            variable_instance_exists(
                _p,
                "maya_visual_sprite"
            )
            &&
            _p.maya_visual_sprite != -1
            &&
            sprite_exists(
                _p.maya_visual_sprite
            )
        );


    if (_has_visual_cache)
    {
        _red_sprite =
            _p.maya_visual_sprite;


        _red_frame =
            _p.maya_visual_frame;


        _red_world_x =
            _p.maya_visual_world_x;


        _red_world_y =
            _p.maya_visual_world_y;


        _red_xscale =
            _p.maya_visual_xscale;


        _red_yscale =
            _p.maya_visual_yscale;


        _red_angle =
            _p.maya_visual_angle;


        _red_alpha =
            _p.maya_visual_alpha;
    }


    if (
        _p.visible
        &&
        _red_sprite != -1
        &&
        sprite_exists(
            _red_sprite
        )
    )
    {
        var _pgx =
            (
                _red_world_x
                -
                _cam_x
            )
            *
            _sx;


        var _pgy =
            (
                _red_world_y
                -
                _cam_y
            )
            *
            _sy;


        draw_sprite_ext(
            _red_sprite,
            _red_frame,
            _pgx,
            _pgy,
            _red_xscale * _sx,
            _red_yscale * _sy,
            _red_angle,
            merge_color(
                c_white,
                c_red,
                _fx_ease
            ),
            _red_alpha
            *
            _fx_ease
        );
    }


    // =====================================================
    // ENEMIGOS ACTIVOS - SIN OSCURECER
    // =====================================================

    with (obj_enemigo_mapa_parent)
    {
        if (
            en_alerta
            &&
            visible
            &&
            sprite_index != -1
        )
        {
            var _egx =
                (
                    x
                    -
                    other.fx_cam_x
                )
                *
                other.fx_scale_x;


            var _egy =
                (
                    y
                    -
                    other.fx_cam_y
                )
                *
                other.fx_scale_y;


            draw_sprite_ext(
                sprite_index,
                image_index,
                _egx,
                _egy,
                image_xscale * other.fx_scale_x,
                image_yscale * other.fx_scale_y,
                image_angle,
                c_white,
                image_alpha
                *
                other.fx_ease_actual
            );
        }
    }


    // =====================================================
    // BALAS ACTIVAS - SIN OSCURECER
    // =====================================================

    with (obj_proyectil_mapa)
    {
        var _owner_valido =
            (
                owner_enemy != noone
                &&
                instance_exists(
                    owner_enemy
                )
                &&
                variable_instance_exists(
                    owner_enemy,
                    "en_alerta"
                )
                &&
                owner_enemy.en_alerta
            );


        if (
            _owner_valido
            &&
            visible
            &&
            sprite_index != -1
        )
        {
            var _bgx =
                (
                    x
                    -
                    other.fx_cam_x
                )
                *
                other.fx_scale_x;


            var _bgy =
                (
                    y
                    -
                    other.fx_cam_y
                )
                *
                other.fx_scale_y;


            draw_sprite_ext(
                sprite_index,
                image_index,
                _bgx,
                _bgy,
                image_xscale * other.fx_scale_x,
                image_yscale * other.fx_scale_y,
                image_angle,
                c_white,
                image_alpha
                *
                other.fx_ease_actual
            );
        }
    }
}


// =========================================================
// HUD DE COMBATE EN MAPA
// =========================================================

if (hud_anim > 0)
{
    var _hud_t =
        clamp(
            hud_anim,
            0,
            1
        );


    var _hud_ease =
        _hud_t
        *
        _hud_t
        *
        (
            3
            -
            (2 * _hud_t)
        );


    var _hud_alpha =
        _hud_ease;


    // =====================================================
    // FUENTE
    // =====================================================

    if (
        variable_global_exists(
            "font_main"
        )
    )
    {
        draw_set_font(
            global.font_main
        );
    }


    // =====================================================
    // MONITOREAR DAÑO / FRAME DE DOLOR
    // =====================================================

    var _hp_actual =
        _p.hp;


    var _hp_max =
        max(
            1,
            _p.hp_max
        );


    if (hud_hp_anterior == -1)
    {
        hud_hp_anterior =
            _hp_actual;
    }
    else if (_hp_actual < hud_hp_anterior)
    {
        hud_timer_dolor =
            game_get_speed(
                gamespeed_fps
            )
            *
            0.5;


        hud_hp_anterior =
            _hp_actual;
    }
    else
    {
        hud_hp_anterior =
            _hp_actual;
    }


    var _prota_head_frame =
        0;


    if (hud_timer_dolor > 0)
    {
        hud_timer_dolor--;


        _prota_head_frame =
            1;
    }


    _prota_head_frame =
        clamp(
            _prota_head_frame,
            0,
            max(
                0,
                sprite_get_number(
                    spr_bbs_prota_head
                )
                -
                1
            )
        );


    // =====================================================
    // ESCALA / POSICIÓN DEL HUD
    // =====================================================

    var _hud_s =
        min(
            _gui_w / 320,
            _gui_h / 240
        )
        *
        hud_size_factor;


    var _hud_target_y =
        _gui_h
        -
        (54 * _hud_s)
        -
        (6 * _hud_s);


    var _hud_hidden_y =
        _gui_h
        +
        (10 * _hud_s);


    var _hud_base_y =
        lerp(
            _hud_hidden_y,
            _hud_target_y,
            _hud_ease
        );


    // =====================================================
    // CAJA
    // =====================================================

    draw_sprite_ext(
        spr_bbs_textbox,
        0,
        6 * _hud_s,
        _hud_base_y,
        2.27451 * _hud_s,
        1.0 * _hud_s,
        0,
        c_white,
        _hud_alpha
    );


    // =====================================================
    // CABEZA
    // =====================================================

    draw_sprite_ext(
        spr_bbs_prota_head,
        _prota_head_frame,
        14 * _hud_s,
        _hud_base_y
        +
        (12 * _hud_s),
        1.0 * _hud_s,
        1.0 * _hud_s,
        0,
        c_white,
        _hud_alpha
    );


    // =====================================================
    // NOMBRE
    // =====================================================

    var _info_x =
        55 * _hud_s;


    var _info_y =
        _hud_base_y
        +
        (6 * _hud_s);


    draw_set_halign(
        fa_left
    );


    draw_set_valign(
        fa_top
    );


    var _name_scale =
        0.84;


    draw_text_transformed_color(
        _info_x,
        _info_y,
        scr_loc(
            "Maya"
        ),
        _name_scale,
        _name_scale,
        0,
        c_white,
        c_white,
        c_white,
        c_white,
        _hud_alpha
    );


    // =====================================================
    // HP LABEL
    // =====================================================

    var _hp_label_y =
        _info_y
        +
        (16 * _hud_s);


    var _hp_scale =
        0.7
        *
        hud_size_factor;


    draw_text_transformed_color(
        _info_x,
        _hp_label_y,
        scr_loc(
            "HP"
        ),
        _hp_scale,
        _hp_scale,
        0,
        c_white,
        c_white,
        c_white,
        c_white,
        _hud_alpha
    );


    // =====================================================
    // HP ACTUAL / MÁXIMO
    // =====================================================

    var _hp_texto =
        string(
            _hp_actual
        )
        +
        " / "
        +
        string(
            _hp_max
        );


    var _hp_texto_referencia =
        "80 / 80";


    var _hp_texto_x_base =
        _info_x
        +
        (24 * _hud_s);


    var _hp_ancho_ref =
        string_width(
            _hp_texto_referencia
        )
        *
        _hp_scale;


    var _hp_ancho_actual =
        string_width(
            _hp_texto
        )
        *
        _hp_scale;


    var _hp_right =
        _hp_texto_x_base
        +
        _hp_ancho_ref;


    var _hp_texto_x =
        _hp_right
        -
        _hp_ancho_actual;


    draw_text_transformed_color(
        _hp_texto_x,
        _hp_label_y,
        _hp_texto,
        _hp_scale,
        _hp_scale,
        0,
        c_white,
        c_white,
        c_white,
        c_white,
        _hud_alpha
    );


    // =====================================================
    // BARRA DE VIDA
    // =====================================================

    var _bar_left =
        _info_x;


    var _bar_right =
        _hp_right;


    var _bar_y1 =
        _hp_label_y
        +
        (10 * _hud_s);


    var _bar_y2 =
        _bar_y1
        +
        (6 * _hud_s);


    draw_set_alpha(
        _hud_alpha
    );


    draw_rectangle_color(
        _bar_left,
        _bar_y1,
        _bar_right,
        _bar_y2,
        $202020,
        $202020,
        $202020,
        $202020,
        false
    );


    var _porcentaje_hp =
        clamp(
            _hp_actual
            /
            _hp_max,
            0,
            1
        );


    draw_set_alpha(
        _hud_alpha
    );


    draw_rectangle_color(
        _bar_left,
        _bar_y1,
        _bar_left
        +
        (
            (_bar_right - _bar_left)
            *
            _porcentaje_hp
        ),
        _bar_y2,
        c_yellow,
        c_yellow,
        c_yellow,
        c_yellow,
        false
    );


    draw_set_alpha(
        1
    );
}


// =========================================================
// RESTAURAR DRAW STATE
// =========================================================

draw_set_halign(
    fa_left
);


draw_set_valign(
    fa_top
);


draw_set_alpha(
    1
);


draw_set_color(
    c_white
);
