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


    // =====================================================
    // TERRENOS ESPECIALES - DISTANCIA DEL FOLLOWER
    // =====================================================
    //
    // Hielo:
    //     conserva la distancia física que había al entrar.
    //
    // Deslizamiento hacia abajo:
    //     Silicio sigue lateralmente a Maya mientras baja.
    //     Al terminar espera a que Maya genere la separación
    //     normal y luego se reincorpora suavemente al punto
    //     exacto de formación, sin teletransportes.
    // =====================================================

    if (!variable_global_exists("party_ice_recover_rate"))
        global.party_ice_recover_rate = 1.25;

    if (!variable_global_exists("party_downslide_wait_frames"))
        global.party_downslide_wait_frames = 8;


    // Cuando Maya ya salió por abajo pero Silicio todavía
    // está dentro, Silicio debe seguir avanzando aunque Maya
    // esté completamente quieta.
    //
    // 6 px/frame = misma velocidad vertical del deslizamiento.
    if (!variable_global_exists("party_downslide_finish_rate"))
        global.party_downslide_finish_rate = 6.0;


    // Una vez Silicio también sale por abajo, acelera todavía
    // más para recuperar la separación normal.
    if (!variable_global_exists("party_downslide_catchup_rate"))
        global.party_downslide_catchup_rate = 8.0;


    // Reincorporación después del deslizamiento.
    //
    // Empieza despacio y acelera gradualmente.
    // Así nunca hay un salto brusco al abandonar wait_gap,
    // pero Silicio sí puede alcanzar la formación aunque Maya
    // continúe corriendo.
    if (!variable_global_exists("party_downslide_rejoin_start_speed"))
        global.party_downslide_rejoin_start_speed = 2.0;

    if (!variable_global_exists("party_downslide_rejoin_speed"))
        global.party_downslide_rejoin_speed = 7.0;

    if (!variable_global_exists("party_downslide_rejoin_accel"))
        global.party_downslide_rejoin_accel = 0.5;


    if (!variable_global_exists("party_special_failsafe_frames"))
        global.party_special_failsafe_frames = 180;

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


// =========================================================
// RESOLVER OBJETO A PARTIR DEL PARTY ID
// =========================================================
//
// "silicio" -> obj_silicio
//
// Primero intenta usar datos ya conocidos de la party.
// Después intenta automáticamente "obj_" + party_id.
// =========================================================

function scr_party_object_from_id(_party_id)
{
    scr_party_init();


    _party_id =
        scr_party_normalize_id(
            _party_id
        );


    if (
        !is_string(_party_id)
        ||
        _party_id == ""
    )
    {
        return -1;
    }


    var _index =
        scr_party_member_index(
            _party_id
        );


    if (_index >= 0)
    {
        var _member =
            global.party_data.members[
                _index
            ];


        if (
            is_struct(_member)
            &&
            variable_struct_exists(
                _member,
                "object_name"
            )
        )
        {
            var _known_obj =
                asset_get_index(
                    string(
                        _member.object_name
                    )
                );


            if (_known_obj != -1)
                return _known_obj;
        }
    }


    // Convención automática:
    // "silicio" -> "obj_silicio"
    var _automatic =
        asset_get_index(
            "obj_"
            +
            string(_party_id)
        );


    if (_automatic != -1)
        return _automatic;


    // Fallback: por si el propio ID ya era nombre de objeto.
    _automatic =
        asset_get_index(
            string(_party_id)
        );


    return _automatic;
}


// =========================================================
// SPAWN DE ACTOR PARTY-CAPABLE SIN UNIRLO TODAVÍA
// =========================================================
//
// Sirve para cinematica:
//
// cs_party_actor("silicio", 500, 200)
//
// Lo crea como NPC/actor cinematográfico normal.
// TODAVÍA NO es follower.
// =========================================================

function scr_party_spawn_cinematic_actor(
    _party_id,
    _x,
    _y,
    _layer = "Instances"
)
{
    scr_party_init();


    _party_id =
        scr_party_normalize_id(
            _party_id
        );


    // Ya existe como actor registrado / party / NPC.
    var _existing =
        scr_cutscene_actor(
            _party_id
        );


    if (
        _existing != noone
        &&
        instance_exists(_existing)
    )
    {
        scr_cutscene_register(
            _party_id,
            _existing
        );

        return _existing;
    }


    var _obj =
        scr_party_object_from_id(
            _party_id
        );


    if (_obj == -1)
    {
        show_debug_message(
            "[PARTY] No pude resolver objeto para: "
            +
            string(_party_id)
        );

        return noone;
    }


    var _actor =
        noone;


    if (
        is_string(_layer)
        &&
        layer_get_id(_layer) != -1
    )
    {
        _actor =
            instance_create_layer(
                _x,
                _y,
                _layer,
                _obj
            );
    }
    else
    {
        _actor =
            instance_create_depth(
                _x,
                _y,
                0,
                _obj
            );
    }


    if (
        _actor == noone
        ||
        !instance_exists(_actor)
    )
    {
        return noone;
    }


    _actor.party_id =
        _party_id;


    // Todavía NO forma parte del grupo.
    if (
        variable_instance_exists(
            _actor,
            "party_member"
        )
    )
    {
        _actor.party_member =
            false;
    }


    if (
        variable_instance_exists(
            _actor,
            "party_follow_suspended"
        )
    )
    {
        _actor.party_follow_suspended =
            false;
    }


    // No persistente mientras siga siendo un NPC normal.
    _actor.persistent =
        false;


    scr_cutscene_register(
        _party_id,
        _actor
    );


    return _actor;
}


// =========================================================
// SEMBRAR RUTA ARTIFICIAL DETRÁS DE MAYA
// =========================================================
//
// Solo se usa cuando una cinemática necesita poner un
// personaje "detrás de Maya" pero todavía no existe una
// ruta antigua suficiente.
//
// Cada entrada equivale aproximadamente a un paso normal
// de Maya (~4 px).
// =========================================================

