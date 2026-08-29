/// =========================================================
/// OBJ_CUTSCENE_CONTROLLER
/// STEP
/// =========================================================

if (!ready)
{
    exit;
}


// =========================================================
// ACTUALIZAR MOVIMIENTOS ACTIVOS
// =========================================================

for (
    var _i = array_length(move_tasks) - 1;
    _i >= 0;
    _i--
)
{
    var _task =
        move_tasks[_i];

    var _actor_move =
        scr_cutscene_actor(
            _task.actor
        );


    if (
        _actor_move == noone
        ||
        !instance_exists(_actor_move)
    )
    {
        array_delete(
            move_tasks,
            _i,
            1
        );

        continue;
    }


    if (_task.arrived)
    {
        if (_task.anim_speed > 0)
        {
            _actor_move.image_speed =
                _task.old_image_speed;

            if (
                _actor_move.sprite_index != -1
                &&
                sprite_exists(
                    _actor_move.sprite_index
                )
            )
            {
                _actor_move.image_index =
                    0;
            }
        }

        if (_actor_move.object_index == obj_player)
        {
            _actor_move.cutscene_motion_active =
                false;
        }

        array_delete(
            move_tasks,
            _i,
            1
        );

        continue;
    }


    var _dx =
        _task.x
        -
        _actor_move.x;

    var _dy =
        _task.y
        -
        _actor_move.y;

    var _distance =
        point_distance(
            _actor_move.x,
            _actor_move.y,
            _task.x,
            _task.y
        );


    if (_distance <= 0.001)
    {
        if (_task.anim_speed > 0)
        {
            _actor_move.image_speed =
                _task.old_image_speed;

            if (
                _actor_move.sprite_index != -1
                &&
                sprite_exists(
                    _actor_move.sprite_index
                )
            )
            {
                _actor_move.image_index =
                    0;
            }
        }

        if (_actor_move.object_index == obj_player)
        {
            _actor_move.cutscene_motion_active =
                false;
        }

        array_delete(
            move_tasks,
            _i,
            1
        );

        continue;
    }


    // Dirección automática.
    if (abs(_dx) >= abs(_dy))
    {
        if (_dx > 0)
        {
            scr_cutscene_face_actor(
                _actor_move,
                "derecha"
            );
        }
        else
        {
            scr_cutscene_face_actor(
                _actor_move,
                "izquierda"
            );
        }
    }
    else
    {
        if (_dy > 0)
        {
            scr_cutscene_face_actor(
                _actor_move,
                "abajo"
            );
        }
        else
        {
            scr_cutscene_face_actor(
                _actor_move,
                "arriba"
            );
        }
    }


    // Animación desde el primer píxel.
    if (
        _task.anim_speed > 0
        &&
        _actor_move.sprite_index != -1
        &&
        sprite_exists(
            _actor_move.sprite_index
        )
    )
    {
        var _frame_count =
            sprite_get_number(
                _actor_move.sprite_index
            );

        if (_frame_count > 1)
        {
            _actor_move.image_speed =
                0;

            if (
                !_task.anim_started
                ||
                _actor_move.image_index < 1
                ||
                _actor_move.image_index >= _frame_count
            )
            {
                _actor_move.image_index =
                    1;

                _task.anim_started =
                    true;
            }
            else
            {
                _actor_move.image_index +=
                    _task.anim_speed;

                if (
                    _actor_move.image_index
                    >=
                    _frame_count
                )
                {
                    _actor_move.image_index =
                        1;
                }
            }
        }
    }


    _task.walk_frames++;


    if (_distance <= _task.speed)
    {
        _actor_move.x =
            _task.x;

        _actor_move.y =
            _task.y;


        if (
            _task.anim_speed > 0
            &&
            _task.walk_frames <= 1
        )
        {
            _task.arrived =
                true;

            continue;
        }


        if (_task.anim_speed > 0)
        {
            _actor_move.image_speed =
                _task.old_image_speed;

            if (
                _actor_move.sprite_index != -1
                &&
                sprite_exists(
                    _actor_move.sprite_index
                )
            )
            {
                _actor_move.image_index =
                    0;
            }
        }


        if (_actor_move.object_index == obj_player)
        {
            _actor_move.cutscene_motion_active =
                false;
        }


        array_delete(
            move_tasks,
            _i,
            1
        );

        continue;
    }


    var _direction =
        point_direction(
            _actor_move.x,
            _actor_move.y,
            _task.x,
            _task.y
        );


    _actor_move.x +=
        lengthdir_x(
            _task.speed,
            _direction
        );

    _actor_move.y +=
        lengthdir_y(
            _task.speed,
            _direction
        );
}


