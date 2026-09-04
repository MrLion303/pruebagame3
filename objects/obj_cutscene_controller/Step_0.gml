/// =========================================================
/// OBJ_CUTSCENE_CONTROLLER
/// BLOQUEO DURANTE MUERTE
/// =========================================================
//
// Este bloque es lo ÚNICO nuevo para el sistema de Game Over.
// Si Maya llegó a 0 HP, la cinemática queda completamente
// congelada durante los 30 frames previos a game_over.
//
// Todo el resto del Step conserva exactamente la versión
// anterior que ya usábamos con party + diálogos.
// =========================================================

if (
    variable_global_exists(
        "gameover_death_freeze_active"
    )
    &&
    global.gameover_death_freeze_active
)
{
    exit;
}


/// =========================================================
/// OBJ_CUTSCENE_CONTROLLER
/// STEP
/// =========================================================

if (!ready)
    exit;


// =========================================================
// ACTUALIZAR FADE DE IMAGEN
// =========================================================

if (cutscene_image_transition_active)
{
    if (cutscene_image_alpha < cutscene_image_target_alpha)
    {
        cutscene_image_alpha = min(
            cutscene_image_target_alpha,
            cutscene_image_alpha + cutscene_image_fade_speed
        );
    }
    else if (cutscene_image_alpha > cutscene_image_target_alpha)
    {
        cutscene_image_alpha = max(
            cutscene_image_target_alpha,
            cutscene_image_alpha - cutscene_image_fade_speed
        );
    }

    if (cutscene_image_alpha == cutscene_image_target_alpha)
    {
        cutscene_image_transition_active = false;
        cutscene_image_waiting = false;

        if (
            cutscene_image_remove_when_done
            &&
            cutscene_image_alpha <= 0
        )
        {
            cutscene_image_sprite = noone;
            cutscene_image_remove_when_done = false;
        }
    }
}


// =========================================================
// ACTUALIZAR CÁMARA
// =========================================================

if (camera_task_active && camera_valid)
{
    var _cam_x = camera_get_view_x(cutscene_camera);
    var _cam_y = camera_get_view_y(cutscene_camera);

    var _cam_dist = point_distance(
        _cam_x,
        _cam_y,
        camera_target_x,
        camera_target_y
    );

    if (_cam_dist <= camera_move_speed)
    {
        camera_set_view_pos(
            cutscene_camera,
            camera_target_x,
            camera_target_y
        );

        camera_task_active = false;
        camera_waiting = false;

        if (camera_restore_target_when_done)
        {
            camera_restore_target_when_done = false;
            camera_custom_active = false;

            camera_set_view_target(
                cutscene_camera,
                camera_original_target
            );
        }
    }
    else
    {
        var _cam_dir = point_direction(
            _cam_x,
            _cam_y,
            camera_target_x,
            camera_target_y
        );

        _cam_x += lengthdir_x(camera_move_speed, _cam_dir);
        _cam_y += lengthdir_y(camera_move_speed, _cam_dir);

        camera_set_view_pos(
            cutscene_camera,
            _cam_x,
            _cam_y
        );
    }
}


// =========================================================
// FINALIZAR JOIN PROGRAMADO AL TERMINAR UN MOVE TASK
// =========================================================

var _finish_party_join_task =
function(_actor, _task)
{
    if (
        !variable_struct_exists(
            _task,
            "party_join_on_arrival"
        )
        ||
        !_task.party_join_on_arrival
    )
    {
        return;
    }


    if (
        variable_struct_exists(
            _task,
            "party_join_seed_history"
        )
        &&
        _task.party_join_seed_history
    )
    {
        scr_party_seed_history_behind_player();
    }


    var _join_id =
        "";


    if (
        variable_struct_exists(
            _task,
            "party_join_id"
        )
    )
    {
        _join_id =
            _task.party_join_id;
    }


    if (
        !scr_party_smart_join(
            _actor,
            _join_id
        )
    )
    {
        show_debug_message(
            "[CUTSCENE] Falló join al llegar: "
            +
            string(_join_id)
        );
    }
};


// =========================================================
// MOVIMIENTOS ACTIVOS DE ACTORES
// =========================================================

