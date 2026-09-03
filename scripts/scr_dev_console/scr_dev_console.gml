
/// =========================================================
/// SCR_DEV_CONSOLE
/// Consola de desarrollador
/// =========================================================

function scr_dev_console_tokenize(_text)
{
    var _out = [];
    var _token = "";
    var _len = string_length(_text);

    for (var _i = 1; _i <= _len; _i++)
    {
        var _ch = string_char_at(_text, _i);

        if (_ch == " " || _ch == "\t")
        {
            if (_token != "")
            {
                array_push(_out, _token);
                _token = "";
            }
        }
        else
        {
            _token += _ch;
        }
    }

    if (_token != "")
        array_push(_out, _token);

    return _out;
}


function scr_dev_console_is_number(_text)
{
    if (!is_string(_text)) return false;

    var _len = string_length(_text);
    if (_len <= 0) return false;

    var _start = 1;
    var _first = string_char_at(_text, 1);

    if (_first == "-" || _first == "+")
    {
        if (_len == 1) return false;
        _start = 2;
    }

    var _has_digit = false;
    var _has_dot = false;

    for (var _i = _start; _i <= _len; _i++)
    {
        var _ch = string_char_at(_text, _i);

        if (_ch >= "0" && _ch <= "9")
        {
            _has_digit = true;
            continue;
        }

        if (_ch == "." && !_has_dot)
        {
            _has_dot = true;
            continue;
        }

        return false;
    }

    return _has_digit;
}


function scr_dev_console_find_room(_name)
{
    var _rooms = asset_get_ids(asset_room);
    var _target = string_lower(string(_name));

    for (var _i = 0; _i < array_length(_rooms); _i++)
    {
        var _room = _rooms[_i];
        if (string_lower(room_get_name(_room)) == _target)
            return _room;
    }

    return -1;
}


function scr_dev_console_find_audio(_name)
{
    var _sounds = asset_get_ids(asset_sound);
    var _target = string_lower(string(_name));

    for (var _i = 0; _i < array_length(_sounds); _i++)
    {
        var _snd = _sounds[_i];
        if (string_lower(audio_get_name(_snd)) == _target)
            return _snd;
    }

    return -1;
}


function scr_dev_console_commands()
{
    return [
        {cmd:"/help",       usage:"/help",                           desc:"Muestra todos los comandos."},
        {cmd:"/tp",         usage:"/tp <x> <y> | /tp <room> [x y]", desc:"Teletransporta a Maya."},
        {cmd:"/where",      usage:"/where",                          desc:"Muestra room y coordenadas."},
        {cmd:"/heal",       usage:"/heal",                           desc:"Cura a Maya al maximo."},
        {cmd:"/kill",       usage:"/kill",                           desc:"Deja a Maya con 0 HP."},
        {cmd:"/winbattle",  usage:"/winbattle",                      desc:"Fuerza la victoria actual."},
        {cmd:"/onehp",      usage:"/onehp",                          desc:"Enemigos vivos a 1 HP."},
        {cmd:"/play",       usage:"/play <mus_* o snd_*>",           desc:"Reproduce musica o sonido."},
        {cmd:"/stopaudio",  usage:"/stopaudio",                      desc:"Detiene todo el audio."},
        {cmd:"/party",      usage:"/party <join|leave> <id>",        desc:"Gestiona la party."},
        {cmd:"/fullscreen", usage:"/fullscreen",                     desc:"Alterna fullscreen."},
        {cmd:"/clear",      usage:"/clear",                          desc:"Limpia el historial."},
        {cmd:"/restart",    usage:"/restart",                        desc:"Reinicia el juego desde cero."},
        {cmd:"/quit",       usage:"/quit",                           desc:"Cierra el juego."}
    ];
}


function scr_dev_console_log(_owner, _text, _color = c_white)
{
    if (_owner == noone || !instance_exists(_owner)) return;

    array_push(_owner.console_log, {
        text: string(_text),
        color: _color
    });

    while (array_length(_owner.console_log) > 12)
        array_delete(_owner.console_log, 0, 1);
}


function scr_dev_console_result(_ok, _message, _close = true)
{
    return {
        ok: _ok,
        message: _message,
        close: _close
    };
}


