/// =========================================================
/// OBJ_SIGILO_FX
/// END STEP - NUEVO
/// =========================================================
///
/// Si Sigilo y el peligro de un enemigo coinciden:
///
///     - conservamos el HUD / enemigos / proyectiles del
///       sistema de peligro;
///     - anulamos ÚNICAMENTE su rectángulo negro general;
///     - nuestra propia oscuridad circular sigue visible.
///
/// =========================================================

if (!instance_exists(obj_player))
{
    exit;
}


var _p =
    instance_find(
        obj_player,
        0
    );


var _activo =
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


if (
    _activo
    &&
    instance_exists(
        obj_mapa_combate_fx
    )
)
{
    with (obj_mapa_combate_fx)
    {
        oscuridad_base =
            0;
    }
}
