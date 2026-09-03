/// =========================================================
/// SCR_PARTY_SYSTEM
/// =========================================================
///
/// Sistema de party para el overworld.
///
/// Cada NPC reclutable debe tener un ID estable:
///
///     party_id = "maya";
///
/// Los miembros:
/// - siguen el historial de posiciones del player;
/// - son persistentes entre rooms;
/// - se ocultan en bbs y shop_*;
/// - pueden ser controlados individualmente por cinemáticas;
/// - se guardan y cargan con save.ini.
/// =========================================================


// =========================================================
// NORMALIZAR IDs ANTIGUOS
// =========================================================
//
// Compatibilidad con pruebas/saves creados antes del cambio
// de nombre de Noelle -> Maya.
// =========================================================

function scr_party_normalize_id(_party_id)
{
    if (!is_string(_party_id))
        return _party_id;

    if (_party_id == "noelle")
        return "maya";

    return _party_id;
}


// =========================================================
// INIT
// =========================================================

function scr_party_init()
{
    if (
        !variable_global_exists("party_data")
        ||
        !is_struct(global.party_data)
    )
    {
        global.party_data = {
            members: []
        };
    }

    if (
        !variable_struct_exists(global.party_data, "members")
        ||
        !is_array(global.party_data.members)
    )
    {
        global.party_data.members = [];
    }

    if (
        !variable_global_exists("party_runtime")
        ||
        !is_struct(global.party_runtime)
    )
    {
        global.party_runtime = {};
    }

    if (
        !variable_global_exists("party_history")
        ||
        !is_array(global.party_history)
    )
    {
        global.party_history = [];
    }

    if (!variable_global_exists("party_history_room"))
        global.party_history_room = -1;

    if (!variable_global_exists("party_room_dirty"))
        global.party_room_dirty = true;

    // =====================================================
    // FOLLOW THE LEADER - ARRAY DE POSICIONES ANTERIORES
    // =====================================================
    //
    // Técnica estilo EarthBound / tutorial:
    //
    // - Maya guarda su X/Y y dirección después de moverse.
    // - Silicio NO calcula una ruta.
    // - Silicio usa directamente una entrada antigua del array.
    //
    // Esto hace que reproduzca literalmente el recorrido
    // anterior de Maya.
    // =====================================================

    // =====================================================
    // DISTANCIA DEL FOLLOWER
    // =====================================================
    //
    // Caminando:
    //     5 posiciones antiguas.
    //
    // Corriendo:
    //     6 posiciones antiguas.
    //
    // Como Maya corre a 6 px en vez de 4 px, esto deja a
    // Silicio un poco más separado cuando corre.
    // =====================================================

    if (!variable_global_exists("party_follow_delay_walk"))
        global.party_follow_delay_walk = 5;

    if (!variable_global_exists("party_follow_delay_run"))
        global.party_follow_delay_run = 6;


    // Delay que se está usando actualmente.
    //
    // Lo interpolamos para que al empezar/dejar de correr
    // Silicio no dé un salto brusco.
    if (!variable_global_exists("party_follow_delay_current"))
        global.party_follow_delay_current =
            global.party_follow_delay_walk;


    // Compatibilidad con versiones anteriores.
    if (!variable_global_exists("party_follow_delay"))
        global.party_follow_delay =
            global.party_follow_delay_walk;

    // Máximo de movimientos anteriores guardados.
    if (!variable_global_exists("party_history_max"))
        global.party_history_max = 300;

    // Última posición REAL registrada de Maya.
    if (!variable_global_exists("party_last_player_x"))
        global.party_last_player_x = 0;

    if (!variable_global_exists("party_last_player_y"))
        global.party_last_player_y = 0;



    // Migrar miembros antiguos de "noelle" a "maya".
    var _party_migrated = false;

    for (
        var _mi = 0;
        _mi < array_length(global.party_data.members);
        _mi++
    )
    {
        var _member =
            global.party_data.members[_mi];

        if (
            is_struct(_member)
            &&
            variable_struct_exists(_member, "id")
        )
        {
            var _normalized =
                scr_party_normalize_id(
                    string(_member.id)
                );

            if (_normalized != _member.id)
            {
                variable_struct_set(
                    _member,
                    "id",
                    _normalized
                );

                // Guardar el struct actualizado de nuevo
                // dentro del array de miembros.
                global.party_data.members[_mi] =
                    _member;

                _party_migrated =
                    true;
            }
        }
    }


    if (_party_migrated)
    {
        global.party_runtime = {};
        global.party_room_dirty = true;
    }
}


