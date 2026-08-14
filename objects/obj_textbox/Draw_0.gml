accept_key = keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(vk_enter);
skip_key = keyboard_check_pressed(ord("X")) || keyboard_check_pressed(vk_shift) || keyboard_check_pressed(vk_control);

var _fast_skip_key = keyboard_check(ord("C")) || keyboard_check(vk_control);
var _is_decision = (variable_instance_exists(id, "page_number") && variable_instance_exists(id, "option_number") && option_number > 0 && page == page_number - 1);

if (!variable_instance_exists(id, "page_number") || page_number <= 0) exit;
if (!variable_instance_exists(id, "text") || !is_array(text)) exit;

var _cam_x = camera_get_view_x(view_camera[0]);
var _cam_y = camera_get_view_y(view_camera[0]);
var _cam_w = camera_get_view_width(view_camera[0]);

textbox_x = _cam_x + (_cam_w - textbox_width) / 2; 
textbox_y = _cam_y + camera_get_view_height(view_camera[0]) - textbox_height - 16;

var _txt_scale = 0.55; 
var _has_speaker = (page < array_length(speaker_sprite) && speaker_sprite[page] != noone && speaker_sprite[page] >= 0);
var _left_margin = _has_speaker ? (border + 75) : (border + 10); 
var _available_width = textbox_width - _left_margin - border;

if setup == false
{
    setup = true;
    draw_set_font(global.font_main);
    draw_set_valign(fa_top);
    draw_set_halign(fa_left);
    
    for(var p = 0; p < page_number; p++)
    {
        text_lenght[p] = string_length(text[p]);
        text_x_offset[p] = 0;
        
        line_break_num[p] = 0;
        
        var _last_space = -1;
        var _line_start_char = 1;
        
        var _p_has_speaker = (p < array_length(speaker_sprite) && speaker_sprite[p] != noone && speaker_sprite[p] >= 0);
        var _p_left_margin = _p_has_speaker ? (border + 75) : (border + 10);
        var _p_avail_width = textbox_width - _p_left_margin - border;
        
        for(var c = 1; c <= text_lenght[p]; c++)
        {
            var _char_current = string_char_at(text[p], c);
            
            if (_char_current == " ") {
                _last_space = c;
            }
            
            var _sub_str = string_copy(text[p], _line_start_char, c - _line_start_char + 1);
            var _str_w = string_width(_sub_str) * _txt_scale;
            
            if (_str_w > _p_avail_width)
            {
                if (_last_space != -1 && _last_space >= _line_start_char)
                {
                    line_break_pos[line_break_num[p], p] = _last_space + 1;
                    line_break_num[p]++;
                    _line_start_char = _last_space + 1;
                    _last_space = -1;
                }
                else
                {
                    line_break_pos[line_break_num[p], p] = c;
                    line_break_num[p]++;
                    _line_start_char = c;
                }
            }
        }
        
        for(var c = 0; c < text_lenght[p]; c++)
        {
            var _char_pos = c + 1;
            char[c, p] = string_char_at(text[p], _char_pos);
            
            var _txt_x = textbox_x + _p_left_margin;
            var _txt_y = textbox_y + border;
            
            var _txt_line = 0;
            var _line_start_pos = 1;
            
            for(var lb = 0; lb < line_break_num[p]; lb++)
            {
                if _char_pos >= line_break_pos[lb, p]
                {
                    _txt_line = lb + 1;
                    _line_start_pos = line_break_pos[lb, p];
                }
            }
            
            if (_line_start_pos == _char_pos && char[c, p] == " ") {
                char_x[c, p] = -9999;
                char_y[c, p] = -9999;
                continue;
            }
            
            var _str_copy = string_copy(text[p], _line_start_pos, _char_pos - _line_start_pos + 1);
            var _current_txt_w = string_width(_str_copy) * _txt_scale;
            
            char_x[c, p] = _txt_x + _current_txt_w - (string_width(char[c, p]) * _txt_scale);
            char_y[c, p] = _txt_y + (_txt_line * 17);
        }
    }
}

if (page >= page_number) page = page_number - 1;
if (page < 0) page = 0;

if (!is_array(text_lenght)) text_lenght = array_create(page_number, 0);
if (array_length(text_lenght) <= page) {
    array_resize(text_lenght, page_number);
}
if (is_undefined(text_lenght[page])) {
    text_lenght[page] = 0;
}

