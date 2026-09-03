
/// =========================================================
/// OBJ_DEV_CONSOLE - STEP
/// =========================================================

// TP pendiente después de room_goto.
if (
    console_tp_pending
    &&
    room == console_tp_room
    &&
    instance_exists(obj_player)
)
{
    var _p = instance_find(obj_player, 0);

    _p.x = console_tp_x;
    _p.y = console_tp_y;

    console_tp_pending = false;
}


// F4 = fullscreen global.
if (keyboard_check_pressed(vk_f4))
{
    scr_dev_console_toggle_fullscreen();
}


// =========================================================
// CONSOLA ABIERTA
// =========================================================

if (console_open)
{
    global.dev_console_open = true;

    if (instance_exists(obj_player))
    {
        var _p = instance_find(obj_player, 0);

        if (variable_instance_exists(_p, "puede_moverse"))
            _p.puede_moverse = false;

        if (variable_instance_exists(_p, "can_move"))
            _p.can_move = false;
    }


    // Siempre empieza por "/".
    if (keyboard_string == "")
        keyboard_string = "/";

    if (string_char_at(keyboard_string, 1) != "/")
        keyboard_string = "/" + keyboard_string;

    if (string_length(keyboard_string) > console_max_input)
    {
        keyboard_string = string_copy(
            keyboard_string,
            1,
            console_max_input
        );
    }


    // Recalcular sugerencias al escribir.
    if (keyboard_string != console_last_input)
    {
        console_last_input = keyboard_string;
        console_suggestions = scr_dev_console_get_suggestions(keyboard_string);
        console_suggestion_index = 0;
    }


    var _count = array_length(console_suggestions);

    if (_count > 0)
    {
        console_suggestion_index = clamp(
            console_suggestion_index,
            0,
            _count - 1
        );
    }
    else
    {
        console_suggestion_index = 0;
    }


    // Arriba / abajo = seleccionar sugerencia.
    if (_count > 0 && keyboard_check_pressed(vk_up))
    {
        console_suggestion_index--;

        if (console_suggestion_index < 0)
            console_suggestion_index = _count - 1;
    }


    if (_count > 0 && keyboard_check_pressed(vk_down))
    {
        console_suggestion_index++;

        if (console_suggestion_index >= _count)
            console_suggestion_index = 0;
    }


    // Tab = completar.
    if (_count > 0 && keyboard_check_pressed(vk_tab))
    {
        var _suggestion = console_suggestions[console_suggestion_index];

        keyboard_string = _suggestion.fill;
        console_last_input = keyboard_string;

        console_suggestions = scr_dev_console_get_suggestions(
            keyboard_string
        );

        console_suggestion_index = 0;

        keyboard_clear(vk_tab);
    }


    // Esc = cerrar.
    if (keyboard_check_pressed(vk_escape))
    {
        scr_dev_console_close(id);
        exit;
    }


    // Enter = ejecutar.
    if (keyboard_check_pressed(vk_enter))
    {
        var _line = keyboard_string;

        scr_dev_console_log(
            id,
            _line,
            c_ltgray
        );

        var _result = scr_dev_console_execute(
            id,
            _line
        );

        if (_result.message != "")
        {
            scr_dev_console_log(
                id,
                _result.message,
                (_result.ok ? c_white : c_red)
            );
        }

        keyboard_clear(vk_enter);

        if (_result.close)
        {
            scr_dev_console_close(id);
        }
        else
        {
            keyboard_string = "/";
            console_last_input = "/";
            console_suggestions = scr_dev_console_get_suggestions("/");
            console_suggestion_index = 0;
        }

        exit;
    }


    // Capturar controles normales.
    keyboard_clear(ord("Z"));
    keyboard_clear(ord("X"));
    keyboard_clear(ord("C"));
    keyboard_clear(vk_enter);
    keyboard_clear(vk_shift);
    keyboard_clear(vk_left);
    keyboard_clear(vk_right);
    keyboard_clear(vk_up);
    keyboard_clear(vk_down);

    exit;
}


// =========================================================
// CONSOLA CERRADA
// =========================================================

global.dev_console_open = false;


// Ctrl + F3 / Ctrl + F3 + T.
var _ctrl = keyboard_check(vk_control);

if (_ctrl && keyboard_check_pressed(vk_f3))
{
    if (keyboard_check(ord("T")))
    {
        ctrl_f3_pending = false;
        ctrl_f3_used_for_console = true;

        scr_dev_console_open(id);


        if (instance_exists(obj_player))
        {
            var _console_player =
                instance_find(
                    obj_player,
                    0
                );


            if (
                variable_instance_exists(
                    _console_player,
                    "movimiento"
                )
            )
            {
                _console_player.movimiento =
                    false;
            }


            _console_player.image_index =
                0;
        }


        exit;
    }

    ctrl_f3_pending = true;
    ctrl_f3_used_for_console = false;
}


// Mientras Ctrl+F3 está sostenido, T abre la consola.
if (
    ctrl_f3_pending
    &&
    _ctrl
    &&
    keyboard_check(vk_f3)
    &&
    keyboard_check_pressed(ord("T"))
)
{
    ctrl_f3_pending = false;
    ctrl_f3_used_for_console = true;

    scr_dev_console_open(id);
    exit;
}


// Si se soltó F3 sin T, alternar debug.
if (
    ctrl_f3_pending
    &&
    keyboard_check_released(vk_f3)
)
{
    ctrl_f3_pending =
        false;


    if (!ctrl_f3_used_for_console)
    {
        // En este proyecto el objeto se llama literalmente "game".
        // Lo buscamos por nombre para evitar referencias inválidas.
        var _game_object =
            asset_get_index(
                "game"
            );


        if (
            _game_object != -1
            &&
            instance_exists(
                _game_object
            )
        )
        {
            var _game =
                instance_find(
                    _game_object,
                    0
                );


            if (
                _game != noone
                &&
                variable_instance_exists(
                    _game,
                    "mostrar_info"
                )
            )
            {
                _game.mostrar_info =
                    !_game.mostrar_info;
            }
        }
    }


    ctrl_f3_used_for_console =
        false;
}
