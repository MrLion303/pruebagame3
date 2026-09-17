/// =========================================================
/// SCR_TIJERAS_JARDIN_SYSTEM
/// =========================================================
///
/// Tijeras Jardín = OBJETO CLAVE PASIVO.
///
/// Una vez obtenidas:
/// - nunca se usan desde el inventario;
/// - nunca se consumen;
/// - al mirar una barrera cortable y pulsar Z o Enter,
///   la barrera pierde su colisión inmediatamente;
/// - después hace fade out y se destruye;
/// - el estado cortado queda persistente en el save.
///
/// IMPORTANTE SOBRE LA BARRERA:
///
/// obj_barrera_cortable debe tener asignado EN EL OBJECT EDITOR
/// un sprite base de colisión, por ejemplo uno de 20x20.
/// Ese sprite se conserva como mask_index aunque la imagen visible
/// cambie por lianas/cables/cuerdas.
///
/// Si escalas la instancia con image_xscale/image_yscale, la máscara
/// y el proxy de colisión se escalan exactamente igual.
/// =========================================================


// =========================================================
// CLAVE PERSISTENTE DE UNA BARRERA
// =========================================================

function scr_tijeras_barrera_save_key(_barrier)
{
    if (
        _barrier == noone
        ||
        !instance_exists(_barrier)
    )
    {
        return "";
    }


    var _room_asset =
        variable_instance_exists(
            _barrier,
            "barrera_room"
        )
        ?
        _barrier.barrera_room
        :
        room;


    var _room_name =
        room_get_name(
            _room_asset
        );


    if (
        variable_instance_exists(
            _barrier,
            "barrera_id"
        )
        &&
        is_string(_barrier.barrera_id)
        &&
        _barrier.barrera_id != ""
    )
    {
        return
            "__tijeras_barrera__"
            +
            _room_name
            +
            "__id__"
            +
            _barrier.barrera_id;
    }


    var _sx =
        variable_instance_exists(
            _barrier,
            "barrera_start_x"
        )
        ?
        _barrier.barrera_start_x
        :
        _barrier.x;


    var _sy =
        variable_instance_exists(
            _barrier,
            "barrera_start_y"
        )
        ?
        _barrier.barrera_start_y
        :
        _barrier.y;


    return
        "__tijeras_barrera__"
        +
        _room_name
        +
        "__"
        +
        string(round(_sx))
        +
        "__"
        +
        string(round(_sy));
}


function scr_tijeras_barrera_is_cut(_barrier)
{
    scr_cutscene_flags_init();


    var _key =
        scr_tijeras_barrera_save_key(
            _barrier
        );


    if (
        _key == ""
        ||
        !variable_struct_exists(
            global.cutscene_flags,
            _key
        )
    )
    {
        return false;
    }


    return
        variable_struct_get(
            global.cutscene_flags,
            _key
        )
        ==
        true;
}


function scr_tijeras_barrera_mark_cut(_barrier)
{
    scr_cutscene_flags_init();


    var _key =
        scr_tijeras_barrera_save_key(
            _barrier
        );


    if (_key == "")
    {
        return false;
    }


    variable_struct_set(
        global.cutscene_flags,
        _key,
        true
    );


    return true;
}


// =========================================================
// NORMALIZAR TIPO DE BARRERA
// =========================================================

function scr_tijeras_barrera_normalize_type(_tipo)
{
    var _result =
        string_lower(
            string(_tipo)
        );


    switch (_result)
    {
        case "cables":
        case "cuerdas":
        case "lianas":
            return _result;
    }


    return "lianas";
}


