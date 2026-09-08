// =========================================================
// EVENTO: CREAR
// =========================================================
enum FASE_BATALLA {
    INICIO,
    JUGADOR_MENU,
    JUGADOR_ACCION,
    ENEMIGO_TURNO,
    ENEMIGO_ATACANDO,
    CINEMATICA,
    VICTORIA,
    DERROTA,
    HUIR
}
 
fase_actual = FASE_BATALLA.INICIO;
 
if (!variable_global_exists("enemigo_actual_id")) {
    global.enemigo_actual_id = "variante 1";
}
 
var _datos_variante = scr_enemigos_data(global.enemigo_actual_id);

enemigos = _datos_variante.enemigos;

// Música base definida por la batalla.
// musica_batalla_actual puede convertirse después en un ID de instancia
// si una cinemática interna cambia la canción.
musica_batalla_asset_base = _datos_variante.musica;
musica_batalla_actual = _datos_variante.musica;

dialogos_turno_actual = _datos_variante.dialogos_turno;

experiencia_batalla =
    variable_struct_exists(_datos_variante, "experiencia")
    ? max(0, round(_datos_variante.experiencia))
    : 0;

suenos_batalla =
    variable_struct_exists(_datos_variante, "suenos")
    ? max(0, round(_datos_variante.suenos))
    : 0;

fondo_batalla =
    variable_struct_exists(_datos_variante, "fondo")
    ? _datos_variante.fondo
    : noone;

cinematicas =
    variable_struct_exists(_datos_variante, "cinematicas")
    ? _datos_variante.cinematicas
    : [];
 
show_debug_message("[CINEMATICAS] enemigo_actual_id=" + string(global.enemigo_actual_id) + " -> cinematicas cargadas: " + string(array_length(cinematicas)));
 
// SISTEMA DE PROBABILIDAD DE ESCAPE
probabilidad_escapar = variable_struct_exists(_datos_variante, "probabilidad_escapar") ? _datos_variante.probabilidad_escapar : 0.5;
exito_escape_turno = (random(1.0) < probabilidad_escapar);
 
victoria_finalizada = false;
 
primer_turno_pasado = false;
mapa_enemigos_muertos = scr_inicializar_muertes_enemigos(enemigos);
 
if (audio_exists(musica_batalla_actual)) {
    var _snd_batalla = audio_play_sound(musica_batalla_actual, 10, true);
    audio_resume_sound(_snd_batalla);
}
 
turno_enemigo_idx = 0;
temporizador_turno_enemigo = 0;
esperando_input_texto_enemigo = false;


// =========================================================
// NÚMERO DE TURNO DE BATALLA
// =========================================================
//
// turno_batalla = 1:
//     primer turno del jugador.
//
// Aumenta cuando TODOS los enemigos ya terminaron su ronda
// y el control vuelve al jugador.
//
// Se utiliza también para activar cinemáticas por turno.
// =========================================================

turno_batalla = 1;


// =========================================================
// PARRY DE ARMAS
// =========================================================
//
// El propio obj_batalla_controller controla TODO el parry:
// estado, input, resultado y dibujo.
//
// Ya NO depende de obj_batalla_parry.
//
// Cualquier arma puede activar esta mecánica con:
//
//     permite_parry: true
//
// La Raqueta Tenis se reconoce además directamente por su ID:
//
//     "raqueta_tenis"
//
// para que el parry no falle aunque equip_db se haya quedado
// temporalmente desincronizado durante una transición.
// =========================================================

parry_waiting = false;
parry_pending_enemy_idx = -1;
parry_pending_damage = 0;
parry_pending_enemy_name = "";
parry_weapon_id = -1;

// Estado visual/lógico del aro.
parry_resolved = false;
parry_success = false;
parry_result_timer = 0;
parry_result_hold_frames = 6;
parry_input_lock = 0;

// =========================================================
// ANIMACIÓN VISUAL DEL PARRY
// =========================================================
//
// La diana entra muy pequeña, crece hasta su tamaño final y
// SOLO entonces empieza a encogerse el aro.
//
// Al terminar, toda la diana se vuelve a hacer pequeña antes
// de desaparecer.
// =========================================================

parry_visual_factor = 0;
parry_intro_finished = false;

// 128x128 * 0.60 = 76.8x76.8 px en Draw GUI.
parry_diana_final_scale = 0.60;

// Velocidad de la animación de aparición/desaparición.
parry_intro_speed = 0.18;
parry_outro_speed = 0.20;

// spr_diana y spr_diana_aro son 128x128.
//
// Ahora hay DOS aros visibles al mismo tiempo.
// El primero empieza justo en el borde de la diana y el
// segundo un poco más afuera. Ambos se encogen a la vez.
//
// Para bloquear el ataque hay que acertar LOS DOS.
parry_ring_source_radius_px = 64;

