function scr_equips_data() {
    global.equip_db = {
        espada_basica: {
            nombre: scr_loc_src("Espada palo"),
            tipo: "arma", // arma o armadura
            ataque: 3,
            defensa: 0,
            descripcion: scr_loc_src("Una espada de madera inofensiva.")
        },
        armadura_basica: {
            nombre: scr_loc_src("Ropa vieja"),
            tipo: "armadura",
            ataque: 0,
            defensa: 2,
            descripcion: scr_loc_src("Te protege un poco del frio.")
        }
    };
}

