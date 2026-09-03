/// =========================================================
/// OBJ_TEXTBOX
/// DRAW COMPLETO
/// =========================================================


// =========================================================
// RECARGA PENDIENTE SIN DESTRUIR LA CAJA
// =========================================================

if (
    variable_instance_exists(id, "textbox_reload_pending")
    &&
    textbox_reload_pending
)
{
    var _reload_id =
        textbox_reload_id;

    textbox_reload_pending =
        false;

    textbox_reload_id =
        "";

    scr_textbox_load_existing(
        id,
        _reload_id
    );
}


// =========================================================
// INPUT
// =========================================================

accept_key =
    keyboard_check_pressed(ord("Z"))
    ||
    keyboard_check_pressed(vk_enter);


skip_key =
    keyboard_check_pressed(ord("X"))
    ||
    keyboard_check_pressed(vk_shift)
    ||
    keyboard_check_pressed(vk_control);


var _fast_skip_key =
    keyboard_check(ord("C"))
    ||
    keyboard_check(vk_control);


var _console_blocks_textbox =
(
    variable_global_exists("dev_console_open")
    &&
    global.dev_console_open
);


if (_console_blocks_textbox)
{
    accept_key = false;
    skip_key = false;
    _fast_skip_key = false;
}


var _is_decision =
(
    variable_instance_exists(id, "page_number")
    &&
    variable_instance_exists(id, "option_number")
    &&
    option_number > 0
    &&
    page == page_number - 1
);


// =========================================================
// SEGURIDAD
// =========================================================

if (
    !variable_instance_exists(id, "page_number")
    ||
    page_number <= 0
)
{
    exit;
}


if (
    !variable_instance_exists(id, "text")
    ||
    !is_array(text)
)
{
    exit;
}


// =========================================================
// CÁMARA
// =========================================================

var _cam =
    view_camera[0];


var _cam_x =
    camera_get_view_x(_cam);


var _cam_y =
    camera_get_view_y(_cam);


var _cam_w =
    camera_get_view_width(_cam);


var _cam_h =
    camera_get_view_height(_cam);


// =========================================================
// POSICIÓN HORIZONTAL
// =========================================================

textbox_x =
    _cam_x
    +
    (_cam_w - textbox_width) / 2;


// =========================================================
// POSICIONES POSIBLES DEL TEXTBOX
// =========================================================

var _textbox_y_top =
    _cam_y
    +
    16;


var _textbox_y_bottom =
    _cam_y
    +
    _cam_h
    -
    textbox_height
    -
    16;


// Por defecto se dibuja abajo.
var _target_textbox_y =
    _textbox_y_bottom;


// =========================================================
// ¿HAY UNA IMAGEN DE CINEMÁTICA EN PANTALLA?
// =========================================================
//
// Mientras una imagen creada con:
//
//     cs_image_show(...)
//
// esté activa:
//
//     TEXTBOX SIEMPRE ABAJO.
//
// La posición del jugador se ignora.
//
// Al terminar:
//
//     cs_image_hide()
//
// vuelve automáticamente al sistema normal.
// =========================================================

var _cutscene_image_active =
    false;


if (instance_exists(obj_cutscene_controller))
{
    var _cutscene_controller =
        instance_find(
            obj_cutscene_controller,
            0
        );


    if (_cutscene_controller != noone)
    {
        if (
            variable_instance_exists(
                _cutscene_controller,
                "cutscene_image_sprite"
            )
        )
        {
            if (
                _cutscene_controller.cutscene_image_sprite
                !=
                noone
            )
            {
                _cutscene_image_active =
                    true;
            }
        }
    }
}


// =========================================================
// IMAGEN CINEMÁTICA
// -> TEXTBOX SIEMPRE ABAJO
// =========================================================

if (_cutscene_image_active)
{
    _target_textbox_y =
        _textbox_y_bottom;
}


// =========================================================
// SIN IMAGEN CINEMÁTICA
// -> EVITAR TAPAR AL PLAYER
// =========================================================

