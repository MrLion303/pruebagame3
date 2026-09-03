function scr_set_defaults_for_text() {
    if (!variable_instance_exists(id, "txtb_spr")) {
        txtb_spr = [spr_textbox];
    }
    if (array_length(txtb_spr) <= page_number) {
        array_resize(txtb_spr, page_number + 1);
    }
    txtb_spr[page_number] = spr_textbox;
    
    if (!variable_instance_exists(id, "speaker_sprite")) {
        speaker_sprite = [noone];
    }
    if (array_length(speaker_sprite) <= page_number) {
        array_resize(speaker_sprite, page_number + 1);
    }
    speaker_sprite[page_number] = noone;
    
    if (!variable_instance_exists(id, "text_sound")) {
        text_sound = [snd_text];
    }
    if (array_length(text_sound) <= page_number) {
        array_resize(text_sound, page_number + 1);
    }
    text_sound[page_number] = snd_text;

    // Inicializar de forma segura los colores y efectos para CADA página nueva
    for (var c = 0; c < 500; c++) {
        col_1[c, page_number] = c_white;
        col_2[c, page_number] = c_white;
        col_3[c, page_number] = c_white;
        col_4[c, page_number] = c_white;
        text_effect[c, page_number] = "none";
    }
    
    line_break_pos[0, page_number] = 999;
    line_break_num[page_number] = 0;
    line_break_offset[page_number] = 0;
    speaker_side[page_number] = 1;
}

/// @param text
/// @param [color]
/// @param [speaker_sprite]
/// @param [text_sound]
function scr_text(_text, _color = c_white, _speaker_spr = noone, _sound = snd_text){
    with (obj_textbox)
    {
        scr_set_defaults_for_text();
        
        text[page_number] = _text;
        
        if (!variable_instance_exists(id, "text_color")) {
            text_color = array_create(page_number + 1, c_white);
        }
        if (array_length(text_color) <= page_number) {
            array_resize(text_color, page_number + 1);
        }
        text_color[page_number] = _color;
        
        speaker_sprite[page_number] = _speaker_spr;
        text_sound[page_number] = (_speaker_spr == noone || _speaker_spr < 0) ? snd_text : _sound;
        
        if (!variable_instance_exists(id, "is_multi_color")) {
            is_multi_color = array_create(page_number + 1, false);
        }
        if (array_length(is_multi_color) <= page_number) {
            array_resize(is_multi_color, page_number + 1);
        }
        is_multi_color[page_number] = false;
        
        text_lenght[page_number] = string_length(_text);
        page_number++;
    }
}

// -------- TEXT VFX (COLOR) --------
function scr_text_color(_start, _end, _col1, _col2, _col3, _col4){
    with (obj_textbox) {
        var _len = string_length(text[page_number - 1]);
        var _safe_end = min(_end, _len - 1);
        
        for (var c = _start; c <= _safe_end; c++)
        {
            col_1[c, page_number - 1] = _col1;
            col_2[c, page_number - 1] = _col2;
            col_3[c, page_number - 1] = _col3;
            col_4[c, page_number - 1] = _col4;
        }
    }
}

function scr_text_multi(_t1, _c1, _t2, _c2) {
    with (obj_textbox) {
        text[page_number] = _t1 + _t2; 
        
        if (!variable_instance_exists(id, "is_multi_color")) {
            is_multi_color = array_create(page_number + 1, false);
        }
        if (array_length(is_multi_color) <= page_number) {
            array_resize(is_multi_color, page_number + 1);
        }
        is_multi_color[page_number] = true;
        
        if (!variable_instance_exists(id, "multi_part1")) multi_part1 = [];
        if (!variable_instance_exists(id, "multi_color1")) multi_color1 = [];
        if (!variable_instance_exists(id, "multi_part2")) multi_part2 = [];
        if (!variable_instance_exists(id, "multi_color2")) multi_color2 = [];
        
        multi_part1[page_number] = _t1;
        multi_color1[page_number] = _c1;
        multi_part2[page_number] = _t2;
        multi_color2[page_number] = _c2;
        
        page_number++;
        text_lenght[page_number - 1] = string_length(text[page_number - 1]);
    }
}