function scr_dev_console_toggle_fullscreen()
{
    var _new_state = !window_get_fullscreen();
    window_set_fullscreen(_new_state);

    if (variable_global_exists("config_data") && is_struct(global.config_data))
        global.config_data.fullscreen_enabled = _new_state;

    if (instance_exists(obj_menu_manager))
    {
        var _menu = instance_find(obj_menu_manager, 0);

        if (variable_instance_exists(_menu, "fullscreen_enabled"))
            _menu.fullscreen_enabled = _new_state;
    }

    return _new_state;
}


function scr_dev_console_open(_owner)
{
    if (_owner == noone || !instance_exists(_owner)) return false;
    if (_owner.console_open) return true;

    _owner.console_open = true;
    global.dev_console_open = true;

    _owner.console_prev_player = noone;
    _owner.console_prev_puede = true;
    _owner.console_prev_can = true;

    if (instance_exists(obj_player))
    {
        var _p = instance_find(obj_player, 0);
        _owner.console_prev_player = _p;

        if (variable_instance_exists(_p, "puede_moverse"))
        {
            _owner.console_prev_puede = _p.puede_moverse;
            _p.puede_moverse = false;
        }

        if (variable_instance_exists(_p, "can_move"))
        {
            _owner.console_prev_can = _p.can_move;
            _p.can_move = false;
        }
    }

    keyboard_string = "/";
    _owner.console_last_input = "/";
    _owner.console_suggestions = scr_dev_console_get_suggestions("/");
    _owner.console_suggestion_index = 0;

    keyboard_clear(ord("T"));

    return true;
}


function scr_dev_console_close(_owner)
{
    if (_owner == noone || !instance_exists(_owner)) return false;

    _owner.console_open = false;
    global.dev_console_open = false;

    var _p = _owner.console_prev_player;

    if (_p != noone && instance_exists(_p))
    {
        if (variable_instance_exists(_p, "puede_moverse"))
            _p.puede_moverse = _owner.console_prev_puede;

        if (variable_instance_exists(_p, "can_move"))
            _p.can_move = _owner.console_prev_can;
    }

    keyboard_string = "";

    keyboard_clear(vk_enter);
    keyboard_clear(vk_escape);

    return true;
}