else if (
    room != bbs
    &&
    instance_exists(obj_player)
)
{
    var _player =
        instance_find(
            obj_player,
            0
        );


    if (_player != noone)
    {
        // =================================================
        // CENTRO VERTICAL DEL PLAYER
        // =================================================

        var _player_center_y =
            (
                _player.bbox_top
                +
                _player.bbox_bottom
            )
            *
            0.5;


        // =================================================
        // ÁREA QUE OCUPARÍA EL TEXTBOX ARRIBA
        // =================================================

        var _top_box_top =
            _textbox_y_top;


        var _top_box_bottom =
            _textbox_y_top
            +
            textbox_height;


        // =================================================
        // ÁREA QUE OCUPARÍA EL TEXTBOX ABAJO
        // =================================================

        var _bottom_box_top =
            _textbox_y_bottom;


        var _bottom_box_bottom =
            _textbox_y_bottom
            +
            textbox_height;


        // =================================================
        // ¿EL TEXTBOX DE ARRIBA TAPARÍA AL PLAYER?
        // =================================================

        var _top_tapa_player =
        !(
            _player.bbox_bottom
            <
            _top_box_top

            ||

            _player.bbox_top
            >
            _top_box_bottom
        );


        // =================================================
        // ¿EL TEXTBOX DE ABAJO TAPARÍA AL PLAYER?
        // =================================================

        var _bottom_tapa_player =
        !(
            _player.bbox_bottom
            <
            _bottom_box_top

            ||

            _player.bbox_top
            >
            _bottom_box_bottom
        );


        // =================================================
        // ARRIBA LIBRE Y ABAJO TAPARÍA
        // =================================================

        if (
            !_top_tapa_player
            &&
            _bottom_tapa_player
        )
        {
            _target_textbox_y =
                _textbox_y_top;
        }


        // =================================================
        // ABAJO LIBRE Y ARRIBA TAPARÍA
        // =================================================

        else if (
            _top_tapa_player
            &&
            !_bottom_tapa_player
        )
        {
            _target_textbox_y =
                _textbox_y_bottom;
        }


        // =================================================
        // AMBOS LUGARES ESTÁN LIBRES
        // =========================================================
        //
        // Player abajo:
        //      cuadro arriba.
        //
        // Player arriba:
        //      cuadro abajo.
        // =================================================

        else if (
            !_top_tapa_player
            &&
            !_bottom_tapa_player
        )
        {
            var _camera_middle_y =
                _cam_y
                +
                (_cam_h * 0.5);


            if (
                _player_center_y
                >=
                _camera_middle_y
            )
            {
                _target_textbox_y =
                    _textbox_y_top;
            }
            else
            {
                _target_textbox_y =
                    _textbox_y_bottom;
            }
        }


        // =================================================
        // CASO EXTREMO:
        // AMBAS POSICIONES TOCARÍAN AL PLAYER
        // =========================================================
        //
        // Elegimos la posición más alejada.
        // =================================================

        else
        {
            var _top_center_y =
                _textbox_y_top
                +
                textbox_height * 0.5;


            var _bottom_center_y =
                _textbox_y_bottom
                +
                textbox_height * 0.5;


            var _dist_top =
                abs(
                    _player_center_y
                    -
                    _top_center_y
                );


            var _dist_bottom =
                abs(
                    _player_center_y
                    -
                    _bottom_center_y
                );


            if (_dist_top >= _dist_bottom)
            {
                _target_textbox_y =
                    _textbox_y_top;
            }
            else
            {
                _target_textbox_y =
                    _textbox_y_bottom;
            }
        }
    }
}


// =========================================================
// DETECTAR CAMBIO DE POSICIÓN
// =========================================================
//
// char_x y char_y se calculan durante setup.
//
// Si el textbox cambia de arriba a abajo,
// debemos recalcular todas las letras.
// =========================================================

if (
    !variable_instance_exists(
        id,
        "textbox_last_y"
    )
)
{
    textbox_last_y =
        _target_textbox_y;
}


if (
    textbox_last_y
    !=
    _target_textbox_y
)
{
    textbox_last_y =
        _target_textbox_y;


    setup =
        false;
}


// =========================================================
// POSICIÓN DEFINITIVA
// =========================================================

textbox_y =
    _target_textbox_y;


// =========================================================
// CONFIGURACIÓN DEL TEXTO
// =========================================================

