/// =========================================================
/// OBJ_SIGILO_FX
/// STEP - NUEVO
/// =========================================================

var _activo = false;


if (instance_exists(obj_player))
{
    var _p =
        instance_find(
            obj_player,
            0
        );


    _activo =
        (
            _p != noone
            &&
            variable_instance_exists(
                _p,
                "sigilo_activo"
            )
            &&
            _p.sigilo_activo
        );
}


if (_activo)
{
    sigilo_anim =
        min(
            1,
            sigilo_anim
            +
            sigilo_anim_speed
        );
}
else
{
    sigilo_anim =
        max(
            0,
            sigilo_anim
            -
            sigilo_anim_speed
        );
}
