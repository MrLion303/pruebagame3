/// =========================================================
/// OBJ_WARP_BLOCK
/// STEP COMPLETO
/// =========================================================

// =========================================================
// CINEMÁTICA ACTIVA
// =========================================================
//
// Durante una cinemática este warp sigue existiendo,
// pero NO puede activarse.
// =========================================================

if (scr_cutscene_world_locked())
{
    exit;
}


if (!instance_exists(obj_player))
{
    exit;
}


// =========================================================
// BLOQUEO AL VOLVER DE UNA TIENDA
// =========================================================
//
// El jugador vuelve a la coordenada EXACTA desde la que
// entró. Si esa coordenada sigue dentro de este mismo warp,
// sin este bloqueo volvería a entrar inmediatamente.
//
// Solo bloqueamos EL warp concreto usado para entrar.
// En cuanto el jugador sale físicamente de él, se desbloquea.
// =========================================================

if (
    variable_global_exists("shop_return_lock")
    &&
    global.shop_return_lock
    &&
    variable_global_exists("shop_return_lock_room")
    &&
    room == global.shop_return_lock_room
    &&
    variable_global_exists("shop_return_lock_warp_x")
    &&
    variable_global_exists("shop_return_lock_warp_y")
    &&
    x == global.shop_return_lock_warp_x
    &&
    y == global.shop_return_lock_warp_y
)
{
    if (place_meeting(x, y, obj_player))
    {
        exit;
    }
    else
    {
        global.shop_return_lock =
            false;
    }
}


// =========================================================
// ENTRAR A WARP
// =========================================================

if (
    place_meeting(x, y, obj_player)
    &&
    !instance_exists(obj_warp)
)
{
    // =====================================================
    // SI EL DESTINO ES UNA TIENDA, GUARDAR RETORNO EXACTO
    // =====================================================

    var _target_room_name =
        room_get_name(
            target_rm
        );


    if (
        string_copy(
            _target_room_name,
            1,
            5
        )
        ==
        "shop_"
    )
    {
        global.shop_return_valid =
            true;

        global.shop_return_room =
            room;

        global.shop_return_x =
            obj_player.x;

        global.shop_return_y =
            obj_player.y;

        global.shop_return_face =
            obj_player.face;


        // Guardar también la música REAL que estaba sonando
        // en la habitación antes de entrar a la tienda.
        // El sistema de guardado del proyecto ya reconoce
        // automáticamente los recursos cuyo nombre es mus_*.
        global.shop_return_music_name =
            scr_save_get_current_music();


        // Guardamos también QUÉ warp concreto se usó.
        // Esto sirve para bloquearlo al regresar hasta que
        // el jugador se aleje de él.
        global.shop_entry_warp_x =
            x;

        global.shop_entry_warp_y =
            y;


        // Cualquier bloqueo anterior deja de aplicar al
        // iniciar una nueva entrada a tienda.
        global.shop_return_lock =
            false;
    }


    // =====================================================
    // CREAR TRANSICIÓN NORMAL
    // =====================================================

    var inst =
        instance_create_depth(
            0,
            0,
            -9999,
            obj_warp
        );


    inst.target_x =
        target_x;

    inst.target_y =
        target_y;

    inst.target_rm =
        target_rm;

    inst.target_face =
        target_face;

    inst.target_music =
        target_music;

    inst.keep_music =
        keep_music;


    // =====================================================
    // CINEMÁTICA CONFIGURADA EN ESTE TP
    // =====================================================

    inst.target_cutscene =
        target_cutscene;

    inst.target_cutscene_once =
        target_cutscene_once;
}