for (var _i = array_length(move_tasks) - 1; _i >= 0; _i--)
{
    var _task = move_tasks[_i];
    var _actor_move = scr_cutscene_actor(_task.actor);

    if (
        _actor_move == noone
        ||
        !instance_exists(_actor_move)
    )
    {
        array_delete(move_tasks, _i, 1);
        continue;
    }

    // Movimiento corto: dejamos un frame de caminata.
    if (_task.arrived)
    {
        if (_task.anim_speed > 0)
        {
            _actor_move.image_speed = _task.old_image_speed;

            if (
                _actor_move.sprite_index != -1
                &&
                sprite_exists(_actor_move.sprite_index)
            )
            {
                _actor_move.image_index = 0;
            }
        }

        if (_actor_move.object_index == obj_player)
        {
            _actor_move.cutscene_motion_active = false;

            if (variable_instance_exists(_actor_move, "puede_moverse"))
                _actor_move.puede_moverse = player_can_move;

            if (variable_instance_exists(_actor_move, "can_move"))
                _actor_move.can_move = player_can_move;
        }

        _finish_party_join_task(
            _actor_move,
            _task
        );

        array_delete(move_tasks, _i, 1);
        continue;
    }

    var _dx = _task.x - _actor_move.x;
    var _dy = _task.y - _actor_move.y;

    var _distance = point_distance(
        _actor_move.x,
        _actor_move.y,
        _task.x,
        _task.y
    );

    if (_distance <= 0.001)
    {
        if (_task.anim_speed > 0)
        {
            _actor_move.image_speed = _task.old_image_speed;

            if (
                _actor_move.sprite_index != -1
                &&
                sprite_exists(_actor_move.sprite_index)
            )
            {
                _actor_move.image_index = 0;
            }
        }

        if (_actor_move.object_index == obj_player)
        {
            _actor_move.cutscene_motion_active = false;

            if (variable_instance_exists(_actor_move, "puede_moverse"))
                _actor_move.puede_moverse = player_can_move;

            if (variable_instance_exists(_actor_move, "can_move"))
                _actor_move.can_move = player_can_move;
        }

        _finish_party_join_task(
            _actor_move,
            _task
        );

        array_delete(move_tasks, _i, 1);
        continue;
    }

    // Dirección automática.
    if (abs(_dx) >= abs(_dy))
    {
        if (_dx > 0)
            scr_cutscene_face_actor(_actor_move, "derecha");
        else
            scr_cutscene_face_actor(_actor_move, "izquierda");
    }
    else
    {
        if (_dy > 0)
            scr_cutscene_face_actor(_actor_move, "abajo");
        else
            scr_cutscene_face_actor(_actor_move, "arriba");
    }

    // Animación desde el primer píxel.
    if (
        _task.anim_speed > 0
        &&
        _actor_move.sprite_index != -1
        &&
        sprite_exists(_actor_move.sprite_index)
    )
    {
        var _frame_count = sprite_get_number(_actor_move.sprite_index);

        if (_frame_count > 1)
        {
            _actor_move.image_speed = 0;

            if (
                !_task.anim_started
                ||
                _actor_move.image_index < 1
                ||
                _actor_move.image_index >= _frame_count
            )
            {
                _actor_move.image_index = 1;
                _task.anim_started = true;
            }
            else
            {
                _actor_move.image_index += _task.anim_speed;

                if (_actor_move.image_index >= _frame_count)
                    _actor_move.image_index = 1;
            }
        }
    }

    _task.walk_frames++;

    if (_distance <= _task.speed)
    {
        _actor_move.x = _task.x;
        _actor_move.y = _task.y;

        if (
            _task.anim_speed > 0
            &&
            _task.walk_frames <= 1
        )
        {
            _task.arrived = true;
            continue;
        }

        if (_task.anim_speed > 0)
        {
            _actor_move.image_speed = _task.old_image_speed;

            if (
                _actor_move.sprite_index != -1
                &&
                sprite_exists(_actor_move.sprite_index)
            )
            {
                _actor_move.image_index = 0;
            }
        }

        if (_actor_move.object_index == obj_player)
        {
            _actor_move.cutscene_motion_active = false;

            if (variable_instance_exists(_actor_move, "puede_moverse"))
                _actor_move.puede_moverse = player_can_move;

            if (variable_instance_exists(_actor_move, "can_move"))
                _actor_move.can_move = player_can_move;
        }

        _finish_party_join_task(
            _actor_move,
            _task
        );

        array_delete(move_tasks, _i, 1);
        continue;
    }

    var _direction = point_direction(
        _actor_move.x,
        _actor_move.y,
        _task.x,
        _task.y
    );

    _actor_move.x += lengthdir_x(_task.speed, _direction);
    _actor_move.y += lengthdir_y(_task.speed, _direction);


    // =====================================================
    // DEPTH TOP-DOWN PARA ACTOR PARTY-CAPABLE EN CINEMÁTICA
    // =====================================================
    //
    // Antes de pertenecer a la party, Silicio también puede
    // cruzar delante/detrás de Maya correctamente.
    // =====================================================

    if (
        _actor_move.object_index != obj_player
        &&
        variable_instance_exists(
            _actor_move,
            "party_id"
        )
        &&
        instance_exists(obj_player)
    )
    {
        var _depth_player =
            instance_find(
                obj_player,
                0
            );


        if (
            scr_party_feet_y(_actor_move)
            >
            scr_party_feet_y(_depth_player)
            +
            0.5
        )
        {
            _actor_move.depth =
                _depth_player.depth
                -
                1;
        }
        else
        {
            _actor_move.depth =
                _depth_player.depth
                +
                1;
        }
    }
}


