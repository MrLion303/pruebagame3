/// =========================================================
/// OBJ_DAMAGE_TEST
/// STEP
/// =========================================================


// =========================================================
// BLOQUEO DURANTE CINEMÁTICAS
// =========================================================
//
// El timer tampoco avanza mientras la cinemática está activa.
// =========================================================

if (scr_cutscene_world_locked())
{
    exit;
}


// =========================================================
// DAÑO NORMAL
// =========================================================

var _p =
    instance_place(
        x,
        y,
        obj_player
    );


if (_p != noone)
{
    timer_dano++;


    if (
        timer_dano
        >=
        tiempo_intervalo
    )
    {
        timer_dano =
            0;


        // 1. Defensa total.
        var _defensa_actual =
            0;


        with (_p)
        {
            _defensa_actual =
                get_jugador_defensa();
        }


        // 2. 1.6% por punto.
        // Tope de 50%.
        var _porcentaje_reduccion =
            min(
                _defensa_actual
                *
                1.6,
                50
            );


        // 3. Daño final.
        var _dano_reducido =
            round(
                dano_base
                *
                (
                    1
                    -
                    (
                        _porcentaje_reduccion
                        /
                        100
                    )
                )
            );


        _dano_reducido =
            max(
                1,
                _dano_reducido
            );


        // 4. Aplicar.
        _p.hp =
            max(
                0,
                _p.hp
                -
                _dano_reducido
            );


        show_debug_message(
            "¡Dano recibido! Base: "
            +
            string(dano_base)
            +
            " | Def: "
            +
            string(_defensa_actual)
            +
            " | Reduccion: "
            +
            string(_porcentaje_reduccion)
            +
            "% | Dano final: "
            +
            string(_dano_reducido)
        );
    }
}
else
{
    timer_dano =
        0;
}
