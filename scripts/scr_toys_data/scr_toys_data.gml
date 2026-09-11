/// =========================================================
/// SCR_TOYS_DATA
/// =========================================================
///
/// Base de datos de Toys y sus efectos de batalla.
///
/// =========================================================
/// CÓMO PERSONALIZAR UN TOY
/// =========================================================
///
/// stun_turnos:
///     0 = no aturde.
///     1 = pierde 1 ataque.
///     2 = pierde 2 ataques.
///     etc.
///
/// reduccion_ataque:
///     Cada punto reduce un 8% el ataque del enemigo.
///     Ejemplo:
///         1 = 8%
///         2 = 16%
///         3 = 24%
///
/// reduccion_defensa:
///     Cada punto reduce un 8% la defensa del enemigo.
///     Cuanta menos defensa tenga, más daño recibe Maya.
///
/// reduccion_precision:
///     Probabilidad EXTRA de que el enemigo falle su ataque.
///     Se expresa de 0 a 1.
///
///     Ejemplos:
///         0.10 = 10%
///         0.25 = 25%
///         0.50 = 50%
///
///     Las reducciones de precisión se acumulan, pero tienen
///     un límite del 95% para evitar una precisión negativa.
///
/// IMPORTANTE:
///     Todos estos debuffs duran hasta terminar la batalla.
///     El stun, en cambio, consume sus turnos normalmente.
/// =========================================================


// =========================================================
// APLICAR EFECTOS COMUNES DE UN TOY
// =========================================================
//
// Esta función evita repetir la misma lógica dentro de cada
// Toy. Para crear Toys nuevos normalmente solo necesitas
// copiar una entrada de global.toy_db y cambiar sus números.
// =========================================================

function scr_toy_aplicar_debuffs(_enemigo, _toy)
{
    if (!is_struct(_enemigo))
    {
        return false;
    }


    // -----------------------------------------------------
    // STUN
    // -----------------------------------------------------

    var _stun =
        variable_struct_exists(_toy, "stun_turnos")
        ?
        max(0, round(_toy.stun_turnos))
        :
        0;


    if (_stun > 0)
    {
        if (!variable_struct_exists(_enemigo, "turnos_stun"))
        {
            _enemigo.turnos_stun = 0;
        }


        // No suma stuns completos infinitamente:
        // conserva el mayor número pendiente.
        _enemigo.turnos_stun =
            max(
                _enemigo.turnos_stun,
                _stun
            );
    }


    // -----------------------------------------------------
    // REDUCCIÓN DE ATAQUE / DAÑO
    // -----------------------------------------------------

    var _atk_down =
        variable_struct_exists(_toy, "reduccion_ataque")
        ?
        max(0, _toy.reduccion_ataque)
        :
        0;


    if (_atk_down > 0)
    {
        if (!variable_struct_exists(_enemigo, "ataque_reducido"))
        {
            _enemigo.ataque_reducido = 0;
        }


        _enemigo.ataque_reducido +=
            _atk_down;
    }


    // -----------------------------------------------------
    // REDUCCIÓN DE DEFENSA
    // -----------------------------------------------------

    var _def_down =
        variable_struct_exists(_toy, "reduccion_defensa")
        ?
        max(0, _toy.reduccion_defensa)
        :
        0;


    if (_def_down > 0)
    {
        if (!variable_struct_exists(_enemigo, "defensa_reducida"))
        {
            _enemigo.defensa_reducida = 0;
        }


        _enemigo.defensa_reducida +=
            _def_down;
    }


    // -----------------------------------------------------
    // REDUCCIÓN DE PRECISIÓN
    // -----------------------------------------------------
    //
    // precision_reducida es una probabilidad 0..0.95.
    // La consume el Begin Step de obj_batalla_controller.
    // -----------------------------------------------------

    var _precision_down =
        variable_struct_exists(_toy, "reduccion_precision")
        ?
        clamp(_toy.reduccion_precision, 0, 0.95)
        :
        0;


    if (_precision_down > 0)
    {
        if (!variable_struct_exists(_enemigo, "precision_reducida"))
        {
            _enemigo.precision_reducida = 0;
        }


        _enemigo.precision_reducida =
            clamp(
                _enemigo.precision_reducida
                +
                _precision_down,
                0,
                0.95
            );
    }


    return true;
}