parry_ring_1_radius_px = 64;
parry_ring_2_start_radius_px = 88;
parry_ring_2_radius_px = parry_ring_2_start_radius_px;

parry_ring_1_hit = false;
parry_ring_2_hit = false;

// 1 = estamos esperando acertar el primer aro.
// 2 = el primero ya fue acertado y esperamos el segundo.
parry_ring_target = 1;

// Ventana válida para CADA aro:
//     > 1 px y <= 14 px desde el centro.
//
// El centro de la diana mide 2x2, por lo que ocupa un radio
// de 1 px desde el punto central. Si el aro que toca acertar
// llega a ese centro, TODO el parry falla.
parry_valid_radius_px = 14;
parry_center_fail_radius_px = 1;

// Velocidad de ambos aros.
parry_ring_shrink_speed_px = 3.5;


// Asegurar bases persistentes.
scr_inventarios_data();
scr_equips_data();


// ---------------------------------------------------------
// OBTENER STRUCT DE ARMA
// ---------------------------------------------------------

f_parry_get_weapon = function(_value)
{
    if (is_struct(_value))
    {
        return _value;
    }

    if (
        is_string(_value)
        &&
        variable_global_exists("equip_db")
        &&
        is_struct(global.equip_db)
        &&
        variable_struct_exists(global.equip_db, _value)
    )
    {
        return variable_struct_get(global.equip_db, _value);
    }

    return undefined;
};


// ---------------------------------------------------------
// ¿ESTE VALOR REPRESENTA UN ARMA CON PARRY?
// ---------------------------------------------------------

f_parry_weapon_is_valid = function(_value)
{
    // Caso más importante: la Raqueta por ID.
    // No depende de que equip_db haya sido refrescado todavía.
    if (is_string(_value) && _value == "raqueta_tenis")
    {
        return true;
    }

    var _weapon = f_parry_get_weapon(_value);

    if (!is_struct(_weapon))
    {
        return false;
    }

    if (
        variable_struct_exists(_weapon, "tipo")
        &&
        _weapon.tipo != "arma"
    )
    {
        return false;
    }

    // Cualquier arma futura con permite_parry=true.
    if (
        variable_struct_exists(_weapon, "permite_parry")
        &&
        _weapon.permite_parry
    )
    {
        return true;
    }

    // Respaldo para una Raqueta guardada como struct antiguo.
    if (
        variable_struct_exists(_weapon, "nombre")
        &&
        string(_weapon.nombre) == "Raqueta Tenis"
    )
    {
        return true;
    }

    return false;
};


// ---------------------------------------------------------
// ENCONTRAR EL ARMA EQUIPADA REAL
// ---------------------------------------------------------

f_player_can_parry = function()
{
    parry_weapon_id = -1;

    var _candidate_player = -1;
    var _candidate_inventory = -1;
    var _candidate_global = -1;

    var _p = noone;

    if (instance_exists(obj_player))
    {
        _p = instance_find(obj_player, 0);

        if (
            _p != noone
            &&
            variable_instance_exists(_p, "equipo_arma")
        )
        {
            _candidate_player = _p.equipo_arma;
        }
    }

    if (
        variable_global_exists("inventory_data")
        &&
        is_struct(global.inventory_data)
        &&
        variable_struct_exists(global.inventory_data, "equipado_arma")
    )
    {
        _candidate_inventory = global.inventory_data.equipado_arma;
    }

    if (variable_global_exists("equipped_arma"))
    {
        _candidate_global = global.equipped_arma;
    }


    var _equipped = -1;

    if (f_parry_weapon_is_valid(_candidate_player))
    {
        _equipped = _candidate_player;
    }
    else if (f_parry_weapon_is_valid(_candidate_inventory))
    {
        _equipped = _candidate_inventory;
    }
    else if (f_parry_weapon_is_valid(_candidate_global))
    {
        _equipped = _candidate_global;
    }
    else
    {
        return false;
    }


    parry_weapon_id = _equipped;


    // Resincronizar fuentes cuando el valor es un ID válido.
    // Si fuera un struct, no forzamos una conversión extraña.
    if (is_string(_equipped))
    {
        if (
            _p != noone
            &&
            variable_instance_exists(_p, "equipo_arma")
        )
        {
            _p.equipo_arma = _equipped;
        }

        if (
            variable_global_exists("inventory_data")
            &&
            is_struct(global.inventory_data)
        )
        {
            global.inventory_data.equipado_arma = _equipped;
        }

        global.equipped_arma = _equipped;
    }


    return true;
};


// ---------------------------------------------------------
// INICIAR PARRY
// ---------------------------------------------------------

