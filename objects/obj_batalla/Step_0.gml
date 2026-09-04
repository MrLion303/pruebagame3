/// =========================================================
/// OBJ_BATALLA
/// STEP
/// =========================================================


// =========================================================
// BLOQUEO DURANTE CINEMÁTICAS
// =========================================================

if (scr_cutscene_world_locked())
{
    exit;
}


// =========================================================
// LÓGICA NORMAL
// =========================================================

if (esta_activo)
{
    var _p =
        instance_place(
            x,
            y,
            obj_player
        );


    if (_p != noone)
    {
        // Verificar que no exista ya una transición.
        if (!instance_exists(obj_transicion_bbs))
        {
            // ---------------------------------------------
            // CONGELAR AL JUGADOR
            // ---------------------------------------------

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


            if (
                variable_instance_exists(
                    _p,
                    "hsp"
                )
            )
            {
                _p.hsp =
                    0;
            }


            if (
                variable_instance_exists(
                    _p,
                    "vsp"
                )
            )
            {
                _p.vsp =
                    0;
            }


            // ---------------------------------------------
            // RETORNO
            // ---------------------------------------------

            global.return_room =
                room;

            global.return_x =
                _p.x;

            global.return_y =
                _p.y;


            global.enemigo_actual_id =
                enemigo_id;


            // ---------------------------------------------
            // ENEMIGOS DESTRUIDOS
            // ---------------------------------------------

            if (
                !variable_global_exists(
                    "enemigos_destruidos"
                )
            )
            {
                global.enemigos_destruidos =
                    {};
            }


            var _id_unico =
                string(room)
                +
                "_"
                +
                string(x)
                +
                "_"
                +
                string(y);


            global.enemigos_destruidos[$ _id_unico] =
                true;


            global.viajando_a_batalla =
                true;


            // ---------------------------------------------
            // TRANSICIÓN
            // ---------------------------------------------

            audio_play_sound(
                snd_bbs_start,
                10,
                false
            );


            instance_create_layer(
                0,
                0,
                layer,
                obj_transicion_bbs
            );


            instance_destroy();
        }
    }
}
