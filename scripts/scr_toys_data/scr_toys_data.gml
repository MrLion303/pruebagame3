/// =========================================================
/// SCR_TOYS_DATA
/// =========================================================
/// Debuffs del jugador hacia el enemigo.
///
/// Cada punto de reducción AT/DEF equivale al 8%.
///
/// REGLA UNIVERSAL:
/// cualquier Toy con stun_turnos: 1 se convierte en 2.
/// =========================================================

function scr_toy_aplicar_debuffs(_enemigo, _toy)
{
    if (!is_struct(_enemigo))
        return false;


    // STUN.
    var _stun =
        variable_struct_exists(_toy, "stun_turnos")
        ? max(0, round(_toy.stun_turnos))
        : 0;

    if (_stun == 1)
        _stun = 2;

    if (_stun > 0)
    {
        if (!variable_struct_exists(_enemigo, "turnos_stun"))
            _enemigo.turnos_stun = 0;

        _enemigo.turnos_stun =
            max(_enemigo.turnos_stun, _stun);
    }


    // ATAQUE.
    var _atk_down =
        variable_struct_exists(_toy, "reduccion_ataque")
        ? max(0, _toy.reduccion_ataque)
        : 0;

    if (_atk_down > 0)
    {
        if (!variable_struct_exists(_enemigo, "ataque_reducido"))
            _enemigo.ataque_reducido = 0;

        _enemigo.ataque_reducido += _atk_down;
    }


    // DEFENSA.
    var _def_down =
        variable_struct_exists(_toy, "reduccion_defensa")
        ? max(0, _toy.reduccion_defensa)
        : 0;

    if (_def_down > 0)
    {
        if (!variable_struct_exists(_enemigo, "defensa_reducida"))
            _enemigo.defensa_reducida = 0;

        _enemigo.defensa_reducida += _def_down;
    }


    // PRECISIÓN.
    var _precision_down =
        variable_struct_exists(_toy, "reduccion_precision")
        ? clamp(_toy.reduccion_precision, 0, 0.95)
        : 0;

    if (_precision_down > 0)
    {
        if (!variable_struct_exists(_enemigo, "precision_reducida"))
            _enemigo.precision_reducida = 0;

        _enemigo.precision_reducida =
            clamp(
                _enemigo.precision_reducida + _precision_down,
                0,
                0.95
            );
    }

    return true;
}


function scr_toys_data()
{
    global.toy_db =
    {
        brillitos:
        {
            nombre: scr_loc_src("Brillitos"),
            tipo: "toy",
            descripcion:
                scr_loc_src(
                    "Aturde por 2 turnos y debilita ataque y defensa."
                ),
            precio_compra: 60,
            precio_venta: 30,
            icono_tienda: -1,
            color_tienda: noone,

            stun_turnos: 2,
            reduccion_ataque: 1,
            reduccion_defensa: 1,
            reduccion_precision: 0,
            porcentaje_por_punto: 0.08,
            icono: -1,

            efecto:
                function(_enemigo, _toy)
                {
                    return scr_toy_aplicar_debuffs(_enemigo, _toy);
                }
        },


        pegamento:
        {
            nombre: scr_loc_src("Pegamento"),
            tipo: "toy",
            descripcion:
                scr_loc_src(
                    "Hace perder 2 turnos al enemigo."
                ),
            precio_compra: 50,
            precio_venta: 25,
            icono_tienda: -1,
            color_tienda: noone,

            stun_turnos: 2,
            reduccion_ataque: 0,
            reduccion_defensa: 0,
            reduccion_precision: 0,
            porcentaje_por_punto: 0.08,
            icono: -1,

            efecto:
                function(_enemigo, _toy)
                {
                    return scr_toy_aplicar_debuffs(_enemigo, _toy);
                }
        },


        flash:
        {
            nombre: scr_loc_src("Flash"),
            tipo: "toy",
            descripcion:
                scr_loc_src(
                    "Desorienta al enemigo y aumenta 30% su probabilidad de fallar."
                ),
            precio_compra: 55,
            precio_venta: 27,
            icono_tienda: -1,
            color_tienda: noone,

            stun_turnos: 0,
            reduccion_ataque: 0,
            reduccion_defensa: 0,
            reduccion_precision: 0.30,
            porcentaje_por_punto: 0.08,
            icono: -1,

            efecto:
                function(_enemigo, _toy)
                {
                    return scr_toy_aplicar_debuffs(_enemigo, _toy);
                }
        },


        // Nuevo: -16% DEF.
        rompearmadura:
        {
            nombre: scr_loc_src("Rompearmadura"),
            tipo: "toy",
            descripcion:
                scr_loc_src(
                    "Reduce bastante la defensa del enemigo durante esta batalla."
                ),
            precio_compra: 65,
            precio_venta: 32,
            icono_tienda: -1,
            color_tienda: noone,

            stun_turnos: 0,
            reduccion_ataque: 0,
            reduccion_defensa: 2,
            reduccion_precision: 0,
            porcentaje_por_punto: 0.08,
            icono: -1,

            efecto:
                function(_enemigo, _toy)
                {
                    return scr_toy_aplicar_debuffs(_enemigo, _toy);
                }
        },


        // Nuevo: -16% AT.
        lastre:
        {
            nombre: scr_loc_src("Lastre"),
            tipo: "toy",
            descripcion:
                scr_loc_src(
                    "Reduce bastante el ataque del enemigo durante esta batalla."
                ),
            precio_compra: 65,
            precio_venta: 32,
            icono_tienda: -1,
            color_tienda: noone,

            stun_turnos: 0,
            reduccion_ataque: 2,
            reduccion_defensa: 0,
            reduccion_precision: 0,
            porcentaje_por_punto: 0.08,
            icono: -1,

            efecto:
                function(_enemigo, _toy)
                {
                    return scr_toy_aplicar_debuffs(_enemigo, _toy);
                }
        }
    };
}
