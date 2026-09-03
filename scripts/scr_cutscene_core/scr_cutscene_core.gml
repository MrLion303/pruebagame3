/// =========================================================
/// SCR_CUTSCENE_CORE
/// CINEMÁTICAS V2
/// =========================================================
///
/// Funciones nuevas principales:
///
/// cs_scene(player_can_move, actions)
/// cs_camera_move(dx, dy, speed, wait)
/// cs_camera_reset(speed, wait)
/// cs_dialog(..., extra_sound, stop_extra_with_dialog, extra_gain)
/// cs_npc_appear(name, object, x, y, layer)
/// cs_npc_disappear_at(object, x, y, tolerance)
/// cs_image_show(sprite, fade_frames)
/// cs_image_hide(fade_frames)
/// cs_end()
///
/// VIDEO: reservado para una implementación posterior.
/// =========================================================

enum CS_ACTION
{
    WAIT,
    DIALOG,

    MOVE,
    MOVE_REL,
    WAIT_MOVES,

    CAMERA_MOVE,
    CAMERA_RESET,

    FACE,
    TELEPORT,

    SPRITE,
    SPRITE_AUTO,

    MUSIC,
    MUSIC_STOP,

    SOUND,
    SOUND_STOP,

    SPAWN,
    DESTROY,
    DESTROY_AT,

    VISIBLE,
    ALPHA,

    IMAGE_SHOW,
    IMAGE_HIDE,

    CALL,
    WAIT_UNTIL,

    PARTY_JOIN,
    PARTY_LEAVE,

    BATTLE,

    END,
    QUIT
}


// =========================================================
// FLAGS
// =========================================================

function scr_cutscene_flags_init()
{
    if (
        !variable_global_exists("cutscene_flags")
        ||
        !is_struct(global.cutscene_flags)
    )
    {
        global.cutscene_flags = {};
    }
}

function scr_cutscene_was_played(_id)
{
    scr_cutscene_flags_init();

    if (variable_struct_exists(global.cutscene_flags, _id))
    {
        return variable_struct_get(
            global.cutscene_flags,
            _id
        );
    }

    return false;
}

function scr_cutscene_mark_played(_id)
{
    scr_cutscene_flags_init();

    variable_struct_set(
        global.cutscene_flags,
        _id,
        true
    );
}


// =========================================================
// CONFIGURACIÓN DE UNA CINEMÁTICA
// =========================================================

function cs_scene(_player_can_move, _actions)
{
    return {
        player_can_move: _player_can_move,
        actions: _actions
    };
}

function scr_cutscene_unpack(_raw)
{
    // Compatibilidad con cinemáticas antiguas que devuelvan
    // directamente un array.
    if (is_array(_raw))
    {
        return {
            player_can_move: false,
            actions: _raw
        };
    }

    if (is_struct(_raw))
    {
        var _can_move = false;
        var _actions = [];

        if (variable_struct_exists(_raw, "player_can_move"))
            _can_move = _raw.player_can_move;

        if (
            variable_struct_exists(_raw, "actions")
            &&
            is_array(_raw.actions)
        )
        {
            _actions = _raw.actions;
        }

        return {
            player_can_move: _can_move,
            actions: _actions
        };
    }

    return {
        player_can_move: false,
        actions: []
    };
}


// =========================================================
// REANUDACIÓN DESPUÉS DE BATALLA
// =========================================================

function scr_cutscene_resume_init()
{
    if (!variable_global_exists("cutscene_resume_pending"))
        global.cutscene_resume_pending = false;

    if (!variable_global_exists("cutscene_resume_id"))
        global.cutscene_resume_id = "";

    if (!variable_global_exists("cutscene_resume_action_index"))
        global.cutscene_resume_action_index = 0;

    if (!variable_global_exists("cutscene_resume_room"))
        global.cutscene_resume_room = -1;

    if (!variable_global_exists("cutscene_resume_player_can_move"))
        global.cutscene_resume_player_can_move = false;
}

function scr_cutscene_clear_resume()
{
    scr_cutscene_resume_init();

    global.cutscene_resume_pending = false;
    global.cutscene_resume_id = "";
    global.cutscene_resume_action_index = 0;
    global.cutscene_resume_room = -1;
    global.cutscene_resume_player_can_move = false;
}


// =========================================================
// ACTORES
// =========================================================

function scr_cutscene_registry_init()
{
    if (
        !variable_global_exists("cutscene_actors")
        ||
        !is_struct(global.cutscene_actors)
    )
    {
        global.cutscene_actors = {};
    }
}

