/// =========================================================
/// SCR_ENEMIGOS_MAPA_DATA
/// =========================================================
///
/// NUEVO:
/// sigilo_factor_vision
///
/// 0.50 = con Sigilo ve al 50% del rango normal.
/// Es personalizable por enemigo.
/// =========================================================

function scr_enemigos_mapa_data(_id)
{
    switch (_id)
    {
        case "volador_1":
            return
            {
                tipo_ataque: "directo",

                sprite_idle: spr_volador_idle_1,
                sprite_alerta: spr_volador_alarma_1,
                sprite_bala: spr_bala_volador_1,

                rango_ataque: 180,
                sigilo_factor_vision: 0.50,

                retraso_inicial: 18,
                intervalo_ataque: 24,

                velocidad_bala: 5.5,
                dano_bala: 8,
                vida_bala_frames: 180,
                escala_bala: 1,
                invulnerabilidad_frames: 16,

                bala_homing: false,
                rotar_bala: false,
                colisiona_paredes: false,

                offset_bala_x: 0,
                offset_bala_y: 0,

                oscuridad: 0.44,

                puede_moverse: true,
                movimiento_preset: "arriba_abajo",
                movimiento_velocidad: 4,
                movimiento_distancia: 64,
                movimiento_solo_alerta: false,
                movimiento_radio: 64,
                movimiento_direccion: "derecha",
                movimiento_angulo: 0,
                movimiento_sentido: 1
            };


        case "volador_directo_01":
            return
            {
                tipo_ataque: "directo",

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

                rango_ataque: 180,
                sigilo_factor_vision: 0.50,

                retraso_inicial: 18,
                intervalo_ataque: 24,

                velocidad_bala: 5.5,
                dano_bala: 8,
                vida_bala_frames: 180,
                escala_bala: 1,
                invulnerabilidad_frames: 16,

                bala_homing: false,
                rotar_bala: false,
                colisiona_paredes: false,

                offset_bala_x: 0,
                offset_bala_y: 0,

                oscuridad: 0.38,

                puede_moverse: false,
                movimiento_preset: "ninguno",
                movimiento_velocidad: 0,
                movimiento_distancia: 64,
                movimiento_radio: 64,
                movimiento_direccion: "derecha",
                movimiento_angulo: 0,
                movimiento_sentido: 1,
                movimiento_solo_alerta: false
            };


        case "volador_espiral_01":
            return
            {
                tipo_ataque: "espiral",

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

                rango_ataque: 210,
                sigilo_factor_vision: 0.50,

                retraso_inicial: 24,
                intervalo_ataque: 105,

                velocidad_bala: 4.5,
                dano_bala: 7,
                vida_bala_frames: 210,
                escala_bala: 1,
                invulnerabilidad_frames: 16,

                bala_homing: false,
                rotar_bala: false,
                colisiona_paredes: false,

                offset_bala_x: 0,
                offset_bala_y: 0,

                oscuridad: 0.38,

                puede_moverse: false,
                movimiento_preset: "ninguno",
                movimiento_velocidad: 0,
                movimiento_distancia: 64,
                movimiento_radio: 64,
                movimiento_direccion: "derecha",
                movimiento_angulo: 0,
                movimiento_sentido: 1,
                movimiento_solo_alerta: false,

                espiral_cantidad: 14,
                espiral_radio_inicial: 14,
                espiral_radio_paso: 4.5,
                espiral_angulo_paso: 32,
                espiral_giro_formacion: 100,
                espiral_formacion_frames: 24,
                espiral_espera_frames: 10
            };
    }


    show_debug_message(
        "[ENEMIGO MAPA] ID desconocido: "
        +
        string(_id)
    );


    return
    {
        tipo_ataque: "directo",

        sprite_idle: -1,
        sprite_alerta: -1,
        sprite_bala: -1,

        rango_ataque: 160,
        sigilo_factor_vision: 0.50,

        retraso_inicial: 20,
        intervalo_ataque: 30,

        velocidad_bala: 5,
        dano_bala: 5,
        vida_bala_frames: 180,
        escala_bala: 1,
        invulnerabilidad_frames: 16,

        bala_homing: false,
        rotar_bala: false,
        colisiona_paredes: false,

        offset_bala_x: 0,
        offset_bala_y: 0,

        oscuridad: 0.38,

        puede_moverse: false,
        movimiento_preset: "ninguno",
        movimiento_velocidad: 0,
        movimiento_distancia: 64,
        movimiento_radio: 64,
        movimiento_direccion: "derecha",
        movimiento_angulo: 0,
        movimiento_sentido: 1,
        movimiento_solo_alerta: false,

        espiral_cantidad: 12,
        espiral_radio_inicial: 14,
        espiral_radio_paso: 4,
        espiral_angulo_paso: 30,
        espiral_giro_formacion: 90,
        espiral_formacion_frames: 24,
        espiral_espera_frames: 10
    };
}
