function scr_enemigos_data(_id_enemigo) {
    
    var _datos_batalla = {
        musica: mus_battle_1,

        // noone = usa el background normal del room bbs.
        // También puedes poner un sprite, por ejemplo spr_fondo_boss.
        fondo: noone,

        experiencia: 0,

        // Recompensa monetaria de la batalla.
        // La moneda se llama Sueños y se muestra abreviada como SO.
        suenos: 100,

        probabilidad_escapar: 0.5,
        
        // =========================================================
        // CINEMATICAS DE LA BATALLA
        //
        // Puedes agregar varias cinematicas dentro de este arreglo.
        //
        // enemigo:
        // 0 = primer enemigo
        // 1 = segundo enemigo
        // 2 = tercer enemigo
        //
        // porcentaje_vida:
        // 0.20 = 20%
        // 0.50 = 50%
        // 0.05 = 5%
        //
        // id:
        // ID de la cinematica dentro de
        // scr_bosses_cinematica_bbs
        //
        // terminar_batalla:
        // false = continua la batalla
        // true = termina la batalla al acabar la cinematica
        // =========================================================
        
        cinematicas: [],
        
        enemigos: [],
        
        dialogos_turno: [
            { texto: scr_loc_src("El... keke? Oh! Claro que me gusta!"), head: spr_bbs_prota_head, snd: snd_noelle },
            { texto: scr_loc_src("* El viento sopla con fuerza en este lugar."), head: noone, snd: snd_text },
            { texto: scr_loc_src("* El enemigo te mira fijamente y sonríe."), head: noone, snd: snd_text }
        ]
    };
    
    switch (_id_enemigo) {
        
        // =========================================================
        // TOBY
        // =========================================================
        
        case "toby":
            
            _datos_batalla.musica = mus_battle_1;
            _datos_batalla.fondo = noone;
            _datos_batalla.experiencia = 100;
            _datos_batalla.suenos = 100; // <-- Cambia aquí los SO que entrega esta batalla
            _datos_batalla.probabilidad_escapar = 0.5;
            
            _datos_batalla.dialogos_turno = [
                { texto: scr_loc_src("El... keke? Oh! Claro que me gusta!"), head: spr_bbs_prota_head, snd: snd_noelle },
                { texto: scr_loc_src("* Toby acomoda su postura de combate."), head: noone, snd: snd_text },
                { texto: scr_loc_src("* Toby bosteza aburrido."), head: spr_bbs_prota_head, snd: snd_text }
            ];
            
            array_push(_datos_batalla.enemigos, {
                nombre: scr_loc_src("Toby"),
                sprite: spr_enemigo_1,
                escala_sprite: 2.0,
                vida_max: 30,
                vida_actual: 30,
                ataque: 2,
                defensa: 0,
                descripcion: scr_loc_src("Hola, esta es mi descripcion"),
                texto_inicio: scr_loc_src("* Un Toby salvaje aparece de su escondite!"),
                texto_muerte: scr_loc_src("* Acabaste con Toby.")
            });
            
            break;
            
            
        // =========================================================
        // SLIME
        // =========================================================
        
        case "slime":
            
            _datos_batalla.musica = mus_battle_1;
            _datos_batalla.fondo = noone;
            _datos_batalla.experiencia = 50;
            _datos_batalla.suenos = 100; // <-- Cambia aquí los SO que entrega esta batalla
            _datos_batalla.probabilidad_escapar = 0.5;
            
            _datos_batalla.dialogos_turno = [
                { texto: scr_loc_src("¡Cuidado con este viscoso amigo!"), head: spr_bbs_prota_head, snd: snd_noelle },
                { texto: scr_loc_src("* El Slime gotea líquido viscoso."), head: noone, snd: snd_text },
                { texto: scr_loc_src("* Burbujas de aire estallan en el cuerpo del Slime."), head: noone, snd: snd_text }
            ];
            
            array_push(_datos_batalla.enemigos, {
                nombre: scr_loc_src("Slime Verdoso"),
                sprite: spr_enemigo_2,
                escala_sprite: 1.0,
                vida_max: 15,
                vida_actual: 15,
                ataque: 1,
                defensa: 1,
                descripcion: scr_loc_src("Un pequeño monstruo gelatinoso."),
                texto_inicio: scr_loc_src("Un Slime gelatinoso bloquea el paso!"),
                texto_muerte: scr_loc_src("* Derrotaste al Slime Verdoso.")
            });
            
            break;
            
            
        // =========================================================
        // BOSS 1 - JEVIL
        // =========================================================
        
        case "boss_1":
            
            _datos_batalla.musica = mus_jevil;
            _datos_batalla.fondo = noone;
            _datos_batalla.experiencia = 50;
            _datos_batalla.suenos = 100; // <-- Cambia aquí los SO que entrega esta batalla
            _datos_batalla.probabilidad_escapar = 0.7;
            
            // -----------------------------------------------------
            // CINEMATICAS DEL BOSS
            //
            // Puedes agregar tantas como quieras.
            //
            // Esta primera se activa cuando Jevil llegue al
            // 20% de vida o menos y, al terminar, la batalla sigue.
            // -----------------------------------------------------
            
            array_push(_datos_batalla.cinematicas, {
                enemigo: 0,
                porcentaje_vida: 0.70,
                id: "boss_prueba_20",
                terminar_batalla: false,
                activada: false
            });
            
            // -----------------------------------------------------
            // EJEMPLO DE UNA SEGUNDA CINEMATICA
            //
            // Está preparada pero comentada.
            //
            // Puedes activarla quitando los comentarios cuando
            // agreguemos "boss_1_05" en
            // scr_bosses_cinematica_bbs.
            // -----------------------------------------------------
            
            
            array_push(_datos_batalla.cinematicas, {
                enemigo: 0,
                porcentaje_vida: 0.20,
                id: "boss_prueba_20",
                terminar_batalla: true,
                activada: false
            });
            
            
            _datos_batalla.dialogos_turno = [
                { texto: scr_loc_src("¡Cuidado! Este enemigo no parece estar jugando."), head: spr_bbs_prota_head, snd: snd_noelle },
                { texto: scr_loc_src("* Jevil se mueve de forma impredecible."), head: noone, snd: snd_text },
                { texto: scr_loc_src("* Una sonrisa extraña aparece en su rostro."), head: noone, snd: snd_text }
            ];
            
            array_push(_datos_batalla.enemigos, {
                nombre: scr_loc_src("Jevil"),
                sprite: spr_enemigo_3,
                escala_sprite: 2.0,
                vida_max: 30,
                vida_actual: 30,
                ataque: 1,
                defensa: 1,
                descripcion: scr_loc_src("Un enemigo impredecible que parece disfrutar el combate."),
                texto_inicio: scr_loc_src("* Jevil aparece frente a ti!"),
                texto_muerte: scr_loc_src("* Derrotaste a Jevil.")
            });
            
            break;
            
            
        // =========================================================
        // VARIANTE 1
        // =========================================================
        
        case "variante 1":
            
            _datos_batalla.musica = mus_battle_1;
            _datos_batalla.fondo = noone;
            _datos_batalla.experiencia = 150; 
            _datos_batalla.suenos = 100; // <-- Cambia aquí los SO que entrega esta batalla
            _datos_batalla.probabilidad_escapar = 0.5;
            
            _datos_batalla.dialogos_turno = [
                { texto: scr_loc_src("¿Estás seguro de que podemos con todos?"), head: spr_bbs_prota_head, snd: snd_noelle },
                { texto: scr_loc_src("* Los enemigos se coordinan para rodearte."), head: noone, snd: snd_text },
                { texto: scr_loc_src("¡Mira cómo se mueven!"), head: spr_bbs_prota_head, snd: snd_noelle }
            ];
            
            array_push(_datos_batalla.enemigos, {
                nombre: scr_loc_src("Toby A"),
                sprite: spr_enemigo_1,
                escala_sprite: 1.5,
                vida_max: 30,
                vida_actual: 30,
                ataque: 2,
                defensa: 0,
                descripcion: scr_loc_src("El primer Toby de la banda."),
                texto_inicio: scr_loc_src("Una pandilla de monstruos salvajes aparece!"),
                texto_muerte: scr_loc_src("* Acabaste con Toby A.")
            });
            
            array_push(_datos_batalla.enemigos, {
                nombre: scr_loc_src("Slime Verdoso"),
                sprite: spr_enemigo_2,
                escala_sprite: 1.0,
                vida_max: 15,
                vida_actual: 15,
                ataque: 1,
                defensa: 1,
                descripcion: scr_loc_src("Un pequeño monstruo gelatinoso."),
                texto_muerte: scr_loc_src("* Derrotaste al Slime Verdoso.")
            });
            
            array_push(_datos_batalla.enemigos, {
                nombre: scr_loc_src("Toby B"),
                sprite: spr_enemigo_1,
                escala_sprite: 1.5,
                vida_max: 30,
                vida_actual: 30,
                ataque: 2,
                defensa: 0,
                descripcion: scr_loc_src("El segundo Toby de refuerzo."),
                texto_muerte: scr_loc_src("* Acabaste con Toby B.")
            });
            
            break;
            
            
        // =========================================================
        // DEFAULT
        // =========================================================
        
        default:
            
            _datos_batalla.musica = mus_battle_1;
            _datos_batalla.fondo = noone;
            _datos_batalla.experiencia = 0;
            _datos_batalla.suenos = 100; // <-- Cambia aquí los SO que entrega esta batalla
            _datos_batalla.probabilidad_escapar = 0.5;
            
            array_push(_datos_batalla.enemigos, {
                nombre: scr_loc_src("Desconocido"),
                sprite: spr_enemigo_1,
                escala_sprite: 2.0,
                vida_max: 10,
                vida_actual: 10,
                ataque: 1,
                defensa: 0,
                descripcion: scr_loc_src("Un error en la matrix."),
                texto_inicio: scr_loc_src("Algo extraño emerge de la oscuridad..."),
                texto_muerte: scr_loc_src("* El enemigo desconocido se desvanece.")
            });
            
            break;
    }
    
    return _datos_batalla;
}