// =========================================================
// ELEGIR SPRITE VISUAL PERSONALIZADO
// =========================================================
///
/// En Creation Code puedes usar:
///
///     tipo_barrera = "lianas";
///     sprite_lianas = spr_mis_lianas;
///
/// o:
///
///     tipo_barrera = "cables";
///     sprite_cables = spr_mis_cables;
///
/// o:
///
///     tipo_barrera = "cuerdas";
///     sprite_cuerdas = spr_mis_cuerdas;
///
/// También puedes usar sprite_personalizado para esa instancia:
///
///     tipo_barrera = "cables";
///     sprite_personalizado = spr_cables_rojos;
///
/// sprite_personalizado tiene prioridad.
///
/// IMPORTANTE:
/// cambiar el sprite visible NO cambia la colisión.
/// La colisión siempre usa sprite_colision, capturado desde el
/// sprite base que tenga obj_barrera_cortable en el Object Editor.
/// =========================================================

function scr_tijeras_barrera_apply_visual_sprite(_barrier)
{
    if (
        _barrier == noone
        ||
        !instance_exists(_barrier)
    )
    {
        return false;
    }


    var _tipo =
        scr_tijeras_barrera_normalize_type(
            _barrier.tipo_barrera
        );


    _barrier.tipo_barrera =
        _tipo;


    var _visual =
        -1;


    // Override absoluto de esta instancia.
    if (
        variable_instance_exists(
            _barrier,
            "sprite_personalizado"
        )
        &&
        _barrier.sprite_personalizado != -1
        &&
        _barrier.sprite_personalizado != noone
        &&
        sprite_exists(
            _barrier.sprite_personalizado
        )
    )
    {
        _visual =
            _barrier.sprite_personalizado;
    }
    else
    {
        switch (_tipo)
        {
            case "cables":
                if (
                    variable_instance_exists(
                        _barrier,
                        "sprite_cables"
                    )
                    &&
                    _barrier.sprite_cables != -1
                    &&
                    _barrier.sprite_cables != noone
                    &&
                    sprite_exists(
                        _barrier.sprite_cables
                    )
                )
                {
                    _visual =
                        _barrier.sprite_cables;
                }
                break;


            case "cuerdas":
                if (
                    variable_instance_exists(
                        _barrier,
                        "sprite_cuerdas"
                    )
                    &&
                    _barrier.sprite_cuerdas != -1
                    &&
                    _barrier.sprite_cuerdas != noone
                    &&
                    sprite_exists(
                        _barrier.sprite_cuerdas
                    )
                )
                {
                    _visual =
                        _barrier.sprite_cuerdas;
                }
                break;


            case "lianas":
            default:
                if (
                    variable_instance_exists(
                        _barrier,
                        "sprite_lianas"
                    )
                    &&
                    _barrier.sprite_lianas != -1
                    &&
                    _barrier.sprite_lianas != noone
                    &&
                    sprite_exists(
                        _barrier.sprite_lianas
                    )
                )
                {
                    _visual =
                        _barrier.sprite_lianas;
                }
                break;
        }
    }


    // Si no configuraste un visual válido, dejamos visible el
    // sprite base de 20x20 en lugar de romper la instancia.
    if (
        _visual != -1
        &&
        _visual != noone
        &&
        sprite_exists(_visual)
    )
    {
        _barrier.sprite_index =
            _visual;
    }
    else if (
        variable_instance_exists(
            _barrier,
            "sprite_colision"
        )
        &&
        _barrier.sprite_colision != -1
        &&
        _barrier.sprite_colision != noone
        &&
        sprite_exists(
            _barrier.sprite_colision
        )
    )
    {
        _barrier.sprite_index =
            _barrier.sprite_colision;
    }


    // CLAVE: el sprite visual nunca manda sobre la máscara.
    if (
        variable_instance_exists(
            _barrier,
            "sprite_colision"
        )
        &&
        _barrier.sprite_colision != -1
        &&
        _barrier.sprite_colision != noone
        &&
        sprite_exists(
            _barrier.sprite_colision
        )
    )
    {
        _barrier.mask_index =
            _barrier.sprite_colision;
    }


    _barrier.image_speed =
        0;

    _barrier.image_index =
        0;


    return true;
}


// =========================================================
// INICIALIZAR BARRERA
// =========================================================

