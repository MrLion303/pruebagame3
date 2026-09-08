/// =========================================================
/// OBJ_SAVE
/// STEP
/// =========================================================


// =========================================================
// SINCRONIZAR COLISIÓN CON EL SPRITE
// =========================================================

if (
    collision_proxy == noone
    ||
    !instance_exists(
        collision_proxy
    )
)
{
    collision_proxy =
        scr_puzzle_collision_proxy_create(
            id
        );
}


scr_puzzle_collision_proxy_sync(
    id,
    collision_proxy
);


// `scr_puzzle_collision_proxy_sync` respeta mask_index del
// dueño. Para obj_save queremos específicamente el tamaño y
// máscara de SU SPRITE visible.
if (
    collision_proxy != noone
    &&
    instance_exists(collision_proxy)
)
{
    collision_proxy.sprite_index =
        sprite_index;

    collision_proxy.mask_index =
        sprite_index;
}


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
// BLOQUEO DE LA MISMA PULSACIÓN QUE CERRÓ EL MENÚ
// =========================================================

var _pause_menu =
    instance_find(
        obj_menu_manager,
        0
    );


if (
    _pause_menu != noone
    &&
    variable_instance_exists(
        _pause_menu,
        "interaction_release_block"
    )
    &&
    _pause_menu.interaction_release_block > 0
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
// INTERACCIÓN DIRECCIONAL ESTRICTA
// =========================================================
//
// El punto de guardado debe estar LITERALMENTE en la línea
// hacia la que mira el sprite de Maya.
//
// No usamos:
//     distance_to_object()
//     rectángulos amplios
//     proximidad lateral
//
// Usamos una línea recta muy corta desde el centro de la
// hitbox del player.
//
// Ejemplo:
//
//     SAVE debajo de Maya
//     Maya mirando derecha
//
//     -> la línea sale a la derecha
//     -> NO toca el save
//     -> NO hay interacción.
//
// facing_direction:
//
//     0 = derecha
//     1 = izquierda
//     2 = abajo
//     3 = arriba
// =========================================================

var _look =
    variable_instance_exists(
        _p,
        "facing_direction"
    )
    ?
    _p.facing_direction
    :
    2;


// Centro físico del player.
var _look_start_x =
    (
        _p.bbox_left
        +
        _p.bbox_right
    )
    *
    0.5;


var _look_start_y =
    (
        _p.bbox_top
        +
        _p.bbox_bottom
    )
    *
    0.5;


// Alcance corto de interacción.
//
// Como obj_save es una colisión/obstáculo, Maya queda
// pegada a él y esta distancia es suficiente sin permitir
// interacción desde lados incorrectos.
var _look_reach =
    18;


var _look_dx =
    0;


var _look_dy =
    0;


switch (_look)
{
    // DERECHA
    case 0:
        _look_dx =
            _look_reach;
        break;


    // IZQUIERDA
    case 1:
        _look_dx =
            -_look_reach;
        break;


    // ABAJO
    case 2:
        _look_dy =
            _look_reach;
        break;


    // ARRIBA
    case 3:
        _look_dy =
            -_look_reach;
        break;
}


// La línea solo comprueba ESTA instancia concreta de obj_save.
var _save_mirado =
    collision_line(
        _look_start_x,
        _look_start_y,
        _look_start_x
        +
        _look_dx,
        _look_start_y
        +
        _look_dy,
        id,
        true,
        false
    );


if (_save_mirado == noone)
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
