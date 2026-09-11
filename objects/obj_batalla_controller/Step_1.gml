/// =========================================================
/// OBJ_BATALLA_CONTROLLER
/// BEGIN STEP COMPLETO
/// =========================================================
/// Toys enemigos + guardia + precisión + pérdida de turno.
/// =========================================================

if (
    room == game_over
    ||
    !variable_instance_exists(id, "fase_actual")
    ||
    !variable_instance_exists(id, "enemigos")
)
{
    exit;
}

scr_battle_runtime_ensure(id);


// Crear automáticamente el gestor modular de ataques.
if (
    room == bbs
    &&
    !instance_exists(obj_batalla_attack_mods)
)
{
    instance_create_depth(
        0,
        0,
        -10000010,
        obj_batalla_attack_mods
    );
}


// =========================================================
// TOY ENEMIGO: EL JUGADOR PIERDE SU TURNO
// =========================================================
// ENEMIGO_ATACANDO espera el texto y luego hace:
// turno_enemigo_idx++.
// Dejamos el índice en -1 para que pase exactamente a 0.
// =========================================================

if (
    fase_actual == FASE_BATALLA.JUGADOR_MENU
    &&
    player_turnos_stun > 0
)
{
    player_turnos_stun--;
    turno_enemigo_idx = -1;

    if (instance_exists(obj_batalla_ui))
    {
        obj_batalla_ui.en_resultado_ataque = true;

        obj_batalla_ui.f_procesar_dialogo(
            scr_loc_src(
                "* El Toy enemigo te inmoviliza. ¡Pierdes este turno!"
            )
        );
    }

    fase_actual = FASE_BATALLA.ENEMIGO_ATACANDO;
    exit;
}


// Lo demás solo aplica al turno enemigo.
if (fase_actual != FASE_BATALLA.ENEMIGO_TURNO)
    exit;


var _total_en = array_length(enemigos);

if (
    turno_enemigo_idx < 0
    ||
    turno_enemigo_idx >= _total_en
)
{
    exit;
}


var _en = enemigos[turno_enemigo_idx];

if (!is_struct(_en))
    exit;

if (
    variable_struct_exists(_en, "vida_actual")
    &&
    _en.vida_actual <= 0
)
{
    exit;
}


// =========================================================
// RUNTIME DEL ENEMIGO
// =========================================================

if (!variable_struct_exists(_en, "ataque_base_runtime"))
{
    _en.ataque_base_runtime =
        variable_struct_exists(_en, "ataque")
        ? _en.ataque
        : 0;
}

if (!variable_struct_exists(_en, "guardia_activa"))
    _en.guardia_activa = false;

if (!variable_struct_exists(_en, "guardia_expira_turno"))
    _en.guardia_expira_turno = -1;

if (!variable_struct_exists(_en, "guardia_multiplicador"))
    _en.guardia_multiplicador = 1;


// La guardia dura exactamente el siguiente turno del jugador.
// Se elimina cuando comienza nuevamente el turno de este enemigo.
if (
    _en.guardia_activa
    &&
    _en.guardia_expira_turno >= 0
    &&
    turno_batalla >= _en.guardia_expira_turno
)
{
    _en.guardia_activa = false;
    _en.guardia_multiplicador = 1;
}


// DEF down del jugador.
// Reconstruimos desde ataque_base_runtime para no acumular.
_en.ataque =
    max(
        0,
        round(
            _en.ataque_base_runtime
            *
            scr_battle_player_received_damage_multiplier(id)
        )
    );


// Stun del enemigo tiene prioridad. El Step normal lo consume.
if (
    variable_struct_exists(_en, "turnos_stun")
    &&
    _en.turnos_stun > 0
)
{
    exit;
}


// =========================================================
// TABLA DE ACCIONES ESPECIALES
// =========================================================

var _puede_guardia =
    variable_struct_exists(_en, "puede_guardia")
    ? _en.puede_guardia
    : false;