function scr_party_seed_history_behind_player()
{
    scr_party_init();


    if (!instance_exists(obj_player))
        return false;


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


    // Un "snapshot" normal representa aproximadamente 4px.
    var _step =
        4;


    var _back_x =
        0;

    var _back_y =
        -_step;


    switch (_face)
    {
        case RIGHT:
            _back_x = -_step;
            _back_y = 0;
            break;

        case LEFT:
            _back_x = _step;
            _back_y = 0;
            break;

        case DOWN:
            _back_x = 0;
            _back_y = -_step;
            break;

        case UP:
            _back_x = 0;
            _back_y = _step;
            break;
    }


    var _seed_count =
        max(
            40,
            (
                array_length(
                    global.party_data.members
                )
                +
                3
            )
            *
            max(
                global.party_follow_delay_walk,
                global.party_follow_delay_run
            )
            +
            12
        );


    global.party_history =
        [];


    // Punto más viejo -> punto más nuevo.
    for (
        var _i = _seed_count;
        _i >= 0;
        _i--
    )
    {
        array_push(
            global.party_history,
            {
                x:
                    _feet_x
                    +
                    (_back_x * _i),

                y:
                    _feet_y
                    +
                    (_back_y * _i),

                face:
                    _face
            }
        );
    }


    global.party_history_room =
        room;

    global.party_room_dirty =
        false;

    global.party_last_player_x =
        _feet_x;

    global.party_last_player_y =
        _feet_y;


    return true;
}


// =========================================================
// OBTENER PUESTO CORRECTO DETRÁS DE MAYA PARA UN NUEVO
// FOLLOWER
// =========================================================
//
// Devuelve:
//
// {
//     x: feet_x,
//     y: feet_y,
//     face: ...,
//     synthetic: true/false
// }
//
// synthetic = true significa que no había ruta útil y hay
// que sembrar una ruta detrás de Maya antes de unir.
// =========================================================