// =========================================================
// DATOS
// =========================================================

function scr_party_member_index(_party_id)
{
    scr_party_init();

    _party_id =
        scr_party_normalize_id(
            _party_id
        );

    if (!is_string(_party_id))
        return -1;

    for (var i = 0; i < array_length(global.party_data.members); i++)
    {
        var _m = global.party_data.members[i];

        if (
            is_struct(_m)
            &&
            variable_struct_exists(_m, "id")
            &&
            _m.id == _party_id
        )
        {
            return i;
        }
    }

    return -1;
}


function scr_party_has(_party_id)
{
    return scr_party_member_index(_party_id) >= 0;
}


// =========================================================
// BUSCAR NPC COLOCADO EN EL ROOM
// =========================================================

function scr_party_find_world_actor(_party_id)
{
    _party_id =
        scr_party_normalize_id(
            _party_id
        );

    if (!is_string(_party_id) || _party_id == "")
        return noone;

    var _count = instance_number(obj_parent_npc);

    for (var i = 0; i < _count; i++)
    {
        var _npc = instance_find(obj_parent_npc, i);

        if (
            _npc != noone
            &&
            instance_exists(_npc)
            &&
            variable_instance_exists(_npc, "party_id")
            &&
            _npc.party_id == _party_id
        )
        {
            return _npc;
        }
    }

    return noone;
}


// =========================================================
// RUNTIME
// =========================================================

function scr_party_runtime_set(_party_id, _actor)
{
    scr_party_init();

    _party_id =
        scr_party_normalize_id(
            _party_id
        );

    if (is_string(_party_id) && _party_id != "")
    {
        variable_struct_set(
            global.party_runtime,
            _party_id,
            _actor
        );
    }
}


function scr_party_get_instance(_party_id)
{
    scr_party_init();

    _party_id =
        scr_party_normalize_id(
            _party_id
        );

    if (!scr_party_has(_party_id))
        return noone;

    if (variable_struct_exists(global.party_runtime, _party_id))
    {
        var _actor = variable_struct_get(
            global.party_runtime,
            _party_id
        );

        if (_actor != noone && instance_exists(_actor))
            return _actor;
    }

    var _world = scr_party_find_world_actor(_party_id);

    if (_world != noone)
    {
        scr_party_runtime_set(_party_id, _world);
        return _world;
    }

    return noone;
}


// =========================================================
// PREPARAR ACTOR COMO PARTY MEMBER
// =========================================================

function scr_party_prepare_actor(_actor, _party_id)
{
    if (_actor == noone || !instance_exists(_actor))
        return false;

    _actor.party_id = _party_id;
    _actor.party_member = true;

    if (!variable_instance_exists(_actor, "party_follow_suspended"))
        _actor.party_follow_suspended = false;

    if (!variable_instance_exists(_actor, "party_rejoin"))
        _actor.party_rejoin = false;

    if (!variable_instance_exists(_actor, "party_hidden_by_system"))
        _actor.party_hidden_by_system = false;

    _actor.persistent = true;

    scr_party_runtime_set(_party_id, _actor);
    scr_cutscene_register(_party_id, _actor);

    // Si el mismo NPC quedó duplicado por ser colocado en el room,
    // conservar solamente el que pertenece a la party.
    var _count = instance_number(obj_parent_npc);

    for (var i = _count - 1; i >= 0; i--)
    {
        var _other = instance_find(obj_parent_npc, i);

        if (
            _other != noone
            &&
            _other != _actor
            &&
            instance_exists(_other)
            &&
            variable_instance_exists(_other, "party_id")
            &&
            _other.party_id == _party_id
        )
        {
            instance_destroy(_other);
        }
    }

    return true;
}


// =========================================================
// UNIR
// =========================================================

