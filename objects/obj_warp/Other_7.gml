/// =========================================================
/// OBJ_WARP
/// FIN DE LA ANIMACIÓN - COMPLETO
/// =========================================================
//
// MISMO FLUJO PARA TODAS LAS HABITACIONES:
//
// 1. La animación cierra.
// 2. Preparamos una posible cinemática del destino.
// 3. Cambiamos de room.
// 4. Colocamos al jugador y gestionamos música.
// 5. La MISMA animación se reproduce hacia atrás.
// 6. Al terminar de abrir, obj_warp se destruye.
// 7. Si hay cinemática pendiente, el jugador sigue bloqueado
//    hasta que obj_settings la inicie.
// =========================================================

if (!warp_room_changed)
{
    // =====================================================
    // LIMPIEZA DE ENEMIGOS DESTRUIDOS
    // =====================================================

    if (
        !variable_global_exists("viajando_a_batalla")
        ||
        !global.viajando_a_batalla
    )
    {
        global.enemigos_destruidos = {};
    }
    else
    {
        global.viajando_a_batalla = false;
    }


    // =====================================================
    // PREPARAR CINEMÁTICA DEL DESTINO
    // =====================================================
    //
    // IMPORTANTE:
    //
    // Esto NO inicia la cinemática ahora.
    //
    // Solo deja anotado:
    //
    //     target_cutscene
    //     target_rm
    //     target_cutscene_once
    //
    // obj_settings la iniciará cuando esta transición haya
    // terminado completamente.
    //
    // Si target_cutscene == "":
    //     no hace nada.
    //
    // Si ya fue vista y target_cutscene_once == true:
    //     tampoco hace nada.
    // =====================================================

    scr_cutscene_warp_entry_queue(
        target_cutscene,
        target_rm,
        target_cutscene_once
    );


    // =====================================================
    // CAMBIO DE HABITACIÓN
    // =====================================================

    room_goto(target_rm);


    // =====================================================
    // COLOCAR JUGADOR
    // =====================================================

    if (instance_exists(obj_player))
    {
        var _p = instance_find(obj_player, 0);

        _p.x = target_x;
        _p.y = target_y;

        if (variable_instance_exists(_p, "face"))
        {
            _p.face = target_face;
        }

        // El jugador seguirá bloqueado mientras obj_warp
        // exista porque hereda de obj_pauser.
        if (variable_instance_exists(_p, "puede_moverse"))
        {
            _p.puede_moverse = false;
        }

        if (variable_instance_exists(_p, "can_move"))
        {
            _p.can_move = false;
        }
    }


    // =====================================================
    // MÚSICA
    // =====================================================

    if (!keep_music)
    {
        audio_stop_all();

        if (target_music != -1)
        {
            var _new_audio =
                audio_play_sound(
                    target_music,
                    1,
                    true
                );

            audio_sound_gain(
                _new_audio,
                0,
                0
            );

            audio_sound_gain(
                _new_audio,
                1,
                1000
            );
        }
    }


    // =====================================================
    // ABRIR LA MISMA TRANSICIÓN EN EL DESTINO
    // =====================================================

    warp_room_changed = true;

    image_index =
        max(
            0,
            sprite_get_number(sprite_index) - 1
        );

    image_speed =
        -warp_anim_speed;

    exit;
}


// Si GameMaker dispara Animation End también al reproducir
// hacia atrás, cerramos aquí. El Step queda como respaldo.
warp_finish();