// -------- NUEVOS EFECTOS DE TEXTO (SHAKE, WAVE, BOUNCE) --------
function scr_text_shake(_start, _end) {
    with (obj_textbox) {
        var _len = string_length(text[page_number - 1]);
        var _safe_end = min(_end, _len - 1);
        
        if (!variable_instance_exists(id, "text_effect")) {
            text_effect = [];
        }
        
        for (var c = _start; c <= _safe_end; c++) {
            text_effect[c, page_number - 1] = "shake";
        }
    }
}

function scr_text_wave(_start, _end) {
    with (obj_textbox) {
        var _len = string_length(text[page_number - 1]);
        var _safe_end = min(_end, _len - 1);
        
        if (!variable_instance_exists(id, "text_effect")) {
            text_effect = [];
        }
        
        for (var c = _start; c <= _safe_end; c++) {
            text_effect[c, page_number - 1] = "wave";
        }
    }
}

function scr_text_bounce(_start, _end) {
    with (obj_textbox) {
        var _len = string_length(text[page_number - 1]);
        var _safe_end = min(_end, _len - 1);
        
        if (!variable_instance_exists(id, "text_effect")) {
            text_effect = [];
        }
        
        for (var c = _start; c <= _safe_end; c++) {
            text_effect[c, page_number - 1] = "bounce";
        }
    }
}

function scr_option(_option, _link_id) {
    option[option_number] = _option;
    option_link_id[option_number] = _link_id;
    option_number++;
}


/// =========================================================
/// REUTILIZAR UNA OBJ_TEXTBOX SIN DESTRUIRLA
/// =========================================================
///
/// Se usa para:
/// - elecciones de diálogos normales;
/// - páginas consecutivas de cinemáticas.
///
/// IMPORTANTE:
/// NO reinicia txtb_img. La animación visual de la caja
/// continúa desde el mismo punto y nunca hay un frame vacío.
/// =========================================================

function scr_textbox_clear_content(_textbox)
{
    if (
        _textbox == noone
        ||
        !instance_exists(_textbox)
    )
    {
        return false;
    }


    with (_textbox)
    {
        if (
            variable_instance_exists(id, "page_extra_instance")
            &&
            page_extra_instance != -1
            &&
            variable_instance_exists(id, "page_extra_stop_current")
            &&
            page_extra_stop_current
            &&
            audio_is_playing(page_extra_instance)
        )
        {
            audio_stop_sound(page_extra_instance);
        }


        page = 0;
        page_number = 0;

        text = [""];
        text_lenght = [0];
        text_color = [c_white];

        txtb_spr = [spr_textbox];
        speaker_sprite = [noone];
        text_sound = [snd_text];

        char = [];
        char_x = [];
        char_y = [];

        col_1 = [];
        col_2 = [];
        col_3 = [];
        col_4 = [];

        text_effect = [];

        line_break_pos = [];
        line_break_num = [];
        line_break_offset = [];
        speaker_side = [];
        text_x_offset = [];

        is_multi_color = [];
        multi_part1 = [];
        multi_color1 = [];
        multi_part2 = [];
        multi_color2 = [];

        draw_char = 0;
        setup = false;

        text_sound_timer = 0;

        option = [""];
        option_link_id = [-1];
        option_pos = 0;
        option_number = 0;

        page_extra_sound = [];
        page_extra_stop = [];
        page_extra_gain = [];

        page_extra_active_page = -1;
        page_extra_instance = -1;
        page_extra_stop_current = true;

        cutscene_dialog_complete = false;

        textbox_reload_pending = false;
        textbox_reload_id = "";

        scr_set_defaults_for_text();
    }


    return true;
}


function scr_textbox_load_existing(_textbox, _text_id)
{
    if (!scr_textbox_clear_content(_textbox))
    {
        return false;
    }


    with (_textbox)
    {
        text_id = _text_id;

        scr_game_text(
            _text_id
        );


        if (page_number > 0)
        {
            text_lenght[0] =
                string_length(
                    text[0]
                );
        }


        setup = false;
        draw_char = 0;
    }


    return true;
}


function create_textbox(_text_id) {
    var _txt = instance_create_depth(0, 0, -9999, obj_textbox);
    with(_txt)
    {
        text_id = _text_id;
        scr_game_text(_text_id); 
        
        if (page_number > 0) {
            text_lenght[0] = string_length(text[0]);
        }
    }
}