function scr_party_join_actor(_actor_or_name, _party_id = "")
{
    scr_party_init();

    var _actor = noone;

    // -----------------------------------------------------
    // STRING -> buscar actor por ID/nombre
    // -----------------------------------------------------
    //
    // IMPORTANTE:
    // En GameMaker actual una instancia puede ser un
    // "ref instance", no necesariamente un real.
    // Por eso NO usamos is_real() para detectar instancias.
    // -----------------------------------------------------

    if (is_string(_actor_or_name))
    {
        _actor = scr_cutscene_actor(_actor_or_name);

        if (_actor == noone)
            _actor = scr_party_find_world_actor(_actor_or_name);
    }
    else if (
        _actor_or_name != noone
        &&
        instance_exists(_actor_or_name)
    )
    {
        _actor = _actor_or_name;
    }

    if (_actor == noone || !instance_exists(_actor))
    {
        show_debug_message(
            "[PARTY] Actor no encontrado: "
            +
            string(_actor_or_name)
        );

        return false;
    }

    var _id = _party_id;

    if (!is_string(_id) || _id == "")
    {
        if (
            variable_instance_exists(_actor, "party_id")
            &&
            is_string(_actor.party_id)
            &&
            _actor.party_id != ""
        )
        {
            _id = _actor.party_id;
        }
        else if (is_string(_actor_or_name))
        {
            _id = _actor_or_name;
        }
        else
        {
            _id = object_get_name(_actor.object_index) + "_party";
        }
    }

    var _member = {
        id: _id,
        object_name: object_get_name(_actor.object_index)
    };

    var _index = scr_party_member_index(_id);

    if (_index >= 0)
        global.party_data.members[_index] = _member;
    else
        array_push(global.party_data.members, _member);

    scr_party_prepare_actor(_actor, _id);

    _actor.party_follow_suspended = false;

    // IMPORTANTE:
    // No hacemos "rejoin" persiguiendo en línea recta.
    // En el próximo update se colocará directamente en el
    // punto correcto de la ruta detrás de Maya.
    _actor.party_rejoin = false;

    // El trigger puede resetear el historial justo después
    // de spawnear al personaje. Si no lo hace, el manager
    // se asegura de que exista uno válido.
    if (
        array_length(global.party_history) <= 0
        ||
        global.party_history_room != room
    )
    {
        global.party_room_dirty =
            true;
    }

    show_debug_message(
        "[PARTY] Se unió: " + string(_id)
    );

    return true;
}


// =========================================================
// SALIR
// =========================================================

function scr_party_leave(_actor_or_id, _destroy_actor = false)
{
    scr_party_init();

    var _actor = noone;
    var _id = "";

    // STRING -> buscar por party_id
    if (is_string(_actor_or_id))
    {
        _id = _actor_or_id;
        _actor = scr_party_get_instance(_id);

        if (_actor == noone)
            _actor = scr_party_find_world_actor(_id);
    }
    // REFERENCIA DE INSTANCIA
    else if (
        _actor_or_id != noone
        &&
        instance_exists(_actor_or_id)
    )
    {
        _actor = _actor_or_id;

        if (variable_instance_exists(_actor, "party_id"))
            _id = _actor.party_id;
    }

    var _index = scr_party_member_index(_id);

    if (_index >= 0)
    {
        array_delete(
            global.party_data.members,
            _index,
            1
        );
    }

    if (_id != "")
        variable_struct_set(global.party_runtime, _id, noone);

    if (_actor != noone && instance_exists(_actor))
    {
        _actor.party_member = false;
        _actor.party_follow_suspended = false;
        _actor.party_rejoin = false;
        _actor.party_hidden_by_system = false;
        _actor.visible = true;
        _actor.persistent = false;

        // Al dejar la party queda quieto en el frame 0.
        _actor.image_speed = 0;
        _actor.image_index = 0;

        if (variable_instance_exists(_actor, "movimiento"))
            _actor.movimiento = false;

        if (_destroy_actor)
            instance_destroy(_actor);
    }

    global.party_room_dirty = true;

    return (_index >= 0 || _actor != noone);
}


// =========================================================
// RESET / SAVE / LOAD
// =========================================================

