
/// =========================================================
/// OBJ_DEV_CONSOLE - DRAW GUI
/// =========================================================

if (!console_open)
    exit;

var _gw = display_get_gui_width();
var _gh = display_get_gui_height();

if (variable_global_exists("font_main"))
    draw_set_font(global.font_main);

draw_set_halign(fa_left);
draw_set_valign(fa_top);

var _margin = 8;
var _input_h = 34;
var _input_y = _gh - _input_h - _margin;
var _line_h = 21;
var _scale = console_scale;


// =========================================================
// SUGERENCIAS
// =========================================================

var _suggest_count = min(
    console_max_suggestions_draw,
    array_length(console_suggestions)
);

var _suggest_y =
    _input_y
    -
    (_suggest_count * _line_h)
    -
    4;


// =========================================================
// LOG
// =========================================================

var _log_bottom = _suggest_y - 5;

var _log_count = min(
    6,
    array_length(console_log)
);

var _log_start =
    array_length(console_log)
    -
    _log_count;


for (var _i = 0; _i < _log_count; _i++)
{
    var _entry =
        console_log[
            _log_start + _i
        ];

    var _ly =
        _log_bottom
        -
        ((_log_count - _i) * _line_h);

    draw_set_alpha(0.55);
    draw_set_color(c_black);

    draw_rectangle(
        _margin,
        _ly,
        _gw - _margin,
        _ly + _line_h,
        false
    );

    draw_set_alpha(1);
    draw_set_color(_entry.color);

    draw_text_transformed(
        _margin + 5,
        _ly + 3,
        _entry.text,
        _scale,
        _scale,
        0
    );
}


// =========================================================
// LISTA DE AUTOCOMPLETADO
// =========================================================

for (var _i = 0; _i < _suggest_count; _i++)
{
    var _suggestion = console_suggestions[_i];
    var _sy = _suggest_y + (_i * _line_h);

    draw_set_alpha(
        (_i == console_suggestion_index ? 0.82 : 0.65)
    );

    draw_set_color(c_black);

    draw_rectangle(
        _margin,
        _sy,
        _gw - _margin,
        _sy + _line_h,
        false
    );

    draw_set_alpha(1);

    draw_set_color(
        (_i == console_suggestion_index ? c_yellow : c_white)
    );

    draw_text_transformed(
        _margin + 5,
        _sy + 3,
        _suggestion.text,
        _scale,
        _scale,
        0
    );

    draw_set_halign(fa_right);
    draw_set_color(c_ltgray);

    draw_text_transformed(
        _gw - _margin - 5,
        _sy + 3,
        _suggestion.detail,
        _scale * 0.9,
        _scale * 0.9,
        0
    );

    draw_set_halign(fa_left);
}


// =========================================================
// INPUT
// =========================================================

// Borde exterior visible.
draw_set_alpha(
    1
);

draw_set_color(
    c_white
);

draw_rectangle(
    _margin - 1,
    _input_y - 1,
    _gw - _margin + 1,
    _input_y + _input_h + 1,
    true
);


draw_set_alpha(0.78);
draw_set_color(c_black);

draw_rectangle(
    _margin,
    _input_y,
    _gw - _margin,
    _input_y + _input_h,
    false
);

draw_set_alpha(1);

var _cursor =
    (
        (current_time div 400)
        mod
        2
        ==
        0
    )
    ?
    "_"
    :
    "";

draw_set_color(c_white);

draw_text_transformed(
    _margin + 7,
    _input_y + 8,
    keyboard_string + _cursor,
    _scale,
    _scale,
    0
);


// Etiqueta visible.
draw_set_halign(
    fa_left
);

draw_set_color(
    c_yellow
);

draw_text_transformed(
    _margin + 3,
    _input_y - 18,
    "DEV CONSOLE",
    _scale * 0.8,
    _scale * 0.8,
    0
);


// Ayuda pequeña.
draw_set_halign(fa_right);
draw_set_color(c_ltgray);

draw_text_transformed(
    _gw - _margin - 5,
    _input_y - 18,
    "Tab: completar   Arriba/Abajo: sugerencias   Esc: cerrar",
    _scale * 0.8,
    _scale * 0.8,
    0
);


// Restaurar draw state.
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_alpha(1);
draw_set_color(c_white);
