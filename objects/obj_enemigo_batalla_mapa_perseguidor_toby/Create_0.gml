/// =========================================================
/// OBJ_ENEMIGO_BATALLA_MAPA_PERSEGUIDOR_TOBY
/// CREATE - NUEVO OBJETO HIJO
/// =========================================================
///
/// Parent obligatorio:
///
///     obj_enemigo_batalla_mapa_parent
///
/// Configuración utilizada:
///
///     "perseguidor_toby"
///
/// dentro de:
///
///     scr_enemigos_batalla_mapa_data
///
/// Comportamiento:
///
///     - patrulla entre A y B;
///     - al detectar a Maya cambia a spr_volador_idle_2;
///     - espera 0.5 segundos quieto;
///     - después empieza a perseguirla;
///     - al tocarla inicia inmediatamente la batalla "toby".
///
/// =========================================================

enemigo_batalla_mapa_id =
    "perseguidor_toby";


event_inherited();