function scr_party_destroy_runtime_instances()
{
    scr_party_init();

    for (var i = 0; i < array_length(global.party_data.members); i++)
    {
        var _m = global.party_data.members[i];

        if (!is_struct(_m) || !variable_struct_exists(_m, "id"))
            continue;

        var _actor = scr_party_get_instance(_m.id);

        if (_actor != noone && instance_exists(_actor))
            instance_destroy(_actor);
    }

    global.party_runtime = {};
}


function scr_party_reset()
{
    scr_party_init();
    scr_party_destroy_runtime_instances();

    global.party_data = {
        members: []
    };

    global.party_runtime = {};
    global.party_history = [];
    global.party_history_room = -1;
    global.party_room_dirty = true;
}


function scr_party_export()
{
    scr_party_init();

    var _out = {
        members: []
    };

    for (var i = 0; i < array_length(global.party_data.members); i++)
    {
        var _m = global.party_data.members[i];

        if (
            is_struct(_m)
            &&
            variable_struct_exists(_m, "id")
            &&
            variable_struct_exists(_m, "object_name")
        )
        {
            var _object_name =
                string(_m.object_name);


            var _actor =
                scr_party_get_instance(
                    _m.id
                );


            if (
                _actor != noone
                &&
                instance_exists(_actor)
            )
            {
                _object_name =
                    object_get_name(
                        _actor.object_index
                    );
            }


            array_push(
                _out.members,
                {
                    id: string(_m.id),
                    object_name: _object_name
                }
            );
        }
    }

    return _out;
}


function scr_party_load(_save_party)
{
    scr_party_init();
    scr_party_destroy_runtime_instances();

    global.party_data = {
        members: []
    };

    if (
        is_struct(_save_party)
        &&
        variable_struct_exists(_save_party, "members")
        &&
        is_array(_save_party.members)
    )
    {
        for (var i = 0; i < array_length(_save_party.members); i++)
        {
            var _m = _save_party.members[i];

            if (
                is_struct(_m)
                &&
                variable_struct_exists(_m, "id")
                &&
                variable_struct_exists(_m, "object_name")
            )
            {
                array_push(
                    global.party_data.members,
                    {
                        id:
                            scr_party_normalize_id(
                                string(_m.id)
                            ),

                        object_name:
                            string(_m.object_name)
                    }
                );
            }
        }
    }

    global.party_runtime = {};
    global.party_history = [];
    global.party_history_room = -1;
    global.party_room_dirty = true;
}


// =========================================================
// ROOMS DONDE NO SE VE LA PARTY
// =========================================================

function scr_party_hidden_room()
{
    if (room == bbs)
        return true;

    var _name = room_get_name(room);

    if (string_copy(_name, 1, 5) == "shop_")
        return true;

    return false;
}


// =========================================================
// RECREAR MIEMBROS FALTANTES
// =========================================================

function scr_party_ensure_instances()
{
    scr_party_init();

    if (!instance_exists(obj_player))
        return;

    var _p = instance_find(obj_player, 0);

    for (var i = 0; i < array_length(global.party_data.members); i++)
    {
        var _m = global.party_data.members[i];

        if (
            !is_struct(_m)
            ||
            !variable_struct_exists(_m, "id")
            ||
            !variable_struct_exists(_m, "object_name")
        )
        {
            continue;
        }

        var _actor = scr_party_get_instance(_m.id);

        if (_actor == noone)
            _actor = scr_party_find_world_actor(_m.id);

        if (_actor == noone)
        {
            var _obj = asset_get_index(_m.object_name);

            if (_obj != -1)
            {
                if (layer_get_id("Instances") != -1)
                {
                    _actor = instance_create_layer(
                        _p.x,
                        _p.y,
                        "Instances",
                        _obj
                    );
                }
                else
                {
                    _actor = instance_create_depth(
                        _p.x,
                        _p.y,
                        _p.depth + 1,
                        _obj
                    );
                }
            }
        }

        if (_actor != noone && instance_exists(_actor))
            scr_party_prepare_actor(_actor, _m.id);
    }
}


// =========================================================
// DIRECCIÓN DEL FOLLOWER
// =========================================================