function scr_cutscene_register(_name, _instance)
{
    scr_cutscene_registry_init();

    variable_struct_set(
        global.cutscene_actors,
        _name,
        _instance
    );

    return _instance;
}

function scr_cutscene_actor(_name)
{
    if (is_real(_name))
    {
        if (instance_exists(_name))
            return _name;
    }

    if (
        is_string(_name)
        &&
        _name == "player"
    )
    {
        if (instance_exists(obj_player))
            return instance_find(obj_player, 0);

        return noone;
    }

    scr_cutscene_registry_init();

    // Miembro activo de la party.
    if (
        is_string(_name)
        &&
        scr_party_has(_name)
    )
    {
        var _party_actor =
            scr_party_get_instance(
                _name
            );

        if (
            _party_actor != noone
            &&
            instance_exists(_party_actor)
        )
        {
            return _party_actor;
        }
    }


    if (
        is_string(_name)
        &&
        variable_struct_exists(
            global.cutscene_actors,
            _name
        )
    )
    {
        var _actor =
            variable_struct_get(
                global.cutscene_actors,
                _name
            );

        if (instance_exists(_actor))
            return _actor;
    }


    // NPC colocado en el room con un party_id.
    // Esto permite usar cs_party_join("maya")
    // sin haberlo creado previamente con cs_spawn().
    if (is_string(_name))
    {
        var _world_actor =
            scr_party_find_world_actor(
                _name
            );

        if (
            _world_actor != noone
            &&
            instance_exists(_world_actor)
        )
        {
            return _world_actor;
        }
    }


    return noone;
}


// =========================================================
// DIRECCIÓN
// =========================================================

function scr_cutscene_face_actor(_actor, _dir)
{
    if (
        _actor == noone
        ||
        !instance_exists(_actor)
    )
    {
        return;
    }

    var _sprite_direccion = noone;

    switch (_dir)
    {
        case "derecha":
        case "right":

            if (variable_instance_exists(_actor, "direccion"))
                _actor.direccion = "derecha";

            if (variable_instance_exists(_actor, "face"))
                _actor.face = RIGHT;

            if (variable_instance_exists(_actor, "facing_direction"))
                _actor.facing_direction = 0;

            if (variable_instance_exists(_actor, "cutscene_sprite_right"))
                _sprite_direccion = _actor.cutscene_sprite_right;

            break;


        case "izquierda":
        case "left":

            if (variable_instance_exists(_actor, "direccion"))
                _actor.direccion = "izquierda";

            if (variable_instance_exists(_actor, "face"))
                _actor.face = LEFT;

            if (variable_instance_exists(_actor, "facing_direction"))
                _actor.facing_direction = 1;

            if (variable_instance_exists(_actor, "cutscene_sprite_left"))
                _sprite_direccion = _actor.cutscene_sprite_left;

            break;


        case "abajo":
        case "down":

            if (variable_instance_exists(_actor, "direccion"))
                _actor.direccion = "abajo";

            if (variable_instance_exists(_actor, "face"))
                _actor.face = DOWN;

            if (variable_instance_exists(_actor, "facing_direction"))
                _actor.facing_direction = 2;

            if (variable_instance_exists(_actor, "cutscene_sprite_down"))
                _sprite_direccion = _actor.cutscene_sprite_down;

            break;


        case "arriba":
        case "up":

            if (variable_instance_exists(_actor, "direccion"))
                _actor.direccion = "arriba";

            if (variable_instance_exists(_actor, "face"))
                _actor.face = UP;

            if (variable_instance_exists(_actor, "facing_direction"))
                _actor.facing_direction = 3;

            if (variable_instance_exists(_actor, "cutscene_sprite_up"))
                _sprite_direccion = _actor.cutscene_sprite_up;

            break;
    }

    if (
        _sprite_direccion != noone
        &&
        sprite_exists(_sprite_direccion)
    )
    {
        _actor.sprite_index = _sprite_direccion;
    }
}


// =========================================================
// CONTROL DEL PLAYER
// =========================================================

function scr_cutscene_set_player_control(_enabled)
{
    global.cutscene_player_can_move = _enabled;

    if (!instance_exists(obj_player))
        return;

    var _player = instance_find(obj_player, 0);

    if (variable_instance_exists(_player, "puede_moverse"))
        _player.puede_moverse = _enabled;

    if (variable_instance_exists(_player, "can_move"))
        _player.can_move = _enabled;
}


// =========================================================
// MÚSICA
// =========================================================

