/// =========================================================
/// SCR_EQUIPS_DATA
/// =========================================================
///
/// Campos modulares opcionales de armas:
///
/// ataque_modo:
///     "lineal" / "circular_carga"
///
/// ataque_golpes:
///     1, 2, 3...
///
/// ataque_cura:
///     HP curado al completar una acción que hizo daño.
///
/// ataque_ancho_centro_mult:
///     1.0 normal, 2.0 doble zona perfecta.
///
/// ataque_confirmar_despues_centro:
///     Z solo funciona después de cruzar el centro.
///
/// Los campos se pueden combinar libremente.
/// =========================================================

function scr_equips_data()
{
    global.equip_db =
    {
        espada_basica:
        {
            nombre: scr_loc_src("Palo"),
            tipo: "arma",
            ataque: 3,
            defensa: 0,
            descripcion: scr_loc_src("Un palo de madera sencillo."),
            precio_compra: 100,
            precio_venta: 50,
            icono_tienda: -1,
            color_tienda: noone
        },


        raqueta_tenis:
        {
            nombre: scr_loc_src("Raqueta Tenis"),
            tipo: "arma",
            ataque: 4,
            defensa: 0,
            permite_parry: true,
            descripcion:
                scr_loc_src(
                    "Una raqueta ligera. Permite hacer parry a los ataques enemigos."
                ),
            precio_compra: 140,
            precio_venta: 70,
            icono_tienda: -1,
            color_tienda: noone
        },


        cuchillo:
        {
            nombre: scr_loc_src("Cuchillo"),
            tipo: "arma",
            ataque: 5,
            defensa: 0,
            descripcion: scr_loc_src("Un cuchillo afilado."),
            precio_compra: 160,
            precio_venta: 80,
            icono_tienda: -1,
            color_tienda: noone
        },


        cutter:
        {
            nombre: scr_loc_src("Cutter"),
            tipo: "arma",
            ataque: 7,
            defensa: 0,
            descripcion:
                scr_loc_src(
                    "Una herramienta con una hoja retráctil."
                ),
            precio_compra: 220,
            precio_venta: 110,
            icono_tienda: -1,
            color_tienda: noone
        },


        // Cura al terminar la acción de ataque.
        baston_vital:
        {
            nombre: scr_loc_src("Bastón Vital"),
            tipo: "arma",
            ataque: 3,
            defensa: 0,
            ataque_cura: 6,
            descripcion:
                scr_loc_src(
                    "Recupera un poco de HP después de una acción de ataque que haga daño."
                ),
            precio_compra: 180,
            precio_venta: 90,
            icono_tienda: -1,
            color_tienda: noone
        },


        // Duplica el radio que cuenta como golpe perfecto.
        espada_certera:
        {
            nombre: scr_loc_src("Espada Certera"),
            tipo: "arma",
            ataque: 4,
            defensa: 0,
            ataque_ancho_centro_mult: 2.0,
            descripcion:
                scr_loc_src(
                    "Su zona de golpe perfecto es el doble de permisiva."
                ),
            precio_compra: 190,
            precio_venta: 95,
            icono_tienda: -1,
            color_tienda: noone
        },


        // No acepta Z antes de haber cruzado el centro.
        lanza_tardia:
        {
            nombre: scr_loc_src("Lanza Tardía"),
            tipo: "arma",
            ataque: 6,
            defensa: 0,
            ataque_confirmar_despues_centro: true,
            descripcion:
                scr_loc_src(
                    "Solo permite confirmar el golpe después de cruzar el centro."
                ),
            precio_compra: 240,
            precio_venta: 120,
            icono_tienda: -1,
            color_tienda: noone
        },


        // Dos timings seguidos.
        dagas_gemelas:
        {
            nombre: scr_loc_src("Dagas Gemelas"),
            tipo: "arma",
            ataque: 3,
            defensa: 0,
            ataque_golpes: 2,
            descripcion:
                scr_loc_src(
                    "Permite realizar dos timings de ataque consecutivos."
                ),
            precio_compra: 230,
            precio_venta: 115,
            icono_tienda: -1,
            color_tienda: noone
        },


        // Tres timings seguidos.
        garras_triples:
        {
            nombre: scr_loc_src("Garras Triples"),
            tipo: "arma",
            ataque: 2,
            defensa: 0,
            ataque_golpes: 3,
            descripcion:
                scr_loc_src(
                    "Permite realizar tres timings de ataque consecutivos."
                ),
            precio_compra: 270,
            precio_venta: 135,
            icono_tienda: -1,
            color_tienda: noone
        },


        // Combinación: después del centro + dos golpes.
        cuchillas_tardias:
        {
            nombre: scr_loc_src("Cuchillas Tardías"),
            tipo: "arma",
            ataque: 3,
            defensa: 0,
            ataque_golpes: 2,
            ataque_confirmar_despues_centro: true,
            descripcion:
                scr_loc_src(
                    "Dos golpes. Cada uno solo se confirma después de cruzar el centro."
                ),
            precio_compra: 290,
            precio_venta: 145,
            icono_tienda: -1,
            color_tienda: noone
        },


        // Target circular de ataque. NO es parry.
        aro_cargado:
        {
            nombre: scr_loc_src("Aro Cargado"),
            tipo: "arma",
            ataque: 5,
            defensa: 0,

            ataque_modo: "circular_carga",

            // 24 frames a 30 FPS = 0.8 segundos.
            carga_tiempo_frames: 24,

            // Desde radio 4 a radio ideal 64 en aprox. 11 frames.
            carga_velocidad_radio: 5.5,
            carga_radio_inicial: 4,
            carga_radio_objetivo: 64,
            carga_radio_max: 90,
            carga_tolerancia_perfecta: 5,

            descripcion:
                scr_loc_src(
                    "Mantén Z para agrandar el aro y suelta cuando llene la diana."
                ),
            precio_compra: 0,
            precio_venta: 160,
            icono_tienda: -1,
            color_tienda: noone
        },


        // Demostración real de combinaciones.
        aro_gemelo_vital:
        {
            nombre: scr_loc_src("Aro Gemelo Vital"),
            tipo: "arma",
            ataque: 3,
            defensa: 0,

            ataque_modo: "circular_carga",
            ataque_golpes: 2,
            ataque_cura: 4,

            carga_tiempo_frames: 24,
            carga_velocidad_radio: 5.5,
            carga_radio_inicial: 4,
            carga_radio_objetivo: 64,
            carga_radio_max: 90,
            carga_tolerancia_perfecta: 5,

            descripcion:
                scr_loc_src(
                    "Ataque circular, dos golpes y una pequeña curación."
                ),
            precio_compra: 380,
            precio_venta: 190,
            icono_tienda: -1,
            color_tienda: noone
        },


        armadura_basica:
        {
            nombre: scr_loc_src("Pijama"),
            tipo: "armadura",
            ataque: 0,
            defensa: 2,
            descripcion: scr_loc_src("Un pijama cómodo."),
            precio_compra: 80,
            precio_venta: 40,
            icono_tienda: -1,
            color_tienda: noone
        },


        zapatos_rapidos:
        {
            nombre: scr_loc_src("Zapatos Rápidos"),
            tipo: "armadura",
            ataque: 0,
            defensa: 1,

            permite_dash_mapa: true,

            descripcion:
                scr_loc_src(
                    "Permiten hacer dash mientras estás dentro del rango de peligro de un enemigo del mapa."
                ),
            precio_compra: 0,
            precio_venta: 130,
            icono_tienda: -1,
            color_tienda: noone
        }
    };
}