function scr_party_apply_direction(_actor, _face)
{
    if (_actor == noone || !instance_exists(_actor))
        return;

    var _dir = "abajo";
    var _facing = 2;
    var _sprite_var = "party_sprite_down";

    switch (_face)
    {
        case RIGHT:
            _dir = "derecha";
            _facing = 0;
            _sprite_var = "party_sprite_right";
            break;

        case LEFT:
            _dir = "izquierda";
            _facing = 1;
            _sprite_var = "party_sprite_left";
            break;

        case UP:
            _dir = "arriba";
            _facing = 3;
            _sprite_var = "party_sprite_up";
            break;

        default:
            _face = DOWN;
            _dir = "abajo";
            _facing = 2;
            _sprite_var = "party_sprite_down";
            break;
    }

    if (variable_instance_exists(_actor, "face"))
        _actor.face = _face;

    if (variable_instance_exists(_actor, "facing_direction"))
        _actor.facing_direction = _facing;

    if (variable_instance_exists(_actor, "direccion"))
        _actor.direccion = _dir;

    // Sprites direccionales opcionales.
    if (variable_instance_exists(_actor, _sprite_var))
    {
        var _spr = variable_instance_get(_actor, _sprite_var);

        if (
            _spr != noone
            &&
            _spr != -1
            &&
            sprite_exists(_spr)
        )
        {
            // No reasignar el mismo sprite cada frame.
            //
            // Hacerlo constantemente puede reiniciar o
            // interferir con image_index/image_speed.
            if (_actor.sprite_index != _spr)
            {
                var _old_frame =
                    floor(_actor.image_index);

                _actor.sprite_index =
                    _spr;

                var _frame_count =
                    sprite_get_number(_spr);

                if (_frame_count > 0)
                {
                    _actor.image_index =
                        _old_frame mod _frame_count;
                }
                else
                {
                    _actor.image_index =
                        0;
                }
            }
        }
    }
}


// =========================================================
// ANIMACIÓN DEL FOLLOWER
// =========================================================
//
// Igual que el player:
//
// - caminando -> reproduce los frames del sprite direccional
// - quieto    -> frame 0
//
// Cada sprite de Silicio puede tener sus 4 frames normales.
// =========================================================

function scr_party_apply_walk_animation(_actor, _moving)
{
    if (
        _actor == noone
        ||
        !instance_exists(_actor)
    )
    {
        return;
    }


    // Siempre manual.
    // Así ningún image_speed externo puede apagar o reiniciar
    // la animación de Silicio.
    _actor.image_speed =
        0;


    if (
        !variable_instance_exists(
            _actor,
            "party_anim_accum"
        )
    )
    {
        _actor.party_anim_accum =
            0;
    }


    if (!_moving)
    {
        _actor.party_anim_accum =
            0;

        _actor.image_index =
            0;

        return;
    }


    var _frame_count =
        1;


    if (
        _actor.sprite_index != -1
        &&
        sprite_exists(
            _actor.sprite_index
        )
    )
    {
        _frame_count =
            sprite_get_number(
                _actor.sprite_index
            );
    }


    if (_frame_count <= 1)
    {
        _actor.image_index =
            0;

        return;
    }


    // 0.22 = alrededor de un frame nuevo cada 4-5 steps.
    var _anim_speed =
        0.22;


    if (
        variable_instance_exists(
            _actor,
            "party_walk_anim_speed"
        )
    )
    {
        _anim_speed =
            max(
                0.01,
                _actor.party_walk_anim_speed
            );
    }


    _actor.party_anim_accum +=
        _anim_speed;


    while (_actor.party_anim_accum >= 1)
    {
        _actor.party_anim_accum -=
            1;

        _actor.image_index =
            (
                floor(
                    _actor.image_index
                )
                +
                1
            )
            mod
            _frame_count;
    }
}


// =========================================================
// ANCLA FÍSICA UNIVERSAL: CENTRO DE LOS PIES
// =========================================================
//
// NO usamos x/y del sprite.
//
// Dos sprites pueden tener:
// - distinto tamaño
// - distinto Origin
// - distinta máscara
//
// pero sus pies pueden alinearse exactamente.
// =========================================================