function scr_cutscene_stop_music(_music = noone)
{
    if (_music != noone)
    {
        if (audio_exists(_music))
            audio_stop_sound(_music);

        return;
    }

    var _sounds = asset_get_ids(asset_sound);

    for (var i = 0; i < array_length(_sounds); i++)
    {
        var _sound = _sounds[i];

        if (!audio_exists(_sound))
            continue;

        var _name = audio_get_name(_sound);

        if (string_starts_with(_name, "mus_"))
        {
            if (audio_is_playing(_sound))
                audio_stop_sound(_sound);
        }
    }

    if (variable_global_exists("cutscene_music_instance"))
        global.cutscene_music_instance = noone;
}


// =========================================================
// CONSTRUCTORES
// =========================================================

function cs_wait(_frames)
{
    return {
        type: CS_ACTION.WAIT,
        frames: max(0, _frames)
    };
}

function cs_wait_seconds(_seconds)
{
    return cs_wait(
        round(
            _seconds
            *
            game_get_speed(gamespeed_fps)
        )
    );
}


// ---------------------------------------------------------
// DIÁLOGO
// ---------------------------------------------------------
//
// _snd:
//     sonido de voz/letras, como hasta ahora.
//
// _extra_sound:
//     sonido largo que empieza UNA VEZ junto al cuadro.
//
// _stop_extra_with_dialog:
//     true = si cierras el cuadro antes de que termine,
//            también se detiene el sonido largo.
//     false = el sonido sigue aunque cierres el cuadro.
// ---------------------------------------------------------

function cs_dialog(
    _text,
    _head = noone,
    _snd = snd_text,
    _color = c_white,
    _extra_sound = noone,
    _stop_extra_with_dialog = true,
    _extra_gain = 1
)
{
    return {
        type: CS_ACTION.DIALOG,
        text: _text,
        color: _color,
        head: _head,
        snd: _snd,
        extra_sound: _extra_sound,
        stop_extra_with_dialog: _stop_extra_with_dialog,
        extra_gain: _extra_gain
    };
}


// ---------------------------------------------------------
// MOVIMIENTO ABSOLUTO DE ACTORES
// ---------------------------------------------------------

function cs_move_to(
    _actor,
    _x,
    _y,
    _speed = 2,
    _wait = true,
    _anim_speed = -1
)
{
    var _velocidad = max(0.01, _speed);
    var _vel_anim = _anim_speed;

    if (_vel_anim < 0)
    {
        _vel_anim = max(0.20, _velocidad * 0.10);
    }

    return {
        type: CS_ACTION.MOVE,
        actor: _actor,
        x: _x,
        y: _y,
        speed: _velocidad,
        wait: _wait,
        anim_speed: _vel_anim
    };
}

function cs_move(
    _actor,
    _x,
    _y,
    _speed = 2,
    _wait = true,
    _anim_speed = -1
)
{
    return cs_move_to(
        _actor,
        _x,
        _y,
        _speed,
        _wait,
        _anim_speed
    );
}

function cs_move_rel(
    _actor,
    _dx,
    _dy,
    _speed = 2,
    _wait = true,
    _anim_speed = -1
)
{
    var _velocidad = max(0.01, _speed);
    var _vel_anim = _anim_speed;

    if (_vel_anim < 0)
    {
        _vel_anim = max(0.20, _velocidad * 0.10);
    }

    return {
        type: CS_ACTION.MOVE_REL,
        actor: _actor,
        dx: _dx,
        dy: _dy,
        speed: _velocidad,
        wait: _wait,
        anim_speed: _vel_anim
    };
}

function cs_wait_moves()
{
    return {
        type: CS_ACTION.WAIT_MOVES
    };
}


// ---------------------------------------------------------
// CÁMARA RELATIVA
// ---------------------------------------------------------
//
// X POSITIVO  = derecha
// X NEGATIVO  = izquierda
// Y POSITIVO  = abajo
// Y NEGATIVO  = arriba
//
// Ejemplos:
// cs_camera_move( 64,   0); // derecha
// cs_camera_move(-64,   0); // izquierda
// cs_camera_move(  0,  48); // abajo
// cs_camera_move(  0, -48); // arriba
// ---------------------------------------------------------

function cs_camera_move(
    _dx,
    _dy,
    _speed = 2,
    _wait = true
)
{
    return {
        type: CS_ACTION.CAMERA_MOVE,
        dx: _dx,
        dy: _dy,
        speed: max(0.01, _speed),
        wait: _wait
    };
}