// =========================================================
// ESPERAS
// =========================================================

if (wait_timer > 0)
{
    wait_timer--;
    exit;
}

if (cutscene_image_waiting)
    exit;

if (camera_waiting && camera_task_active)
    exit;

if (waiting_dialogue)
{
    if (instance_exists(obj_textbox))
    {
        var _wait_textbox =
            instance_find(
                obj_textbox,
                0
            );


        var _belongs_to_this_cutscene =
            (
                _wait_textbox != noone
                &&
                variable_instance_exists(
                    _wait_textbox,
                    "cutscene_owner"
                )
                &&
                _wait_textbox.cutscene_owner == id
            );


        var _dialog_finished =
            (
                _belongs_to_this_cutscene
                &&
                variable_instance_exists(
                    _wait_textbox,
                    "cutscene_dialog_complete"
                )
                &&
                _wait_textbox.cutscene_dialog_complete
            );


        if (!_dialog_finished)
        {
            dialogue_seen =
                true;

            exit;
        }


        waiting_dialogue =
            false;

        dialogue_seen =
            false;

        dialogue_grace =
            0;
    }
    else
    {
        if (
            dialog_extra_sound_stop_with_dialog
            &&
            dialog_extra_sound_instance != -1
            &&
            audio_is_playing(dialog_extra_sound_instance)
        )
        {
            audio_stop_sound(dialog_extra_sound_instance);
        }


        dialog_extra_sound_instance =
            -1;

        dialog_extra_sound_stop_with_dialog =
            true;


        if (
            !dialogue_seen
            &&
            dialogue_grace > 0
        )
        {
            dialogue_grace--;
            exit;
        }


        waiting_dialogue =
            false;

        dialogue_seen =
            false;

        dialogue_grace =
            0;
    }
}

if (waiting_sound_instance != -1)
{
    if (audio_is_playing(waiting_sound_instance))
        exit;

    waiting_sound_instance = -1;
}

if (waiting_task_id != -1)
{
    var _still_exists = false;

    for (var _t = 0; _t < array_length(move_tasks); _t++)
    {
        if (move_tasks[_t].id == waiting_task_id)
        {
            _still_exists = true;
            break;
        }
    }

    if (_still_exists)
        exit;

    waiting_task_id = -1;
}


// =========================================================
// NO HAY MÁS ACCIONES
// =========================================================

if (action_index >= array_length(actions))
{
    if (!missing_end_warned)
    {
        missing_end_warned = true;

        show_debug_message(
            "[CUTSCENE] ERROR: "
            +
            string(cutscene_id)
            +
            " llegó al final sin cs_end()."
        );
    }

    exit;
}


var _action = actions[action_index];


// =========================================================
// CERRAR CAJA SOLO CUANDO TERMINA LA CADENA
// =========================================================