function scr_party_feet_x(_actor)
{
    if (
        _actor == noone
        ||
        !instance_exists(_actor)
    )
    {
        return 0;
    }


    return
        (
            _actor.bbox_left
            +
            _actor.bbox_right
        )
        *
        0.5;
}


function scr_party_feet_y(_actor)
{
    if (
        _actor == noone
        ||
        !instance_exists(_actor)
    )
    {
        return 0;
    }


    return _actor.bbox_bottom;
}


// =========================================================
// COLOCAR LOS PIES DE UN ACTOR EN UNA COORDENADA
// =========================================================

function scr_party_place_feet(_actor, _target_feet_x, _target_feet_y)
{
    if (
        _actor == noone
        ||
        !instance_exists(_actor)
    )
    {
        return false;
    }


    var _current_feet_x =
        scr_party_feet_x(
            _actor
        );

    var _current_feet_y =
        scr_party_feet_y(
            _actor
        );


    _actor.x +=
        _target_feet_x
        -
        _current_feet_x;

    _actor.y +=
        _target_feet_y
        -
        _current_feet_y;


    return true;
}


function scr_party_seed_history()
{
    scr_party_init();


    global.party_history =
        [];

    global.party_history_room =
        room;

    global.party_room_dirty =
        false;


    if (!instance_exists(obj_player))
        return;


    var _p =
        instance_find(
            obj_player,
            0
        );


    var _face =
        variable_instance_exists(
            _p,
            "face"
        )
        ?
        _p.face
        :
        DOWN;


    var _feet_x =
        scr_party_feet_x(
            _p
        );

    var _feet_y =
        scr_party_feet_y(
            _p
        );


    // =====================================================
    // BUFFER INICIAL EN LOS PIES ACTUALES DE MAYA
    // =====================================================

    var _seed_count =
        max(
            32,
            (
                array_length(
                    global.party_data.members
                )
                +
                2
            )
            *
            global.party_follow_delay
            +
            8
        );


    for (
        var _i = 0;
        _i < _seed_count;
        _i++
    )
    {
        array_push(
            global.party_history,
            {
                x:
                    _feet_x,

                y:
                    _feet_y,

                face:
                    _face
            }
        );
    }


    // Estas variables ahora también representan PIES,
    // no el x/y del Origin.
    global.party_last_player_x =
        _feet_x;

    global.party_last_player_y =
        _feet_y;
}


function scr_party_record_player()
{
    scr_party_init();


    if (!instance_exists(obj_player))
        return;


    if (scr_party_hidden_room())
        return;


    if (
        global.party_room_dirty
        ||
        global.party_history_room != room
        ||
        array_length(
            global.party_history
        )
        <=
        0
    )
    {
        scr_party_seed_history();
    }


    var _p =
        instance_find(
            obj_player,
            0
        );


    var _feet_x =
        scr_party_feet_x(
            _p
        );

    var _feet_y =
        scr_party_feet_y(
            _p
        );


    var _dx =
        _feet_x
        -
        global.party_last_player_x;

    var _dy =
        _feet_y
        -
        global.party_last_player_y;


    // Maya no avanzó.
    if (
        abs(_dx) <= 0.001
        &&
        abs(_dy) <= 0.001
    )
    {
        return;
    }


    // Warp / teleport.
    if (
        abs(_dx) > 16
        ||
        abs(_dy) > 16
    )
    {
        scr_party_seed_history();

        return;
    }


    var _face =
        variable_instance_exists(
            _p,
            "face"
        )
        ?
        _p.face
        :
        DOWN;


    // =====================================================
    // GUARDAR LOS PIES REALES DE MAYA
    // =====================================================

    array_push(
        global.party_history,
        {
            x:
                _feet_x,

            y:
                _feet_y,

            face:
                _face
        }
    );


    global.party_last_player_x =
        _feet_x;

    global.party_last_player_y =
        _feet_y;


    var _over =
        array_length(
            global.party_history
        )
        -
        global.party_history_max;


    if (_over > 0)
    {
        array_delete(
            global.party_history,
            0,
            _over
        );
    }
}