f_parry_start = function(_enemy_idx, _damage, _enemy_name)
{
    parry_waiting = true;

    parry_pending_enemy_idx = _enemy_idx;
    parry_pending_damage = max(0, _damage);
    parry_pending_enemy_name = _enemy_name;

    parry_ring_1_radius_px = parry_ring_source_radius_px;
    parry_ring_2_radius_px = parry_ring_2_start_radius_px;

    parry_ring_1_hit = false;
    parry_ring_2_hit = false;
    parry_ring_target = 1;

    parry_resolved = false;
    parry_success = false;
    parry_result_timer = 0;

    // La diana aparece primero diminuta y crece.
    // El aro NO empieza a encogerse durante esta animación.
    parry_visual_factor = 0.08;
    parry_intro_finished = false;

    // El bloqueo real se aplica cuando termina la entrada.
    parry_input_lock = 0;

    keyboard_clear(ord("Z"));
    keyboard_clear(vk_enter);

    if (instance_exists(obj_batalla_ui))
    {
        obj_batalla_ui.en_resultado_ataque = false;
        obj_batalla_ui.en_menu_fight = false;
        obj_batalla_ui.en_seleccion_enemigo = false;

        if (variable_instance_exists(obj_batalla_ui, "en_menu_act"))
            obj_batalla_ui.en_menu_act = false;

        if (variable_instance_exists(obj_batalla_ui, "en_menu_item"))
            obj_batalla_ui.en_menu_item = false;

        if (variable_instance_exists(obj_batalla_ui, "en_menu_mercy"))
            obj_batalla_ui.en_menu_mercy = false;

        obj_batalla_ui.f_procesar_dialogo("");
    }

    fase_actual = FASE_BATALLA.CINEMATICA;
};


// ---------------------------------------------------------
// RESOLVER EL INPUT DEL PARRY
// ---------------------------------------------------------

f_parry_resolve = function(_success)
{
    if (parry_resolved)
    {
        return;
    }

    parry_resolved = true;
    parry_success = _success;
    parry_result_timer = parry_result_hold_frames;

    // El sonido de acierto se reproduce al acertar CADA aro,
    // no aquí, para que se escuchen claramente los dos golpes.
};


// VARIABLES CONTROL CINEMÁTICA
cinematica_activa = false;
cinematica_dialogos = [];
cinematica_idx = 0;
cinematica_terminar_batalla = false;
fase_pre_cinematica = FASE_BATALLA.INICIO;


// =========================================================
// VERIFICAR CINEMÁTICAS DE BATALLA
// =========================================================
//
// Una entrada puede activarse mediante:
//
//     vida: 10
//
// o mediante:
//
//     porcentaje_vida: 0.50
//
// o mediante:
//
//     turno: 3
//
// Si una entrada incluye VARIAS condiciones, cualquiera de
// ellas puede dispararla.
//
// OPCIONAL:
//
//     nuevo_sprite: spr_mi_sprite
//
// cambia el sprite del enemigo indicado justo antes de que
// comience la cinemática.
//
// También puede usarse:
//
//     nueva_escala_sprite: 2.0
//
// =========================================================