var _prob_guardia =
    _puede_guardia
    ? clamp(
        variable_struct_exists(_en, "probabilidad_guardia")
        ? _en.probabilidad_guardia
        : 0,
        0,
        0.95
    )
    : 0;

var _puede_toys =
    variable_struct_exists(_en, "puede_usar_toys")
    ? _en.puede_usar_toys
    : false;

var _toys_disponibles =
    (
        variable_struct_exists(_en, "toys_disponibles")
        &&
        is_array(_en.toys_disponibles)
    )
    ? _en.toys_disponibles
    : [];

var _prob_toy =
    (
        _puede_toys
        &&
        array_length(_toys_disponibles) > 0
    )
    ? clamp(
        variable_struct_exists(_en, "probabilidad_toy")
        ? _en.probabilidad_toy
        : 0,
        0,
        0.95
    )
    : 0;


// Conservar al menos 5% de ataque normal.
var _total_especial = _prob_guardia + _prob_toy;

if (_total_especial > 0.95)
{
    var _escala_prob = 0.95 / _total_especial;
    _prob_guardia *= _escala_prob;
    _prob_toy *= _escala_prob;
}


var _accion_roll = random(1.0);


// =========================================================
// GUARDIA
// =========================================================

if (
    _prob_guardia > 0
    &&
    _accion_roll < _prob_guardia
)
{
    var _reduccion_guardia =
        clamp(
            variable_struct_exists(_en, "guardia_reduccion")
            ? _en.guardia_reduccion
            : 0.50,
            0,
            0.95
        );

    _en.guardia_activa = true;
    _en.guardia_multiplicador = 1 - _reduccion_guardia;
    _en.guardia_expira_turno = turno_batalla + 1;

    if (instance_exists(obj_batalla_ui))
    {
        obj_batalla_ui.en_resultado_ataque = true;

        obj_batalla_ui.f_procesar_dialogo(
            scr_locf(
                "* {enemy} entra en guardia y recibirá menos daño durante tu próximo turno.",
                {
                    enemy: scr_loc(_en.nombre)
                }
            )
        );
    }

    fase_actual = FASE_BATALLA.ENEMIGO_ATACANDO;
    exit;
}


// =========================================================
// TOY ENEMIGO
// =========================================================

if (
    _prob_toy > 0
    &&
    _accion_roll < (_prob_guardia + _prob_toy)
)
{
    var _toy_id =
        _toys_disponibles[
            irandom(array_length(_toys_disponibles) - 1)
        ];

    var _texto_toy =
        scr_enemy_toy_apply(
            id,
            _toy_id,
            scr_loc(_en.nombre)
        );

    if (instance_exists(obj_batalla_ui))
    {
        obj_batalla_ui.en_resultado_ataque = true;
        obj_batalla_ui.f_procesar_dialogo(_texto_toy);
    }

    fase_actual = FASE_BATALLA.ENEMIGO_ATACANDO;
    exit;
}


// =========================================================
// PRECISIÓN REDUCIDA DEL ENEMIGO
// =========================================================
// Mantiene el sistema que ya existía en el repositorio.
// =========================================================

var _precision_down =
    variable_struct_exists(_en, "precision_reducida")
    ? clamp(_en.precision_reducida, 0, 0.95)
    : 0;

if (_precision_down <= 0)
    exit;

if (!variable_struct_exists(_en, "precision_ultimo_turno"))
    _en.precision_ultimo_turno = -1;

if (_en.precision_ultimo_turno == turno_batalla)
    exit;

_en.precision_ultimo_turno = turno_batalla;

if (random(1.0) >= _precision_down)
    exit;


// Falló: no hay daño ni parry.
if (instance_exists(obj_batalla_ui))
{
    obj_batalla_ui.en_resultado_ataque = true;

    obj_batalla_ui.f_procesar_dialogo(
        scr_locf(
            "* {enemy} intenta atacar, ¡pero falla!",
            {
                enemy: scr_loc(_en.nombre)
            }
        )
    );
}

fase_actual = FASE_BATALLA.ENEMIGO_ATACANDO;
