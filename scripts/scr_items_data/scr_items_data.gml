function scr_item_db() {
    global.item_db = {
        agua: {
            nombre: scr_loc_src("Vaso de Agua"),
            descripcion: scr_loc_src("Ayuda a hidratarte"),
            tipo: "consumible",
            efecto: function() {
                var _p = obj_player;
                if (instance_exists(_p)) {
                    _p.hp = min(_p.hp_max, _p.hp + 10);
                }
				audio_play_sound(snd_health, 10, false);
            },
            icono: -1 
        },
        manzana: {
            nombre: scr_loc_src("Manzana"),
            descripcion: scr_loc_src("Rica y crujiente"),
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
