/// scr_toys_data
/// Base de datos de toys y sus efectos de batalla.

function scr_toys_data() {

    global.toy_db = {

        // =========================================================
        // BRILLITOS
        // =========================================================
        brillitos: {

            nombre: scr_loc_src("Brillitos"),
            tipo: "toy",
            descripcion: scr_loc_src("Aturde y debilita al enemigo."),

            // Datos de tienda.
            precio_compra: 60,
            precio_venta: 30,
            icono_tienda: -1,
            color_tienda: noone,

            stun_turnos: 1,
            reduccion_ataque: 1,
            reduccion_defensa: 1,
            porcentaje_por_punto: 0.08,

            icono: -1,

            efecto: function(_enemigo, _toy) {

                if (!is_struct(_enemigo)) {
                    return false;
                }

                // -------------------------------------------------
                // STUN
                // -------------------------------------------------
                if (!variable_struct_exists(_enemigo, "turnos_stun")) {
                    _enemigo.turnos_stun = 0;
                }

                _enemigo.turnos_stun = max(
                    _enemigo.turnos_stun,
                    _toy.stun_turnos
                );

                // -------------------------------------------------
                // REDUCCIÓN DE ATAQUE
                // -------------------------------------------------
                if (!variable_struct_exists(_enemigo, "ataque_reducido")) {
                    _enemigo.ataque_reducido = 0;
                }

                _enemigo.ataque_reducido += _toy.reduccion_ataque;

                // -------------------------------------------------
                // REDUCCIÓN DE DEFENSA
                // -------------------------------------------------
                if (!variable_struct_exists(_enemigo, "defensa_reducida")) {
                    _enemigo.defensa_reducida = 0;
                }

                _enemigo.defensa_reducida += _toy.reduccion_defensa;

                return true;
            }
        },


        // =========================================================
        // PEGAMENTO
        // =========================================================
        pegamento: {

            nombre: scr_loc_src("Pegamento"),
            tipo: "toy",
            descripcion: scr_loc_src("Hace perder un turno al enemigo."),

            // Datos de tienda.
            precio_compra: 50,
            precio_venta: 25,
            icono_tienda: -1,
            color_tienda: noone,

            stun_turnos: 1,
            reduccion_ataque: 0,
            reduccion_defensa: 0,
            porcentaje_por_punto: 0.08,

            icono: -1,

            efecto: function(_enemigo, _toy) {

                if (!is_struct(_enemigo)) {
                    return false;
                }

                if (!variable_struct_exists(_enemigo, "turnos_stun")) {
                    _enemigo.turnos_stun = 0;
                }

                _enemigo.turnos_stun = max(
                    _enemigo.turnos_stun,
                    _toy.stun_turnos
                );

                return true;
            }
        }
    };
}