function scr_party_get_delayed_position(_follower_index)
{
    scr_party_init();


    var _count =
        array_length(
            global.party_history
        );


    if (_count <= 0)
    {
        return {
            x: 0,
            y: 0,
            face: DOWN
        };
    }


    // =====================================================
    // FOLLOWER 0 = 5 MOVIMIENTOS ATRÁS
    // FOLLOWER 1 = 10 MOVIMIENTOS ATRÁS
    // FOLLOWER 2 = 15 MOVIMIENTOS ATRÁS
    // =====================================================

    var _base_delay =
        global.party_follow_delay_current;


    var _delay =
        round(
            (
                _follower_index + 1
            )
            *
            _base_delay
        );


    var _index =
        _count
        -
        1
        -
        _delay;


    _index =
        clamp(
            _index,
            0,
            _count - 1
        );


    return global.party_history[
        _index
    ];
}


function scr_party_cutscene_take_control(_actor)
{
    if (
        _actor == noone
        ||
        !instance_exists(_actor)
        ||
        !variable_instance_exists(_actor, "party_member")
        ||
        !_actor.party_member
    )
    {
        return false;
    }

    _actor.party_follow_suspended = true;
    _actor.party_rejoin = false;

    return true;
}


function scr_party_release_cutscene_control()
{
    scr_party_init();

    for (var i = 0; i < array_length(global.party_data.members); i++)
    {
        var _m = global.party_data.members[i];

        if (!is_struct(_m) || !variable_struct_exists(_m, "id"))
            continue;

        var _actor = scr_party_get_instance(_m.id);

        if (_actor != noone && instance_exists(_actor))
        {
            _actor.party_follow_suspended = false;

            // Volver directamente a la ruta normal.
            _actor.party_rejoin = false;
        }
    }
}


// =========================================================
// ROOM START
// =========================================================

function scr_party_on_room_start()
{
    scr_party_init();


    // Cada habitación empieza con un buffer nuevo alrededor
    // de la posición actual de Maya.
    global.party_room_dirty =
        true;

    global.party_history_room =
        -1;

    global.party_history =
        [];
}