if (
    _action.type != CS_ACTION.DIALOG
    &&
    instance_exists(obj_textbox)
)
{
    var _held_textbox =
        instance_find(
            obj_textbox,
            0
        );


    if (
        _held_textbox != noone
        &&
        variable_instance_exists(
            _held_textbox,
            "cutscene_owner"
        )
        &&
        _held_textbox.cutscene_owner == id
        &&
        variable_instance_exists(
            _held_textbox,
            "cutscene_dialog_complete"
        )
        &&
        _held_textbox.cutscene_dialog_complete
    )
    {
        _held_textbox.cutscene_keep_instance =
            false;

        instance_destroy(
            _held_textbox
        );
    }
}


switch (_action.type)
{
    // =====================================================
    // WAIT
    // =====================================================

    case CS_ACTION.WAIT:

        wait_timer = _action.frames;
        action_index++;

        break;


    // =====================================================
    // DIALOG
    // =====================================================
    //
    // Los CS_ACTION.DIALOG consecutivos se agrupan como
    // PÁGINAS DE LA MISMA obj_textbox.
    //
    // Esto evita que la caja desaparezca/reaparezca entre
    // líneas de una misma cadena de diálogo.
    // =====================================================

    case CS_ACTION.DIALOG:

        var _textbox =
            noone;


        if (instance_exists(obj_textbox))
        {
            var _candidate =
                instance_find(
                    obj_textbox,
                    0
                );


            if (
                _candidate != noone
                &&
                variable_instance_exists(
                    _candidate,
                    "cutscene_owner"
                )
                &&
                _candidate.cutscene_owner == id
                &&
                variable_instance_exists(
                    _candidate,
                    "cutscene_dialog_complete"
                )
                &&
                _candidate.cutscene_dialog_complete
            )
            {
                _textbox =
                    _candidate;

                scr_textbox_clear_content(
                    _textbox
                );
            }
            else
            {
                exit;
            }
        }


        if (_textbox == noone)
        {
            if (layer_get_id("Instances") != -1)
            {
                _textbox =
                    instance_create_layer(
                        0,
                        0,
                        "Instances",
                        obj_textbox
                    );
            }
            else
            {
                _textbox =
                    instance_create_depth(
                        0,
                        0,
                        -100000,
                        obj_textbox
                    );
            }


            scr_textbox_clear_content(
                _textbox
            );
        }


        _textbox.depth =
            -100000;

        _textbox.cutscene_keep_instance =
            true;

        _textbox.cutscene_owner =
            id;

        _textbox.cutscene_dialog_complete =
            false;


        var _dialog_text =
            scr_loc(
                _action.text
            );


        with (_textbox)
        {
            scr_text(
                _dialog_text,
                _action.color,
                _action.head,
                _action.snd
            );


            page_extra_sound =
                [
                    _action.extra_sound
                ];

            page_extra_stop =
                [
                    _action.stop_extra_with_dialog
                ];

            page_extra_gain =
                [
                    _action.extra_gain
                ];

            page_extra_active_page =
                -1;

            page_extra_instance =
                -1;

            page_extra_stop_current =
                true;

            setup =
                false;

            draw_char =
                0;
        }


        dialog_extra_sound_instance =
            -1;

        dialog_extra_sound_stop_with_dialog =
            true;


        waiting_dialogue =
            true;

        dialogue_seen =
            true;

        dialogue_grace =
            0;


        action_index++;


        break;


    // =====================================================
    // MOVE / MOVE_REL
    // =====================================================

    case CS_ACTION.MOVE:
    case CS_ACTION.MOVE_REL:

        var _actor_new_move = scr_cutscene_actor(_action.actor);

        if (_actor_new_move == noone)
        {
            show_debug_message(
                "[CUTSCENE] Actor no encontrado: "
                +
                string(_action.actor)
            );

            action_index++;
            break;
        }

        // PARTY:
        // si este actor pertenece al grupo, la cinemática toma
        // control individual de él y el follow automático deja
        // de moverlo hasta terminar la cinemática.
        scr_party_cutscene_take_control(
            _actor_new_move
        );


        var _target_x;
        var _target_y;

        if (_action.type == CS_ACTION.MOVE)
        {
            _target_x = _action.x;
            _target_y = _action.y;
        }
        else
        {
            _target_x = _actor_new_move.x + _action.dx;
            _target_y = _actor_new_move.y + _action.dy;
        }

        var _start_dx = _target_x - _actor_new_move.x;
        var _start_dy = _target_y - _actor_new_move.y;

        if (abs(_start_dx) >= abs(_start_dy))
        {
            if (_start_dx > 0)
                scr_cutscene_face_actor(_actor_new_move, "derecha");
            else if (_start_dx < 0)
                scr_cutscene_face_actor(_actor_new_move, "izquierda");
        }
        else
        {
            if (_start_dy > 0)
                scr_cutscene_face_actor(_actor_new_move, "abajo");
            else if (_start_dy < 0)
                scr_cutscene_face_actor(_actor_new_move, "arriba");
        }

        var _task_id = next_task_id++;

        var _task_new = {
            id: _task_id,
            actor: _action.actor,
            x: _target_x,
            y: _target_y,
            speed: _action.speed,
            anim_speed: _action.anim_speed,
            old_image_speed: _actor_new_move.image_speed,
            anim_started: false,
            walk_frames: 0,
            arrived: false
        };

        if (
            _action.anim_speed > 0
            &&
            _actor_new_move.sprite_index != -1
            &&
            sprite_exists(_actor_new_move.sprite_index)
        )
        {
            var _initial_frames = sprite_get_number(_actor_new_move.sprite_index);

            if (_initial_frames > 1)
            {
                _actor_new_move.image_speed = 0;
                _actor_new_move.image_index = 1;
                _task_new.anim_started = true;
            }
        }

        array_push(move_tasks, _task_new);

        if (_actor_new_move.object_index == obj_player)
        {
            _actor_new_move.cutscene_motion_active = true;

            // Aunque sea una cinemática interactiva, durante un
            // movimiento programado el player no puede pelearse
            // contra el script usando las flechas.
            if (variable_instance_exists(_actor_new_move, "puede_moverse"))
                _actor_new_move.puede_moverse = false;

            if (variable_instance_exists(_actor_new_move, "can_move"))
                _actor_new_move.can_move = false;
        }

        if (_action.wait)
            waiting_task_id = _task_id;

        action_index++;

        break;


    // =====================================================
    // WAIT MOVES
    // =====================================================

    case CS_ACTION.WAIT_MOVES:

        if (array_length(move_tasks) <= 0)
            action_index++;

        break;


    // =====================================================
    // CAMERA MOVE
    // =====================================================

    case CS_ACTION.CAMERA_MOVE:

        if (!camera_valid)
        {
            action_index++;
            break;
        }

        if (!camera_custom_active)
        {
            camera_original_target = camera_get_view_target(cutscene_camera);
            camera_set_view_target(cutscene_camera, noone);
            camera_custom_active = true;
        }

        var _current_cam_x = camera_get_view_x(cutscene_camera);
        var _current_cam_y = camera_get_view_y(cutscene_camera);

        camera_target_x = _current_cam_x + _action.dx;
        camera_target_y = _current_cam_y + _action.dy;
        camera_move_speed = _action.speed;
        camera_restore_target_when_done = false;
        camera_task_active = true;
        camera_waiting = _action.wait;

        action_index++;

        break;


    // =====================================================
    // CAMERA RESET
    // =====================================================

    case CS_ACTION.CAMERA_RESET:

        if (!camera_valid)
        {
            action_index++;
            break;
        }

        if (!camera_custom_active)
        {
            action_index++;
            break;
        }

        camera_target_x = camera_origin_x;
        camera_target_y = camera_origin_y;
        camera_move_speed = _action.speed;
        camera_restore_target_when_done = true;
        camera_task_active = true;
        camera_waiting = _action.wait;

        action_index++;

        break;


    // =====================================================
    // FACE
    // =====================================================

    case CS_ACTION.FACE:

        var _actor_face = scr_cutscene_actor(_action.actor);

        if (_actor_face != noone)
        {
            scr_party_cutscene_take_control(
                _actor_face
            );

            scr_cutscene_face_actor(
                _actor_face,
                _action.direction
            );
        }

        action_index++;

        break;


    // =====================================================
    // TELEPORT
    // =====================================================

    case CS_ACTION.TELEPORT:

        var _actor_tp = scr_cutscene_actor(_action.actor);

        if (_actor_tp != noone)
        {
            scr_party_cutscene_take_control(
                _actor_tp
            );

            _actor_tp.x = _action.x;
            _actor_tp.y = _action.y;
        }

        action_index++;

        break;


    // =====================================================
    // SPRITE
    // =====================================================

    case CS_ACTION.SPRITE:

        var _actor_sprite = scr_cutscene_actor(_action.actor);

        if (_actor_sprite != noone)
        {
            scr_party_cutscene_take_control(
                _actor_sprite
            );

            if (_actor_sprite.object_index == obj_player)
            {
                _actor_sprite.cutscene_sprite_override = _action.sprite;
                _actor_sprite.cutscene_sprite_override_active = true;
            }
            else
            {
                _actor_sprite.sprite_index = _action.sprite;
            }

            _actor_sprite.image_index = _action.image_index;
            _actor_sprite.image_speed = _action.image_speed;
        }

        action_index++;

        break;


    // =====================================================
    // SPRITE AUTO
    // =====================================================

    case CS_ACTION.SPRITE_AUTO:

        var _actor_auto = scr_cutscene_actor(_action.actor);

        if (_actor_auto != noone)
        {
            if (
                variable_instance_exists(
                    _actor_auto,
                    "cutscene_sprite_override_active"
                )
            )
            {
                _actor_auto.cutscene_sprite_override_active = false;
            }
        }

        action_index++;

        break;


    // =====================================================
    // MUSIC
    // =====================================================

    case CS_ACTION.MUSIC:

        if (_action.stop_previous)
            scr_cutscene_stop_music();

        if (audio_exists(_action.music))
        {
            var _music_instance = audio_play_sound(
                _action.music,
                _action.priority,
                _action.loop
            );

            audio_sound_gain(
                _music_instance,
                _action.gain,
                0
            );

            global.cutscene_music_instance = _music_instance;
        }

        action_index++;

        break;


    // =====================================================
    // MUSIC STOP
    // =====================================================

    case CS_ACTION.MUSIC_STOP:

        scr_cutscene_stop_music(_action.music);
        action_index++;

        break;


    // =====================================================
    // SOUND
    // =====================================================

    case CS_ACTION.SOUND:

        if (audio_exists(_action.sound))
        {
            var _sound_instance = audio_play_sound(
                _action.sound,
                _action.priority,
                _action.loop
            );

            audio_sound_gain(
                _sound_instance,
                _action.gain,
                0
            );

            if (_action.wait)
                waiting_sound_instance = _sound_instance;
        }

        action_index++;

        break;


    // =====================================================
    // SOUND STOP
    // =====================================================

    case CS_ACTION.SOUND_STOP:

        if (audio_is_playing(_action.sound))
            audio_stop_sound(_action.sound);

        action_index++;

        break;


    // =====================================================
    // SPAWN / NPC APPEAR
    // =====================================================

    case CS_ACTION.SPAWN:

        var _layer = layer_get_id(_action.layer);
        var _new_actor;

        if (_layer != -1)
        {
            _new_actor = instance_create_layer(
                _action.x,
                _action.y,
                _action.layer,
                _action.object
            );
        }
        else
        {
            _new_actor = instance_create_depth(
                _action.x,
                _action.y,
                0,
                _action.object
            );
        }

        scr_cutscene_register(
            _action.name,
            _new_actor
        );

        action_index++;

        break;


    // =====================================================
    // DESTROY BY ACTOR NAME
    // =====================================================

    case CS_ACTION.DESTROY:

        var _actor_destroy = scr_cutscene_actor(_action.actor);

        if (_actor_destroy != noone)
            instance_destroy(_actor_destroy);

        action_index++;

        break;


    // =====================================================
    // DESTROY AT COORDINATES
    // =====================================================

    case CS_ACTION.DESTROY_AT:

        var _candidate = instance_nearest(
            _action.x,
            _action.y,
            _action.object
        );

        if (
            _candidate != noone
            &&
            instance_exists(_candidate)
        )
        {
            var _candidate_dist = point_distance(
                _action.x,
                _action.y,
                _candidate.x,
                _candidate.y
            );

            if (_candidate_dist <= _action.tolerance)
                instance_destroy(_candidate);
        }

        action_index++;

        break;


    // =====================================================
    // VISIBLE
    // =====================================================

    case CS_ACTION.VISIBLE:

        var _actor_visible = scr_cutscene_actor(_action.actor);

        if (_actor_visible != noone)
            _actor_visible.visible = _action.visible;

        action_index++;

        break;


    // =====================================================
    // ALPHA
    // =====================================================

    case CS_ACTION.ALPHA:

        var _actor_alpha = scr_cutscene_actor(_action.actor);

        if (_actor_alpha != noone)
            _actor_alpha.image_alpha = _action.alpha;

        action_index++;

        break;


    // =====================================================
    // IMAGE SHOW
    // =====================================================

    case CS_ACTION.IMAGE_SHOW:

        if (
            _action.sprite == noone
            ||
            !sprite_exists(_action.sprite)
        )
        {
            action_index++;
            break;
        }

        cutscene_image_sprite = _action.sprite;
        cutscene_image_alpha = 0;
        cutscene_image_target_alpha = 1;
        cutscene_image_fade_speed = 1 / max(1, _action.fade_frames);
        cutscene_image_remove_when_done = false;
        cutscene_image_transition_active = true;
        cutscene_image_waiting = true;

        action_index++;

        break;


    // =====================================================
    // IMAGE HIDE
    // =====================================================

    case CS_ACTION.IMAGE_HIDE:

        if (cutscene_image_sprite == noone)
        {
            action_index++;
            break;
        }

        cutscene_image_target_alpha = 0;
        cutscene_image_fade_speed = 1 / max(1, _action.fade_frames);
        cutscene_image_remove_when_done = true;
        cutscene_image_transition_active = true;
        cutscene_image_waiting = true;

        action_index++;

        break;


    // =====================================================
    // CALL
    // =====================================================

    case CS_ACTION.CALL:

        var _function_call = _action.func;
        _function_call();
        action_index++;

        break;


    // =====================================================
    // WAIT UNTIL
    // =====================================================

    case CS_ACTION.WAIT_UNTIL:

        var _condition = _action.func;

        if (_condition())
            action_index++;

        break;


    // =====================================================
    // PARTY ACTOR
    // =====================================================
    //
    // Crea/asegura un personaje party-capable como actor
    // normal de la cinemática, SIN unirlo al grupo.
    // =====================================================

    case CS_ACTION.PARTY_ACTOR:

        var _cin_party_actor =
            scr_party_spawn_cinematic_actor(
                _action.party_id,
                _action.x,
                _action.y,
                _action.layer
            );


        if (
            _cin_party_actor == noone
            ||
            !instance_exists(
                _cin_party_actor
            )
        )
        {
            show_debug_message(
                "[CUTSCENE] No pude crear actor party: "
                +
                string(
                    _action.party_id
                )
            );
        }


        action_index++;

        break;


    // =====================================================
    // PARTY JOIN
    // =====================================================

    case CS_ACTION.PARTY_JOIN:

        if (
            !scr_party_smart_join(
                _action.actor,
                _action.party_id
            )
        )
        {
            show_debug_message(
                "[CUTSCENE] No se pudo unir a party: "
                +
                string(_action.actor)
            );
        }


        action_index++;

        break;


    // =====================================================
    // PARTY JOIN BEHIND
    // =====================================================
    //
    // 1. Busca al actor.
    // 2. Calcula su slot REAL detrás de Maya.
    // 3. Camina hasta ese punto.
    // 4. SOLO al llegar se une al grupo.
    // =====================================================

    case CS_ACTION.PARTY_JOIN_BEHIND:

        var _join_actor =
            scr_cutscene_actor(
                _action.actor
            );


        var _join_id =
            _action.party_id;


        if (
            !is_string(_join_id)
            ||
            _join_id == ""
        )
        {
            if (is_string(_action.actor))
            {
                _join_id =
                    _action.actor;
            }
            else if (
                _join_actor != noone
                &&
                instance_exists(_join_actor)
                &&
                variable_instance_exists(
                    _join_actor,
                    "party_id"
                )
            )
            {
                _join_id =
                    _join_actor.party_id;
            }
        }


        // Si no existe, JOIN normal ya sabe spawnearlo.
        // No tiene sentido "acercarse" si no hay un punto
        // inicial visible desde el que caminar.
        if (
            _join_actor == noone
            ||
            !instance_exists(_join_actor)
        )
        {
            scr_party_smart_join(
                _action.actor,
                _join_id
            );


            action_index++;

            break;
        }


        var _join_member_index =
            scr_party_member_index(
                _join_id
            );


        if (_join_member_index < 0)
        {
            _join_member_index =
                array_length(
                    global.party_data.members
                );
        }


        var _join_target =
            scr_party_get_join_target(
                _join_member_index
            );


        // Primero poner sprite/dirección apropiada para que el
        // bbox usado al convertir pies->origin sea el correcto.
        scr_party_apply_direction(
            _join_actor,
            _join_target.face
        );


        var _join_origin =
            scr_party_origin_for_feet(
                _join_actor,
                _join_target.x,
                _join_target.y
            );


        var _join_task_id =
            next_task_id++;


        var _join_task =
        {
            id:
                _join_task_id,

            actor:
                _action.actor,

            x:
                _join_origin.x,

            y:
                _join_origin.y,

            speed:
                _action.speed,

            anim_speed:
                _action.anim_speed,

            old_image_speed:
                _join_actor.image_speed,

            anim_started:
                false,

            walk_frames:
                0,

            arrived:
                false,

            party_join_on_arrival:
                true,

            party_join_id:
                _join_id,

            party_join_seed_history:
                _join_target.synthetic
        };


        if (
            _action.anim_speed > 0
            &&
            _join_actor.sprite_index != -1
            &&
            sprite_exists(
                _join_actor.sprite_index
            )
        )
        {
            var _join_frames =
                sprite_get_number(
                    _join_actor.sprite_index
                );


            if (_join_frames > 1)
            {
                _join_actor.image_speed =
                    0;

                _join_actor.image_index =
                    1;

                _join_task.anim_started =
                    true;
            }
        }


        array_push(
            move_tasks,
            _join_task
        );


        if (_action.wait)
        {
            waiting_task_id =
                _join_task_id;
        }


        action_index++;

        break;


    // =====================================================
    // PARTY LEAVE
    // =====================================================

    case CS_ACTION.PARTY_LEAVE:

        scr_party_leave(
            _action.actor,
            _action.destroy_actor
        );

        action_index++;

        break;


    // =====================================================
    // BATTLE
    // =====================================================
    //
    // Suspende la cinemática. No la termina.
    // =====================================================

    case CS_ACTION.BATTLE:

        var _player = instance_find(obj_player, 0);

        if (_player != noone)
        {
            global.return_x = _player.x;
            global.return_y = _player.y;

            if (variable_instance_exists(_player, "hp"))
                global.player_hp_current = _player.hp;

            if (variable_instance_exists(_player, "puede_moverse"))
                _player.puede_moverse = false;

            if (variable_instance_exists(_player, "can_move"))
                _player.can_move = false;

            if (variable_instance_exists(_player, "cutscene_motion_active"))
                _player.cutscene_motion_active = false;

            _player.image_index = 0;
        }

        global.return_room = room;
        global.enemigo_actual_id = _action.enemy_id;
        global.battle_enemy_id = _action.enemy_id;

        scr_cutscene_resume_init();

        global.cutscene_resume_pending = true;
        global.cutscene_resume_id = cutscene_id;
        global.cutscene_resume_action_index = action_index + 1;
        global.cutscene_resume_room = room;
        global.cutscene_resume_player_can_move = player_can_move;

        suspended_for_battle = true;
        restore_player_movement = false;
        cutscene_finished = false;

        global.cutscene_active = false;

        if (!instance_exists(obj_transicion_bbs))
        {
            instance_create_depth(
                0,
                0,
                -1000000,
                obj_transicion_bbs
            );
        }

        instance_destroy();
        exit;


    // =====================================================
    // END
    // =====================================================

    case CS_ACTION.END:

        cutscene_finished = true;
        suspended_for_battle = false;
        restore_player_movement = true;

        scr_cutscene_clear_resume();

        instance_destroy();
        exit;


    // =====================================================
    // QUIT
    // =====================================================

    case CS_ACTION.QUIT:

        game_end();
        exit;
}