function scr_dev_console_get_suggestions(_input)
{
    var _list = [];

    if (!is_string(_input) || string_length(_input) <= 0)
        return _list;

    var _lower = string_lower(_input);

    if (string_char_at(_lower, 1) != "/")
        return _list;

    var _tokens = scr_dev_console_tokenize(_lower);
    var _len = string_length(_lower);
    var _ends_space = (_len > 0 && string_char_at(_lower, _len) == " ");

    // Primer token: comandos.
    if (array_length(_tokens) <= 1 && !_ends_space)
    {
        var _defs = scr_dev_console_commands();

        for (var _i = 0; _i < array_length(_defs); _i++)
        {
            var _def = _defs[_i];

            if (string_starts_with(string_lower(_def.cmd), _lower))
            {
                array_push(_list, {
                    fill: _def.cmd + " ",
                    text: _def.usage,
                    detail: _def.desc
                });
            }
        }

        return _list;
    }

    if (array_length(_tokens) <= 0)
        return _list;

    var _cmd = _tokens[0];

    // /tp -> rooms.
    if (_cmd == "/tp")
    {
        var _partial = "";

        if (array_length(_tokens) >= 2 && !_ends_space)
            _partial = _tokens[1];

        // Si parece numero, esta escribiendo coordenadas.
        if (_partial != "" && scr_dev_console_is_number(_partial))
            return _list;

        var _rooms = asset_get_ids(asset_room);

        for (var _i = 0; _i < array_length(_rooms); _i++)
        {
            var _name = room_get_name(_rooms[_i]);

            if (_partial == "" || string_starts_with(string_lower(_name), _partial))
            {
                array_push(_list, {
                    fill: "/tp " + _name + " ",
                    text: _name,
                    detail: "Habitacion"
                });

                if (array_length(_list) >= 10)
                    break;
            }
        }

        return _list;
    }

    // /play -> mus_* / snd_*.
    if (_cmd == "/play")
    {
        var _partial = "";

        if (array_length(_tokens) >= 2 && !_ends_space)
            _partial = _tokens[1];

        var _sounds = asset_get_ids(asset_sound);

        for (var _i = 0; _i < array_length(_sounds); _i++)
        {
            var _name = audio_get_name(_sounds[_i]);
            var _lname = string_lower(_name);

            var _valid =
                string_starts_with(_lname, "mus_")
                ||
                string_starts_with(_lname, "snd_");

            if (
                _valid
                &&
                (
                    _partial == ""
                    ||
                    string_starts_with(_lname, _partial)
                )
            )
            {
                array_push(_list, {
                    fill: "/play " + _name,
                    text: _name,
                    detail: (string_starts_with(_lname, "mus_") ? "Musica" : "Sonido")
                });

                if (array_length(_list) >= 10)
                    break;
            }
        }

        return _list;
    }

    // /party -> join / leave.
    if (_cmd == "/party")
    {
        if (
            array_length(_tokens) <= 1
            ||
            (
                array_length(_tokens) == 2
                &&
                !_ends_space
            )
        )
        {
            var _partial = "";

            if (array_length(_tokens) == 2)
                _partial = _tokens[1];

            var _ops = ["join", "leave"];

            for (var _i = 0; _i < array_length(_ops); _i++)
            {
                var _op = _ops[_i];

                if (_partial == "" || string_starts_with(_op, _partial))
                {
                    array_push(_list, {
                        fill: "/party " + _op + " ",
                        text: _op,
                        detail: (_op == "join" ? "Unir NPC" : "Quitar miembro")
                    });
                }
            }

            return _list;
        }

        if (
            array_length(_tokens) >= 2
            &&
            _tokens[1] == "leave"
            &&
            variable_global_exists("party_data")
            &&
            is_struct(global.party_data)
            &&
            variable_struct_exists(global.party_data, "members")
        )
        {
            var _partial = "";

            if (array_length(_tokens) >= 3 && !_ends_space)
                _partial = _tokens[2];

            var _members = global.party_data.members;

            for (var _i = 0; _i < array_length(_members); _i++)
            {
                var _member = _members[_i];

                if (is_struct(_member) && variable_struct_exists(_member, "id"))
                {
                    var _id = string(_member.id);

                    if (_partial == "" || string_starts_with(string_lower(_id), _partial))
                    {
                        array_push(_list, {
                            fill: "/party leave " + _id,
                            text: _id,
                            detail: "Miembro actual"
                        });
                    }
                }
            }
        }

        return _list;
    }

    return _list;
}


