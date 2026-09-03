/// =========================================================
/// SCR_SAVE_SYSTEM
/// =========================================================



// =========================================================
// OBTENER MÚSICA ACTUAL
// =========================================================
//
// Solamente considera recursos cuyo nombre comience
// exactamente por:
//
// mus_
//
// Devuelve, por ejemplo:
//
// "mus_jevil"
//
// Si no hay música:
//
// ""
//
// =========================================================

function scr_save_get_current_music()
{
    var _sounds =
        asset_get_ids(asset_sound);


    for (
        var i = 0;
        i < array_length(_sounds);
        i++
    )
    {
        var _sound =
            _sounds[i];


        if (!audio_exists(_sound))
        {
            continue;
        }


        var _name =
            audio_get_name(_sound);


        if (
            string_starts_with(
                _name,
                "mus_"
            )
        )
        {
            if (
                audio_is_playing(_sound)
                ||
                audio_is_paused(_sound)
            )
            {
                return _name;
            }
        }
    }


    return "";
}



// =========================================================
// DETENER TODAS LAS MÚSICAS mus_
// =========================================================

function scr_save_stop_all_music()
{
    var _sounds =
        asset_get_ids(asset_sound);


    for (
        var i = 0;
        i < array_length(_sounds);
        i++
    )
    {
        var _sound =
            _sounds[i];


        if (!audio_exists(_sound))
        {
            continue;
        }


        var _name =
            audio_get_name(_sound);


        if (
            string_starts_with(
                _name,
                "mus_"
            )
        )
        {
            if (
                audio_is_playing(_sound)
                ||
                audio_is_paused(_sound)
            )
            {
                audio_stop_sound(
                    _sound
                );
            }
        }
    }
}



// =========================================================
// RESTAURAR MÚSICA DE UN SAVE
// =========================================================

function scr_save_restore_music(_music_name)
{
    // Solamente controlamos música mus_.
    scr_save_stop_all_music();


    // Guardado realizado mientras había silencio.
    if (
        !is_string(_music_name)
        ||
        _music_name == ""
    )
    {
        return;
    }


    // Seguridad: nunca reproducir algo que no sea mus_.
    if (
        !string_starts_with(
            _music_name,
            "mus_"
        )
    )
    {
        return;
    }


    var _music =
        asset_get_index(
            _music_name
        );


    if (
        _music != -1
        &&
        audio_exists(_music)
    )
    {
        audio_play_sound(
            _music,
            10,
            true
        );
    }
}



// =========================================================
// GUARDAR
// =========================================================

