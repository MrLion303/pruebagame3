function scr_toys_data() {
    global.toy_db = {
        brillitos: {
            nombre: "Brillitos",
            tipo: "toy",
            descripcion: "Un puñado de brillitos. Aturde al enemigo y reduce su ataque y defensa.",

            // Cantidad de turnos que el enemigo no podrá atacar.
            stun_turnos: 1,

            // Reduce el ataque del enemigo mientras dure la batalla.
            reduccion_ataque: 2,

            // Reduce la defensa del enemigo mientras dure la batalla.
            reduccion_defensa: 2,

            icono: -1
        }
    };
}