function scr_dev_console_execute(_owner, _line)
{
    var _line_clean = string_trim(string(_line));

    if (_line_clean == "" || _line_clean == "/")
        return scr_dev_console_result(false, "Escribe un comando.", false);

    if (string_char_at(_line_clean, 1) != "/")
        return scr_dev_console_result(false, "Los comandos deben comenzar con /.", false);

    var _tokens = scr_dev_console_tokenize(_line_clean);

    if (array_length(_tokens) <= 0)
        return scr_dev_console_result(false, "Comando vacio.", false);

    var _cmd = string_lower(_tokens[0]);

    // -----------------------------------------------------
    // HELP
    // -----------------------------------------------------
    if (_cmd == "/help")
    {
        _owner.console_log = [];
        scr_dev_console_log(_owner, "Comandos de desarrollador:", c_yellow);

        var _defs = scr_dev_console_commands();

        for (var _i = 0; _i < array_length(_defs); _i++)
        {
            scr_dev_console_log(
                _owner,
                _defs[_i].usage + " - " + _defs[_i].desc,
                c_white
            );
        }

        return scr_dev_console_result(true, "", false);
    }

    // -----------------------------------------------------
    // WHERE
    // -----------------------------------------------------
    if (_cmd == "/where")
    {
        if (!instance_exists(obj_player))
            return scr_dev_console_result(false, "No existe obj_player.", false);

        var _p = instance_find(obj_player, 0);

        return scr_dev_console_result(
            true,
            room_get_name(room)
            + " | X="
            + string(_p.x)
            + " Y="
            + string(_p.y),
            false
        );
    }

    // -----------------------------------------------------
    // TP
    // -----------------------------------------------------
    if (_cmd == "/tp")
    {
        if (!instance_exists(obj_player))
            return scr_dev_console_result(false, "No existe obj_player.", false);

        var _p = instance_find(obj_player, 0);

        // /tp X Y
        if (
            array_length(_tokens) == 3
            &&
            scr_dev_console_is_number(_tokens[1])
            &&
            scr_dev_console_is_number(_tokens[2])
        )
        {
            _p.x = real(_tokens[1]);
            _p.y = real(_tokens[2]);

            return scr_dev_console_result(
                true,
                "TP -> X=" + string(_p.x) + " Y=" + string(_p.y)
            );
        }

        // /tp ROOM
        // /tp ROOM X Y
        if (array_length(_tokens) == 2 || array_length(_tokens) == 4)
        {
            var _target_room = scr_dev_console_find_room(_tokens[1]);

            if (_target_room == -1)
                return scr_dev_console_result(false, "Room no encontrada: " + _tokens[1], false);

            var _tx = _p.x;
            var _ty = _p.y;

            if (array_length(_tokens) == 4)
            {
                if (
                    !scr_dev_console_is_number(_tokens[2])
                    ||
                    !scr_dev_console_is_number(_tokens[3])
                )
                {
                    return scr_dev_console_result(false, "Uso: /tp <room> [x y]", false);
                }

                _tx = real(_tokens[2]);
                _ty = real(_tokens[3]);
            }

            _owner.console_tp_pending = true;
            _owner.console_tp_room = _target_room;
            _owner.console_tp_x = _tx;
            _owner.console_tp_y = _ty;

            room_goto(_target_room);

            return scr_dev_console_result(
                true,
                "TP -> " + room_get_name(_target_room)
            );
        }

        return scr_dev_console_result(
            false,
            "Uso: /tp <x> <y> | /tp <room> [x y]",
            false
        );
    }

    // -----------------------------------------------------
    // HEAL
    // -----------------------------------------------------
    if (_cmd == "/heal")
    {
        if (!instance_exists(obj_player))
            return scr_dev_console_result(false, "No existe obj_player.", false);

        var _p = instance_find(obj_player, 0);

        if (!variable_instance_exists(_p, "hp_max"))
            return scr_dev_console_result(false, "El jugador no tiene hp_max.", false);

        _p.hp = _p.hp_max;
        global.player_hp_current = _p.hp;

        return scr_dev_console_result(true, "HP restaurado al maximo.");
    }

    // -----------------------------------------------------
    // KILL
    // -----------------------------------------------------
    if (_cmd == "/kill")
    {
        if (!instance_exists(obj_player))
            return scr_dev_console_result(false, "No existe obj_player.", false);

        var _p = instance_find(obj_player, 0);
        _p.hp = 0;
        global.player_hp_current = 0;

        return scr_dev_console_result(true, "Maya ha sido puesta a 0 HP.");
    }

    // -----------------------------------------------------
    // ONEHP
    // -----------------------------------------------------
    if (_cmd == "/onehp")
    {
        if (!instance_exists(obj_batalla_controller))
            return scr_dev_console_result(false, "No hay una batalla activa.", false);

        var _bc = instance_find(obj_batalla_controller, 0);
        var _changed = 0;

        for (var _i = 0; _i < array_length(_bc.enemigos); _i++)
        {
            var _enemy = _bc.enemigos[_i];

            var _dead =
                (
                    variable_struct_exists(_enemy, "derrotado")
                    &&
                    _enemy.derrotado
                )
                ||
                _enemy.vida_actual <= 0;

            if (!_dead)
            {
                _enemy.vida_actual = 1;
                _bc.enemigos[_i] = _enemy;
                _changed++;
            }
        }

        if (instance_exists(obj_batalla_ui))
            obj_batalla_ui.enemigos = _bc.enemigos;

        return scr_dev_console_result(
            true,
            string(_changed) + " enemigo(s) quedaron a 1 HP."
        );
    }

    // -----------------------------------------------------
    // WINBATTLE
    // -----------------------------------------------------
    if (_cmd == "/winbattle")
    {
        if (
            !instance_exists(obj_batalla_controller)
            ||
            !instance_exists(obj_batalla_ui)
        )
        {
            return scr_dev_console_result(false, "No hay una batalla activa.", false);
        }

        var _bc = instance_find(obj_batalla_controller, 0);
        var _ui = instance_find(obj_batalla_ui, 0);

        if (_bc.fase_actual == FASE_BATALLA.VICTORIA)
            return scr_dev_console_result(false, "La batalla ya esta en victoria.", false);

        for (var _i = 0; _i < array_length(_bc.enemigos); _i++)
        {
            _bc.enemigos[_i].vida_actual = 0;
            _bc.enemigos[_i].derrotado = true;

            if (
                variable_instance_exists(_bc, "mapa_enemigos_muertos")
                &&
                ds_exists(_bc.mapa_enemigos_muertos, ds_type_map)
            )
            {
                scr_marcar_enemigo_muerto(
                    _bc.mapa_enemigos_muertos,
                    _i
                );
            }
        }

        _ui.enemigos = _bc.enemigos;
        _ui.en_resultado_ataque = false;
        _ui.en_menu_fight = false;
        _ui.en_seleccion_enemigo = false;

        if (variable_instance_exists(_ui, "en_menu_toys"))
            _ui.en_menu_toys = false;

        if (variable_instance_exists(_ui, "en_menu_inventario"))
            _ui.en_menu_inventario = false;

        _ui.f_iniciar_victoria();
        _bc.fase_actual = FASE_BATALLA.VICTORIA;

        return scr_dev_console_result(true, "Victoria forzada.");
    }

    // -----------------------------------------------------
    // PLAY
    // -----------------------------------------------------
    if (_cmd == "/play")
    {
        if (array_length(_tokens) < 2)
            return scr_dev_console_result(false, "Uso: /play <mus_* o snd_*>", false);

        var _asset = scr_dev_console_find_audio(_tokens[1]);

        if (_asset == -1 || !audio_exists(_asset))
            return scr_dev_console_result(false, "Audio no encontrado: " + _tokens[1], false);

        var _name = audio_get_name(_asset);
        var _loop = string_starts_with(string_lower(_name), "mus_");

        if (_loop)
            scr_save_stop_all_music();

        audio_play_sound(_asset, 10, _loop);

        return scr_dev_console_result(
            true,
            "Reproduciendo " + _name + (_loop ? " (loop)" : "")
        );
    }

    // -----------------------------------------------------
    // STOPAUDIO
    // -----------------------------------------------------
    if (_cmd == "/stopaudio")
    {
        audio_stop_all();
        return scr_dev_console_result(true, "Audio detenido.");
    }

    // -----------------------------------------------------
    // PARTY
    // -----------------------------------------------------
    if (_cmd == "/party")
    {
        if (array_length(_tokens) < 3)
            return scr_dev_console_result(false, "Uso: /party <join|leave> <id>", false);

        var _op = string_lower(_tokens[1]);
        var _party_id = _tokens[2];

        if (_op == "join")
        {
            var _ok = scr_party_join_actor(_party_id);

            return scr_dev_console_result(
                _ok,
                (_ok ? "Se unio a la party: " : "No pude unir a la party: ") + _party_id,
                !_ok
            );
        }

        if (_op == "leave")
        {
            var _ok = scr_party_leave(_party_id, false);

            return scr_dev_console_result(
                _ok,
                (_ok ? "Salio de la party: " : "No pude sacar de la party: ") + _party_id,
                !_ok
            );
        }

        return scr_dev_console_result(false, "Usa join o leave.", false);
    }

    // -----------------------------------------------------
    // FULLSCREEN
    // -----------------------------------------------------
    if (_cmd == "/fullscreen")
    {
        var _state = scr_dev_console_toggle_fullscreen();

        return scr_dev_console_result(
            true,
            (_state ? "Pantalla completa activada." : "Pantalla completa desactivada.")
        );
    }

    // -----------------------------------------------------
    // CLEAR
    // -----------------------------------------------------
    if (_cmd == "/clear")
    {
        _owner.console_log = [];
        return scr_dev_console_result(true, "", false);
    }

    // -----------------------------------------------------
    // RESTART
    // -----------------------------------------------------
    if (_cmd == "/restart")
    {
        game_restart();
        return scr_dev_console_result(true, "Reiniciando...");
    }

    // -----------------------------------------------------
    // QUIT
    // -----------------------------------------------------
    if (_cmd == "/quit")
    {
        game_end();
        return scr_dev_console_result(true, "Cerrando...");
    }

    return scr_dev_console_result(
        false,
        "Comando desconocido: " + _tokens[0] + ". Usa /help.",
        false
    );
}

