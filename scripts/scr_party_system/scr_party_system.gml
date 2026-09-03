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

    // 7 breadcrumbs x ~4 px = ~28 px entre personajes.
    if (!variable_global_exists("party_spacing_steps"))
        global.party_spacing_steps = 7;

    if (!variable_global_exists("party_history_min_distance"))
        global.party_history_min_distance = 2;

    if (!variable_global_exists("party_rejoin_speed"))
        global.party_rejoin_speed = 6;


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
                _member.id =
                    _normalized;

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

    if (
        is_real(_actor_or_name)
        &&
        instance_exists(_actor_or_name)
    )
    {
        _actor = _actor_or_name;
    }
    else if (is_string(_actor_or_name))
    {
        _actor = scr_cutscene_actor(_actor_or_name);

        if (_actor == noone)
            _actor = scr_party_find_world_actor(_actor_or_name);
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
    _actor.party_rejoin = true;

    // Si ya existe historial en este room, se incorpora caminando
    // hacia su posición de follower. Si todavía no existe, el
    // manager lo sembrará normalmente.
    if (
        array_length(global.party_history) <= 0
        ||
        global.party_history_room != room
    )
    {
        global.party_room_dirty = true;
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

    if (
        is_real(_actor_or_id)
        &&
        instance_exists(_actor_or_id)
    )
    {
        _actor = _actor_or_id;

        if (variable_instance_exists(_actor, "party_id"))
            _id = _actor.party_id;
    }
    else if (is_string(_actor_or_id))
    {
        _id = _actor_or_id;
        _actor = scr_party_get_instance(_id);

        if (_actor == noone)
            _actor = scr_party_find_world_actor(_id);
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
            _actor.sprite_index = _spr;
        }
    }
}


// =========================================================
// HISTORIAL DEL PLAYER
// =========================================================

function scr_party_seed_history()
{
    scr_party_init();

    global.party_history = [];

    if (!instance_exists(obj_player))
    {
        global.party_history_room = room;
        return;
    }

    var _p = instance_find(obj_player, 0);

    var _face =
        variable_instance_exists(_p, "face")
        ?
        _p.face
        :
        DOWN;

    var _bx = 0;
    var _by = -1;

    switch (_face)
    {
        case UP:
            _bx = 0;
            _by = 1;
            break;

        case LEFT:
            _bx = 1;
            _by = 0;
            break;

        case RIGHT:
            _bx = -1;
            _by = 0;
            break;
    }

    var _steps = max(
        14,
        (array_length(global.party_data.members) + 2)
        *
        global.party_spacing_steps
    );

    // El array se guarda de "pasado" a "presente".
    for (var s = _steps; s >= 0; s--)
    {
        array_push(
            global.party_history,
            {
                x: _p.x + (_bx * s * 4),
                y: _p.y + (_by * s * 4),
                face: _face
            }
        );
    }

    global.party_history_room = room;
    global.party_room_dirty = false;
}


function scr_party_record_player()
{
    scr_party_init();

    if (!instance_exists(obj_player))
        return;

    if (
        global.party_room_dirty
        ||
        global.party_history_room != room
        ||
        array_length(global.party_history) <= 0
    )
    {
        scr_party_seed_history();
        return;
    }

    var _p = instance_find(obj_player, 0);

    var _last =
        global.party_history[
            array_length(global.party_history) - 1
        ];

    if (
        point_distance(
            _last.x,
            _last.y,
            _p.x,
            _p.y
        )
        >=
        global.party_history_min_distance
    )
    {
        var _face =
            variable_instance_exists(_p, "face")
            ?
            _p.face
            :
            DOWN;

        array_push(
            global.party_history,
            {
                x: _p.x,
                y: _p.y,
                face: _face
            }
        );

        var _over =
            array_length(global.party_history)
            -
            700;

        if (_over > 0)
            array_delete(global.party_history, 0, _over);
    }
}


// =========================================================
// CONTROL INDIVIDUAL EN CINEMÁTICAS
// =========================================================

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
            _actor.party_rejoin = true;
        }
    }
}


// =========================================================
// ROOM START
// =========================================================