function scr_tijeras_barrera_init(_barrier)
{
    if (
        _barrier == noone
        ||
        !instance_exists(_barrier)
    )
    {
        return false;
    }


    if (
        variable_instance_exists(
            _barrier,
            "barrera_inicializada"
        )
        &&
        _barrier.barrera_inicializada
    )
    {
        return true;
    }


    scr_tijeras_barrera_apply_visual_sprite(
        _barrier
    );


    _barrier.barrera_save_key =
        scr_tijeras_barrera_save_key(
            _barrier
        );


    // Si esta barrera ya se cortó antes, ni siquiera creamos
    // la colisión durante este Room Start.
    if (
        scr_tijeras_barrera_is_cut(
            _barrier
        )
    )
    {
        with (_barrier)
        {
            instance_destroy();
        }


        return false;
    }


    _barrier.collision_proxy =
        scr_puzzle_collision_proxy_create(
            _barrier
        );


    _barrier.barrera_inicializada =
        true;


    return true;
}


// =========================================================
// BUSCAR BARRERA FRENTE A MAYA
// =========================================================

function scr_tijeras_find_barrier_in_front(_player)
{
    if (
        _player == noone
        ||
        !instance_exists(_player)
        ||
        !instance_exists(obj_barrera_cortable)
    )
    {
        return noone;
    }


    var _face =
        DOWN;


    if (
        variable_instance_exists(
            _player,
            "face"
        )
    )
    {
        _face =
            _player.face;
    }
    else if (
        variable_instance_exists(
            _player,
            "facing_direction"
        )
    )
    {
        _face =
            _player.facing_direction;
    }


    // Alcance desde el borde real de la máscara del jugador.
    // Como la barrera usa su sprite 20x20 como mask_index, si la
    // escalas en el room su bbox también crece automáticamente.
    var _reach =
        40;

    var _margin =
        6;


    var _x1 =
        _player.bbox_left;

    var _y1 =
        _player.bbox_top;

    var _x2 =
        _player.bbox_right;

    var _y2 =
        _player.bbox_bottom;


    switch (_face)
    {
        case RIGHT:
            _x1 =
                _player.bbox_right;

            _x2 =
                _player.bbox_right + _reach;

            _y1 =
                _player.bbox_top - _margin;

            _y2 =
                _player.bbox_bottom + _margin;
            break;


        case LEFT:
            _x1 =
                _player.bbox_left - _reach;

            _x2 =
                _player.bbox_left;

            _y1 =
                _player.bbox_top - _margin;

            _y2 =
                _player.bbox_bottom + _margin;
            break;


        case UP:
            _x1 =
                _player.bbox_left - _margin;

            _x2 =
                _player.bbox_right + _margin;

            _y1 =
                _player.bbox_top - _reach;

            _y2 =
                _player.bbox_top;
            break;


        case DOWN:
        default:
            _x1 =
                _player.bbox_left - _margin;

            _x2 =
                _player.bbox_right + _margin;

            _y1 =
                _player.bbox_bottom;

            _y2 =
                _player.bbox_bottom + _reach;
            break;
    }


    var _best =
        noone;

    var _best_distance =
        999999;


    var _count =
        instance_number(
            obj_barrera_cortable
        );


    for (
        var _i = 0;
        _i < _count;
        _i++
    )
    {
        var _barrier =
            instance_find(
                obj_barrera_cortable,
                _i
            );


        if (
            _barrier == noone
            ||
            !instance_exists(_barrier)
            ||
            (
                variable_instance_exists(
                    _barrier,
                    "cortando"
                )
                &&
                _barrier.cortando
            )
        )
        {
            continue;
        }


        var _overlap =
            (
                _barrier.bbox_right >= _x1
                &&
                _barrier.bbox_left <= _x2
                &&
                _barrier.bbox_bottom >= _y1
                &&
                _barrier.bbox_top <= _y2
            );


        if (!_overlap)
        {
            continue;
        }


        var _center_x =
            (_barrier.bbox_left + _barrier.bbox_right) * 0.5;

        var _center_y =
            (_barrier.bbox_top + _barrier.bbox_bottom) * 0.5;


        var _distance =
            point_distance(
                _player.x,
                _player.y,
                _center_x,
                _center_y
            );


        if (_distance < _best_distance)
        {
            _best_distance =
                _distance;

            _best =
                _barrier;
        }
    }


    return _best;
}