var _txt_scale =
    0.55;


var _has_speaker =
(
    page < array_length(speaker_sprite)
    &&
    speaker_sprite[page] != noone
    &&
    speaker_sprite[page] >= 0
);


var _left_margin =
    _has_speaker
    ?
    (border + 75)
    :
    (border + 10);


var _available_width =
    textbox_width
    -
    _left_margin
    -
    border;


// =========================================================
// SETUP
// =========================================================

if (setup == false)
{
    setup =
        true;


    draw_set_font(
        global.font_main
    );


    draw_set_valign(
        fa_top
    );


    draw_set_halign(
        fa_left
    );


    for (
        var p = 0;
        p < page_number;
        p++
    )
    {
        text_lenght[p] =
            string_length(
                text[p]
            );


        text_x_offset[p] =
            0;


        line_break_num[p] =
            0;


        var _last_space =
            -1;


        var _line_start_char =
            1;


        var _p_has_speaker =
        (
            p < array_length(speaker_sprite)
            &&
            speaker_sprite[p] != noone
            &&
            speaker_sprite[p] >= 0
        );


        var _p_left_margin =
            _p_has_speaker
            ?
            (border + 75)
            :
            (border + 10);


        var _p_avail_width =
            textbox_width
            -
            _p_left_margin
            -
            border;


        // =================================================
        // SALTOS DE LÍNEA
        // =================================================

        for (
            var c = 1;
            c <= text_lenght[p];
            c++
        )
        {
            var _char_current =
                string_char_at(
                    text[p],
                    c
                );


            if (_char_current == " ")
            {
                _last_space =
                    c;
            }


            var _sub_str =
                string_copy(
                    text[p],
                    _line_start_char,
                    c
                    -
                    _line_start_char
                    +
                    1
                );


            var _str_w =
                string_width(
                    _sub_str
                )
                *
                _txt_scale;


            if (_str_w > _p_avail_width)
            {
                if (
                    _last_space != -1
                    &&
                    _last_space
                    >=
                    _line_start_char
                )
                {
                    line_break_pos[
                        line_break_num[p],
                        p
                    ] =
                        _last_space + 1;


                    line_break_num[p]++;


                    _line_start_char =
                        _last_space + 1;


                    _last_space =
                        -1;
                }
                else
                {
                    line_break_pos[
                        line_break_num[p],
                        p
                    ] =
                        c;


                    line_break_num[p]++;


                    _line_start_char =
                        c;
                }
            }
        }


        // =================================================
        // POSICIÓN DE CADA CARÁCTER
        // =================================================

        for (
            var c = 0;
            c < text_lenght[p];
            c++
        )
        {
            var _char_pos =
                c + 1;


            char[c, p] =
                string_char_at(
                    text[p],
                    _char_pos
                );


            var _txt_x =
                textbox_x
                +
                _p_left_margin;


            var _txt_y =
                textbox_y
                +
                border;


            var _txt_line =
                0;


            var _line_start_pos =
                1;


            for (
                var lb = 0;
                lb < line_break_num[p];
                lb++
            )
            {
                if (
                    _char_pos
                    >=
                    line_break_pos[lb, p]
                )
                {
                    _txt_line =
                        lb + 1;


                    _line_start_pos =
                        line_break_pos[
                            lb,
                            p
                        ];
                }
            }


            if (
                _line_start_pos
                ==
                _char_pos
                &&
                char[c, p] == " "
            )
            {
                char_x[c, p] =
                    -9999;


                char_y[c, p] =
                    -9999;


                continue;
            }


            var _str_copy =
                string_copy(
                    text[p],
                    _line_start_pos,
                    _char_pos
                    -
                    _line_start_pos
                    +
                    1
                );


            var _current_txt_w =
                string_width(
                    _str_copy
                )
                *
                _txt_scale;


            char_x[c, p] =
                _txt_x
                +
                _current_txt_w
                -
                (
                    string_width(
                        char[c, p]
                    )
                    *
                    _txt_scale
                );


            char_y[c, p] =
                _txt_y
                +
                (_txt_line * 17);
        }
    }
}


