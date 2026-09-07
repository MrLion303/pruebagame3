if (
    variable_global_exists("gameover_death_freeze_active")
    &&
    global.gameover_death_freeze_active
)
{
    image_speed =
        0;

    exit;
}


// =========================================================
// DEPTH SORT AUTOMÁTICO
// =========================================================
//
// Todos los NPC hijos de obj_parent_npc entran
// automáticamente al sistema.
//
scr_depth_sort_register(
    id
);


// =========================================================
// PARTY
// =========================================================
//
// Para un NPC reclutable, en su Creation Code:
//
//     party_id = "noelle";
//
// Mientras sea miembro de la party, este Step padre deja de
// abrir el diálogo normal. El seguimiento lo hace obj_settings.
// =========================================================

if (!variable_instance_exists(id, "party_id"))
{
    party_id = "";
}

if (!variable_instance_exists(id, "party_member"))
{
    party_member = false;
}

if (!variable_instance_exists(id, "party_follow_suspended"))
{
    party_follow_suspended = false;
}

if (!variable_instance_exists(id, "party_rejoin"))
{
    party_rejoin = false;
}

if (party_member)
{
    exit;
}


// =========================================================
// MEMORIA PERSISTENTE DEL NPC
// =========================================================
//
// Creation Code OPCIONAL:
//
//     npc_memory_id = "gerson";
//
//     npc_dialogues =
//     [
//         "gerson_primera_vez",
//         "gerson_segunda_vez",
//         "gerson_tercera_vez"
//     ];
//
// Si hay más interacciones que diálogos, se repite el último.
//
// Si npc_dialogues no se configura, el NPC sigue utilizando
// `text_id` exactamente como antes.
// =========================================================

scr_npc_memory_init();


if (!variable_instance_exists(id, "npc_memory_id"))
{
    npc_memory_id =
        "";
}


if (
    !is_string(npc_memory_id)
    ||
    npc_memory_id == ""
)
{
    // ID estable para NPCs colocados en el Room Editor.
    // xstart/ystart no cambian aunque el NPC se mueva después.
    npc_memory_id =
        "npc_"
        +
        room_get_name(room)
        +
        "_"
        +
        object_get_name(object_index)
        +
        "_"
        +
        string(round(xstart))
        +
        "_"
        +
        string(round(ystart));
}


if (!variable_instance_exists(id, "npc_dialogues"))
{
    npc_dialogues =
        [];
}


// =========================================================
// PRUEBA DE MEMORIA: NPC 2 / STAR WALKER
// =========================================================
//
// Sin Creation Code adicional:
//
//     1ra interacción -> "npc 2"
//     2da interacción -> "npc 2 - second"
//     3ra+            -> "npc 2 - third"
//
// Se usa una ID fija para que esta prueba conserve su memoria
// incluso si después mueves al NPC dentro del Room Editor.
// =========================================================

if (
    variable_instance_exists(id, "text_id")
    &&
    text_id == "npc 2"
    &&
    (
        !is_array(npc_dialogues)
        ||
        array_length(npc_dialogues) <= 0
    )
)
{
    npc_memory_id =
        "npc 2";


    npc_dialogues =
    [
        "npc 2",
        "npc 2 - second",
        "npc 2 - third"
    ];
}


// Definir la distancia de interacción con los pies (en píxeles)
var _interaction_distance = 32; 

// Comprobar si el jugador presiona Z o Enter
var _interact_key = keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(vk_enter);

// Verificar si el jugador existe en la habitación
if (instance_exists(obj_player))
{
    // Usamos el centro horizontal del NPC, pero para la vertical usamos su PARTE BAJA (los pies)
    var _npc_cx = bbox_left + (bbox_right - bbox_left) / 2;
    var _npc_cy = bbox_bottom; // Base del NPC
     
    var _player_cx = obj_player.bbox_left + (obj_player.bbox_right - obj_player.bbox_left) / 2;
    var _player_cy = obj_player.bbox_top + (obj_player.bbox_bottom - obj_player.bbox_top) / 2;
     
    // Calcular la distancia tomando en cuenta la base del NPC
    var _distance = point_distance(_player_cx, _player_cy, _npc_cx, _npc_cy);
     
    // Verificamos si el menú está cerrado (o si ni siquiera existe el gestor de menús)
    var _is_menu_closed = !instance_exists(obj_menu_manager) || (instance_exists(obj_menu_manager) && obj_menu_manager.state == MENU_STATE.CLOSED);

    // Si el jugador está cerca, presiona la tecla, NO hay caja de texto Y EL MENÚ ESTÁ CERRADO
    if (_distance <= _interaction_distance && _interact_key && !instance_exists(obj_textbox) && _is_menu_closed)
    {
        var _player_facing = obj_player.facing_direction;
        var _is_looking_at_npc = false;
         
        // Diferencias exactas basadas en la nueva posición de los pies del NPC
        var _diff_x = _npc_cx - _player_cx; 
        var _diff_y = _npc_cy - _player_cy; 
         
        // Margen de tolerancia lateral
        var _tolerance = 20; 
         
        switch (_player_facing)
        {
            case 0: // Mirando a la DERECHA
                if (_diff_x > 0 && abs(_diff_y) <= _tolerance) _is_looking_at_npc = true;
                break;
                 
            case 1: // Mirando a la IZQUIERDA
                if (_diff_x < 0 && abs(_diff_y) <= _tolerance) _is_looking_at_npc = true;
                break;
                 
            case 2: // Mirando ABAJO
                if (_diff_y > 0 && abs(_diff_x) <= _tolerance) _is_looking_at_npc = true;
                break;
                 
            case 3: // Mirando ARRIBA
                if (_diff_y < 0 && abs(_diff_x) <= _tolerance) _is_looking_at_npc = true;
                break;
        }
         
        // Si cumple la dirección y está en la zona de los pies, abrir diálogo
        if (_is_looking_at_npc)
        {
            var _dialogue_id =
                text_id;


            // =============================================
            // DIÁLOGO SEGÚN CUÁNTAS VECES YA HABLAMOS
            // =============================================

            if (
                is_array(npc_dialogues)
                &&
                array_length(npc_dialogues) > 0
            )
            {
                var _talk_count =
                    scr_npc_memory_get_talk_count(
                        npc_memory_id
                    );


                var _dialogue_index =
                    clamp(
                        _talk_count,
                        0,
                        array_length(npc_dialogues) - 1
                    );


                _dialogue_id =
                    npc_dialogues[_dialogue_index];
            }


            if (
                is_string(_dialogue_id)
                &&
                _dialogue_id != ""
            )
            {
                create_textbox(
                    _dialogue_id
                );


                // Se recuerda desde el momento en que comenzó
                // correctamente la conversación.
                scr_npc_memory_mark_talk(
                    npc_memory_id
                );
            }
        }
    }
}
