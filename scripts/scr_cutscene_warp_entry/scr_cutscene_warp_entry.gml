/// =========================================================
/// SCR_CUTSCENE_WARP_ENTRY
/// =========================================================
///
/// CINEMÁTICA AUTOMÁTICA CONFIGURADA DESDE obj_warp_block.
///
/// Ejemplo Creation Code:
///
///     target_cutscene = "entrada_gerson";
///
/// Al cruzar ese warp:
///
///     room origen
///         ↓
///     transición
///         ↓
///     room destino
///         ↓
///     termina el fade
///         ↓
///     cinemática
///
/// Si ya fue vista:
///
///     transición normal
///         ↓
///     NO cinemática
///
/// Usa global.cutscene_flags, por lo que:
///
/// - se recuerda en el save;
/// - Nueva Partida permite verla otra vez.
///
/// =========================================================


// =========================================================
// INICIALIZACIÓN
// =========================================================

function scr_cutscene_warp_entry_init()
{
    if (
        !variable_global_exists(
            "warp_cutscene_pending"
        )
    )
    {
        global.warp_cutscene_pending =
            false;
    }


    if (
        !variable_global_exists(
            "warp_cutscene_pending_id"
        )
    )
    {
        global.warp_cutscene_pending_id =
            "";
    }


    if (
        !variable_global_exists(
            "warp_cutscene_pending_room"
        )
    )
    {
        global.warp_cutscene_pending_room =
            -1;
    }


    if (
        !variable_global_exists(
            "warp_cutscene_pending_once"
        )
    )
    {
        global.warp_cutscene_pending_once =
            true;
    }


    if (
        !variable_global_exists(
            "cutscene_world_locked"
        )
    )
    {
        global.cutscene_world_locked =
            false;
    }
}


// =========================================================
// ¿EL MUNDO ESTÁ BLOQUEADO POR UNA CINEMÁTICA?
// =========================================================

function scr_cutscene_world_locked()
{
    scr_cutscene_warp_entry_init();


    return
        global.cutscene_world_locked;
}


// =========================================================
// BLOQUEAR TRIGGERS / PELIGROS
// =========================================================
//
// NO desactivamos instancias.
//
// Los objetos siguen existiendo.
// Sus Steps consultan scr_cutscene_world_locked().
//
// Esto conserva:
// - timers;
// - variables;
// - estado interno;
// - posición;
// - configuración.
//
// =========================================================

function scr_cutscene_world_lock()
{
    scr_cutscene_warp_entry_init();


    global.cutscene_world_locked =
        true;


    return true;
}


// =========================================================
// DESBLOQUEAR MUNDO
// =========================================================

function scr_cutscene_world_unlock()
{
    scr_cutscene_warp_entry_init();


    global.cutscene_world_locked =
        false;


    return true;
}


// =========================================================
// LIMPIAR SOLO EL PENDIENTE
// =========================================================
//
// OJO:
// NO desbloquea el mundo.
//
// Cuando la cinemática YA empezó, borramos el pendiente pero
// el lock debe seguir activo hasta que termine el controller.
// =========================================================

function scr_cutscene_warp_entry_clear()
{
    scr_cutscene_warp_entry_init();


    global.warp_cutscene_pending =
        false;

    global.warp_cutscene_pending_id =
        "";

    global.warp_cutscene_pending_room =
        -1;

    global.warp_cutscene_pending_once =
        true;
}


// =========================================================
// CANCELAR PENDIENTE
// =========================================================

function scr_cutscene_warp_entry_cancel()
{
    scr_cutscene_warp_entry_clear();

    scr_cutscene_world_unlock();


    return false;
}


// =========================================================
// PREPARAR CINEMÁTICA DESDE UN WARP
// =========================================================
//
// Se llama JUSTO ANTES de room_goto().
//
// _id:
//     ID de scr_cutscene_data.
//
// _target_room:
//     room a la que estamos viajando.
//
// _once:
//     true = una sola vez por partida.
//     false = cada vez que se use ese warp.
//
// =========================================================

function scr_cutscene_warp_entry_queue(
    _id,
    _target_room,
    _once = true
)
{
    scr_cutscene_warp_entry_init();
    scr_cutscene_flags_init();


    // Cualquier warp nuevo sustituye un pendiente viejo.
    scr_cutscene_warp_entry_clear();


    if (
        !is_string(_id)
        ||
        _id == ""
    )
    {
        return false;
    }


    // =====================================================
    // ONE SHOT
    // =====================================================

    if (
        _once
        &&
        scr_cutscene_was_played(
            _id
        )
    )
    {
        return false;
    }


    global.warp_cutscene_pending =
        true;

    global.warp_cutscene_pending_id =
        _id;

    global.warp_cutscene_pending_room =
        _target_room;

    global.warp_cutscene_pending_once =
        _once;


    return true;
}


// =========================================================
// BLOQUEAR PLAYER MIENTRAS ESPERAMOS EL FINAL DEL FADE
// =========================================================

function scr_cutscene_warp_entry_hold_player()
{
    if (!instance_exists(obj_player))
        return;


    var _p =
        instance_find(
            obj_player,
            0
        );


    if (
        variable_instance_exists(
            _p,
            "puede_moverse"
        )
    )
    {
        _p.puede_moverse =
            false;
    }


    if (
        variable_instance_exists(
            _p,
            "can_move"
        )
    )
    {
        _p.can_move =
            false;
    }
}


