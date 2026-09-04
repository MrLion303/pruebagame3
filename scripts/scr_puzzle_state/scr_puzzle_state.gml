/// =========================================================
/// SCR_PUZZLE_STATE
/// =========================================================
///
/// Persistencia de cajas resueltas.
///
/// IMPORTANTE:
///
/// NO guardamos la posición intermedia de la caja.
///
/// Solamente guardamos:
///
///     - qué caja ya completó su puzzle;
///     - qué botón fue el objetivo final.
///
/// Para no duplicar sistemas de guardado, estos datos usan
/// global.cutscene_flags con claves reservadas "__puzzle__".
///
/// Tu scr_save_system YA guarda y restaura cutscene_flags,
/// así que el puzzle queda automáticamente dentro del save.
///
/// Nueva Partida también reinicia cutscene_flags, por lo que
/// los puzzles vuelven correctamente a su estado inicial.
/// =========================================================


// =========================================================
// ID AUTOMÁTICA DE UNA CAJA
// =========================================================
//
// Usa:
//
//     room de origen
//     x inicial
//     y inicial
//
// Por eso NO tienes que escribir IDs manualmente.
// =========================================================

function scr_puzzle_box_auto_id(
    _room_asset,
    _start_x,
    _start_y
)
{
    return
        "__puzzle__box__"
        +
        room_get_name(
            _room_asset
        )
        +
        "__"
        +
        string(
            round(_start_x)
        )
        +
        "__"
        +
        string(
            round(_start_y)
        );
}


// =========================================================
// CLAVE DEL BOTÓN
// =========================================================
//
// Si el botón tiene:
//
//     puzzle_link_id = "puerta_1";
//
// usamos esa ID.
//
// Si NO tiene ID, generamos una automáticamente con room+x+y.
// =========================================================

function scr_puzzle_button_key(_button)
{
    if (
        _button == noone
        ||
        !instance_exists(
            _button
        )
    )
    {
        return "";
    }


    if (
        variable_instance_exists(
            _button,
            "puzzle_link_id"
        )
        &&
        is_string(
            _button.puzzle_link_id
        )
        &&
        _button.puzzle_link_id
        !=
        ""
    )
    {
        return
            "link:"
            +
            _button.puzzle_link_id;
    }


    return
        "pos:"
        +
        room_get_name(room)
        +
        ":"
        +
        string(
            round(_button.x)
        )
        +
        ":"
        +
        string(
            round(_button.y)
        );
}


// =========================================================
// ¿CAJA COMPLETADA?
// =========================================================

function scr_puzzle_box_is_completed(_box_id)
{
    scr_cutscene_flags_init();


    return variable_struct_exists(
        global.cutscene_flags,
        _box_id
    );
}


// =========================================================
// OBTENER BOTÓN FINAL GUARDADO
// =========================================================

function scr_puzzle_box_target_key(_box_id)
{
    scr_cutscene_flags_init();


    if (
        variable_struct_exists(
            global.cutscene_flags,
            _box_id
        )
    )
    {
        var _value =
            variable_struct_get(
                global.cutscene_flags,
                _box_id
            );


        if (is_string(_value))
        {
            return _value;
        }
    }


    return "";
}


// =========================================================
// MARCAR PUZZLE COMPLETADO
// =========================================================

function scr_puzzle_box_complete(
    _box_id,
    _button
)
{
    scr_cutscene_flags_init();


    variable_struct_set(
        global.cutscene_flags,
        _box_id,
        scr_puzzle_button_key(
            _button
        )
    );
}


// =========================================================
// CREAR PROXY DE COLISIÓN
// =========================================================
//
// Creamos una instancia REAL de "colision", invisible,
// copiando la máscara/sprite del dueño.
//
// Así obj_player sigue usando su sistema actual:
//
//     place_meeting(..., colision)
//
// y detecta cajas/barreras sin tener que configurar Parent.
// =========================================================

function scr_puzzle_collision_proxy_create(_owner)
{
    if (
        _owner == noone
        ||
        !instance_exists(
            _owner
        )
    )
    {
        return noone;
    }


    var _proxy =
        instance_create_depth(
            _owner.x,
            _owner.y,
            0,
            colision
        );


    if (
        _proxy == noone
        ||
        !instance_exists(
            _proxy
        )
    )
    {
        return noone;
    }


    _proxy.visible =
        false;


    scr_puzzle_collision_proxy_sync(
        _owner,
        _proxy
    );


    return _proxy;
}


// =========================================================
// SINCRONIZAR PROXY
// =========================================================

function scr_puzzle_collision_proxy_sync(
    _owner,
    _proxy
)
{
    if (
        _owner == noone
        ||
        !instance_exists(
            _owner
        )
        ||
        _proxy == noone
        ||
        !instance_exists(
            _proxy
        )
    )
    {
        return false;
    }


    _proxy.x =
        _owner.x;

    _proxy.y =
        _owner.y;


    _proxy.sprite_index =
        _owner.sprite_index;


    if (_owner.mask_index != -1)
    {
        _proxy.mask_index =
            _owner.mask_index;
    }
    else
    {
        _proxy.mask_index =
            _owner.sprite_index;
    }


    _proxy.image_xscale =
        _owner.image_xscale;

    _proxy.image_yscale =
        _owner.image_yscale;

    _proxy.image_angle =
        _owner.image_angle;

    _proxy.image_index =
        _owner.image_index;

    _proxy.image_speed =
        0;

    _proxy.visible =
        false;


    return true;
}


// =========================================================
// DESTRUIR PROXY
// =========================================================

function scr_puzzle_collision_proxy_destroy(_proxy)
{
    if (
        _proxy != noone
        &&
        instance_exists(
            _proxy
        )
    )
    {
        with (_proxy)
        {
            instance_destroy();
        }
    }
}