// =========================================================
// ESPERAS
// =========================================================

if (wait_timer > 0)
{
    wait_timer--;
    exit;
}


if (waiting_dialogue)
{
    if (instance_exists(obj_textbox))
    {
        dialogue_seen =
            true;

        exit;
    }


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


if (waiting_sound_instance != -1)
{
    if (
        audio_is_playing(
            waiting_sound_instance
        )
    )
    {
        exit;
    }


    waiting_sound_instance =
        -1;
}


if (waiting_task_id != -1)
{
    var _still_exists =
        false;


    for (
        var _t = 0;
        _t < array_length(move_tasks);
        _t++
    )
    {
        if (
            move_tasks[_t].id
            ==
            waiting_task_id
        )
        {
            _still_exists =
                true;

            break;
        }
    }


    if (_still_exists)
    {
        exit;
    }


    waiting_task_id =
        -1;
}


// =========================================================
// NO FINALIZAR AUTOMÁTICAMENTE
// =========================================================
//
// Si faltó cs_end(), se queda activo.
// =========================================================

if (
    action_index
    >=
    array_length(actions)
)
{
    if (!missing_end_warned)
    {
        missing_end_warned =
            true;

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


// =========================================================
// ACCIÓN ACTUAL
// =========================================================

var _action =
    actions[action_index];


switch (_action.type)
{
    // =====================================================
    // WAIT
    // =====================================================

    case CS_ACTION.WAIT:

        wait_timer =
            _action.frames;

        action_index++;

        break;


    // =====================================================
    // DIALOG
    // =====================================================

    case CS_ACTION.DIALOG:

        if (instance_exists(obj_textbox))
        {
            exit;
        }


        var _textbox =
            noone;


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
                    -99999,
                    obj_textbox
                );
        }


        var _dialog_text =
            scr_loc(
                _action.text
            );

        var _dialog_color =
            _action.color;

        var _dialog_head =
            _action.head;

        var _dialog_sound =
            _action.snd;


        with (_textbox)
        {
            scr_text(
                _dialog_text,
                _dialog_color,
                _dialog_head,
                _dialog_sound
            );
        }


        if (
            !variable_instance_exists(
                _textbox,
                "text"
            )
            ||
            !is_array(
                _textbox.text
            )
            ||
            array_length(
                _textbox.text
            ) <= 0
        )
        {
            _textbox.text =
            [
                _dialog_text
            ];

            _textbox.page_number =
                1;
        }


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

        var _actor_new_move =
            scr_cutscene_actor(
                _action.actor
            );


        if (_actor_new_move == noone)
        {
            show_debug_message(
                "[CUTSCENE] Actor no encontrado: "
                +
                string(
                    _action.actor
                )
            );

            action_index++;

            break;
        }


        var _target_x;
        var _target_y;


        if (_action.type == CS_ACTION.MOVE)
        {
            _target_x =
                _action.x;

            _target_y =
                _action.y;
        }
        else
        {
            _target_x =
                _actor_new_move.x
                +
                _action.dx;

            _target_y =
                _actor_new_move.y
                +
                _action.dy;
        }


        var _start_dx =
            _target_x
            -
            _actor_new_move.x;

        var _start_dy =
            _target_y
            -
            _actor_new_move.y;


        if (
            abs(_start_dx)
            >=
            abs(_start_dy)
        )
        {
            if (_start_dx > 0)
            {
                scr_cutscene_face_actor(
                    _actor_new_move,
                    "derecha"
                );
            }
            else if (_start_dx < 0)
            {
                scr_cutscene_face_actor(
                    _actor_new_move,
                    "izquierda"
                );
            }
        }
        else
        {
            if (_start_dy > 0)
            {
                scr_cutscene_face_actor(
                    _actor_new_move,
                    "abajo"
                );
            }
            else if (_start_dy < 0)
            {
                scr_cutscene_face_actor(
                    _actor_new_move,
                    "arriba"
                );
            }
        }


        var _task_id =
            next_task_id++;


        var _task_new =
        {
            id:
                _task_id,

            actor:
                _action.actor,

            x:
                _target_x,

            y:
                _target_y,

            speed:
                _action.speed,

            anim_speed:
                _action.anim_speed,

            old_image_speed:
                _actor_new_move.image_speed,

            anim_started:
                false,

            walk_frames:
                0,

            arrived:
                false
        };


        if (
            _action.anim_speed > 0
            &&
            _actor_new_move.sprite_index != -1
            &&
            sprite_exists(
                _actor_new_move.sprite_index
            )
        )
        {
            var _initial_frames =
                sprite_get_number(
                    _actor_new_move.sprite_index
                );


            if (_initial_frames > 1)
            {
                _actor_new_move.image_speed =
                    0;

                _actor_new_move.image_index =
                    1;

                _task_new.anim_started =
                    true;
            }
        }


        array_push(
            move_tasks,
            _task_new
        );


        if (_actor_new_move.object_index == obj_player)
        {
            _actor_new_move.cutscene_motion_active =
                true;
        }


        if (_action.wait)
        {
            waiting_task_id =
                _task_id;
        }


        action_index++;

        break;


    // =====================================================
    // WAIT MOVES
    // =====================================================

    case CS_ACTION.WAIT_MOVES:

        if (
            array_length(move_tasks)
            <=
            0
        )
        {
            action_index++;
        }

        break;


    // =====================================================
    // FACE
    // =====================================================

    case CS_ACTION.FACE:

        var _actor_face =
            scr_cutscene_actor(
                _action.actor
            );


        if (_actor_face != noone)
        {
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

        var _actor_tp =
            scr_cutscene_actor(
                _action.actor
            );


        if (_actor_tp != noone)
        {
            _actor_tp.x =
                _action.x;

            _actor_tp.y =
                _action.y;
        }


        action_index++;

        break;


    // =====================================================
    // SPRITE
    // =====================================================

    case CS_ACTION.SPRITE:

        var _actor_sprite =
            scr_cutscene_actor(
                _action.actor
            );


        if (_actor_sprite != noone)
        {
            if (
                _actor_sprite.object_index
                ==
                obj_player
            )
            {
                _actor_sprite.cutscene_sprite_override =
                    _action.sprite;

                _actor_sprite.cutscene_sprite_override_active =
                    true;
            }
            else
            {
                _actor_sprite.sprite_index =
                    _action.sprite;
            }


            _actor_sprite.image_index =
                _action.image_index;

            _actor_sprite.image_speed =
                _action.image_speed;
        }


        action_index++;

        break;


    // =====================================================
    // SPRITE AUTO
    // =====================================================

    case CS_ACTION.SPRITE_AUTO:

        var _actor_auto =
            scr_cutscene_actor(
                _action.actor
            );


        if (_actor_auto != noone)
        {
            if (
                variable_instance_exists(
                    _actor_auto,
                    "cutscene_sprite_override_active"
                )
            )
            {
                _actor_auto.cutscene_sprite_override_active =
                    false;
            }
        }


        action_index++;

        break;


    // =====================================================
    // MUSIC
    // =====================================================

    case CS_ACTION.MUSIC:

        if (_action.stop_previous)
        {
            scr_cutscene_stop_music();
        }


        if (audio_exists(_action.music))
        {
            var _music_instance =
                audio_play_sound(
                    _action.music,
                    _action.priority,
                    _action.loop
                );


            audio_sound_gain(
                _music_instance,
                _action.gain,
                0
            );


            global.cutscene_music_instance =
                _music_instance;
        }


        action_index++;

        break;


    // =====================================================
    // MUSIC STOP
    // =====================================================

    case CS_ACTION.MUSIC_STOP:

        scr_cutscene_stop_music(
            _action.music
        );


        action_index++;

        break;


    // =====================================================
    // SOUND
    // =====================================================

    case CS_ACTION.SOUND:

        if (audio_exists(_action.sound))
        {
            var _sound_instance =
                audio_play_sound(
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
            {
                waiting_sound_instance =
                    _sound_instance;
            }
        }


        action_index++;

        break;


    // =====================================================
    // SOUND STOP
    // =====================================================

    case CS_ACTION.SOUND_STOP:

        if (audio_is_playing(_action.sound))
        {
            audio_stop_sound(
                _action.sound
            );
        }


        action_index++;

        break;


    // =====================================================
    // SPAWN
    // =====================================================

    case CS_ACTION.SPAWN:

        var _layer =
            layer_get_id(
                _action.layer
            );


        var _new_actor;


        if (_layer != -1)
        {
            _new_actor =
                instance_create_layer(
                    _action.x,
                    _action.y,
                    _action.layer,
                    _action.object
                );
        }
        else
        {
            _new_actor =
                instance_create_depth(
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
    // DESTROY
    // =====================================================

    case CS_ACTION.DESTROY:

        var _actor_destroy =
            scr_cutscene_actor(
                _action.actor
            );


        if (_actor_destroy != noone)
        {
            instance_destroy(
                _actor_destroy
            );
        }


        action_index++;

        break;


    // =====================================================
    // VISIBLE
    // =====================================================

    case CS_ACTION.VISIBLE:

        var _actor_visible =
            scr_cutscene_actor(
                _action.actor
            );


        if (_actor_visible != noone)
        {
            _actor_visible.visible =
                _action.visible;
        }


        action_index++;

        break;


    // =====================================================
    // ALPHA
    // =====================================================

    case CS_ACTION.ALPHA:

        var _actor_alpha =
            scr_cutscene_actor(
                _action.actor
            );


        if (_actor_alpha != noone)
        {
            _actor_alpha.image_alpha =
                _action.alpha;
        }


        action_index++;

        break;


    // =====================================================
    // CALL
    // =====================================================

    case CS_ACTION.CALL:

        var _function_call =
            _action.func;


        _function_call();


        action_index++;

        break;


    // =====================================================
    // WAIT UNTIL
    // =====================================================

    case CS_ACTION.WAIT_UNTIL:

        var _condition =
            _action.func;


        if (_condition())
        {
            action_index++;
        }


        break;


    // =====================================================
    // BATTLE
    // =====================================================
    //
    // SUSPENDE la cinemática.
    // NO la termina.
    // =====================================================

    case CS_ACTION.BATTLE:

        var _player =
            instance_find(
                obj_player,
                0
            );


        if (_player != noone)
        {
            global.return_x =
                _player.x;

            global.return_y =
                _player.y;


            if (
                variable_instance_exists(
                    _player,
                    "hp"
                )
            )
            {
                global.player_hp_current =
                    _player.hp;
            }


            if (
                variable_instance_exists(
                    _player,
                    "puede_moverse"
                )
            )
            {
                _player.puede_moverse =
                    false;
            }


            if (
                variable_instance_exists(
                    _player,
                    "can_move"
                )
            )
            {
                _player.can_move =
                    false;
            }


            if (
                variable_instance_exists(
                    _player,
                    "cutscene_motion_active"
                )
            )
            {
                _player.cutscene_motion_active =
                    false;
            }


            _player.image_index =
                0;
        }


        global.return_room =
            room;


        global.enemigo_actual_id =
            _action.enemy_id;

        global.battle_enemy_id =
            _action.enemy_id;


        // Guardar exactamente dónde continuar.
        scr_cutscene_resume_init();

        global.cutscene_resume_pending =
            true;

        global.cutscene_resume_id =
            cutscene_id;

        global.cutscene_resume_action_index =
            action_index + 1;

        global.cutscene_resume_room =
            room;


        suspended_for_battle =
            true;

        restore_player_movement =
            false;

        cutscene_finished =
            false;


        // Mientras estamos en batalla,
        // la cinemática queda suspendida.
        global.cutscene_active =
            false;


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
    //
    // ÚNICO final normal de una cinemática.
    // =====================================================

    case CS_ACTION.END:

        cutscene_finished =
            true;

        suspended_for_battle =
            false;

        restore_player_movement =
            true;


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