function cs_camera_reset(
    _speed = 2,
    _wait = true
)
{
    return {
        type: CS_ACTION.CAMERA_RESET,
        speed: max(0.01, _speed),
        wait: _wait
    };
}


function cs_face(_actor, _direction)
{
    return {
        type: CS_ACTION.FACE,
        actor: _actor,
        direction: _direction
    };
}

function cs_teleport(_actor, _x, _y)
{
    return {
        type: CS_ACTION.TELEPORT,
        actor: _actor,
        x: _x,
        y: _y
    };
}

function cs_sprite(
    _actor,
    _sprite,
    _image_index = 0,
    _image_speed = 0
)
{
    return {
        type: CS_ACTION.SPRITE,
        actor: _actor,
        sprite: _sprite,
        image_index: _image_index,
        image_speed: _image_speed
    };
}

function cs_sprite_auto(_actor)
{
    return {
        type: CS_ACTION.SPRITE_AUTO,
        actor: _actor
    };
}

function cs_music_play(
    _music,
    _loop = true,
    _stop_previous = true,
    _gain = 1,
    _priority = 10
)
{
    return {
        type: CS_ACTION.MUSIC,
        music: _music,
        loop: _loop,
        stop_previous: _stop_previous,
        gain: _gain,
        priority: _priority
    };
}

function cs_music_stop(_music = noone)
{
    return {
        type: CS_ACTION.MUSIC_STOP,
        music: _music
    };
}

function cs_sound(
    _sound,
    _wait = false,
    _loop = false,
    _gain = 1,
    _priority = 10
)
{
    return {
        type: CS_ACTION.SOUND,
        sound: _sound,
        wait: _wait,
        loop: _loop,
        gain: _gain,
        priority: _priority
    };
}

function cs_sound_stop(_sound)
{
    return {
        type: CS_ACTION.SOUND_STOP,
        sound: _sound
    };
}


// ---------------------------------------------------------
// NPCS / OBJETOS
// ---------------------------------------------------------

function cs_spawn(
    _name,
    _object,
    _x,
    _y,
    _layer = "Instances"
)
{
    return {
        type: CS_ACTION.SPAWN,
        name: _name,
        object: _object,
        x: _x,
        y: _y,
        layer: _layer
    };
}

function cs_npc_appear(
    _name,
    _object,
    _x,
    _y,
    _layer = "Instances"
)
{
    return cs_spawn(
        _name,
        _object,
        _x,
        _y,
        _layer
    );
}

function cs_destroy(_actor)
{
    return {
        type: CS_ACTION.DESTROY,
        actor: _actor
    };
}

function cs_npc_disappear(_actor)
{
    return cs_destroy(_actor);
}

function cs_npc_disappear_at(
    _object,
    _x,
    _y,
    _tolerance = 8
)
{
    return {
        type: CS_ACTION.DESTROY_AT,
        object: _object,
        x: _x,
        y: _y,
        tolerance: max(0, _tolerance)
    };
}

function cs_visible(_actor, _visible)
{
    return {
        type: CS_ACTION.VISIBLE,
        actor: _actor,
        visible: _visible
    };
}

function cs_alpha(_actor, _alpha)
{
    return {
        type: CS_ACTION.ALPHA,
        actor: _actor,
        alpha: clamp(_alpha, 0, 1)
    };
}


// ---------------------------------------------------------
// IMAGEN CINEMÁTICA FULLSCREEN
// ---------------------------------------------------------
//
// La imagen hace fade sobre el gameplay.
// Cuando cs_image_show() termina, permanece en pantalla.
// Se pueden ejecutar cs_dialog() mientras siga visible.
// cs_image_hide() hace fade de regreso al gameplay.
// ---------------------------------------------------------

function cs_image_show(
    _sprite,
    _fade_frames = 20
)
{
    return {
        type: CS_ACTION.IMAGE_SHOW,
        sprite: _sprite,
        fade_frames: max(1, _fade_frames)
    };
}

function cs_image_hide(_fade_frames = 20)
{
    return {
        type: CS_ACTION.IMAGE_HIDE,
        fade_frames: max(1, _fade_frames)
    };
}


function cs_do(_func)
{
    return {
        type: CS_ACTION.CALL,
        func: _func
    };
}

function cs_wait_until(_func)
{
    return {
        type: CS_ACTION.WAIT_UNTIL,
        func: _func
    };
}