// =========================================================
// DIBUJAR CONSOLA DESDE EL OBJETO "game"
// =========================================================
//
// NO depende de ningún Draw/Draw GUI de obj_dev_console.
// El objeto persistente "game" llama esta función desde su
// Draw GUI, que ya sabemos que funciona en el proyecto.
// =========================================================

function scr_dev_console_draw()
{
    // -----------------------------------------------------
    // BUSCAR OBJETO DE CONSOLA POR NOMBRE
    // -----------------------------------------------------

    var _console_object =
        asset_get_index(
            "obj_dev_console"
        );


    if (_console_object == -1)
    {
        return;
    }


    if (!instance_exists(_console_object))
    {
        return;
    }


    var _c =
        instance_find(
            _console_object,
            0
        );


    if (_c == noone)
    {
        return;
    }


    if (
        !variable_instance_exists(
            _c,
            "console_open"
        )
        ||
        !_c.console_open
    )
    {
        return;
    }


    // -----------------------------------------------------
    // CONFIGURACIÓN
    // -----------------------------------------------------

    var _gw =
        display_get_gui_width();

    var _gh =
        display_get_gui_height();


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


    draw_set_halign(
        fa_left
    );

    draw_set_valign(
        fa_top
    );


    var _margin =
        8;

    var _input_h =
        42;

    var _input_y =
        _gh
        -
        _input_h
        -
        _margin;

    var _line_h =
        25;

    var _scale =
        0.62;


    // =====================================================
    // OSCURECER LEVEMENTE LA PARTE INFERIOR
    // =====================================================

    draw_set_alpha(
        0.18
    );

    draw_set_color(
        c_black
    );

    draw_rectangle(
        0,
        max(0, _gh - 310),
        _gw,
        _gh,
        false
    );


    draw_set_alpha(
        1
    );


    // =====================================================
    // SUGERENCIAS
    // =====================================================

    var _suggestions =
        (
            variable_instance_exists(
                _c,
                "console_suggestions"
            )
            &&
            is_array(
                _c.console_suggestions
            )
        )
        ?
        _c.console_suggestions
        :
        [];


    var _max_suggestions =
        (
            variable_instance_exists(
                _c,
                "console_max_suggestions_draw"
            )
        )
        ?
        _c.console_max_suggestions_draw
        :
        8;


    var _suggest_count =
        min(
            _max_suggestions,
            array_length(
                _suggestions
            )
        );


    var _selected =
        (
            variable_instance_exists(
                _c,
                "console_suggestion_index"
            )
        )
        ?
        _c.console_suggestion_index
        :
        0;


    var _suggest_y =
        _input_y
        -
        (_suggest_count * _line_h)
        -
        5;


    // =====================================================
    // HISTORIAL / RESPUESTAS
    // =====================================================

    var _log =
        (
            variable_instance_exists(
                _c,
                "console_log"
            )
            &&
            is_array(
                _c.console_log
            )
        )
        ?
        _c.console_log
        :
        [];


    var _log_count =
        min(
            6,
            array_length(
                _log
            )
        );


    var _log_start =
        array_length(
            _log
        )
        -
        _log_count;


    var _log_bottom =
        _suggest_y
        -
        6;


    for (
        var _i = 0;
        _i < _log_count;
        _i++
    )
    {
        var _entry =
            _log[
                _log_start + _i
            ];


        var _ly =
            _log_bottom
            -
            ((_log_count - _i) * _line_h);


        draw_set_alpha(
            0.72
        );

        draw_set_color(
            c_black
        );

        draw_rectangle(
            _margin,
            _ly,
            _gw - _margin,
            _ly + _line_h,
            false
        );


        draw_set_alpha(
            1
        );


        var _entry_color =
            (
                is_struct(_entry)
                &&
                variable_struct_exists(
                    _entry,
                    "color"
                )
            )
            ?
            _entry.color
            :
            c_white;


        var _entry_text =
            (
                is_struct(_entry)
                &&
                variable_struct_exists(
                    _entry,
                    "text"
                )
            )
            ?
            _entry.text
            :
            string(_entry);


        draw_set_color(
            _entry_color
        );


        draw_text_transformed(
            _margin + 7,
            _ly + 4,
            _entry_text,
            _scale,
            _scale,
            0
        );
    }


    // =====================================================
    // AUTOCOMPLETADO
    // =====================================================

    for (
        var _i = 0;
        _i < _suggest_count;
        _i++
    )
    {
        var _suggestion =
            _suggestions[_i];


        var _sy =
            _suggest_y
            +
            (_i * _line_h);


        var _is_selected =
            (_i == _selected);


        draw_set_alpha(
            _is_selected
            ?
            0.92
            :
            0.75
        );

        draw_set_color(
            c_black
        );

        draw_rectangle(
            _margin,
            _sy,
            _gw - _margin,
            _sy + _line_h,
            false
        );


        draw_set_alpha(
            1
        );


        draw_set_color(
            _is_selected
            ?
            c_yellow
            :
            c_white
        );


        var _suggest_text =
            (
                is_struct(_suggestion)
                &&
                variable_struct_exists(
                    _suggestion,
                    "text"
                )
            )
            ?
            _suggestion.text
            :
            string(_suggestion);


        draw_text_transformed(
            _margin + 7,
            _sy + 4,
            _suggest_text,
            _scale,
            _scale,
            0
        );


        if (
            is_struct(_suggestion)
            &&
            variable_struct_exists(
                _suggestion,
                "detail"
            )
        )
        {
            draw_set_halign(
                fa_right
            );

            draw_set_color(
                c_ltgray
            );


            draw_text_transformed(
                _gw - _margin - 7,
                _sy + 4,
                _suggestion.detail,
                _scale * 0.88,
                _scale * 0.88,
                0
            );


            draw_set_halign(
                fa_left
            );
        }
    }


    // =====================================================
    // ETIQUETA
    // =====================================================

    draw_set_alpha(
        0.88
    );

    draw_set_color(
        c_black
    );

    draw_rectangle(
        _margin,
        _input_y - 25,
        _gw - _margin,
        _input_y,
        false
    );


    draw_set_alpha(
        1
    );

    draw_set_color(
        c_yellow
    );


    draw_text_transformed(
        _margin + 7,
        _input_y - 21,
        "DEV CONSOLE",
        _scale * 0.92,
        _scale * 0.92,
        0
    );


    draw_set_halign(
        fa_right
    );

    draw_set_color(
        c_ltgray
    );


    draw_text_transformed(
        _gw - _margin - 7,
        _input_y - 21,
        "TAB completar | Flechas elegir | ESC cerrar",
        _scale * 0.72,
        _scale * 0.72,
        0
    );


    draw_set_halign(
        fa_left
    );


    // =====================================================
    // CAJA DE ENTRADA
    // =====================================================

    // Borde blanco muy visible.
    draw_set_alpha(
        1
    );

    draw_set_color(
        c_white
    );

    draw_rectangle(
        _margin - 2,
        _input_y - 2,
        _gw - _margin + 2,
        _input_y + _input_h + 2,
        false
    );


    // Interior.
    draw_set_color(
        c_black
    );

    draw_rectangle(
        _margin + 1,
        _input_y + 1,
        _gw - _margin - 1,
        _input_y + _input_h - 1,
        false
    );


    // Cursor.
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


    draw_set_color(
        c_white
    );


    draw_text_transformed(
        _margin + 9,
        _input_y + 10,
        keyboard_string
        +
        _cursor,
        _scale,
        _scale,
        0
    );


    // =====================================================
    // RESTAURAR DRAW STATE
    // =====================================================

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
}

