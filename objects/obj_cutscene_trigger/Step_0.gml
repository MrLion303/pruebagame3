/// =========================================================
/// OBJ_CUTSCENE_TRIGGER
/// STEP
/// =========================================================

var _inside =
    place_meeting(
        x,
        y,
        obj_player
    );


scr_cutscene_resume_init();


var _resume_pending =
    global.cutscene_resume_pending;


// No relanzar el trigger mientras estamos volviendo
// de una batalla perteneciente a una cinemática.
if (
    _inside
    &&
    !player_was_inside
    &&
    !instance_exists(obj_cutscene_controller)
    &&
    !_resume_pending
)
{
    if (cutscene_id != "")
    {
        if (one_shot)
        {
            if (!scr_cutscene_was_played(cutscene_id))
            {
                scr_cutscene_start(
                    cutscene_id,
                    true
                );
            }
        }
        else
        {
            scr_cutscene_start(
                cutscene_id,
                false
            );
        }
    }
}


player_was_inside =
    _inside;