// =========================================================
// ¿SE PUEDE INTERACTUAR CON EL MUNDO?
// =========================================================

function scr_tijeras_world_interaction_allowed()
{
    if (
        instance_exists(obj_textbox)
        ||
        instance_exists(obj_save_menu)
        ||
        instance_exists(obj_shop_controller)
        ||
        instance_exists(obj_warp)
        ||
        instance_exists(obj_cofre_ui)
    )
    {
        return false;
    }


    if (
        variable_global_exists("cutscene_active")
        &&
        global.cutscene_active
    )
    {
        return false;
    }


    if (instance_exists(obj_menu_manager))
    {
        var _menu =
            instance_find(
                obj_menu_manager,
                0
            );


        if (
            _menu != noone
            &&
            instance_exists(_menu)
            &&
            variable_instance_exists(
                _menu,
                "state"
            )
            &&
            _menu.state != MENU_STATE.CLOSED
        )
        {
            return false;
        }
    }


    return true;
}


// =========================================================
// EMPEZAR CORTE
// =========================================================

function scr_tijeras_barrera_begin_cut(_barrier)
{
    if (
        _barrier == noone
        ||
        !instance_exists(_barrier)
        ||
        _barrier.cortando
    )
    {
        return false;
    }


    // Persistencia desde el primer frame del corte.
    scr_tijeras_barrera_mark_cut(
        _barrier
    );


    // El camino queda libre INMEDIATAMENTE, antes del fade.
    scr_puzzle_collision_proxy_destroy(
        _barrier.collision_proxy
    );

    _barrier.collision_proxy =
        noone;


    _barrier.cortando =
        true;

    _barrier.image_alpha =
        1;


    // Consumir exactamente la misma interacción para que un NPC,
    // cofre o guardado detrás de la barrera no reciba el Z/Enter.
    keyboard_clear(ord("Z"));
    keyboard_clear(vk_enter);


    if (instance_exists(obj_menu_manager))
    {
        var _menu =
            instance_find(
                obj_menu_manager,
                0
            );


        if (
            _menu != noone
            &&
            instance_exists(_menu)
            &&
            variable_instance_exists(
                _menu,
                "interaction_release_block"
            )
        )
        {
            _menu.interaction_release_block =
                2;
        }
    }


    return true;
}


// =========================================================
// PICKUP DE TIJERAS
// =========================================================

function scr_tijeras_pickup_save_key(_pickup)
{
    if (
        _pickup == noone
        ||
        !instance_exists(_pickup)
    )
    {
        return "";
    }


    return
        "__pickup_tijeras_jardin__"
        +
        room_get_name(
            _pickup.pickup_room
        )
        +
        "__"
        +
        string(round(_pickup.pickup_start_x))
        +
        "__"
        +
        string(round(_pickup.pickup_start_y));
}


function scr_tijeras_pickup_was_taken(_pickup)
{
    scr_cutscene_flags_init();


    var _key =
        scr_tijeras_pickup_save_key(
            _pickup
        );


    if (
        _key == ""
        ||
        !variable_struct_exists(
            global.cutscene_flags,
            _key
        )
    )
    {
        return false;
    }


    return
        variable_struct_get(
            global.cutscene_flags,
            _key
        )
        ==
        true;
}


function scr_tijeras_pickup_mark_taken(_pickup)
{
    scr_cutscene_flags_init();


    var _key =
        scr_tijeras_pickup_save_key(
            _pickup
        );


    if (_key == "")
    {
        return false;
    }


    variable_struct_set(
        global.cutscene_flags,
        _key,
        true
    );


    return true;
}