if (draw_char < text_lenght[page])
{
    var _current_char_checking = string_char_at(text[page], floor(draw_char));
    var _is_punctuation = (_current_char_checking == "." || _current_char_checking == "," || _current_char_checking == "!" || _current_char_checking == "?");
    
    var _actual_speed = _fast_skip_key ? 999 : (_is_punctuation ? 0.08 : text_spd);
    
    draw_char += _actual_speed;
    draw_char = clamp(draw_char, 0, text_lenght[page]);
    
    if (floor(draw_char) > 0 && floor(draw_char) <= text_lenght[page])
    {
        var _char_to_speak = string_char_at(text[page], floor(draw_char));
        if (_char_to_speak != " ")
        {
            if (!_is_punctuation && !_fast_skip_key)
            {
                text_sound_timer++;
            }
            
            if (text_sound_timer >= text_sound_delay || _fast_skip_key)
            {
                text_sound_timer = 0;
                
                var _current_sound = (page < array_length(text_sound) && text_sound[page] != undefined) ? text_sound[page] : snd_text;
                
                if (audio_exists(_current_sound) && !_fast_skip_key) {
                    audio_play_sound(_current_sound, 1, false);
                }
            }
        }
    }
    
    if (skip_key || _fast_skip_key)
    {
        draw_char = text_lenght[page];
    }
}
else if (accept_key || (_fast_skip_key && !_is_decision))
{
    if (draw_char >= text_lenght[page]) {
        if page < page_number - 1
        {
            page++;
            draw_char = 0;
        }
        else
        {
            if variable_instance_exists(id, "option_number") && option_number > 0 {
                create_textbox(option_link_id[option_pos]);
            }
            instance_destroy();
            exit;
        }
    }
}

var _txtb_x = textbox_x;
var _txtb_y = textbox_y;
txtb_img += txtb_img_spd;

var _current_txtb_spr = (page < array_length(txtb_spr) && txtb_spr[page] != undefined) ? txtb_spr[page] : spr_textbox;
txtb_spr_w = sprite_get_width(_current_txtb_spr);
txtb_spr_h = sprite_get_height(_current_txtb_spr);

draw_sprite_ext(_current_txtb_spr, txtb_img, _txtb_x, _txtb_y, textbox_width/txtb_spr_w, textbox_height/txtb_spr_h, 0, c_white, 1);

var _safe_speaker = (page < array_length(speaker_sprite)) ? speaker_sprite[page] : noone;
if (_safe_speaker != noone && _safe_speaker >= 0)
{
    draw_sprite(_safe_speaker, 0, _txtb_x + border + 4, _txtb_y + border + 4);
}

// Opciones
if (variable_instance_exists(id, "option_number") && option_number > 0)
{
    if (draw_char == text_lenght[page] && page == page_number - 1)
    {
        draw_set_font(global.font_main);
        option_pos += keyboard_check_pressed(vk_right) - keyboard_check_pressed(vk_left);
        option_pos = clamp(option_pos, 0, option_number - 1);
        
        var _op_scale = 0.45;
        var _op_spacing = 10; 
        var _total_options_width = 0;
        
        for (var op = 0; op < option_number; op++)
        {
            _total_options_width += (string_width(option[op]) * _op_scale);
            if (op < option_number - 1) {
                _total_options_width += _op_spacing;
            }
        }
        
        var _start_x = textbox_x + (textbox_width - _total_options_width) / 2;
        var _start_y = textbox_y + textbox_height - border - 18; 
        var _current_x = _start_x;
        
        for (var op = 0; op < option_number; op++)
        {
            var _text_w = string_width(option[op]) * _op_scale;
            
            if option_pos == op 
            {
                draw_sprite_ext(spr_textbox_arrow, 0, _current_x - 7, _start_y + 1, 0.4, 0.4, 0, c_white, 1);
            }
            
            draw_text_transformed(_current_x, _start_y, option[op], _op_scale, _op_scale, 0);
            _current_x += _text_w + _op_spacing;
        }
    }
}

// Dibujar el texto carácter por carácter con colores y efectos aplicados
draw_set_font(global.font_main);
var _time = get_timer() / 100000;

for (var c = 0; c < draw_char; c++)
{
    if (char_x[c, page] != -9999) {
        var _c1 = c_white;
        var _c2 = c_white;
        var _c3 = c_white;
        var _c4 = c_white;
        
        if (variable_instance_exists(id, "col_1")) {
            try {
                _c1 = col_1[c, page];
                _c2 = col_2[c, page];
                _c3 = col_3[c, page];
                _c4 = col_4[c, page];
            } catch(_exception) {
                _c1 = c_white;
                _c2 = c_white;
                _c3 = c_white;
                _c4 = c_white;
            }
        }
        
        var _draw_x = char_x[c, page];
        var _draw_y = char_y[c, page];
        
        var _eff = "none";
        if (variable_instance_exists(id, "text_effect")) {
            try {
                _eff = text_effect[c, page];
            } catch(_e) {
                _eff = "none";
            }
        }
        
        if (_eff == "shake") {
            _draw_x += random_range(-1, 1);
            _draw_y += random_range(-1, 1);
        }
        else if (_eff == "wave") {
            _draw_y += sin((_time + c) * 0.5) * 3;
        }
        else if (_eff == "bounce") {
            _draw_y -= abs(sin((_time + c) * 0.8)) * 4;
        }
        
        draw_text_transformed_color(_draw_x, _draw_y, char[c, page], _txt_scale, _txt_scale, 0, _c1, _c2, _c3, _c4, 1);
    }
}