function scr_party_update()
{
    scr_party_init();


    if (!instance_exists(obj_player))
        return;


    scr_party_ensure_instances();


    // =====================================================
    // ¿MAYA ESTÁ CORRIENDO?
    // =====================================================
    //
    // Misma lógica que usa obj_player:
    //
    // Auto-correr OFF:
    //     X / Shift = correr.
    //
    // Auto-correr ON:
    //     corre normalmente;
    //     X / Shift = caminar.
    // =====================================================

    var _auto_run_active =
        variable_global_exists(
            "autocorrer_enabled"
        )
        &&
        global.autocorrer_enabled;


    var _run_modifier =
        keyboard_check(
            ord("X")
        )
        ||
        keyboard_check(
            vk_shift
        );


    var _player_running =
        _auto_run_active
        ?
        !_run_modifier
        :
        _run_modifier;


    var _delay_target =
        _player_running
        ?
        global.party_follow_delay_run
        :
        global.party_follow_delay_walk;


    // Cambio suave entre ambas distancias.
    global.party_follow_delay_current =
        lerp(
            global.party_follow_delay_current,
            _delay_target,
            0.28
        );


    if (
        abs(
            global.party_follow_delay_current
            -
            _delay_target
        )
        <
        0.05
    )
    {
        global.party_follow_delay_current =
            _delay_target;
    }


    // Mantener la variable antigua sincronizada por
    // compatibilidad con cualquier otro código.
    global.party_follow_delay =
        global.party_follow_delay_current;


    // =====================================================
    // BATTLE / SHOP
    // =====================================================

    if (scr_party_hidden_room())
    {
        for (
            var _i = 0;
            _i < array_length(
                global.party_data.members
            );
            _i++
        )
        {
            var _m =
                global.party_data.members[_i];


            if (
                !is_struct(_m)
                ||
                !variable_struct_exists(
                    _m,
                    "id"
                )
            )
            {
                continue;
            }


            var _actor =
                scr_party_get_instance(
                    _m.id
                );


            if (
                _actor != noone
                &&
                instance_exists(_actor)
            )
            {
                _actor.visible =
                    false;

                _actor.party_hidden_by_system =
                    true;


                if (
                    variable_instance_exists(
                        _actor,
                        "movimiento"
                    )
                )
                {
                    _actor.movimiento =
                        false;
                }


                scr_party_apply_walk_animation(
                    _actor,
                    false
                );
            }
        }


        return;
    }


    // Guardar la posición final de los PIES de Maya.
    scr_party_record_player();


    if (
        array_length(
            global.party_history
        )
        <=
        0
    )
    {
        return;
    }


    // =====================================================
    // FOLLOWERS
    // =====================================================

    for (
        var _i = 0;
        _i < array_length(
            global.party_data.members
        );
        _i++
    )
    {
        var _m =
            global.party_data.members[_i];


        if (
            !is_struct(_m)
            ||
            !variable_struct_exists(
                _m,
                "id"
            )
        )
        {
            continue;
        }


        var _actor =
            scr_party_get_instance(
                _m.id
            );


        if (
            _actor == noone
            ||
            !instance_exists(_actor)
        )
        {
            continue;
        }


        _actor.visible =
            true;

        _actor.party_hidden_by_system =
            false;


        if (
            variable_instance_exists(
                _actor,
                "party_follow_suspended"
            )
            &&
            _actor.party_follow_suspended
        )
        {
            continue;
        }


        var _target =
            scr_party_get_delayed_position(
                _i
            );


        // =================================================
        // POSICIÓN ANTERIOR DEL FOLLOWER = SUS PIES
        // =================================================

        var _old_feet_x =
            scr_party_feet_x(
                _actor
            );

        var _old_feet_y =
            scr_party_feet_y(
                _actor
            );


        // =================================================
        // PRIMERO CAMBIAR DIRECCIÓN / SPRITE
        // =================================================
        //
        // El bbox puede cambiar entre arriba/abajo/etc.
        // Por eso el sprite se cambia ANTES de colocar pies.
        // =================================================

        scr_party_apply_direction(
            _actor,
            _target.face
        );


        // =================================================
        // DESPUÉS ALINEAR PIES
        // =================================================

        scr_party_place_feet(
            _actor,
            _target.x,
            _target.y
        );


        var _new_feet_x =
            scr_party_feet_x(
                _actor
            );

        var _new_feet_y =
            scr_party_feet_y(
                _actor
            );


        // =================================================
        // ORDEN DE DIBUJO MAYA <-> FOLLOWER
        // =================================================
        //
        // En un RPG top-down:
        //
        // quien tiene los pies más ABAJO en pantalla
        // debe dibujarse DELANTE.
        //
        // GameMaker dibuja delante los depths más bajos.
        //
        // Por eso:
        //
        // Silicio debajo de Maya:
        //     depth = player.depth - 1
        //     -> Silicio delante.
        //
        // Silicio encima de Maya:
        //     depth = player.depth + 1
        //     -> Silicio detrás.
        //
        // Si están a la misma altura, dejamos a Maya delante.
        // =================================================

        var _player_instance =
            instance_find(
                obj_player,
                0
            );


        if (
            _player_instance != noone
            &&
            instance_exists(
                _player_instance
            )
        )
        {
            var _player_feet_y =
                scr_party_feet_y(
                    _player_instance
                );


            if (
                _new_feet_y
                >
                _player_feet_y + 0.5
            )
            {
                // Silicio está físicamente más abajo:
                // debe tapar a Maya.
                _actor.depth =
                    _player_instance.depth
                    -
                    1;
            }
            else
            {
                // Silicio está arriba o a la misma altura:
                // Maya debe dibujarse por delante.
                _actor.depth =
                    _player_instance.depth
                    +
                    1;
            }
        }


        var _moved =
        (
            abs(
                _new_feet_x - _old_feet_x
            )
            >
            0.001
            ||
            abs(
                _new_feet_y - _old_feet_y
            )
            >
            0.001
        );


        if (
            variable_instance_exists(
                _actor,
                "movimiento"
            )
        )
        {
            _actor.movimiento =
                _moved;
        }


        scr_party_apply_walk_animation(
            _actor,
            _moved
        );
    }
}


