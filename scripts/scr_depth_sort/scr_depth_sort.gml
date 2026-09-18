/// =========================================================
/// SCR_DEPTH_SORT
/// =========================================================
///
/// Y-SORT UNIVERSAL POR "PIES".
///
/// Quien tenga los pies más abajo en pantalla:
///     se dibuja delante.
///
/// REGISTRAR UN OBJETO:
///
///     scr_depth_sort_register(id);
///
/// OPCIONAL:
///
///     scr_depth_sort_register(id, bias, anchor_offset_y);
///
/// bias:
///     ajuste fino de depth.
///
/// anchor_offset_y:
///     desplaza el punto usado como "pies".
///
/// NUEVO:
/// En modo plataforma Maya SIEMPRE queda visualmente delante
/// de Silicio, independientemente de la Y de ambos.
/// =========================================================


function scr_depth_sort_init()
{
    if (
        !variable_global_exists(
            "depth_sort_registry"
        )
        ||
        !is_array(
            global.depth_sort_registry
        )
    )
    {
        global.depth_sort_registry =
            [];
    }
}


// =========================================================
// REGISTRAR
// =========================================================

function scr_depth_sort_register(
    _actor,
    _bias = 0,
    _anchor_offset_y = 0
)
{
    scr_depth_sort_init();


    if (
        _actor == noone
        ||
        !instance_exists(_actor)
    )
    {
        return false;
    }


    _actor.depth_sort_enabled =
        true;


    if (
        !variable_instance_exists(
            _actor,
            "depth_sort_bias"
        )
    )
    {
        _actor.depth_sort_bias =
            _bias;
    }


    if (
        !variable_instance_exists(
            _actor,
            "depth_sort_anchor_offset_y"
        )
    )
    {
        _actor.depth_sort_anchor_offset_y =
            _anchor_offset_y;
    }


    if (
        !variable_instance_exists(
            _actor,
            "depth_sort_registered"
        )
        ||
        !_actor.depth_sort_registered
    )
    {
        array_push(
            global.depth_sort_registry,
            _actor
        );


        _actor.depth_sort_registered =
            true;
    }


    return true;
}


// =========================================================
// APLICAR A UNA INSTANCIA
// =========================================================

function scr_depth_sort_apply(_actor)
{
    if (
        _actor == noone
        ||
        !instance_exists(_actor)
    )
    {
        return false;
    }


    if (
        variable_instance_exists(
            _actor,
            "depth_sort_enabled"
        )
        &&
        !_actor.depth_sort_enabled
    )
    {
        return false;
    }


    var _offset =
        0;


    if (
        variable_instance_exists(
            _actor,
            "depth_sort_anchor_offset_y"
        )
    )
    {
        _offset =
            _actor.depth_sort_anchor_offset_y;
    }


    var _bias =
        0;


    if (
        variable_instance_exists(
            _actor,
            "depth_sort_bias"
        )
    )
    {
        _bias =
            _actor.depth_sort_bias;
    }


    // =====================================================
    // PUNTO DE APOYO = PARTE BAJA DE LA MÁSCARA
    // =====================================================
    //
    // GameMaker dibuja delante los depth MÁS BAJOS.
    // =====================================================

    var _feet_y =
        _actor.bbox_bottom
        +
        _offset;


    _actor.depth =
        -round(
            _feet_y
            *
            10
        )
        +
        _bias;


    return true;
}


// =========================================================
// ACTUALIZAR TODOS LOS REGISTRADOS
// =========================================================

function scr_depth_sort_update()
{
    scr_depth_sort_init();


    for (
        var _i =
            array_length(
                global.depth_sort_registry
            )
            -
            1;

        _i >= 0;

        _i--
    )
    {
        var _actor =
            global.depth_sort_registry[
                _i
            ];


        if (
            _actor == noone
            ||
            !instance_exists(_actor)
        )
        {
            array_delete(
                global.depth_sort_registry,
                _i,
                1
            );


            continue;
        }


        scr_depth_sort_apply(
            _actor
        );
    }


    // =====================================================
    // PLATAFORMA: MAYA SIEMPRE DELANTE DE SILICIO
    // =====================================================
    //
    // Primero se hace el Y-sort normal de todos.
    // Después, únicamente en modo plataforma, Silicio queda
    // exactamente una unidad de depth detrás de Maya.
    //
    // depth menor = más al frente.
    // =====================================================

    var _platformer =
        (
            variable_global_exists(
                "platformer_active"
            )
            &&
            global.platformer_active
        );


    if (
        _platformer
        &&
        instance_exists(
            obj_player
        )
        &&
        instance_exists(
            obj_silicio
        )
    )
    {
        var _maya =
            instance_find(
                obj_player,
                0
            );


        var _silicio =
            instance_find(
                obj_silicio,
                0
            );


        if (
            _maya != noone
            &&
            instance_exists(
                _maya
            )
            &&
            _silicio != noone
            &&
            instance_exists(
                _silicio
            )
        )
        {
            _silicio.depth =
                _maya.depth
                +
                1;
        }
    }
}