function scr_guardar_juego(_seccion)
{
    // =====================================================
    // ASEGURAR SISTEMAS
    // =====================================================

    scr_level_data();

    scr_inventarios_data();

    scr_config_data();

    scr_cofre_init();

    scr_cutscene_flags_init();


    // =====================================================
    // SINCRONIZAR
    // =====================================================

    scr_config_sync();

    scr_inventarios_sync();


    // =====================================================
    // DATOS GENERALES
    // =====================================================

    var _px =
        0;


    var _py =
        0;


    var _proom =
        room;


    var _facing =
        2;


    // =====================================================
    // PLAYER
    // =====================================================

    if (instance_exists(obj_player))
    {
        // =================================================
        // CURAR AL MÁXIMO AL GUARDAR
        // =================================================

        if (
            variable_instance_exists(
                obj_player,
                "hp"
            )
            &&
            variable_instance_exists(
                obj_player,
                "hp_max"
            )
        )
        {
            obj_player.hp =
                obj_player.hp_max;


            global.player_hp_current =
                obj_player.hp;
        }


        // =================================================
        // POSICIÓN
        // =================================================

        _px =
            obj_player.x;


        _py =
            obj_player.y;


        _proom =
            room;


        if (
            variable_instance_exists(
                obj_player,
                "face"
            )
        )
        {
            _facing =
                obj_player.face;
        }


        // =================================================
        // NIVEL
        // =================================================

        global.level_data.nivel =
            obj_player.nivel;


        global.level_data.exp_actual =
            obj_player.exp_actual;


        global.level_data.exp_siguiente =
            obj_player.exp_siguiente;


        global.level_data.ataque_base =
            obj_player.ataque_base;


        global.level_data.defensa_base =
            obj_player.defensa_base;


        global.level_data.hp_max =
            obj_player.hp_max;


        // =================================================
        // INVENTARIO
        // =================================================

        global.inventory_data.consumibles =
            obj_player.inventory;


        global.inventory_data.equipado_arma =
            obj_player.equipo_arma;


        global.inventory_data.equipado_armadura =
            obj_player.equipo_armadura;
    }


    // =====================================================
    // MÚSICA
    // =====================================================

    var _music =
        scr_save_get_current_music();


    // =====================================================
    // DATOS EXTRA DEL SLOT
    // =====================================================

    var _save_data =
    {
        config:
            global.config_data,

        inventarios:
            global.inventory_data,

        nivel:
            global.level_data,

        cofre:
            global.chest_data,

        cutscene_flags:
            global.cutscene_flags,

        music:
            _music
    };


    // =====================================================
    // SERIALIZAR
    // =====================================================

    var _json_string =
        json_stringify(
            _save_data
        );


    var _base64_string =
        base64_encode(
            _json_string
        );


    // =====================================================
    // ESCRIBIR SAVE
    // =====================================================

    ini_open(
        "save.ini"
    );


    ini_write_real(
        _seccion,
        "room",
        _proom
    );


    ini_write_real(
        _seccion,
        "x",
        _px
    );


    ini_write_real(
        _seccion,
        "y",
        _py
    );


    ini_write_real(
        _seccion,
        "facing",
        _facing
    );


    if (
        !variable_global_exists(
            "playtime_frames"
        )
    )
    {
        global.playtime_frames =
            0;
    }


    ini_write_real(
        _seccion,
        "playtime",
        global.playtime_frames
    );


    ini_write_string(
        _seccion,
        "extra_data",
        _base64_string
    );


    ini_close();


    show_debug_message(
        "¡Juego guardado en "
        +
        _seccion
        +
        " con éxito!"
    );
}



// =========================================================
// CARGAR
// =========================================================

function scr_cargar_juego(_seccion)
{
    // =====================================================
    // COMPROBAR SAVE
    // =====================================================

    if (!file_exists("save.ini"))
    {
        return false;
    }


    // =====================================================
    // LEER INI
    // =====================================================

    ini_open(
        "save.ini"
    );


    var _extra =
        ini_read_string(
            _seccion,
            "extra_data",
            ""
        );


    var _facing =
        ini_read_real(
            _seccion,
            "facing",
            2
        );


    global.playtime_frames =
        ini_read_real(
            _seccion,
            "playtime",
            0
        );


    ini_close();


    if (_extra == "")
    {
        return false;
    }


    // =====================================================
    // DECODIFICAR
    // =====================================================

    var _json_string =
        base64_decode(
            _extra
        );


    var _save_data =
        json_parse(
            _json_string
        );


    if (!is_struct(_save_data))
    {
        return false;
    }


    // =====================================================
    // ASEGURAR SISTEMAS
    // =====================================================

    scr_config_data();

    scr_inventarios_data();

    scr_level_data();

    scr_cofre_init();

    scr_cutscene_flags_init();


    // =====================================================
    // CONFIG
    // =====================================================

    if (
        variable_struct_exists(
            _save_data,
            "config"
        )
        &&
        is_struct(
            _save_data.config
        )
    )
    {
        global.config_data =
            _save_data.config;
    }


    // Añade campos faltantes de saves antiguos.
    scr_config_data();


    // =====================================================
    // INVENTARIO
    // =====================================================

    if (
        variable_struct_exists(
            _save_data,
            "inventarios"
        )
        &&
        is_struct(
            _save_data.inventarios
        )
    )
    {
        global.inventory_data =
            _save_data.inventarios;
    }


    // =====================================================
    // NIVEL
    // =====================================================

    if (
        variable_struct_exists(
            _save_data,
            "nivel"
        )
        &&
        is_struct(
            _save_data.nivel
        )
    )
    {
        global.level_data =
            _save_data.nivel;
    }


    // =====================================================
    // COFRE
    // =====================================================

    global.chest_data =
        array_create(
            50,
            -1
        );


    if (
        variable_struct_exists(
            _save_data,
            "cofre"
        )
        &&
        is_array(
            _save_data.cofre
        )
    )
    {
        var _cofre_guardado =
            _save_data.cofre;


        var _copiar =
            min(
                50,
                array_length(
                    _cofre_guardado
                )
            );


        for (
            var i = 0;
            i < _copiar;
            i++
        )
        {
            global.chest_data[i] =
                _cofre_guardado[i];
        }
    }


    // =====================================================
    // CINEMÁTICAS VISTAS
    // =====================================================

    global.cutscene_flags =
        {};


    if (
        variable_struct_exists(
            _save_data,
            "cutscene_flags"
        )
        &&
        is_struct(
            _save_data.cutscene_flags
        )
    )
    {
        global.cutscene_flags =
            _save_data.cutscene_flags;
    }


    // =====================================================
    // RESTAURAR ALIAS DE INVENTARIOS
    // =====================================================

    if (
        variable_struct_exists(
            global.inventory_data,
            "toys"
        )
    )
    {
        global.toy_inventory =
            global.inventory_data.toys;
    }


    if (
        variable_struct_exists(
            global.inventory_data,
            "equipamiento"
        )
    )
    {
        global.equipment_inventory =
            global.inventory_data.equipamiento;
    }


    // =====================================================
    // EQUIPAMIENTO ACTUAL
    // =====================================================

    if (
        variable_struct_exists(
            global.inventory_data,
            "equipado_arma"
        )
    )
    {
        global.equipped_arma =
            global.inventory_data.equipado_arma;
    }


    if (
        variable_struct_exists(
            global.inventory_data,
            "equipado_armadura"
        )
    )
    {
        global.equipped_armadura =
            global.inventory_data.equipado_armadura;
    }


    // =====================================================
    // APLICAR CONFIG
    // =====================================================

    scr_config_apply();


    // =====================================================
    // DIRECCIÓN
    // =====================================================

    global.load_facing =
        _facing;


    // =====================================================
    // MÚSICA
    // =====================================================
    //
    // Saves viejos que no tengan "music" simplemente
    // mantienen el comportamiento anterior.
    // =====================================================

    if (
        variable_struct_exists(
            _save_data,
            "music"
        )
    )
    {
        if (is_string(_save_data.music))
        {
            scr_save_restore_music(
                _save_data.music
            );
        }
    }


    return true;
}



