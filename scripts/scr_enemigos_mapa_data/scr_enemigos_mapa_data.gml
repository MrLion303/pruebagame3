/// =========================================================
/// SCR_ENEMIGOS_MAPA_DATA
/// =========================================================
///
/// Base de datos de enemigos voladores del mapa.
///
/// TIPOS DE ATAQUE:
///
///     "directo"
///     "espiral"
///
/// PRESETS DE MOVIMIENTO:
///
///     "ninguno"
///     "izquierda_derecha"
///     "arriba_abajo"
///     "circulo"
///     "continuo"
///
/// Cada enemigo real debe ser un objeto hijo de:
///
///     obj_enemigo_mapa_parent
///
/// El objeto hijo solo necesita establecer enemigo_mapa_id
/// antes de llamar event_inherited().
/// =========================================================

function scr_enemigos_mapa_data(_id)
{
    switch (_id)
    {
        // =================================================
        // VOLADOR 1
        // =================================================
        //
        // spr_volador_idle_1
        // spr_volador_alarma_1
        // spr_bala_volador_1
        //
        // Ataque:
        //     directo
        //
        // Movimiento:
        //     arriba <-> abajo
        //     4 px/frame
        // =================================================

        case "volador_1":
            return
            {
                tipo_ataque:
                    "directo",

                sprite_idle:
                    spr_volador_idle_1,

                sprite_alerta:
                    spr_volador_alarma_1,

                sprite_bala:
                    spr_bala_volador_1,


                // -----------------------------------------
                // ATAQUE
                // -----------------------------------------

                rango_ataque:
                    180,

                retraso_inicial:
                    18,

                intervalo_ataque:
                    24,

                velocidad_bala:
                    5.5,

                dano_bala:
                    8,

                vida_bala_frames:
                    180,

                escala_bala:
                    1,

                invulnerabilidad_frames:
                    16,

                bala_homing:
                    false,

                rotar_bala:
                    false,

                colisiona_paredes:
                    false,

                offset_bala_x:
                    0,

                offset_bala_y:
                    0,


                // Un poco más oscuro que la versión anterior.
                oscuridad:
                    0.44,


                // -----------------------------------------
                // MOVIMIENTO
                // -----------------------------------------

                puede_moverse:
                    true,

                movimiento_preset:
                    "arriba_abajo",

                // Velocidad normal de Maya.
                movimiento_velocidad:
                    4,

                // 64 px hacia arriba y 64 px hacia abajo
                // tomando como centro el punto donde
                // colocaste obj_volador_1 en la room.
                movimiento_distancia:
                    64,

                // false:
                // se mueve tanto en idle como en alarma.
                movimiento_solo_alerta:
                    false,

                // Solo usados por otros presets.
                movimiento_radio:
                    64,

                movimiento_direccion:
                    "derecha",

                movimiento_angulo:
                    0,

                movimiento_sentido:
                    1
            };


        // =================================================
        // PLANTILLA - DISPARO DIRECTO SIN MOVIMIENTO
        // =================================================

        case "volador_directo_01":
            return
            {
                tipo_ataque:
                    "directo",

                sprite_idle:
                    asset_get_index(
                        "spr_enemigo_mapa_directo_idle"
                    ),

                sprite_alerta:
                    asset_get_index(
                        "spr_enemigo_mapa_directo_alerta"
                    ),

                sprite_bala:
                    asset_get_index(
                        "spr_bala_mapa_directo"
                    ),

                rango_ataque:
                    180,

                retraso_inicial:
                    18,

                intervalo_ataque:
                    24,

                velocidad_bala:
                    5.5,

                dano_bala:
                    8,

                vida_bala_frames:
                    180,

                escala_bala:
                    1,

                invulnerabilidad_frames:
                    16,

                bala_homing:
                    false,

                rotar_bala:
                    false,

                colisiona_paredes:
                    false,

                offset_bala_x:
                    0,

                offset_bala_y:
                    0,

                oscuridad:
                    0.38,

                puede_moverse:
                    false,

                movimiento_preset:
                    "ninguno",

                movimiento_velocidad:
                    0,

                movimiento_distancia:
                    64,

                movimiento_radio:
                    64,

                movimiento_direccion:
                    "derecha",

                movimiento_angulo:
                    0,

                movimiento_sentido:
                    1,

                movimiento_solo_alerta:
                    false
            };


        // =================================================
        // PLANTILLA - ESPIRAL SIN MOVIMIENTO
        // =================================================

        case "volador_espiral_01":
            return
            {
                tipo_ataque:
                    "espiral",

                sprite_idle:
                    asset_get_index(
                        "spr_enemigo_mapa_espiral_idle"
                    ),

                sprite_alerta:
                    asset_get_index(
                        "spr_enemigo_mapa_espiral_alerta"
                    ),

                sprite_bala:
                    asset_get_index(
                        "spr_bala_mapa_espiral"
                    ),

                rango_ataque:
                    210,

                retraso_inicial:
                    24,

                intervalo_ataque:
                    105,

                velocidad_bala:
                    4.5,

                dano_bala:
                    7,

                vida_bala_frames:
                    210,

                escala_bala:
                    1,

                invulnerabilidad_frames:
                    16,

                bala_homing:
                    false,

                rotar_bala:
                    false,

                colisiona_paredes:
                    false,

                offset_bala_x:
                    0,

                offset_bala_y:
                    0,

                oscuridad:
                    0.38,

                puede_moverse:
                    false,

                movimiento_preset:
                    "ninguno",

                movimiento_velocidad:
                    0,

                movimiento_distancia:
                    64,

                movimiento_radio:
                    64,

                movimiento_direccion:
                    "derecha",

                movimiento_angulo:
                    0,

                movimiento_sentido:
                    1,

                movimiento_solo_alerta:
                    false,


                // -----------------------------------------
                // ESPIRAL
                // -----------------------------------------

                espiral_cantidad:
                    14,

                espiral_radio_inicial:
                    14,

                espiral_radio_paso:
                    4.5,

                espiral_angulo_paso:
                    32,

                espiral_giro_formacion:
                    100,

                espiral_formacion_frames:
                    24,

                espiral_espera_frames:
                    10
            };
    }


    // =====================================================
    // FALLBACK
    // =====================================================

    show_debug_message(
        "[ENEMIGO MAPA] ID desconocido: "
        +
        string(_id)
    );


    return
    {
        tipo_ataque:
            "directo",

        sprite_idle:
            -1,

        sprite_alerta:
            -1,

        sprite_bala:
            -1,

        rango_ataque:
            160,

        retraso_inicial:
            20,

        intervalo_ataque:
            30,

        velocidad_bala:
            5,

        dano_bala:
            5,

        vida_bala_frames:
            180,

        escala_bala:
            1,

        invulnerabilidad_frames:
            16,

        bala_homing:
            false,

        rotar_bala:
            false,

        colisiona_paredes:
            false,

        offset_bala_x:
            0,

        offset_bala_y:
            0,

        oscuridad:
            0.38,

        puede_moverse:
            false,

        movimiento_preset:
            "ninguno",

        movimiento_velocidad:
            0,

        movimiento_distancia:
            64,

        movimiento_radio:
            64,

        movimiento_direccion:
            "derecha",

        movimiento_angulo:
            0,

        movimiento_sentido:
            1,

        movimiento_solo_alerta:
            false,

        espiral_cantidad:
            12,

        espiral_radio_inicial:
            14,

        espiral_radio_paso:
            4,

        espiral_angulo_paso:
            30,

        espiral_giro_formacion:
            90,

        espiral_formacion_frames:
            24,

        espiral_espera_frames:
            10
    };
}