function scr_party_get_join_target(_follower_index)
{
    scr_party_init();


    if (!instance_exists(obj_player))
    {
        return {
            x: 0,
            y: 0,
            face: DOWN,
            synthetic: true
        };
    }


    var _p =
        instance_find(
            obj_player,
            0
        );


    var _player_feet_x =
        scr_party_feet_x(
            _p
        );

    var _player_feet_y =
        scr_party_feet_y(
            _p
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


    // Asegurar que haya historial.
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


    var _target =
        scr_party_get_delayed_position(
            _follower_index
        );


    var _dist_to_player =
        point_distance(
            _target.x,
            _target.y,
            _player_feet_x,
            _player_feet_y
        );


    // Si el historial sí contiene un punto realmente detrás,
    // usar exactamente ese camino.
    if (_dist_to_player >= 8)
    {
        return {
            x: _target.x,
            y: _target.y,
            face: _target.face,
            synthetic: false
        };
    }


    // No hay camino suficiente (por ejemplo, Maya estaba
    // quieta desde el inicio de la room).
    //
    // Crear un punto geométrico detrás de ella.
    var _gap =
        round(
            global.party_follow_delay_walk
            *
            4
            *
            (_follower_index + 1)
        );


    var _x =
        _player_feet_x;

    var _y =
        _player_feet_y;


    switch (_face)
    {
        case RIGHT:
            _x -= _gap;
            break;

        case LEFT:
            _x += _gap;
            break;

        case DOWN:
            _y -= _gap;
            break;

        case UP:
            _y += _gap;
            break;
    }


    return {
        x: _x,
        y: _y,
        face: _face,
        synthetic: true
    };
}


// =========================================================
// CONVERTIR UN TARGET DE "PIES" A X/Y DE LA INSTANCIA
// =========================================================

function scr_party_origin_for_feet(
    _actor,
    _feet_x,
    _feet_y
)
{
    if (
        _actor == noone
        ||
        !instance_exists(_actor)
    )
    {
        return {
            x: 0,
            y: 0
        };
    }


    return {
        x:
            _actor.x
            +
            (
                _feet_x
                -
                scr_party_feet_x(_actor)
            ),

        y:
            _actor.y
            +
            (
                _feet_y
                -
                scr_party_feet_y(_actor)
            )
    };
}


// =========================================================
// SMART JOIN
// =========================================================
//
// cs_party_join("silicio")
//
// Si Silicio existe:
//     usa esa instancia.
//
// Si NO existe:
//     resuelve obj_silicio,
//     lo crea directamente en su slot detrás de Maya,
//     y lo une.
//
// No es necesario dejar obj_silicio colocado en la room.
// =========================================================

function scr_party_smart_join(
    _actor_or_name,
    _party_id = ""
)
{
    scr_party_init();


    var _actor =
        noone;

    var _id =
        _party_id;


    if (is_string(_actor_or_name))
    {
        if (
            !is_string(_id)
            ||
            _id == ""
        )
        {
            _id =
                scr_party_normalize_id(
                    _actor_or_name
                );
        }


        _actor =
            scr_cutscene_actor(
                _actor_or_name
            );


        if (_actor == noone)
        {
            _actor =
                scr_party_find_world_actor(
                    _actor_or_name
                );
        }
    }
    else if (
        _actor_or_name != noone
        &&
        instance_exists(
            _actor_or_name
        )
    )
    {
        _actor =
            _actor_or_name;


        if (
            !is_string(_id)
            ||
            _id == ""
        )
        {
            if (
                variable_instance_exists(
                    _actor,
                    "party_id"
                )
            )
            {
                _id =
                    _actor.party_id;
            }
        }
    }


    // =====================================================
    // NO EXISTE -> SPAWN AUTOMÁTICO EN SU SLOT
    // =====================================================

    if (
        _actor == noone
        ||
        !instance_exists(_actor)
    )
    {
        if (
            !is_string(_id)
            ||
            _id == ""
        )
        {
            return false;
        }


        var _slot_index =
            array_length(
                global.party_data.members
            );


        var _target =
            scr_party_get_join_target(
                _slot_index
            );


        // Si era un target sintético, preparar el historial
        // antes del join para que no haya snap en el siguiente
        // End Step.
        if (_target.synthetic)
        {
            scr_party_seed_history_behind_player();

            _target =
                scr_party_get_join_target(
                    _slot_index
                );
        }


        if (!instance_exists(obj_player))
            return false;


        var _p =
            instance_find(
                obj_player,
                0
            );


        _actor =
            scr_party_spawn_cinematic_actor(
                _id,
                _p.x,
                _p.y,
                "Instances"
            );


        if (
            _actor == noone
            ||
            !instance_exists(_actor)
        )
        {
            return false;
        }


        scr_party_apply_direction(
            _actor,
            _target.face
        );


        scr_party_place_feet(
            _actor,
            _target.x,
            _target.y
        );
    }


    return scr_party_join_actor(
        _actor,
        _id
    );
}


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
// TERRENO BAJO UN FOLLOWER
// =========================================================

function scr_party_actor_overlaps(_actor, _object)
{
    if (
        _actor == noone
        ||
        !instance_exists(_actor)
    )
    {
        return false;
    }


    return
        collision_rectangle(
            _actor.bbox_left,
            _actor.bbox_top,
            _actor.bbox_right,
            _actor.bbox_bottom,
            _object,
            false,
            true
        )
        !=
        noone;
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


    _actor.image_speed =
        0;


    // =====================================================
    // VARIABLES SEGURAS
    // =====================================================

    if (!variable_instance_exists(_actor, "party_anim_accum"))
        _actor.party_anim_accum = 0;

    if (!variable_instance_exists(_actor, "party_anim_hold"))
        _actor.party_anim_hold = 0;

    if (!variable_instance_exists(_actor, "party_anim_hold_max"))
        _actor.party_anim_hold_max = 6;

    if (!variable_instance_exists(_actor, "party_anim_was_moving"))
        _actor.party_anim_was_moving = false;

    if (!variable_instance_exists(_actor, "party_ice_tap_timer"))
        _actor.party_ice_tap_timer = 0;

    if (!variable_instance_exists(_actor, "party_ice_tap_duration"))
        _actor.party_ice_tap_duration = 4;

    if (!variable_instance_exists(_actor, "party_ice_tap_frame"))
        _actor.party_ice_tap_frame = 0;


    // =====================================================
    // DESLIZAMIENTO HACIA ABAJO
    // =====================================================
    //
    // El follower ya sigue la ruta histórica de Maya.
    // Aquí solamente forzamos su pose especial mientras su
    // cuerpo está dentro del objeto.
    // =====================================================

    var _party_downslide_visual =
        false;


    if (
        variable_instance_exists(
            _actor,
            "party_special_mode"
        )
    )
    {
        _party_downslide_visual =
            (
                (
                    _actor.party_special_mode
                    ==
                    "downslide_follow"
                )
                &&
                scr_party_actor_overlaps(
                    _actor,
                    obj_deslizamiento_abajo
                )
            )
            ||
            (
                _actor.party_special_mode
                ==
                "downslide_exit"
            );
    }


    if (_party_downslide_visual)
    {
        scr_party_apply_direction(
            _actor,
            DOWN
        );


        var _slide_frames =
            sprite_get_number(
                _actor.sprite_index
            );


        if (_slide_frames >= 5)
        {
            _actor.image_index =
                4;
        }
        else
        {
            _actor.image_index =
                max(
                    0,
                    _slide_frames - 1
                );
        }


        _actor.party_anim_accum =
            0;

        _actor.party_anim_hold =
            0;

        _actor.party_anim_was_moving =
            false;

        _actor.party_ice_tap_timer =
            0;

        return;
    }


    // =====================================================
    // HIELO AZUL - PARTY
    // =====================================================
    //
    // Silicio se desliza visualmente en idle igual que Maya.
    // =====================================================

    if (
        scr_party_actor_overlaps(
            _actor,
            obj_hielo_azul
        )
    )
    {
        _actor.image_index =
            0;

        _actor.party_anim_accum =
            0;

        _actor.party_anim_hold =
            0;

        _actor.party_anim_was_moving =
            false;

        _actor.party_ice_tap_timer =
            0;

        return;
    }


    // =====================================================
    // HIELO NORMAL - PARTY
    // =====================================================
    //
    // Igual que Maya:
    // una nueva pulsación produce una pequeña reacción,
    // mantener la tecla NO mantiene la caminata.
    // =====================================================

    if (
        scr_party_actor_overlaps(
            _actor,
            obj_hielo
        )
    )
    {
        var _ice_frame_count =
            sprite_get_number(
                _actor.sprite_index
            );


        // El frame 4 de spr_silicio_abajo queda reservado.
        if (
            variable_instance_exists(
                _actor,
                "party_sprite_down"
            )
            &&
            _actor.sprite_index
            ==
            _actor.party_sprite_down
            &&
            _ice_frame_count >= 5
        )
        {
            _ice_frame_count =
                4;
        }


        var _ice_tap =
            keyboard_check_pressed(vk_right)
            ||
            keyboard_check_pressed(vk_left)
            ||
            keyboard_check_pressed(vk_up)
            ||
            keyboard_check_pressed(vk_down);


        if (
            _ice_tap
            &&
            _ice_frame_count > 1
        )
        {
            _actor.party_ice_tap_frame++;


            if (
                _actor.party_ice_tap_frame <= 0
                ||
                _actor.party_ice_tap_frame
                >=
                _ice_frame_count
            )
            {
                _actor.party_ice_tap_frame =
                    1;
            }


            _actor.image_index =
                _actor.party_ice_tap_frame;


            _actor.party_ice_tap_timer =
                _actor.party_ice_tap_duration;
        }


        if (_actor.party_ice_tap_timer > 0)
        {
            _actor.party_ice_tap_timer--;
        }
        else
        {
            _actor.image_index =
                0;
        }


        _actor.party_anim_accum =
            0;

        _actor.party_anim_hold =
            0;

        _actor.party_anim_was_moving =
            false;

        return;
    }


    // =====================================================
    // ANIMACIÓN NORMAL
    // =====================================================

    _actor.party_ice_tap_timer =
        0;


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


    // =====================================================
    // RESERVAR EL QUINTO FRAME DE ABAJO
    // =====================================================

    var _walk_frame_count =
        _frame_count;


    if (
        variable_instance_exists(
            _actor,
            "party_sprite_down"
        )
        &&
        _actor.sprite_index
        ==
        _actor.party_sprite_down
        &&
        _frame_count >= 5
    )
    {
        _walk_frame_count =
            4;
    }


    if (_walk_frame_count <= 1)
    {
        _actor.image_index =
            0;

        _actor.party_anim_accum =
            0;

        _actor.party_anim_was_moving =
            _moving;

        return;
    }


    // Si venimos del frame especial 4, volver al frame 0.
    //
    // La caminata normal de Silicio SIEMPRE empieza dentro
    // del rango:
    //
    //     0, 1, 2, 3
    //
    if (
        floor(_actor.image_index)
        < 0
        ||
        floor(_actor.image_index)
        >=
        _walk_frame_count
    )
    {
        _actor.image_index =
            0;

        _actor.party_anim_accum =
            0;
    }


    // =====================================================
    // MOVIÉNDOSE
    // =====================================================

    if (_moving)
    {
        // NO forzar 0 -> 1 al empezar.
        //
        // El frame 0 forma parte real de la caminata, por lo
        // que la secuencia completa será:
        //
        //     0 -> 1 -> 2 -> 3 -> 0
        //
        // para ARRIBA, ABAJO, IZQUIERDA y DERECHA.
        _actor.party_anim_hold =
            _actor.party_anim_hold_max;


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


        // =================================================
        // SECUENCIA ESTRICTA DE SILICIO
        // =================================================
        //
        // Máximo UN avance por Step.
        //
        // Esto garantiza que jamás pueda ocurrir:
        //
        //     1 -> 3
        //
        // aunque el acumulador tenga un valor alto.
        //
        // Secuencia:
        //
        //     0 -> 1 -> 2 -> 3 -> 0
        // =================================================

        if (_actor.party_anim_accum >= 1)
        {
            _actor.party_anim_accum -=
                1;


            var _next =
                floor(
                    _actor.image_index
                )
                +
                1;


            if (_next >= _walk_frame_count)
            {
                _next =
                    0;
            }


            _actor.image_index =
                clamp(
                    _next,
                    0,
                    _walk_frame_count - 1
                );
        }
    }


    // =====================================================
    // QUIETO
    // =====================================================

    else
    {
        if (_actor.party_anim_hold > 0)
        {
            _actor.party_anim_hold--;
        }


        if (_actor.party_anim_hold <= 0)
        {
            _actor.party_anim_accum =
                0;

            _actor.image_index =
                0;
        }
    }


    _actor.party_anim_was_moving =
        _moving;
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



// =========================================================
// DISTANCIA FÍSICA SOBRE EL HISTORIAL
// =========================================================
//
// Los delays normales de la party se basan en "snapshots".
// En hielo eso puede reducir mucho la separación física
// cuando Maya desacelera.
//
// Para terrenos especiales usamos distancia REAL recorrida
// sobre el historial, no cantidad de snapshots.
// =========================================================

function scr_party_history_gap_for_delay(_follower_index)
{
    scr_party_init();


    var _count =
        array_length(
            global.party_history
        );


    if (_count <= 1)
        return 0;


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


    var _target_index =
        clamp(
            _count
            -
            1
            -
            _delay,
            0,
            _count - 1
        );


    var _distance =
        0;


    for (
        var _i = _count - 1;
        _i > _target_index;
        _i--
    )
    {
        var _a =
            global.party_history[_i];

        var _b =
            global.party_history[_i - 1];


        _distance +=
            point_distance(
                _a.x,
                _a.y,
                _b.x,
                _b.y
            );
    }


    return _distance;
}


// =========================================================
// TARGET A X PÍXELES DE DISTANCIA SOBRE LA RUTA
// =========================================================

function scr_party_get_position_by_path_gap(_gap)
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


    _gap =
        max(
            0,
            _gap
        );


    var _accum =
        0;


    // Punto más nuevo.
    var _latest =
        global.party_history[
            _count - 1
        ];


    if (_gap <= 0)
        return _latest;


    // Recorrer la ruta hacia atrás.
    for (
        var _i = _count - 1;
        _i > 0;
        _i--
    )
    {
        var _newer =
            global.party_history[_i];

        var _older =
            global.party_history[_i - 1];


        var _segment =
            point_distance(
                _newer.x,
                _newer.y,
                _older.x,
                _older.y
            );


        if (_segment <= 0.0001)
            continue;


        if (
            _accum
            +
            _segment
            >=
            _gap
        )
        {
            var _inside =
                _gap
                -
                _accum;


            var _t =
                clamp(
                    _inside
                    /
                    _segment,
                    0,
                    1
                );


            return {
                x:
                    lerp(
                        _newer.x,
                        _older.x,
                        _t
                    ),

                y:
                    lerp(
                        _newer.y,
                        _older.y,
                        _t
                    ),

                face:
                    _older.face
            };
        }


        _accum +=
            _segment;
    }


    return global.party_history[0];
}


// =========================================================
// DISTANCIA ACTUAL DE UN FOLLOWER SOBRE LA RUTA
// =========================================================
//
// Busca el punto del historial más cercano a los pies del
// follower y calcula cuánta ruta hay desde ahí hasta Maya.
// =========================================================

function scr_party_path_gap_to_actor(_actor)
{
    scr_party_init();


    if (
        _actor == noone
        ||
        !instance_exists(_actor)
    )
    {
        return 0;
    }


    var _count =
        array_length(
            global.party_history
        );


    if (_count <= 1)
        return 0;


    var _feet_x =
        scr_party_feet_x(
            _actor
        );

    var _feet_y =
        scr_party_feet_y(
            _actor
        );


    var _nearest_index =
        _count - 1;

    var _nearest_distance =
        1000000000;


    for (
        var _i = _count - 1;
        _i >= 0;
        _i--
    )
    {
        var _point =
            global.party_history[_i];


        var _d =
            point_distance(
                _feet_x,
                _feet_y,
                _point.x,
                _point.y
            );


        if (_d < _nearest_distance)
        {
            _nearest_distance =
                _d;

            _nearest_index =
                _i;
        }
    }


    var _gap =
        0;


    for (
        var _i = _count - 1;
        _i > _nearest_index;
        _i--
    )
    {
        var _a =
            global.party_history[_i];

        var _b =
            global.party_history[_i - 1];


        _gap +=
            point_distance(
                _a.x,
                _a.y,
                _b.x,
                _b.y
            );
    }


    return
        _gap
        +
        _nearest_distance;
}


// =========================================================
// ACERCAR UN VALOR SIN SALTOS
// =========================================================

function scr_party_approach_value(
    _value,
    _target,
    _amount
)
{
    if (_value < _target)
    {
        return min(
            _value + _amount,
            _target
        );
    }


    if (_value > _target)
    {
        return max(
            _value - _amount,
            _target
        );
    }


    return _target;
}


// =========================================================
// ESTADO ESPECIAL DEL FOLLOWER
// =========================================================

function scr_party_special_state_init(_actor)
{
    if (
        _actor == noone
        ||
        !instance_exists(_actor)
    )
    {
        return;
    }


    if (!variable_instance_exists(_actor, "party_special_mode"))
        _actor.party_special_mode = "none";

    if (!variable_instance_exists(_actor, "party_special_gap"))
        _actor.party_special_gap = 0;

    if (!variable_instance_exists(_actor, "party_downslide_wait_timer"))
        _actor.party_downslide_wait_timer = 0;

    if (!variable_instance_exists(_actor, "party_downslide_has_entered"))
        _actor.party_downslide_has_entered = false;

    if (!variable_instance_exists(_actor, "party_downslide_exit_remaining"))
        _actor.party_downslide_exit_remaining = 0;

    // Distancia NUEVA recorrida por Maya DESPUÉS de que
    // Silicio termina completamente el deslizamiento.
    //
    // No incluye ningún zig-zag hecho dentro del trigger.
    if (!variable_instance_exists(_actor, "party_downslide_gap_accum"))
        _actor.party_downslide_gap_accum = 0;

    // Velocidad física actual de la reincorporación.
    if (!variable_instance_exists(_actor, "party_downslide_rejoin_current_speed"))
        _actor.party_downslide_rejoin_current_speed = 0;

    // Borde inferior anterior de Silicio.
    //
    // Sirve para saber si realmente ENTRÓ desde arriba.
    // Así caminar hacia arriba atravesando el trigger no
    // activa accidentalmente el deslizamiento.
    if (!variable_instance_exists(_actor, "party_downslide_prev_bottom"))
        _actor.party_downslide_prev_bottom = _actor.bbox_bottom;

    if (!variable_instance_exists(_actor, "party_ice_has_entered"))
        _actor.party_ice_has_entered = false;

    if (!variable_instance_exists(_actor, "party_special_post_timer"))
        _actor.party_special_post_timer = 0;
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
    // DISTANCIA DINÁMICA SOLO SI MAYA SE MUEVE
    // =====================================================
    //
    // Mantener X / Shift mientras Maya está quieta NO debe
    // cambiar la separación de Silicio.
    //
    // Primero comprobamos si los PIES del player realmente
    // cambiaron desde el último punto registrado.
    // =====================================================

    var _player_instance =
        instance_find(
            obj_player,
            0
        );


    var _player_feet_x_now =
        scr_party_feet_x(
            _player_instance
        );

    var _player_feet_y_now =
        scr_party_feet_y(
            _player_instance
        );


    var _player_dx_now =
        _player_feet_x_now
        -
        global.party_last_player_x;

    var _player_dy_now =
        _player_feet_y_now
        -
        global.party_last_player_y;


    var _player_move_distance =
        point_distance(
            0,
            0,
            _player_dx_now,
            _player_dy_now
        );


    var _player_actually_moved =
        (_player_move_distance > 0.001);


    // =====================================================
    // SOLO CAMBIAR EL DELAY SI HUBO MOVIMIENTO REAL
    // =====================================================

    var _player_on_forced_surface_for_delay =
        (
            scr_party_actor_overlaps(
                _player_instance,
                obj_hielo
            )
            ||
            scr_party_actor_overlaps(
                _player_instance,
                obj_hielo_azul
            )
            ||
            (
                variable_instance_exists(
                    _player_instance,
                    "downslide_active"
                )
                &&
                _player_instance.downslide_active
            )
        );


    if (
        _player_actually_moved
        &&
        !_player_on_forced_surface_for_delay
    )
    {
        // Detectamos caminar/correr por lo que Maya hizo
        // realmente este frame, no por X/Shift ni Auto-correr.
        //
        // Normal ≈ 4 px
        // Correr ≈ 6 px
        var _player_running =
            (_player_move_distance > 4.5);


        var _delay_target =
            _player_running
            ?
            global.party_follow_delay_run
            :
            global.party_follow_delay_walk;


        // =================================================
        // TRANSICIÓN DE DISTANCIA
        // =================================================
        //
        // Al EMPEZAR a correr:
        // abrimos distancia relativamente rápido.
        //
        // Al DEJAR de correr:
        // volvemos más lentamente hacia Maya.
        //
        // Esto evita que Silicio "se recoja" de golpe.
        // =================================================

        var _delay_lerp_speed =
            (
                _delay_target
                >
                global.party_follow_delay_current
            )
            ?
            0.24
            :
            0.08;


        global.party_follow_delay_current =
            lerp(
                global.party_follow_delay_current,
                _delay_target,
                _delay_lerp_speed
            );


        if (
            abs(
                global.party_follow_delay_current
                -
                _delay_target
            )
            <
            0.03
        )
        {
            global.party_follow_delay_current =
                _delay_target;
        }
    }


    // Si Maya está quieta, party_follow_delay_current
    // se queda EXACTAMENTE como estaba.


    // Compatibilidad con código anterior.
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


        // =================================================
        // TARGET NORMAL + TERRENOS ESPECIALES
        // =================================================
        //
        // El movimiento normal de party sigue usando el
        // sistema habitual.
        //
        // Solo hielo / deslizamiento usan distancia física
        // sobre la ruta para evitar cambios bruscos.
        // =================================================

        scr_party_special_state_init(
            _actor
        );


        var _normal_target =
            scr_party_get_delayed_position(
                _i
            );


        var _normal_gap =
            max(
                scr_party_history_gap_for_delay(
                    _i
                ),
                (
                    _i + 1
                )
                *
                global.party_follow_delay_walk
                *
                4
            );


        var _target =
            _normal_target;


        var _hold_follow =
            false;


        var _player_on_normal_ice =
            scr_party_actor_overlaps(
                _player_instance,
                obj_hielo
            );


        var _player_on_blue_ice =
            scr_party_actor_overlaps(
                _player_instance,
                obj_hielo_azul
            );


        var _player_on_ice =
            (
                _player_on_normal_ice
                ||
                _player_on_blue_ice
            );


        var _actor_on_ice =
            (
                scr_party_actor_overlaps(
                    _actor,
                    obj_hielo
                )
                ||
                scr_party_actor_overlaps(
                    _actor,
                    obj_hielo_azul
                )
            );


        var _player_on_downslide =
            (
                variable_instance_exists(
                    _player_instance,
                    "downslide_active"
                )
                &&
                _player_instance.downslide_active
            );


        var _actor_on_downslide =
            scr_party_actor_overlaps(
                _actor,
                obj_deslizamiento_abajo
            );


        // =================================================
        // DESLIZAMIENTO HACIA ABAJO - SILICIO
        // =================================================
        //
        // NUEVO COMPORTAMIENTO:
        //
        // - NO espera ningún tiempo artificial.
        // - Sigue normalmente a Maya hasta entrar él mismo.
        // - Solo se activa si Silicio entra desde ARRIBA.
        // - Una vez activado, YA NO DEPENDE de dónde esté Maya.
        // - Baja automáticamente hasta salir del objeto.
        // - Después recorre downslide_exit_extra píxeles.
        // - Finalmente vuelve a alcanzar a Maya.
        //
        // =================================================

        var _mode =
            _actor.party_special_mode;


        var _mode_is_downslide =
            (
                _mode == "downslide_follow"
                ||
                _mode == "downslide_exit"
                ||
                _mode == "downslide_wait_gap"
                ||
                _mode == "downslide_rejoin"
            );


        // -------------------------------------------------
        // OBTENER EL OBJETO DE DESLIZAMIENTO QUE TOCA SILICIO
        // -------------------------------------------------

        var _actor_downslide_zone =
            collision_rectangle(
                _actor.bbox_left,
                _actor.bbox_top,
                _actor.bbox_right,
                _actor.bbox_bottom,
                obj_deslizamiento_abajo,
                false,
                true
            );


        _actor_on_downslide =
            (
                _actor_downslide_zone
                !=
                noone
            );


        // -------------------------------------------------
        // ACTIVAR ÚNICAMENTE AL ENTRAR DESDE ARRIBA
        // -------------------------------------------------
        //
        // También exigimos que el borde inferior ACTUAL haya
        // avanzado hacia abajo respecto al frame anterior.
        //
        // Por eso:
        //
        // caminar hacia ARRIBA por el trigger
        //     -> NO activa el modo
        //
        // entrar desde ARRIBA bajando
        //     -> SÍ activa el modo
        //
        // -------------------------------------------------

        if (
            !_mode_is_downslide
            &&
            _actor_on_downslide
        )
        {
            var _actor_entered_from_top =
                (
                    _actor.bbox_bottom
                    >
                    _actor.party_downslide_prev_bottom
                )
                &&
                (
                    _actor.party_downslide_prev_bottom
                    <=
                    _actor_downslide_zone.bbox_top
                    +
                    4
                );


            if (_actor_entered_from_top)
            {
                _actor.party_special_mode =
                    "downslide_follow";


                _actor.party_downslide_has_entered =
                    true;


                _actor.party_special_post_timer =
                    0;


                // Guardar la separación solo para poder
                // recuperarla después del deslizamiento.
                _actor.party_special_gap =
                    max(
                        _normal_gap,
                        scr_party_path_gap_to_actor(
                            _actor
                        )
                    );
            }
        }


        // -------------------------------------------------
        // ARRASTRE AUTÓNOMO HACIA ABAJO
        // -------------------------------------------------
        //
        // IMPORTANTE:
        //
        // La BAJADA no depende de Maya: Silicio seguirá
        // avanzando hacia abajo mientras siga dentro de
        // obj_deslizamiento_abajo.
        //
        // La X sí usa la ruta de party para copiar los
        // movimientos laterales de Maya durante la bajada.
        //
        // Por tanto, aunque Maya:
        //
        //     - esté quieta;
        //     - esté muy lejos;
        //     - haya girado;
        //     - ya haya salido hace tiempo;
        //
        // Silicio terminará de bajar obligatoriamente.
        //
        // -------------------------------------------------

        if (
            _actor.party_special_mode
            ==
            "downslide_follow"
        )
        {
            // Recalcular zona porque el estado puede haber
            // empezado este mismo frame.
            _actor_downslide_zone =
                collision_rectangle(
                    _actor.bbox_left,
                    _actor.bbox_top,
                    _actor.bbox_right,
                    _actor.bbox_bottom,
                    obj_deslizamiento_abajo,
                    false,
                    true
                );


            _actor_on_downslide =
                (
                    _actor_downslide_zone
                    !=
                    noone
                );


            if (_actor_on_downslide)
            {
                // =================================================
                // BAJADA AUTOMÁTICA
                // =================================================
                //
                // Silicio siempre baja a la misma velocidad que
                // Maya durante el deslizamiento.
                // =================================================

                var _slide_step =
                    6;


                // =================================================
                // SEGUIR TAMBIÉN EL MOVIMIENTO LATERAL DE MAYA
                // =================================================
                //
                // La Y sigue siendo autónoma: Silicio terminará
                // de bajar aunque Maya ya esté lejos o quieta.
                //
                // Pero la X sí toma el recorrido de la party con
                // la separación que Silicio llevaba al entrar.
                //
                // Así, si Maya hace:
                //
                //     ↓
                //     ↓
                //     ← ←
                //     ↓
                //
                // Silicio repetirá también ese desplazamiento
                // lateral cuando ese tramo de ruta le corresponda.
                // =================================================

                var _slide_route_target =
                    scr_party_get_position_by_path_gap(
                        _actor.party_special_gap
                    );


                var _current_slide_x =
                    scr_party_feet_x(
                        _actor
                    );


                var _desired_slide_x =
                    _slide_route_target.x;


                // Usar la misma velocidad lateral configurada
                // para el deslizamiento de Maya.
                var _slide_side_step =
                    4;


                if (
                    variable_instance_exists(
                        _player_instance,
                        "downslide_side_speed"
                    )
                )
                {
                    _slide_side_step =
                        max(
                            1,
                            _player_instance.downslide_side_speed
                        );
                }


                var _slide_dx =
                    _desired_slide_x
                    -
                    _current_slide_x;


                var _next_slide_x =
                    _current_slide_x;


                if (_slide_dx != 0)
                {
                    _next_slide_x +=
                        sign(
                            _slide_dx
                        )
                        *
                        min(
                            abs(
                                _slide_dx
                            ),
                            _slide_side_step
                        );
                }


                _target = {
                    x:
                        _next_slide_x,

                    y:
                        scr_party_feet_y(
                            _actor
                        )
                        +
                        _slide_step,

                    face:
                        DOWN
                };
            }
            else
            {
                // =========================================
                // YA SALIÓ DEL OBJETO
                // =========================================
                //
                // Ahora debe ser expulsado unos píxeles extra
                // igual que Maya.
                // =========================================

                _actor.party_special_mode =
                    "downslide_exit";


                if (
                    variable_instance_exists(
                        _player_instance,
                        "downslide_exit_extra"
                    )
                )
                {
                    _actor.party_downslide_exit_remaining =
                        max(
                            0,
                            _player_instance.downslide_exit_extra
                        );
                }
                else
                {
                    _actor.party_downslide_exit_remaining =
                        4;
                }
            }
        }


        // -------------------------------------------------
        // EXPULSIÓN EXTRA FUERA DEL OBJETO
        // -------------------------------------------------

        if (
            _actor.party_special_mode
            ==
            "downslide_exit"
        )
        {
            if (
                _actor.party_downslide_exit_remaining
                >
                0
            )
            {
                var _exit_step =
                    min(
                        6,
                        _actor.party_downslide_exit_remaining
                    );


                _target = {
                    x:
                        scr_party_feet_x(
                            _actor
                        ),

                    y:
                        scr_party_feet_y(
                            _actor
                        )
                        +
                        _exit_step,

                    face:
                        DOWN
                };


                _actor.party_downslide_exit_remaining -=
                    _exit_step;
            }
            else
            {
                // =========================================
                // TERMINÓ COMPLETAMENTE EL DESLIZAMIENTO
                // =========================================
                //
                // NO intentar alcanzar ni separarse de Maya.
                //
                // Silicio se queda exactamente donde terminó
                // la expulsión.
                //
                // La separación normal se reconstruirá porque
                // MAYA se alejará al volver a caminar.
                // =========================================

                _actor.party_special_mode =
                    "downslide_wait_gap";


                // Empezamos a contar DESDE AQUÍ.
                // Todo lo recorrido durante el deslizamiento
                // queda fuera de esta medición.
                _actor.party_downslide_gap_accum =
                    0;


                _actor.party_downslide_rejoin_current_speed =
                    0;


                _actor.party_special_post_timer =
                    0;


                _actor.party_special_gap =
                    0;
            }
        }


        // -------------------------------------------------
        // ESPERAR A QUE MAYA GENERE LA SEPARACIÓN NORMAL
        // -------------------------------------------------
        //
        // COMPORTAMIENTO DESEADO:
        //
        // 1. Maya termina de deslizarse.
        // 2. Silicio termina de deslizarse.
        // 3. Ambos pueden quedar exactamente en el mismo punto.
        // 4. Si Maya está quieta, Silicio TAMBIÉN queda quieto.
        // 5. Cuando Maya camina, Silicio NO se mueve todavía.
        // 6. La distancia sobre la ruta va creciendo.
        // 7. Cuando alcanza _normal_gap, Silicio vuelve al
        //    sistema normal de seguimiento.
        //
        // Silicio jamás intenta "crear" esa distancia por sí
        // mismo.
        // -------------------------------------------------

        if (
            _actor.party_special_mode
            ==
            "downslide_wait_gap"
        )
        {
            // =================================================
            // SILICIO SE QUEDA EXACTAMENTE QUIETO
            // =================================================

            var _actor_wait_x =
                scr_party_feet_x(
                    _actor
                );


            var _actor_wait_y =
                scr_party_feet_y(
                    _actor
                );


            _target = {
                x:
                    _actor_wait_x,

                y:
                    _actor_wait_y,

                face:
                    _actor.face
            };


            // =================================================
            // CONTAR SOLO RECORRIDO NUEVO DE MAYA
            // =================================================
            //
            // _player_move_distance es lo que Maya recorrió
            // realmente ESTE frame.
            //
            // Como party_downslide_gap_accum se puso a 0 justo
            // al terminar Silicio la expulsión, aquí NO entran:
            //
            //     - zig-zags hechos durante el deslizamiento;
            //     - distancia histórica previa;
            //     - correcciones laterales antiguas.
            //
            // Solo cuenta lo que Maya camina A PARTIR DE AHORA.
            // =================================================

            if (_player_actually_moved)
            {
                _actor.party_downslide_gap_accum +=
                    max(
                        0,
                        _player_move_distance
                    );
            }


            _actor.party_special_gap =
                _actor.party_downslide_gap_accum;


            // =================================================
            // YA SE GENERÓ LA DISTANCIA NORMAL DE LA PARTY
            // =================================================

            if (
                _actor.party_downslide_gap_accum
                >=
                _normal_gap
            )
            {
                _actor.party_special_mode =
                    "downslide_rejoin";


                // IMPORTANTÍSIMO:
                // impedir que el bloque rejoin mueva a Silicio
                // en ESTE MISMO Step.
                _actor.party_special_post_timer =
                    1;


                _actor.party_downslide_rejoin_current_speed =
                    0;
            }
        }


        // -------------------------------------------------
        // REINCORPORACIÓN SUAVE A LA FORMACIÓN
        // -------------------------------------------------
        //
        // Ya existe la distancia normal entre Maya y Silicio,
        // pero Silicio puede estar lateralmente desplazado.
        //
        // Aquí NO teletransportamos.
        //
        // Calculamos el punto normal de formación y avanzamos
        // hacia él con una velocidad física máxima.
        //
        // Como _target cambia poco a poco:
        //
        //     _moved = true
        //
        // y scr_party_apply_walk_animation() reproduce la
        // animación normal de caminar/correr de Silicio.
        // -------------------------------------------------

        if (
            _actor.party_special_mode
            ==
            "downslide_rejoin"
        )
        {
            var _rejoin_x =
                scr_party_feet_x(
                    _actor
                );


            var _rejoin_y =
                scr_party_feet_y(
                    _actor
                );


            // =================================================
            // PRIMER FRAME: NO MOVER NADA
            // =================================================
            //
            // El cambio wait_gap -> rejoin ocurre antes dentro
            // del mismo Step. Sin esta protección, Silicio podía
            // desplazarse inmediatamente varios píxeles.
            // =================================================

            if (_actor.party_special_post_timer > 0)
            {
                _actor.party_special_post_timer--;


                _target = {
                    x:
                        _rejoin_x,

                    y:
                        _rejoin_y,

                    face:
                        _actor.face
                };
            }
            else
            {
                var _rejoin_target =
                    _normal_target;


                var _rejoin_dx =
                    _rejoin_target.x
                    -
                    _rejoin_x;


                var _rejoin_dy =
                    _rejoin_target.y
                    -
                    _rejoin_y;


                var _rejoin_distance =
                    point_distance(
                        _rejoin_x,
                        _rejoin_y,
                        _rejoin_target.x,
                        _rejoin_target.y
                    );


                // =============================================
                // ACELERACIÓN PROGRESIVA
                // =============================================
                //
                // Primer movimiento ≈ 2.5 px.
                // Después 3.0, 3.5, 4.0... hasta máximo 7.
                //
                // Nunca empieza con un salto de 8 px.
                // =============================================

                if (
                    _actor.party_downslide_rejoin_current_speed
                    <=
                    0
                )
                {
                    _actor.party_downslide_rejoin_current_speed =
                        global.party_downslide_rejoin_start_speed;
                }
                else
                {
                    _actor.party_downslide_rejoin_current_speed =
                        min(
                            global.party_downslide_rejoin_speed,
                            _actor.party_downslide_rejoin_current_speed
                            +
                            global.party_downslide_rejoin_accel
                        );
                }


                var _rejoin_speed =
                    max(
                        0.1,
                        _actor.party_downslide_rejoin_current_speed
                    );


                // =============================================
                // DIRECCIÓN VISUAL PARA LA ANIMACIÓN
                // =============================================

                var _rejoin_face =
                    _rejoin_target.face;


                if (abs(_rejoin_dx) > abs(_rejoin_dy))
                {
                    if (_rejoin_dx > 0)
                        _rejoin_face = RIGHT;
                    else if (_rejoin_dx < 0)
                        _rejoin_face = LEFT;
                }
                else
                {
                    if (_rejoin_dy > 0)
                        _rejoin_face = DOWN;
                    else if (_rejoin_dy < 0)
                        _rejoin_face = UP;
                }


                // =============================================
                // YA ESTÁ EXACTAMENTE EN FORMACIÓN
                // =============================================

                if (_rejoin_distance <= 0.25)
                {
                    // No hace falta ninguna corrección visible.
                    _target = {
                        x:
                            _rejoin_x,

                        y:
                            _rejoin_y,

                        face:
                            _rejoin_face
                    };


                    _actor.party_special_mode =
                        "none";


                    _actor.party_downslide_has_entered =
                        false;


                    _actor.party_downslide_exit_remaining =
                        0;


                    _actor.party_downslide_gap_accum =
                        0;


                    _actor.party_downslide_rejoin_current_speed =
                        0;


                    _actor.party_special_post_timer =
                        0;
                }
                else
                {
                    // =========================================
                    // MOVER COMO MÁXIMO _rejoin_speed
                    // =========================================
                    //
                    // Incluso el último ajuste pasa por aquí.
                    // No existe un "snap al target" separado.
                    // =========================================

                    var _step_distance =
                        min(
                            _rejoin_speed,
                            _rejoin_distance
                        );


                    var _rejoin_direction =
                        point_direction(
                            _rejoin_x,
                            _rejoin_y,
                            _rejoin_target.x,
                            _rejoin_target.y
                        );


                    _target = {
                        x:
                            _rejoin_x
                            +
                            lengthdir_x(
                                _step_distance,
                                _rejoin_direction
                            ),

                        y:
                            _rejoin_y
                            +
                            lengthdir_y(
                                _step_distance,
                                _rejoin_direction
                            ),

                        face:
                            _rejoin_face
                    };


                    // Si este paso alcanza el target, NO hacemos
                    // none todavía. Se comprobará en el siguiente
                    // Step con distancia <= 0.25.
                    //
                    // Así tampoco existe un cambio de sistema en
                    // el mismo frame que el último movimiento.
                }
            }
        }


        // -------------------------------------------------
        // GUARDAR POSICIÓN PREVIA PARA EL PRÓXIMO FRAME
        // -------------------------------------------------
        //
        // Esto se hace ANTES de colocar al actor en _target.
        //
        // En el siguiente Step tendremos:
        //
        //     previous bottom = posición antes del movimiento
        //     current bottom  = posición después del movimiento
        //
        // suficiente para saber si entró bajando.
        // -------------------------------------------------

        _actor.party_downslide_prev_bottom =
            _actor.bbox_bottom;


        // =================================================
        // HIELO NORMAL / AZUL
        // =================================================
        //
        // Al entrar al hielo capturamos la distancia FÍSICA
        // actual de Silicio sobre la ruta y la conservamos.
        //
        // Esto arregla:
        //
        // - hielo normal: que se acerque demasiado cuando
        //   Maya pierde velocidad;
        //
        // - hielo azul: que al entrar corriendo se reajuste
        //   de golpe a la distancia de caminar.
        // =================================================

        _mode =
            _actor.party_special_mode;


        _mode_is_downslide =
            (
                _mode == "downslide_follow"
                ||
                _mode == "downslide_exit"
                ||
                _mode == "downslide_wait_gap"
                ||
                _mode == "downslide_rejoin"
            );


        if (
            !_mode_is_downslide
            &&
            _player_on_ice
            &&
            _mode != "ice_hold"
        )
        {
            _actor.party_special_mode =
                "ice_hold";


            _actor.party_special_gap =
                max(
                    _normal_gap,
                    scr_party_path_gap_to_actor(
                        _actor
                    )
                );


            _actor.party_ice_has_entered =
                _actor_on_ice;


            _actor.party_special_post_timer =
                0;
        }


        // -------------------------------------------------
        // CONSERVAR DISTANCIA EN HIELO
        // -------------------------------------------------

        if (
            _actor.party_special_mode
            ==
            "ice_hold"
        )
        {
            if (_actor_on_ice)
            {
                _actor.party_ice_has_entered =
                    true;
            }


            _target =
                scr_party_get_position_by_path_gap(
                    _actor.party_special_gap
                );


            if (_player_on_ice)
            {
                _actor.party_special_post_timer =
                    0;
            }
            else
            {
                _actor.party_special_post_timer++;
            }


            // No recuperar la distancia normal hasta que
            // Silicio también haya pasado y salido del hielo.
            if (
                !_player_on_ice
                &&
                _actor.party_ice_has_entered
                &&
                !_actor_on_ice
            )
            {
                _actor.party_special_mode =
                    "ice_recover";
            }


            if (
                !_player_on_ice
                &&
                _actor.party_special_post_timer
                >=
                global.party_special_failsafe_frames
            )
            {
                _actor.party_special_mode =
                    "ice_recover";
            }
        }


        // -------------------------------------------------
        // VOLVER SUAVEMENTE A LA DISTANCIA NORMAL
        // -------------------------------------------------

        if (
            _actor.party_special_mode
            ==
            "ice_recover"
        )
        {
            // Si Maya entra a otro hielo antes de terminar
            // la recuperación, conservar la distancia actual.
            if (_player_on_ice)
            {
                _actor.party_special_mode =
                    "ice_hold";


                _actor.party_special_gap =
                    max(
                        1,
                        scr_party_path_gap_to_actor(
                            _actor
                        )
                    );


                _actor.party_ice_has_entered =
                    _actor_on_ice;


                _actor.party_special_post_timer =
                    0;


                _target =
                    scr_party_get_position_by_path_gap(
                        _actor.party_special_gap
                    );
            }
            else
            {
                _actor.party_special_gap =
                    scr_party_approach_value(
                        _actor.party_special_gap,
                        _normal_gap,
                        global.party_ice_recover_rate
                    );


                _target =
                    scr_party_get_position_by_path_gap(
                        _actor.party_special_gap
                    );


                if (
                    abs(
                        _actor.party_special_gap
                        -
                        _normal_gap
                    )
                    <=
                    0.5
                )
                {
                    _actor.party_special_mode =
                        "none";


                    _actor.party_ice_has_entered =
                        false;


                    _actor.party_special_post_timer =
                        0;


                    _target =
                        _normal_target;
                }
            }
        }


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

        if (!_hold_follow)
        {
            scr_party_apply_direction(
                _actor,
                _target.face
            );


            // =============================================
            // DESPUÉS ALINEAR PIES
            // =============================================

            scr_party_place_feet(
                _actor,
                _target.x,
                _target.y
            );
        }


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