// =========================================================
// ROOM START
// =========================================================
//
// En cuanto cargó la ROOM DESTINO:
//
// - bloqueamos los triggers;
// - bloqueamos al player;
//
// incluso aunque obj_warp todavía esté abriendo el fade.
//
// Así ningún enemigo, damage, music trigger o warp puede
// ejecutarse antes de la cinemática.
// =========================================================

function scr_cutscene_warp_entry_on_room_start()
{
    scr_cutscene_warp_entry_init();


    if (!global.warp_cutscene_pending)
        return false;


    // El pendiente pertenece únicamente a su destino.
    if (
        room
        !=
        global.warp_cutscene_pending_room
    )
    {
        scr_cutscene_warp_entry_clear();

        return false;
    }


    var _id =
        global.warp_cutscene_pending_id;


    // Puede haberse marcado como vista por otro camino.
    if (
        global.warp_cutscene_pending_once
        &&
        scr_cutscene_was_played(_id)
    )
    {
        scr_cutscene_warp_entry_clear();

        return false;
    }


    scr_cutscene_world_lock();

    scr_cutscene_warp_entry_hold_player();


    return true;
}


// =========================================================
// ¿SIGUE ACTIVA ALGUNA TRANSICIÓN?
// =========================================================

function scr_cutscene_warp_entry_transition_active()
{
    // Warp normal.
    if (instance_exists(obj_warp))
        return true;


    // Nueva partida.
    if (instance_exists(obj_new_game_transition))
        return true;


    // Transición de batalla.
    if (instance_exists(obj_transicion_bbs))
        return true;


    // Cargar partida.
    if (instance_exists(obj_save_menu))
    {
        var _save =
            instance_find(
                obj_save_menu,
                0
            );


        if (
            _save != noone
            &&
            variable_instance_exists(
                _save,
                "transicion_activa"
            )
            &&
            _save.transicion_activa
        )
        {
            return true;
        }
    }


    return false;
}


// =========================================================
// VALIDAR QUE LA ID EXISTA
// =========================================================

function scr_cutscene_warp_entry_valid_id(_id)
{
    var _raw =
        scr_cutscene_data(
            _id
        );


    var _scene =
        scr_cutscene_unpack(
            _raw
        );


    return
        is_array(
            _scene.actions
        )
        &&
        array_length(
            _scene.actions
        )
        >
        0;
}


// =========================================================
// STEP DE OBJ_SETTINGS
// =========================================================
//
// Inicia la cinemática SOLO cuando obj_warp terminó
// completamente de abrir la transición.
//
// =========================================================

function scr_cutscene_warp_entry_update()
{
    scr_cutscene_warp_entry_init();


    if (!global.warp_cutscene_pending)
        return false;


    // =====================================================
    // SEGURIDAD DE ROOM
    // =====================================================

    if (
        room
        !=
        global.warp_cutscene_pending_room
    )
    {
        return
            scr_cutscene_warp_entry_cancel();
    }


    var _id =
        global.warp_cutscene_pending_id;


    // =====================================================
    // YA FUE VISTA
    // =====================================================

    if (
        global.warp_cutscene_pending_once
        &&
        scr_cutscene_was_played(_id)
    )
    {
        return
            scr_cutscene_warp_entry_cancel();
    }


    // =====================================================
    // ID INVÁLIDA
    // =====================================================

    if (
        !scr_cutscene_warp_entry_valid_id(
            _id
        )
    )
    {
        show_debug_message(
            "[CUTSCENE WARP] ID inexistente o vacía: "
            +
            string(_id)
        );


        scr_cutscene_warp_entry_cancel();


        // No dejar al player atrapado por un error de config.
        if (instance_exists(obj_player))
        {
            scr_cutscene_set_player_control(
                true
            );
        }


        return false;
    }


    // =====================================================
    // MANTENER BLOQUEO
    // =====================================================

    scr_cutscene_world_lock();

    scr_cutscene_warp_entry_hold_player();


    // =====================================================
    // NO COMPETIR CON OTRA CINEMÁTICA
    // =====================================================

    if (instance_exists(obj_cutscene_controller))
        return false;


    if (
        variable_global_exists(
            "cutscene_active"
        )
        &&
        global.cutscene_active
    )
    {
        return false;
    }


    // =====================================================
    // ESPERAR FIN REAL DEL FADE
    // =====================================================

    if (
        scr_cutscene_warp_entry_transition_active()
    )
    {
        return false;
    }


    // =====================================================
    // INICIAR
    // =====================================================
    //
    // true:
    // marca la ID en global.cutscene_flags.
    //
    // Ese struct ya forma parte del save actual.
    // =====================================================

    if (
        scr_cutscene_start(
            _id,
            true
        )
    )
    {
        // Ya no es "pendiente".
        //
        // NO hacemos world_unlock:
        // obj_cutscene_controller mantiene el lock hasta
        // su Destroy.
        scr_cutscene_warp_entry_clear();


        return true;
    }


    return false;
}
