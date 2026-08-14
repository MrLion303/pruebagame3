function scr_item_db() {
    global.item_db = {
        agua: {
            nombre: "Vaso de Agua",
            descripcion: "Ayuda a hidratarte",
            tipo: "consumible",
            efecto: function() {
                var _p = obj_player;
                if (instance_exists(_p)) {
                    _p.hp = min(_p.hp_max, _p.hp + 1);
                }
				audio_play_sound(snd_health, 10, false);
            },
            icono: -1 
        },
        manzana: {
            nombre: "Manzana",
            descripcion: "Rica y crujiente",
            tipo: "consumible",
            efecto: function() {
                var _p = obj_player;
                if (instance_exists(_p)) {
                    _p.hp = min(_p.hp_max, _p.hp + 20);
                }
				audio_play_sound(snd_health, 10, false);
            },
            icono: -1
        }
    };
}