f_verificar_cinematicas = function()
{
    if (array_length(cinematicas) <= 0)
    {
        return false;
    }


    for (var i = 0; i < array_length(cinematicas); i++)
    {
        var _cin =
            cinematicas[i];


        if (
            variable_struct_exists(
                _cin,
                "activada"
            )
            &&
            _cin.activada
        )
        {
            continue;
        }


        var _en_idx =
            variable_struct_exists(
                _cin,
                "enemigo"
            )
            ?
            round(_cin.enemigo)
            :
            0;


        if (
            _en_idx < 0
            ||
            _en_idx >= array_length(enemigos)
        )
        {
            continue;
        }


        var _en =
            enemigos[_en_idx];


        // Una cinemática perteneciente a un enemigo no debe
        // iniciarse después de que ese enemigo ya murió.
        if (_en.vida_actual <= 0)
        {
            continue;
        }


        var _pct_hp =
            _en.vida_actual
            /
            max(
                1,
                _en.vida_max
            );


        var _tiene_vida_absoluta =
            variable_struct_exists(
                _cin,
                "vida"
            );


        var _tiene_vida =
            variable_struct_exists(
                _cin,
                "porcentaje_vida"
            );


        var _tiene_turno =
            variable_struct_exists(
                _cin,
                "turno"
            );


        // Una entrada sin ninguna condición no se dispara.
        if (
            !_tiene_vida_absoluta
            &&
            !_tiene_vida
            &&
            !_tiene_turno
        )
        {
            continue;
        }


        var _cumple_vida_absoluta =
            false;


        if (_tiene_vida_absoluta)
        {
            _cumple_vida_absoluta =
                _en.vida_actual
                <=
                max(
                    0,
                    round(
                        _cin.vida
                    )
                );
        }


        var _cumple_vida =
            false;


        if (_tiene_vida)
        {
            _cumple_vida =
                _pct_hp
                <=
                clamp(
                    _cin.porcentaje_vida,
                    0,
                    1
                );
        }


        var _cumple_turno =
            false;


        if (_tiene_turno)
        {
            _cumple_turno =
                turno_batalla
                >=
                max(
                    1,
                    round(
                        _cin.turno
                    )
                );
        }


        if (
            !_cumple_vida_absoluta
            &&
            !_cumple_vida
            &&
            !_cumple_turno
        )
        {
            continue;
        }


        // =================================================
        // MARCAR COMO ACTIVADA
        // =================================================

        _cin.activada =
            true;

        cinematicas[i] =
            _cin;


        // =================================================
        // CAMBIAR SPRITE DEL ENEMIGO
        // =================================================

        if (
            variable_struct_exists(
                _cin,
                "nuevo_sprite"
            )
            &&
            _cin.nuevo_sprite != noone
            &&
            sprite_exists(
                _cin.nuevo_sprite
            )
        )
        {
            _en.sprite =
                _cin.nuevo_sprite;


            _en.anim_index =
                0;
        }


        if (
            variable_struct_exists(
                _cin,
                "nueva_escala_sprite"
            )
        )
        {
            _en.escala_sprite =
                max(
                    0.01,
                    _cin.nueva_escala_sprite
                );
        }


        var _motivo =
            "";


        if (_cumple_vida_absoluta)
        {
            _motivo =
                string(
                    round(
                        _en.vida_actual
                    )
                )
                +
                " HP";
        }
        else if (_cumple_vida)
        {
            _motivo =
                string(
                    round(
                        _pct_hp * 100
                    )
                )
                +
                "% de vida";
        }
        else
        {
            _motivo =
                "turno "
                +
                string(
                    turno_batalla
                );
        }


        var _cin_id =
            variable_struct_exists(
                _cin,
                "id"
            )
            ?
            _cin.id
            :
            "";


        show_debug_message(
            "[CINEMATICAS] Activando '"
            +
            string(_cin_id)
            +
            "' -> enemigo "
            +
            string(_en_idx)
            +
            " por "
            +
            _motivo
        );


        var _dialogos =
            [];


        if (
            is_string(_cin_id)
            &&
            _cin_id != ""
        )
        {
            _dialogos =
                scr_bosses_cinematica_bbs(
                    _cin_id
                );
        }


        // Se permite usar una entrada únicamente para cambiar
        // sprite aunque el ID no tenga diálogos.
        if (array_length(_dialogos) <= 0)
        {
            continue;
        }


        cinematica_activa =
            true;

        cinematica_dialogos =
            _dialogos;

        cinematica_idx =
            0;

        cinematica_terminar_batalla =
            variable_struct_exists(
                _cin,
                "terminar_batalla"
            )
            ?
            _cin.terminar_batalla
            :
            false;


        fase_pre_cinematica =
            fase_actual;

        fase_actual =
            FASE_BATALLA.CINEMATICA;


        if (instance_exists(obj_batalla_ui))
        {
            obj_batalla_ui.en_resultado_ataque =
                false;

            obj_batalla_ui.en_menu_fight =
                false;

            obj_batalla_ui.en_seleccion_enemigo =
                false;


            if (
                variable_instance_exists(
                    obj_batalla_ui,
                    "en_menu_act"
                )
            )
            {
                obj_batalla_ui.en_menu_act =
                    false;
            }


            if (
                variable_instance_exists(
                    obj_batalla_ui,
                    "en_menu_item"
                )
            )
            {
                obj_batalla_ui.en_menu_item =
                    false;
            }


            if (
                variable_instance_exists(
                    obj_batalla_ui,
                    "en_menu_mercy"
                )
            )
            {
                obj_batalla_ui.en_menu_mercy =
                    false;
            }


            // Primer diálogo.
            obj_batalla_ui.f_procesar_dialogo(
                cinematica_dialogos[0]
            );


            obj_batalla_ui.draw_char =
                0;

            obj_batalla_ui.setup =
                false;
        }


        return true;
    }


    return false;
};


// =========================================================
// DUCKING DE MÚSICA CUANDO SUENA CUALQUIER snd_
// =========================================================
//
// 0.86 = la música baja un poco mientras suena un SFX.
// Puedes acercarlo a 1.0 si lo quieres todavía más sutil.
// =========================================================

duck_music_gain = 0.86;
duck_snd_assets = [];

var _audio_assets = asset_get_ids(asset_sound);

for (var _a = 0; _a < array_length(_audio_assets); _a++)
{
    var _asset_audio = _audio_assets[_a];
    var _audio_name = audio_get_name(_asset_audio);

    if (string_copy(_audio_name, 1, 4) == "snd_")
    {
        array_push(
            duck_snd_assets,
            _asset_audio
        );
    }
}
