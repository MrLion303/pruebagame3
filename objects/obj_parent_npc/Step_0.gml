/// =========================================================
/// OBJ_PARENT_NPC - STEP
/// =========================================================


// =========================================================
// PARTY
// =========================================================

if (!variable_instance_exists(id, "party_id"))
{
    party_id =
        "";
}


if (!variable_instance_exists(id, "party_member"))
{
    party_member =
        false;
}


if (!variable_instance_exists(id, "party_follow_suspended"))
{
    party_follow_suspended =
        false;
}


if (!variable_instance_exists(id, "party_rejoin"))
{
    party_rejoin =
        false;
}


// IMPORTANTÍSIMO:
// mientras pertenece a la party, este padre NO toca nada.
// Posición, sprite y animación pertenecen al party system.
if (party_member)
{
    exit;
}


// =========================================================
// NPC NORMAL
// =========================================================

var _interaction_distance =
    32;

var _interact_key =
    keyboard_check_pressed(ord("Z"))
    ||
    keyboard_check_pressed(vk_enter);


if (instance_exists(obj_player))
{
    var _npc_cx =
        bbox_left
        +
        (bbox_right - bbox_left) / 2;

    var _npc_cy =
        bbox_bottom;


    var _player_cx =
        obj_player.bbox_left
        +
        (obj_player.bbox_right - obj_player.bbox_left) / 2;

    var _player_cy =
        obj_player.bbox_top
        +
        (obj_player.bbox_bottom - obj_player.bbox_top) / 2;


    var _distance =
        point_distance(
            _player_cx,
            _player_cy,
            _npc_cx,
            _npc_cy
        );


    var _is_menu_closed =
        !instance_exists(obj_menu_manager)
        ||
        obj_menu_manager.state == MENU_STATE.CLOSED;


    if (
        _distance <= _interaction_distance
        &&
        _interact_key
        &&
        !instance_exists(obj_textbox)
        &&
        _is_menu_closed
    )
    {
        var _player_facing =
            obj_player.facing_direction;

        var _is_looking_at_npc =
            false;


        var _diff_x =
            _npc_cx - _player_cx;

        var _diff_y =
            _npc_cy - _player_cy;


        var _tolerance =
            20;


        switch (_player_facing)
        {
            case 0:
                if (
                    _diff_x > 0
                    &&
                    abs(_diff_y) <= _tolerance
                )
                {
                    _is_looking_at_npc = true;
                }
                break;


            case 1:
                if (
                    _diff_x < 0
                    &&
                    abs(_diff_y) <= _tolerance
                )
                {
                    _is_looking_at_npc = true;
                }
                break;


            case 2:
                if (
                    _diff_y > 0
                    &&
                    abs(_diff_x) <= _tolerance
                )
                {
                    _is_looking_at_npc = true;
                }
                break;


            case 3:
                if (
                    _diff_y < 0
                    &&
                    abs(_diff_x) <= _tolerance
                )
                {
                    _is_looking_at_npc = true;
                }
                break;
        }


        if (_is_looking_at_npc)
        {
            create_textbox(
                text_id
            );
        }
    }
}
