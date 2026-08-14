function scr_enemigos_data(_id_enemigo) {
    var _datos_batalla = {
        musica: mus_battle_1, 
        enemigos: [],
        dialogos_turno: [
            { texto: "El... keke? Oh! Claro que me gusta!", head: spr_bbs_prota_head, snd: snd_noelle },
            { texto: "* El viento sopla con fuerza en este lugar.", head: noone, snd: snd_text },
            { texto: "* El enemigo te mira fijamente y sonríe.", head: noone, snd: snd_text }
        ]
    };
    
    switch (_id_enemigo) {
        case "toby":
            _datos_batalla.musica = mus_battle_1;
            _datos_batalla.dialogos_turno = [
                { texto: "El... keke? Oh! Claro que me gusta!", head: spr_bbs_prota_head, snd: snd_noelle },
                { texto: "* Toby acomoda su postura de combate.", head: noone, snd: snd_text },
                { texto: "* Toby bosteza aburrido.", head: spr_bbs_prota_head, snd: snd_text }
            ];
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
            _datos_batalla.dialogos_turno = [
                { texto: "¡Cuidado con este viscoso amigo!", head: spr_bbs_prota_head, snd: snd_noelle },
                { texto: "* El Slime gotea líquido viscoso.", head: noone, snd: snd_text },
                { texto: "* Burbujas de aire estallan en el cuerpo del Slime.", head: noone, snd: snd_text }
            ];
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
            _datos_batalla.dialogos_turno = [
                { texto: "¿Estás seguro de que podemos con todos?", head: spr_bbs_prota_head, snd: snd_noelle },
                { texto: "* Los enemigos se coordinan para rodearte.", head: noone, snd: snd_text },
                { texto: "¡Mira cómo se mueven!", head: spr_bbs_prota_head, snd: snd_noelle }
            ];
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