// =========================================================
// APLICAR DATOS CARGADOS AL PLAYER
// =========================================================

function scr_aplicar_datos_cargados(_jugador)
{
    // =====================================================
    // NIVEL
    // =====================================================

    _jugador.nivel =
        global.level_data.nivel;


    _jugador.exp_actual =
        global.level_data.exp_actual;


    _jugador.exp_siguiente =
        global.level_data.exp_siguiente;


    _jugador.ataque_base =
        global.level_data.ataque_base;


    _jugador.defensa_base =
        global.level_data.defensa_base;


    _jugador.hp_max =
        global.level_data.hp_max;


    // Como guardar cura por completo,
    // cargar comienza con HP completo.
    _jugador.hp =
        _jugador.hp_max;


    global.player_hp_current =
        _jugador.hp;


    // =====================================================
    // INVENTARIO
    // =====================================================

    _jugador.inventory =
        global.inventory_data.consumibles;


    _jugador.equipo_arma =
        global.inventory_data.equipado_arma;


    _jugador.equipo_armadura =
        global.inventory_data.equipado_armadura;


    global.equipped_arma =
        _jugador.equipo_arma;


    global.equipped_armadura =
        _jugador.equipo_armadura;


    // =====================================================
    // DIRECCIÓN
    // =====================================================

    if (
        variable_global_exists(
            "load_facing"
        )
    )
    {
        _jugador.facing_direction =
            global.load_facing;


        switch (global.load_facing)
        {
            // DERECHA
            case 0:

                _jugador.face =
                    RIGHT;


                _jugador.direccion =
                    "derecha";

                break;


            // IZQUIERDA
            case 1:

                _jugador.face =
                    LEFT;


                _jugador.direccion =
                    "izquierda";

                break;


            // ABAJO
            case 2:

                _jugador.face =
                    DOWN;


                _jugador.direccion =
                    "abajo";

                break;


            // ARRIBA
            case 3:

                _jugador.face =
                    UP;


                _jugador.direccion =
                    "arriba";

                break;
        }
    }
}
