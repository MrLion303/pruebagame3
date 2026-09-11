/// =========================================================
/// SCR_ENEMIGOS_RUTA_DANO_DATA
/// =========================================================
///
/// Base de datos para enemigos de RUTA que:
//
//     - NO inician BBS;
//     - recorren puntos por coordenadas;
//     - repiten la ruta en bucle;
//     - oscurecen la pantalla al acercarte;
//     - dañan a Maya al tocarla.
///
/// Cada enemigo real será hijo de:
//
//     obj_enemigo_ruta_dano_parent
///
/// =========================================================
/// CÓMO HACER UNA RUTA
/// =========================================================
///
/// ruta_puntos es un array de structs {x, y}.
///
/// EJEMPLO CUADRADO:
///
///     ruta_puntos:
///     [
///         { x: 200, y: 200 },
///         { x: 360, y: 200 },
///         { x: 360, y: 360 },
///         { x: 200, y: 360 }
///     ]
///
/// El recorrido será:
///
///     1 -> 2 -> 3 -> 4 -> 1 -> 2 -> ...
///
/// Es un BUCLE infinito.
///
/// IMPORTANTE:
///
/// Este tipo de enemigo SÍ usa coordenadas absolutas.
/// Al crearse aparece en el PRIMER punto de la ruta.
///
/// Cada tramo usa smootherstep:
///
///     acelera -> avanza -> frena -> waypoint
///
/// De esa forma los cambios en esquinas son suaves y el
/// enemigo toca exactamente todos los puntos de la ruta.
///
/// =========================================================
/// PELIGRO
/// =========================================================
///
/// rango_peligro:
///     distancia a la que empieza el mismo efecto visual de
///     los enemigos de mapa que disparan.
///
/// oscuridad:
///     0..1.
///     0.44 = mismo nivel que volador_1 actualmente.
///
/// Como obj_enemigo_ruta_dano_parent es hijo de
/// obj_enemigo_mapa_parent, obj_mapa_combate_fx lo detecta
/// automáticamente.
///
/// =========================================================
/// DAÑO
/// =========================================================
///
/// dano_contacto:
///     daño base ANTES de la defensa de Maya.
///
/// invulnerabilidad_frames:
///     i-frames después del golpe.
///
/// Usa la misma fórmula de defensa, sonido y shake de los
/// proyectiles de mapa.
///
/// =========================================================


function scr_enemigos_ruta_dano_data(_id)
{
    switch (_id)
    {
        // =================================================
        // RUTA DAÑO 01 - EJEMPLO CUADRADO
        // =================================================

        case "ruta_dano_01":
            return
            {
                // -----------------------------------------
                // RUTA
                // -----------------------------------------

                ruta_puntos:
                [
                    {
                        x: 200,
                        y: 200
                    },

                    {
                        x: 360,
                        y: 200
                    },

                    {
                        x: 360,
                        y: 360
                    },

                    {
                        x: 200,
                        y: 360
                    }
                ],


                ruta_velocidad:
                    3.0,


                // -----------------------------------------
                // PELIGRO VISUAL
                // -----------------------------------------

                rango_peligro:
                    180,

                oscuridad:
                    0.44,


                // -----------------------------------------
                // CONTACTO
                // -----------------------------------------

                dano_contacto:
                    8,

                invulnerabilidad_frames:
                    16
            };
    }


    // =====================================================
    // FALLBACK
    // =====================================================

    show_debug_message(
        "[ENEMIGO RUTA DAÑO] ID desconocido: "
        +
        string(
            _id
        )
    );


    return
    {
        ruta_puntos:
        [
            {
                x: 0,
                y: 0
            },

            {
                x: 64,
                y: 0
            }
        ],

        ruta_velocidad:
            2.0,

        rango_peligro:
            160,

        oscuridad:
            0.38,

        dano_contacto:
            5,

        invulnerabilidad_frames:
            16
    };
}