// =========================================================
// BASE DE DATOS
// =========================================================

function scr_toys_data()
{
    global.toy_db =
    {
        // =================================================
        // BRILLITOS
        // =================================================
        //
        // Toy mixto:
        // - aturde 2 ataques;
        // - baja ataque;
        // - baja defensa.
        // =================================================

        brillitos:
        {
            nombre:
                scr_loc_src("Brillitos"),

            tipo:
                "toy",

            descripcion:
                scr_loc_src(
                    "Aturde por 2 turnos y debilita ataque y defensa."
                ),


            // ---------------------------------------------
            // TIENDA
            // ---------------------------------------------

            precio_compra:
                60,

            precio_venta:
                30,

            icono_tienda:
                -1,

            color_tienda:
                noone,


            // ---------------------------------------------
            // EFECTOS
            // ---------------------------------------------

            stun_turnos:
                2,

            reduccion_ataque:
                1,

            reduccion_defensa:
                1,

            reduccion_precision:
                0,

            // Cada punto de reducción de AT/DEF equivale al
            // 8% en las fórmulas actuales de batalla.
            porcentaje_por_punto:
                0.08,


            icono:
                -1,


            efecto:
                function(_enemigo, _toy)
                {
                    return
                        scr_toy_aplicar_debuffs(
                            _enemigo,
                            _toy
                        );
                }
        },


        // =================================================
        // PEGAMENTO
        // =================================================
        //
        // Toy de control puro:
        // el enemigo pierde sus próximos 2 ataques.
        // =================================================

        pegamento:
        {
            nombre:
                scr_loc_src("Pegamento"),

            tipo:
                "toy",

            descripcion:
                scr_loc_src(
                    "Hace perder 2 turnos al enemigo."
                ),


            // ---------------------------------------------
            // TIENDA
            // ---------------------------------------------

            precio_compra:
                50,

            precio_venta:
                25,

            icono_tienda:
                -1,

            color_tienda:
                noone,


            // ---------------------------------------------
            // EFECTOS
            // ---------------------------------------------

            stun_turnos:
                2,

            reduccion_ataque:
                0,

            reduccion_defensa:
                0,

            reduccion_precision:
                0,

            porcentaje_por_punto:
                0.08,


            icono:
                -1,


            efecto:
                function(_enemigo, _toy)
                {
                    return
                        scr_toy_aplicar_debuffs(
                            _enemigo,
                            _toy
                        );
                }
        },


        // =================================================
        // FLASH
        // =================================================
        //
        // EJEMPLO DE TOY DE PRECISIÓN.
        //
        // El enemigo conserva su turno, pero cada vez que
        // intenta atacar tiene un 30% adicional de fallar.
        //
        // Puedes renombrarlo, cambiar precio, descripción,
        // iconos y porcentaje libremente.
        // =================================================

        flash:
        {
            nombre:
                scr_loc_src("Flash"),

            tipo:
                "toy",

            descripcion:
                scr_loc_src(
                    "Desorienta al enemigo y aumenta 30% su probabilidad de fallar."
                ),


            // ---------------------------------------------
            // TIENDA
            // ---------------------------------------------

            precio_compra:
                55,

            precio_venta:
                27,

            icono_tienda:
                -1,

            color_tienda:
                noone,


            // ---------------------------------------------
            // EFECTOS
            // ---------------------------------------------

            stun_turnos:
                0,

            reduccion_ataque:
                0,

            reduccion_defensa:
                0,

            reduccion_precision:
                0.30,

            porcentaje_por_punto:
                0.08,


            icono:
                -1,


            efecto:
                function(_enemigo, _toy)
                {
                    return
                        scr_toy_aplicar_debuffs(
                            _enemigo,
                            _toy
                        );
                }
        },


        // =================================================
        // EJEMPLO PARA CREAR OTROS TOYS
        // =================================================
        //
        // Copia una entrada anterior y combina:
        //
        // stun_turnos:        0,
        // reduccion_ataque:   2,
        // reduccion_defensa:  2,
        // reduccion_precision: 0.20,
        //
        // No necesitas tocar obj_batalla_controller para
        // añadir nuevas combinaciones.
        // =================================================
    };
}