// =========================================================
// SEGURIDAD DE PÁGINA
// =========================================================

if (page >= page_number)
{
    page =
        page_number - 1;
}


if (page < 0)
{
    page =
        0;
}


if (!is_array(text_lenght))
{
    text_lenght =
        array_create(
            page_number,
            0
        );
}


if (
    array_length(text_lenght)
    <=
    page
)
{
    array_resize(
        text_lenght,
        page_number
    );
}


if (
    is_undefined(
        text_lenght[page]
    )
)
{
    text_lenght[page] =
        0;
}


// =========================================================
// SONIDO EXTRA POR PÁGINA
// =========================================================
//
// Las cinemáticas pueden agrupar varios cs_dialog dentro de
// esta misma caja. Cada página puede tener su propio sonido
// largo opcional.
//
// stop = true:
//     se corta al cambiar de página / cerrar la caja.
//
// stop = false:
//     continúa aunque el diálogo avance.
// =========================================================

if (
    !variable_instance_exists(
        id,
        "page_extra_sound"
    )
)
{
    page_extra_sound =
        [];
}


if (
    !variable_instance_exists(
        id,
        "page_extra_stop"
    )
)
{
    page_extra_stop =
        [];
}


if (
    !variable_instance_exists(
        id,
        "page_extra_gain"
    )
)
{
    page_extra_gain =
        [];
}


if (
    !variable_instance_exists(
        id,
        "page_extra_active_page"
    )
)
{
    page_extra_active_page =
        -1;

    page_extra_instance =
        -1;

    page_extra_stop_current =
        true;
}


if (
    page_extra_active_page
    !=
    page
)
{
    // Cerrar sonido de la página anterior solamente
    // cuando así fue configurado.
    if (
        page_extra_instance != -1
        &&
        page_extra_stop_current
        &&
        audio_is_playing(
            page_extra_instance
        )
    )
    {
        audio_stop_sound(
            page_extra_instance
        );
    }


    page_extra_instance =
        -1;

    page_extra_active_page =
        page;


    page_extra_stop_current =
        (
            page
            <
            array_length(page_extra_stop)
            &&
            !is_undefined(
                page_extra_stop[page]
            )
        )
        ?
        page_extra_stop[page]
        :
        true;


    var _page_extra_sound =
        (
            page
            <
            array_length(page_extra_sound)
            &&
            !is_undefined(
                page_extra_sound[page]
            )
        )
        ?
        page_extra_sound[page]
        :
        noone;


    var _page_extra_gain =
        (
            page
            <
            array_length(page_extra_gain)
            &&
            !is_undefined(
                page_extra_gain[page]
            )
        )
        ?
        page_extra_gain[page]
        :
        1;


    if (
        _page_extra_sound != noone
        &&
        audio_exists(
            _page_extra_sound
        )
    )
    {
        page_extra_instance =
            audio_play_sound(
                _page_extra_sound,
                10,
                false
            );


        audio_sound_gain(
            page_extra_instance,
            _page_extra_gain,
            0
        );
    }
}


// =========================================================
// TYPEWRITER
// =========================================================

if (
    draw_char
    <
    text_lenght[page]
)
{
    var _current_char_checking =
        string_char_at(
            text[page],
            floor(draw_char)
        );


    var _is_punctuation =
    (
        _current_char_checking == "."
        ||
        _current_char_checking == ","
        ||
        _current_char_checking == "!"
        ||
        _current_char_checking == "?"
    );


    var _actual_speed =
        _fast_skip_key
        ?
        999
        :
        (
            _is_punctuation
            ?
            0.08
            :
            text_spd
        );


    draw_char +=
        _actual_speed;


    draw_char =
        clamp(
            draw_char,
            0,
            text_lenght[page]
        );


    if (
        floor(draw_char) > 0
        &&
        floor(draw_char)
        <=
        text_lenght[page]
    )
    {
        var _char_to_speak =
            string_char_at(
                text[page],
                floor(draw_char)
            );


        if (_char_to_speak != " ")
        {
            if (
                !_is_punctuation
                &&
                !_fast_skip_key
            )
            {
                text_sound_timer++;
            }


            if (
                text_sound_timer
                >=
                text_sound_delay
                ||
                _fast_skip_key
            )
            {
                text_sound_timer =
                    0;


                var _current_sound =
                    (
                        page
                        <
                        array_length(text_sound)
                        &&
                        text_sound[page]
                        !=
                        undefined
                    )
                    ?
                    text_sound[page]
                    :
                    snd_text;


                if (
                    audio_exists(
                        _current_sound
                    )
                    &&
                    !_fast_skip_key
                )
                {
                    audio_play_sound(
                        _current_sound,
                        1,
                        false
                    );
                }
            }
        }
    }


    if (
        skip_key
        ||
        _fast_skip_key
    )
    {
        draw_char =
            text_lenght[page];
    }
}