// =========================================================
// PARTY
// =========================================================
//
// Unir:
//     cs_party_join("maya")
//
// Sacar, pero dejar como NPC:
//     cs_party_leave("maya")
//
// Sacar y destruir/desaparecer:
//     cs_party_leave("maya", true)
// =========================================================

function cs_party_join(
    _actor,
    _party_id = ""
)
{
    return {
        type:
            CS_ACTION.PARTY_JOIN,

        actor:
            _actor,

        party_id:
            _party_id
    };
}


function cs_party_leave(
    _actor,
    _destroy_actor = false
)
{
    return {
        type:
            CS_ACTION.PARTY_LEAVE,

        actor:
            _actor,

        destroy_actor:
            _destroy_actor
    };
}


function cs_battle(_enemy_id)
{
    return {
        type: CS_ACTION.BATTLE,
        enemy_id: _enemy_id
    };
}

function cs_end()
{
    return {
        type: CS_ACTION.END
    };
}

function cs_quit()
{
    return {
        type: CS_ACTION.QUIT
    };
}


// =========================================================
// CREAR CONTROLLER
// =========================================================

function scr_cutscene_create_controller(
    _id,
    _actions,
    _start_index = 0,
    _player_can_move = false
)
{
    var _controller = noone;

    if (layer_get_id("Instances") != -1)
    {
        _controller =
            instance_create_layer(
                0,
                0,
                "Instances",
                obj_cutscene_controller
            );
    }
    else
    {
        _controller =
            instance_create_depth(
                0,
                0,
                -90000,
                obj_cutscene_controller
            );
    }

    _controller.cutscene_id = _id;
    _controller.actions = _actions;
    _controller.action_index = _start_index;
    _controller.player_can_move = _player_can_move;
    _controller.ready = true;

    return _controller;
}


// =========================================================
// INICIAR DESDE EL PRINCIPIO
// =========================================================

function scr_cutscene_start(
    _id,
    _mark_as_played = true
)
{
    if (instance_exists(obj_cutscene_controller))
        return false;

    var _raw = scr_cutscene_data(_id);
    var _scene = scr_cutscene_unpack(_raw);
    var _actions = _scene.actions;
    var _player_can_move = _scene.player_can_move;

    if (
        !is_array(_actions)
        ||
        array_length(_actions) <= 0
    )
    {
        show_debug_message(
            "[CUTSCENE] No existe o está vacía: "
            +
            string(_id)
        );

        return false;
    }

    scr_cutscene_flags_init();
    scr_cutscene_clear_resume();

    if (_mark_as_played)
        scr_cutscene_mark_played(_id);

    global.cutscene_active = true;
    scr_cutscene_set_player_control(_player_can_move);

    if (instance_exists(obj_player))
    {
        var _player = instance_find(obj_player, 0);

        if (!variable_instance_exists(_player, "cutscene_motion_active"))
            _player.cutscene_motion_active = false;

        if (!variable_instance_exists(_player, "cutscene_sprite_override_active"))
            _player.cutscene_sprite_override_active = false;
    }

    if (instance_exists(obj_menu_manager))
    {
        if (variable_instance_exists(obj_menu_manager, "state"))
            obj_menu_manager.state = 0;
    }

    scr_cutscene_create_controller(
        _id,
        _actions,
        0,
        _player_can_move
    );

    return true;
}


// =========================================================
// REANUDAR DESPUÉS DE BATALLA
// =========================================================

function scr_cutscene_resume_after_battle()
{
    scr_cutscene_resume_init();

    if (!global.cutscene_resume_pending)
        return false;

    if (
        global.cutscene_resume_room != -1
        &&
        room != global.cutscene_resume_room
    )
    {
        return false;
    }

    if (instance_exists(obj_cutscene_controller))
        return true;

    var _id = global.cutscene_resume_id;
    var _index = global.cutscene_resume_action_index;
    var _player_can_move = global.cutscene_resume_player_can_move;

    var _raw = scr_cutscene_data(_id);
    var _scene = scr_cutscene_unpack(_raw);
    var _actions = _scene.actions;

    if (
        !is_array(_actions)
        ||
        array_length(_actions) <= 0
    )
    {
        show_debug_message(
            "[CUTSCENE] No pude reanudar: "
            +
            string(_id)
        );

        scr_cutscene_clear_resume();
        return false;
    }

    // Guardamos localmente antes de limpiar.
    scr_cutscene_clear_resume();

    global.cutscene_active = true;
    scr_cutscene_set_player_control(_player_can_move);

    scr_cutscene_create_controller(
        _id,
        _actions,
        _index,
        _player_can_move
    );

    return true;
}
