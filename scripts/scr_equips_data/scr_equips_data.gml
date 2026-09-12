/// =========================================================
/// SCR_EQUIPS_DATA
/// =========================================================
///
/// ARMAS ACTIVAS:
///
///     Palo
///     Raqueta Tenis
///     Cuchillo
///     Cutter
///     Bastón Vital
///     Espada Certera
///     Dagas Gemelas
///     Garras Triples
///     Aro Cargado
///     Aro Gemelo Vital
///
/// ELIMINADAS DEL JUEGO:
///
///     lanza_tardia
///     cuchillas_tardias
///
/// Esos IDs se limpian automáticamente de saves/inventarios.
/// =========================================================


function scr_equips_is_removed(_id)
{
    return
        _id == "lanza_tardia"
        ||
        _id == "cuchillas_tardias";
}


// =========================================================
// LIMPIAR EQUIPO ELIMINADO DE PARTIDAS EXISTENTES
// =========================================================

function scr_equips_cleanup_removed()
{
    scr_inventarios_data();


    // -----------------------------------------------------
    // INVENTARIO PERSISTENTE
    // -----------------------------------------------------

    if (
        variable_struct_exists(
            global.inventory_data,
            "equipamiento"
        )
        &&
        is_array(
            global.inventory_data.equipamiento
        )
    )
    {
        for (
            var _i = 0;
            _i < array_length(
                global.inventory_data.equipamiento
            );
            _i++
        )
        {
            if (
                scr_equips_is_removed(
                    global.inventory_data.equipamiento[_i]
                )
            )
            {
                global.inventory_data.equipamiento[_i] =
                    -1;
            }
        }
    }


    // -----------------------------------------------------
    // ALIAS GLOBAL DEL INVENTARIO DE EQUIPO
    // -----------------------------------------------------

    if (
        variable_global_exists(
            "equipment_inventory"
        )
        &&
        is_array(
            global.equipment_inventory
        )
    )
    {
        for (
            var _j = 0;
            _j < array_length(
                global.equipment_inventory
            );
            _j++
        )
        {
            if (
                scr_equips_is_removed(
                    global.equipment_inventory[_j]
                )
            )
            {
                global.equipment_inventory[_j] =
                    -1;
            }
        }


        global.inventory_data.equipamiento =
            global.equipment_inventory;
    }


    // -----------------------------------------------------
    // ARMA EQUIPADA PERSISTENTE
    // -----------------------------------------------------

    if (
        variable_struct_exists(
            global.inventory_data,
            "equipado_arma"
        )
        &&
        scr_equips_is_removed(
            global.inventory_data.equipado_arma
        )
    )
    {
        global.inventory_data.equipado_arma =
            -1;
    }


    if (
        variable_global_exists(
            "equipped_arma"
        )
        &&
        scr_equips_is_removed(
            global.equipped_arma
        )
    )
    {
        global.equipped_arma =
            -1;
    }


    // -----------------------------------------------------
    // PLAYER
    // -----------------------------------------------------

    if (instance_exists(obj_player))
    {
        var _p =
            instance_find(
                obj_player,
                0
            );


        if (
            _p != noone
            &&
            variable_instance_exists(
                _p,
                "equipo_arma"
            )
            &&
            scr_equips_is_removed(
                _p.equipo_arma
            )
        )
        {
            _p.equipo_arma =
                -1;
        }
    }


    // -----------------------------------------------------
    // COFRE
    // -----------------------------------------------------

    if (
        variable_global_exists(
            "chest_data"
        )
        &&
        is_array(
            global.chest_data
        )
    )
    {
        for (
            var _c = 0;
            _c < array_length(
                global.chest_data
            );
            _c++
        )
        {
            if (
                scr_equips_is_removed(
                    global.chest_data[_c]
                )
            )
            {
                global.chest_data[_c] =
                    -1;
            }
        }
    }
}


// =========================================================
// BASE DE DATOS
// =========================================================

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
            precio_compra: 0,
            precio_venta: 0,
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

            precio_compra: 0,
            precio_venta: 0,
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
            precio_compra: 0,
            precio_venta: 0,
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

            precio_compra: 0,
            precio_venta: 0,
            icono_tienda: -1,
            color_tienda: noone
        },


        baston_vital:
        {
            nombre: scr_loc_src("Bastón Vital"),
            tipo: "arma",
            ataque: 3,
            defensa: 0,

            ataque_cura: 6,

            descripcion:
                scr_loc_src(
                    "Recupera 6 HP después de una acción de ataque que haya hecho daño."
                ),

            precio_compra: 0,
            precio_venta: 0,
            icono_tienda: -1,
            color_tienda: noone
        },


        // =================================================
        // ESPADA CERTERA
        // =================================================
        //
        // Ensancha FÍSICAMENTE la barra móvil.
        //
        // El efecto visual se dibuja desde:
        //
        //     obj_batalla_ui -> Draw GUI End
        //
        // para que no pueda quedar debajo de la UI normal.
        // =================================================

        espada_certera:
        {
            nombre: scr_loc_src("Espada Certera"),
            tipo: "arma",
            ataque: 4,
            defensa: 0,

            ataque_barra_ancho_mult: 2.4,

            descripcion:
                scr_loc_src(
                    "Su barra móvil es mucho más ancha, facilitando detenerla sobre el centro."
                ),

            precio_compra: 0,
            precio_venta: 0,
            icono_tienda: -1,
            color_tienda: noone
        },


        // =================================================
        // MULTI-HIT
        // =================================================

        dagas_gemelas:
        {
            nombre: scr_loc_src("Dagas Gemelas"),
            tipo: "arma",
            ataque: 3,
            defensa: 0,

            ataque_golpes: 2,

            descripcion:
                scr_loc_src(
                    "Lanza dos barras juntas desde el mismo lado del target."
                ),

            precio_compra: 0,
            precio_venta: 0,
            icono_tienda: -1,
            color_tienda: noone
        },


        garras_triples:
        {
            nombre: scr_loc_src("Garras Triples"),
            tipo: "arma",
            ataque: 2,
            defensa: 0,

            ataque_golpes: 3,

            descripcion:
                scr_loc_src(
                    "Lanza tres barras juntas desde el mismo lado del target."
                ),

            precio_compra: 0,
            precio_venta: 0,
            icono_tienda: -1,
            color_tienda: noone
        },


        // =================================================
        // ATAQUE CARGADO
        // =================================================

        aro_cargado:
        {
            nombre: scr_loc_src("Aro Cargado"),
            tipo: "arma",
            ataque: 5,
            defensa: 0,

            ataque_modo: "circular_carga",

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
            precio_venta: 0,
            icono_tienda: -1,
            color_tienda: noone
        },


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
                    "Realiza dos cargas consecutivas sobre una misma diana y recupera 4 HP."
                ),

            precio_compra: 0,
            precio_venta: 0,
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
            precio_compra: 0,
            precio_venta: 0,
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
            precio_venta: 0,
            icono_tienda: -1,
            color_tienda: noone
        }
    };


    scr_equips_cleanup_removed();
}
