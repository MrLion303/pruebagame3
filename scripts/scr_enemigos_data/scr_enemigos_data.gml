function scr_enemigos_data(_id_enemigo) {
    var _datos_batalla = {
        musica: mus_battle_1, 
        enemigos: []
    };
    
    switch (_id_enemigo) {
        case "toby":
            _datos_batalla.musica = mus_battle_1;
            array_push(_datos_batalla.enemigos, {
                nombre: "Toby",
                sprite: spr_enemigo_1,
                escala_sprite: 2.0,
                vida_max: 30,
                vida_actual: 30,
                ataque: 2,
                defensa: 0,
                descripcion: "Hola, esta es mi descripcion",
                texto_inicio: "* Un Toby salvaje aparece de su escondite!",
                texto_muerte: "* Acabaste con Toby."
            });
            break;
            
        case "slime":
            _datos_batalla.musica = mus_battle_1;
            array_push(_datos_batalla.enemigos, {
                nombre: "Slime Verdoso",
                sprite: spr_enemigo_2,
                escala_sprite: 1.0,
                vida_max: 15,
                vida_actual: 15,
                ataque: 1,
                defensa: 1,
                descripcion: "Un pequeno monstruo gelatinoso.",
                texto_inicio: "Un Slime gelatinoso bloquea el paso!",
                texto_muerte: "* Derrotaste al Slime Verdoso."
            });
            break;
            
        case "variante 1":
            _datos_batalla.musica = mus_battle_1; 
            array_push(_datos_batalla.enemigos, {
                nombre: "Toby A",
                sprite: spr_enemigo_1,
                escala_sprite: 1.5,
                vida_max: 30,
                vida_actual: 30,
                ataque: 2,
                defensa: 0,
                descripcion: "El primer Toby de la banda.",
                texto_inicio: "Una pandilla de monstruos salvajes aparece!",
                texto_muerte: "* Acabaste con Toby A."
            });
            array_push(_datos_batalla.enemigos, {
                nombre: "Slime Verdoso",
                sprite: spr_enemigo_2,
                escala_sprite: 1.0,
                vida_max: 15,
                vida_actual: 15,
                ataque: 1,
                defensa: 1,
                descripcion: "Un pequeno monstruo gelatinoso.",
                texto_muerte: "* Derrotaste al Slime Verdoso."
            });
            array_push(_datos_batalla.enemigos, {
                nombre: "Toby B",
                sprite: spr_enemigo_1,
                escala_sprite: 1.5,
                vida_max: 30,
                vida_actual: 30,
                ataque: 2,
                defensa: 0,
                descripcion: "El segundo Toby de refuerzo.",
                texto_muerte: "* Acabaste con Toby B."
            });
            break;
        
        default:
            _datos_batalla.musica = mus_battle_1;
            array_push(_datos_batalla.enemigos, {
                nombre: "Desconocido",
                sprite: spr_enemigo_1,
                escala_sprite: 2.0,
                vida_max: 10,
                vida_actual: 10,
                ataque: 1,
                defensa: 0,
                descripcion: "Un error en la matrix.",
                texto_inicio: "Algo extrano emerge de la oscuridad...",
                texto_muerte: "* El enemigo desconocido se desvanece."
            });
            break;
    }
    
    return _datos_batalla;
}