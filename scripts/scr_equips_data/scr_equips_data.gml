/// =========================================================
/// SCR_EQUIPS_DATA
/// =========================================================
///
/// MODIFICADORES MODULARES DE ARMAS:
///
/// ataque_modo:
///     "lineal" / "circular_carga"
///
/// ataque_golpes:
///     1, 2, 3...
///     Si es mayor a 1, se mantienen UN SOLO target/diana y
///     pasan varias barras/cargas una después de otra.
///
/// ataque_cura:
///     HP curado al completar toda la acción si hizo daño.
///
/// ataque_barra_ancho_mult:
///     1.0 = barra normal.
///     2.0 = barra móvil al doble de ancho horizontal.
///
/// carga_*:
///     Ajustes del ataque circular.
///
/// IMPORTANTE:
/// La mecánica de "confirmar después del centro" fue eliminada
/// por completo.
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


        // Cura al terminar toda la acción de ataque.
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


        // La BARRA MÓVIL es más ancha.
        espada_certera:
        {
            nombre: scr_loc_src("Espada Certera"),
            tipo: "arma",
            ataque: 4,
            defensa: 0,

            // Doble ancho horizontal de la barra móvil.
            ataque_barra_ancho_mult: 2.0,

            descripcion:
                scr_loc_src(
                    "Su barra de ataque es más ancha, haciendo más fácil detenerla sobre el centro."
                ),
            precio_compra: 190,
            precio_venta: 95,
            icono_tienda: -1,
            color_tienda: noone
        },


        // La antigua confirmación tardía fue eliminada.
        // Conservamos el ID para no romper saves existentes.
        lanza_tardia:
        {
            nombre: scr_loc_src("Lanza"),
            tipo: "arma",
            ataque: 6,
            defensa: 0,
            descripcion:
                scr_loc_src(
                    "Una lanza de buen alcance y gran poder de ataque."
                ),
            precio_compra: 240,
            precio_venta: 120,
            icono_tienda: -1,
            color_tienda: noone
        },


        // Dos barras consecutivas sobre UN SOLO target.
        dagas_gemelas:
        {
            nombre: scr_loc_src("Dagas Gemelas"),
            tipo: "arma",
            ataque: 3,
            defensa: 0,
            ataque_golpes: 2,
            descripcion:
                scr_loc_src(
                    "Hace pasar dos barras consecutivas sobre un mismo target."
                ),
            precio_compra: 230,
            precio_venta: 115,
            icono_tienda: -1,
            color_tienda: noone
        },


        // Tres barras consecutivas sobre UN SOLO target.
        garras_triples:
        {
            nombre: scr_loc_src("Garras Triples"),
            tipo: "arma",
            ataque: 2,
            defensa: 0,
            ataque_golpes: 3,
            descripcion:
                scr_loc_src(
                    "Hace pasar tres barras consecutivas sobre un mismo target."
                ),
            precio_compra: 270,
            precio_venta: 135,
            icono_tienda: -1,
            color_tienda: noone
        },


        // Antes tenía confirmación tardía.
        // El ID se conserva, pero ahora solo mantiene el doble golpe.
        cuchillas_tardias:
        {
            nombre: scr_loc_src("Cuchillas Dobles"),
            tipo: "arma",
            ataque: 3,
            defensa: 0,
            ataque_golpes: 2,
            descripcion:
                scr_loc_src(
                    "Hace pasar dos barras consecutivas sobre un mismo target."
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

            // Una vez pulsado Z, hay 24 frames para soltar.
            carga_tiempo_frames: 24,

            carga_velocidad_radio: 5.5,
            carga_radio_inicial: 4,
            carga_radio_objetivo: 64,
            carga_radio_max: 90,
            carga_tolerancia_perfecta: 5,

            descripcion:
                scr_loc_src(
                    "Mantén Z para agrandar el aro y suelta cuando coincida con la diana."
                ),
            precio_compra: 0,
            precio_venta: 160,
            icono_tienda: -1,
            color_tienda: noone
        },


        // Combinación real: misma diana, dos cargas y curación.
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
                    "Dos cargas consecutivas sobre una sola diana y una pequeña curación."
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