// =========================================================
// AVANZAR / CERRAR
// =========================================================

else if (
    accept_key
    ||
    (
        _fast_skip_key
        &&
        !_is_decision
    )
)
{
    if (
        draw_char
        >=
        text_lenght[page]
    )
    {
        if (
            page
            <
            page_number - 1
        )
        {
            page++;


            draw_char =
                0;
        }
        else
        {
            // =================================================
            // ELECCIÓN NORMAL
            // =================================================

            if (
                variable_instance_exists(
                    id,
                    "option_number"
                )
                &&
                option_number > 0
            )
            {
                textbox_reload_id =
                    option_link_id[
                        option_pos
                    ];

                textbox_reload_pending =
                    true;

                option_number =
                    0;
            }

            // =================================================
            // DIÁLOGO DE CINEMÁTICA
            // =================================================

            else if (
                variable_instance_exists(
                    id,
                    "cutscene_keep_instance"
                )
                &&
                cutscene_keep_instance
            )
            {
                cutscene_dialog_complete =
                    true;


                if (
                    variable_instance_exists(
                        id,
                        "page_extra_instance"
                    )
                    &&
                    page_extra_instance != -1
                    &&
                    variable_instance_exists(
                        id,
                        "page_extra_stop_current"
                    )
                    &&
                    page_extra_stop_current
                    &&
                    audio_is_playing(
                        page_extra_instance
                    )
                )
                {
                    audio_stop_sound(
                        page_extra_instance
                    );

                    page_extra_instance =
                        -1;
                }
            }

            // =================================================
            // DIÁLOGO NORMAL SIN ELECCIÓN
            // =================================================

            else
            {
                if (
                    variable_instance_exists(
                        id,
                        "page_extra_instance"
                    )
                    &&
                    page_extra_instance != -1
                    &&
                    variable_instance_exists(
                        id,
                        "page_extra_stop_current"
                    )
                    &&
                    page_extra_stop_current
                    &&
                    audio_is_playing(
                        page_extra_instance
                    )
                )
                {
                    audio_stop_sound(
                        page_extra_instance
                    );
                }


                instance_destroy();


                exit;
            }
        }
    }
}


// =========================================================
// TEXTBOX
// =========================================================

var _txtb_x =
    textbox_x;


var _txtb_y =
    textbox_y;


txtb_img +=
    txtb_img_spd;


var _current_txtb_spr =
    (
        page
        <
        array_length(txtb_spr)
        &&
        txtb_spr[page]
        !=
        undefined
    )
    ?
    txtb_spr[page]
    :
    spr_textbox;


txtb_spr_w =
    sprite_get_width(
        _current_txtb_spr
    );


txtb_spr_h =
    sprite_get_height(
        _current_txtb_spr
    );


draw_sprite_ext(
    _current_txtb_spr,
    scr_ui_box_frame(_current_txtb_spr),
    _txtb_x,
    _txtb_y,
    textbox_width / txtb_spr_w,
    textbox_height / txtb_spr_h,
    0,
    c_white,
    1
);


// =========================================================
// RETRATO
// =========================================================

var _safe_speaker =
    (
        page
        <
        array_length(speaker_sprite)
    )
    ?
    speaker_sprite[page]
    :
    noone;


if (
    _safe_speaker != noone
    &&
    _safe_speaker >= 0
)
{
    draw_sprite(
        _safe_speaker,
        0,
        _txtb_x + border + 4,
        _txtb_y + border + 4
    );
}