function scr_party_on_room_start()
{
    scr_party_init();

    global.party_room_dirty = true;
    global.party_history_room = -1;
}


// =========================================================
// UPDATE
// =========================================================

function scr_party_update()
{
    scr_party_init();

    if (!instance_exists(obj_player))
        return;

    scr_party_ensure_instances();

    // -----------------------------------------------------
    // OCULTAR EN BATALLA / SHOP
    // -----------------------------------------------------

    if (scr_party_hidden_room())
    {
        for (var i = 0; i < array_length(global.party_data.members); i++)
        {
            var _m = global.party_data.members[i];

            if (!is_struct(_m) || !variable_struct_exists(_m, "id"))
                continue;

            var _actor = scr_party_get_instance(_m.id);

            if (_actor != noone && instance_exists(_actor))
            {
                _actor.visible = false;
                _actor.party_hidden_by_system = true;
            }
        }

        global.party_room_dirty = true;
        global.party_history_room = room;

        return;
    }

    // -----------------------------------------------------
    // REAPARECER
    // -----------------------------------------------------

    for (var i = 0; i < array_length(global.party_data.members); i++)
    {
        var _m = global.party_data.members[i];

        if (!is_struct(_m) || !variable_struct_exists(_m, "id"))
            continue;

        var _actor = scr_party_get_instance(_m.id);

        if (
            _actor != noone
            &&
            instance_exists(_actor)
            &&
            variable_instance_exists(_actor, "party_hidden_by_system")
            &&
            _actor.party_hidden_by_system
        )
        {
            _actor.visible = true;
            _actor.party_hidden_by_system = false;
        }
    }

    scr_party_record_player();

    if (array_length(global.party_history) <= 0)
        return;

    // -----------------------------------------------------
    // FOLLOW
    // -----------------------------------------------------

    for (var i = 0; i < array_length(global.party_data.members); i++)
    {
        var _m = global.party_data.members[i];

        if (!is_struct(_m) || !variable_struct_exists(_m, "id"))
            continue;

        var _actor = scr_party_get_instance(_m.id);

        if (_actor == noone || !instance_exists(_actor))
            continue;

        if (
            variable_instance_exists(_actor, "party_follow_suspended")
            &&
            _actor.party_follow_suspended
        )
        {
            if (variable_instance_exists(_actor, "movimiento"))
                _actor.movimiento = false;

            continue;
        }

        var _target_index =
            array_length(global.party_history)
            -
            1
            -
            ((i + 1) * global.party_spacing_steps);

        _target_index = clamp(
            _target_index,
            0,
            array_length(global.party_history) - 1
        );

        var _target = global.party_history[_target_index];

        var _old_x = _actor.x;
        var _old_y = _actor.y;

        var _distance = point_distance(
            _actor.x,
            _actor.y,
            _target.x,
            _target.y
        );

        var _rejoin =
            variable_instance_exists(_actor, "party_rejoin")
            &&
            _actor.party_rejoin;

        if (
            _rejoin
            &&
            _distance > global.party_rejoin_speed
        )
        {
            var _dir = point_direction(
                _actor.x,
                _actor.y,
                _target.x,
                _target.y
            );

            _actor.x += lengthdir_x(
                global.party_rejoin_speed,
                _dir
            );

            _actor.y += lengthdir_y(
                global.party_rejoin_speed,
                _dir
            );
        }
        else
        {
            _actor.x = _target.x;
            _actor.y = _target.y;

            if (_rejoin)
                _actor.party_rejoin = false;
        }

        var _moved =
            abs(_actor.x - _old_x) > 0.01
            ||
            abs(_actor.y - _old_y) > 0.01;

        var _face = _target.face;

        // Durante la reincorporación, mirar hacia el vector real.
        if (_rejoin && _moved)
        {
            var _dx = _actor.x - _old_x;
            var _dy = _actor.y - _old_y;

            if (abs(_dx) >= abs(_dy))
                _face = (_dx >= 0) ? RIGHT : LEFT;
            else
                _face = (_dy >= 0) ? DOWN : UP;
        }

        scr_party_apply_direction(
            _actor,
            _face
        );

        if (variable_instance_exists(_actor, "movimiento"))
            _actor.movimiento = _moved;
    }
}
