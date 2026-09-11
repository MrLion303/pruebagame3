/// =========================================================
/// SCR_ENEMIGOS_BATALLA_MAPA_DATA
/// =========================================================
///
/// sigilo_factor_vision multiplica rango_persecucion mientras
/// Maya mantiene S con la habilidad Sigilo.
/// =========================================================

function scr_enemigos_batalla_mapa_data(_id)
{
    switch (_id)
    {
        case "caminante_01":
            return
            {
                batalla_id: "variante 1",

                modo_activacion: "persecucion",

                rango_persecucion: 120,
                sigilo_factor_vision: 0.50,

                radio_contacto: 18,

                sprite_alerta: -1,

                persecucion_velocidad: 4.0,

                puede_moverse: true,
                movimiento_preset: "izquierda_derecha",
                movimiento_velocidad: 2.0,
                movimiento_distancia: 64,
                movimiento_radio: 64,
                movimiento_direccion: "derecha",
                movimiento_angulo: 0,
                movimiento_sentido: 1,
                movimiento_diagonal_angulo: 45
            };


        case "perseguidor_toby":
            return
            {
                batalla_id: "toby",

                modo_activacion: "persecucion",

                rango_persecucion: 160,

                // 160 -> 80 con Sigilo.
                // Personalizable por enemigo.
                sigilo_factor_vision: 0.50,

                radio_contacto: 18,

                sprite_alerta:
                    spr_volador_alarma_2,

                persecucion_velocidad: 5.5,

                puede_moverse: true,
                movimiento_preset: "izquierda_derecha",
                movimiento_velocidad: 3.0,
                movimiento_distancia: 80,
                movimiento_radio: 64,
                movimiento_direccion: "derecha",
                movimiento_angulo: 0,
                movimiento_sentido: 1,
                movimiento_diagonal_angulo: 45
            };
    }


    show_debug_message(
        "[ENEMIGO BATALLA MAPA] ID desconocido: "
        +
        string(_id)
    );


    return
    {
        batalla_id: "variante 1",

        modo_activacion: "contacto",

        rango_persecucion: 100,
        sigilo_factor_vision: 0.50,

        radio_contacto: 18,

        sprite_alerta: -1,

        persecucion_velocidad: 4.0,

        puede_moverse: false,
        movimiento_preset: "ninguno",
        movimiento_velocidad: 0,
        movimiento_distancia: 64,
        movimiento_radio: 64,
        movimiento_direccion: "derecha",
        movimiento_angulo: 0,
        movimiento_sentido: 1,
        movimiento_diagonal_angulo: 45
    };
}