// =========================================================
// OPCIONES
// =========================================================

if (
    variable_instance_exists(
        id,
        "option_number"
    )
    &&
    option_number > 0
)
{
    if (
        draw_char
        ==
        text_lenght[page]
        &&
        page
        ==
        page_number - 1
    )
    {
        draw_set_font(
            global.font_main
        );


        if (!_console_blocks_textbox)
        {
            option_pos +=
                keyboard_check_pressed(vk_right)
                -
                keyboard_check_pressed(vk_left);
        }


        option_pos =
            clamp(
                option_pos,
                0,
                option_number - 1
            );


        var _op_scale =
            0.45;


        var _op_spacing =
            10;


        var _total_options_width =
            0;


        for (
            var op = 0;
            op < option_number;
            op++
        )
        {
            _total_options_width +=
                (
                    string_width(
                        option[op]
                    )
                    *
                    _op_scale
                );


            if (
                op
                <
                option_number - 1
            )
            {
                _total_options_width +=
                    _op_spacing;
            }
        }


        var _start_x =
            textbox_x
            +
            (
                textbox_width
                -
                _total_options_width
            )
            /
            2;


        var _start_y =
            textbox_y
            +
            textbox_height
            -
            border
            -
            18;


        var _current_x =
            _start_x;


        for (
            var op = 0;
            op < option_number;
            op++
        )
        {
            var _text_w =
                string_width(
                    option[op]
                )
                *
                _op_scale;


            if (
                option_pos
                ==
                op
            )
            {
                draw_sprite_ext(
                    spr_textbox_arrow,
                    0,
                    _current_x - 7,
                    _start_y + 1,
                    0.4,
                    0.4,
                    0,
                    c_white,
                    1
                );
            }


            draw_text_transformed(
                _current_x,
                _start_y,
                option[op],
                _op_scale,
                _op_scale,
                0
            );


            _current_x +=
                _text_w
                +
                _op_spacing;
        }
    }
}


// =========================================================
// TEXTO CARÁCTER POR CARÁCTER
// =========================================================

draw_set_font(
    global.font_main
);


var _time =
    get_timer()
    /
    100000;


for (
    var c = 0;
    c < draw_char;
    c++
)
{
    if (
        char_x[c, page]
        !=
        -9999
    )
    {
        var _c1 =
            c_white;


        var _c2 =
            c_white;


        var _c3 =
            c_white;


        var _c4 =
            c_white;


        if (
            variable_instance_exists(
                id,
                "col_1"
            )
        )
        {
            try
            {
                _c1 =
                    col_1[c, page];


                _c2 =
                    col_2[c, page];


                _c3 =
                    col_3[c, page];


                _c4 =
                    col_4[c, page];
            }
            catch (_exception)
            {
                _c1 =
                    c_white;


                _c2 =
                    c_white;


                _c3 =
                    c_white;


                _c4 =
                    c_white;
            }
        }


        var _draw_x =
            char_x[c, page];


        var _draw_y =
            char_y[c, page];


        var _eff =
            "none";


        if (
            variable_instance_exists(
                id,
                "text_effect"
            )
        )
        {
            try
            {
                _eff =
                    text_effect[c, page];
            }
            catch (_e)
            {
                _eff =
                    "none";
            }
        }


        // =================================================
        // SHAKE
        // =================================================

        if (_eff == "shake")
        {
            _draw_x +=
                random_range(
                    -1,
                    1
                );


            _draw_y +=
                random_range(
                    -1,
                    1
                );
        }


        // =================================================
        // WAVE
        // =================================================

        else if (_eff == "wave")
        {
            _draw_y +=
                sin(
                    (_time + c)
                    *
                    0.5
                )
                *
                3;
        }


        // =================================================
        // BOUNCE
        // =================================================

        else if (_eff == "bounce")
        {
            _draw_y -=
                abs(
                    sin(
                        (_time + c)
                        *
                        0.8
                    )
                )
                *
                4;
        }


        draw_text_transformed_color(
            _draw_x,
            _draw_y,
            char[c, page],
            _txt_scale,
            _txt_scale,
            0,
            _c1,
            _c2,
            _c3,
            _c4,
            1
        );
    }
}
