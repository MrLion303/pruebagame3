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
            create_textbox(text_id);
        }
    }
}