/// =========================================================
/// OBJ_BUTTONS_CONTINUE
/// ROOM START
/// =========================================================

if (
    newgame_transition_active
    &&
    newgame_transition_phase == 2
)
{
    if (!instance_exists(obj_player))
    {
        instance_create_layer(
            newgame_x,
            newgame_y,
            "Player",
            obj_player
        );
    }


    if (instance_exists(obj_player))
    {
        obj_player.x =
            newgame_x;


        obj_player.y =
            newgame_y;


        if (
            variable_instance_exists(
                obj_player,
                "puede_moverse"
            )
        )
        {
            obj_player.puede_moverse =
                false;
        }


        if (
            variable_instance_exists(
                obj_player,
                "can_move"
            )
        )
        {
            obj_player.can_move =
                false;
        }
    }


    newgame_transition_progress =
        1;


    newgame_transition_phase =
        3;
}