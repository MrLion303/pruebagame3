/// =========================================================
/// OBJ_SAVE
/// STEP
/// =========================================================


// =========================================================
// PLAYER
// =========================================================

if (!instance_exists(obj_player))
{
    exit;
}


var _p =
    instance_find(
        obj_player,
        0
    );


// =========================================================
// ESPERAR A QUE TERMINE EL DIÁLOGO
// =========================================================
//
// Cuando desaparece obj_textbox:
//
//     abrir automáticamente obj_save_menu
//
// =========================================================

if (save_waiting_dialogue)
{
    // Mantener al jugador bloqueado.
    if (
        variable_instance_exists(
            _p,
            "puede_moverse"
        )
    )
    {
        _p.puede_moverse =
            false;
    }


    if (
        variable_instance_exists(
            _p,
            "can_move"
        )
    )
    {
        _p.can_move =
            false;
    }


    // Todavía estamos leyendo.
    if (
        save_dialogue_textbox != noone
        &&
        instance_exists(
            save_dialogue_textbox
        )
    )
    {
        exit;
    }


    // =========================================
    // TERMINÓ EL TEXTBOX
    // =========================================

    save_waiting_dialogue =
        false;

    save_dialogue_textbox =
        noone;


    // Abrir interfaz de guardado.
    if (
        !instance_exists(obj_save_menu)
        &&
        instance_exists(obj_menu_manager)
        &&
        obj_menu_manager.state
        ==
        MENU_STATE.CLOSED
    )
    {
        instance_create_depth(
            0,
            0,
            -9999,
            obj_save_menu
        );


        audio_play_sound(
            snd_menumove,
            10,
            false
        );


        keyboard_clear(
            ord("Z")
        );

        keyboard_clear(
            vk_enter
        );
    }


    exit;
}


// =========================================================
// NO INTERACTUAR SI HAY OTRA INTERFAZ
// =========================================================

if (instance_exists(obj_save_menu))
{
    exit;
}


if (instance_exists(obj_textbox))
{
    exit;
}


if (
    !instance_exists(obj_menu_manager)
    ||
    obj_menu_manager.state
    !=
    MENU_STATE.CLOSED
)
{
    exit;
}


// =========================================================
// CONFIRMAR
// =========================================================

var _confirm =
    keyboard_check_pressed(
        ord("Z")
    )
    ||
    keyboard_check_pressed(
        vk_enter
    );


if (!_confirm)
{
    exit;
}


// =========================================================
// DISTANCIA
// =========================================================

if (distance_to_object(obj_player) >= 8)
{
    exit;
}


// =========================================================
// OBTENER CONFIGURACIÓN DEL DIÁLOGO
// =========================================================

var _dialogue_data =
    scr_save_dialogue_data(
        save_dialogue_id
    );


// Fallback absoluto.
if (
    !is_struct(_dialogue_data)
    ||
    !variable_struct_exists(
        _dialogue_data,
        "lines"
    )
    ||
    !is_array(
        _dialogue_data.lines
    )
)
{
    _dialogue_data =
        scr_save_dialogue_data(
            "default"
        );
}


var _repeatable =
    false;


if (
    variable_struct_exists(
        _dialogue_data,
        "repeatable"
    )
)
{
    _repeatable =
        _dialogue_data.repeatable;
}


var _dialogue =
    _dialogue_data.lines;


// =========================================================
// ID ÚNICA DEL PUNTO
// =========================================================
//
// Solo importa para diálogos NO repetibles.
//
// Se genera automáticamente:
//
//     save_intro_<room>_<x>_<y>
//
// No necesitas asignar IDs manualmente.
// =========================================================

var _once_id =
    save_dialogue_once_id;


if (
    !is_string(_once_id)
    ||
    _once_id == ""
)
{
    _once_id =
        "save_intro_"
        +
        room_get_name(room)
        +
        "_"
        +
        string(round(x))
        +
        "_"
        +
        string(round(y));
}


// =========================================================
// DECIDIR SI HAY QUE MOSTRAR EL DIÁLOGO
// =========================================================
//
// REPETIBLE:
//
//     siempre true
//
// NO REPETIBLE:
//
//     solamente si todavía no está marcado
//
// =========================================================

var _show_dialogue =
    _repeatable;


if (!_repeatable)
{
    _show_dialogue =
        !scr_cutscene_was_played(
            _once_id
        );
}


// =========================================================
// MOSTRAR DIÁLOGO
// =========================================================

if (
    _show_dialogue
    &&
    array_length(_dialogue) > 0
)
{
    // =========================================
    // CREAR TEXTBOX
    // =========================================

    save_dialogue_textbox =
        instance_create_depth(
            0,
            0,
            -9999,
            obj_textbox
        );


    // =========================================
    // AÑADIR TODAS LAS PÁGINAS
    // =========================================

    for (
        var _i = 0;
        _i < array_length(_dialogue);
        _i++
    )
    {
        var _line =
            _dialogue[_i];


        var _texto =
            "";

        var _head =
            noone;

        var _snd =
            snd_text;

        var _color =
            c_white;


        if (
            is_struct(_line)
            &&
            variable_struct_exists(
                _line,
                "texto"
            )
        )
        {
            _texto =
                scr_loc(
                    _line.texto
                );
        }


        if (
            is_struct(_line)
            &&
            variable_struct_exists(
                _line,
                "head"
            )
        )
        {
            _head =
                _line.head;
        }


        if (
            is_struct(_line)
            &&
            variable_struct_exists(
                _line,
                "snd"
            )
        )
        {
            _snd =
                _line.snd;
        }


        if (
            is_struct(_line)
            &&
            variable_struct_exists(
                _line,
                "color"
            )
        )
        {
            _color =
                _line.color;
        }


        scr_text(
            _texto,
            _color,
            _head,
            _snd
        );
    }


    // =========================================
    // MARCAR COMO VISTO
    // =========================================
    //
    // SOLO si el diálogo es NO repetible.
    //
    // Los repetibles jamás se marcan, por lo que vuelven
    // a mostrarse en cada interacción.
    // =========================================

    if (!_repeatable)
    {
        scr_cutscene_mark_played(
            _once_id
        );
    }


    // =========================================
    // BLOQUEAR PLAYER
    // =========================================

    if (
        variable_instance_exists(
            _p,
            "puede_moverse"
        )
    )
    {
        _p.puede_moverse =
            false;
    }


    if (
        variable_instance_exists(
            _p,
            "can_move"
        )
    )
    {
        _p.can_move =
            false;
    }


    save_waiting_dialogue =
        true;


    audio_play_sound(
        snd_menumove,
        10,
        false
    );


    keyboard_clear(
        ord("Z")
    );

    keyboard_clear(
        vk_enter
    );


    exit;
}


// =========================================================
// SIN DIÁLOGO PENDIENTE
// -> ABRIR SAVE DIRECTAMENTE
// =========================================================
//
// Esto ocurre cuando:
//
// - el diálogo NO repetible ya fue visto;
// - o por seguridad el diálogo no tiene páginas.
//
// =========================================================

if (!instance_exists(obj_save_menu))
{
    instance_create_depth(
        0,
        0,
        -9999,
        obj_save_menu
    );


    audio_play_sound(
        snd_menumove,
        10,
        false
    );
}
