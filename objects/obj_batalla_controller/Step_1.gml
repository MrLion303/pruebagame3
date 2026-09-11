/// =========================================================
/// OBJ_BATALLA_CONTROLLER
/// BEGIN STEP - NUEVO EVENTO
/// =========================================================
///
/// Añade este código creando un evento:
///
///     Step > Begin Step
///
/// NO reemplaza el Step normal del controller.
///
/// Este evento implementa la reducción de precisión causada
/// por Toys sin interferir con el flujo actual de ataques,
/// stun, parry o cinemáticas.
/// =========================================================


// =========================================================
// SEGURIDAD
// =========================================================

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


// Solo interesa justo antes de procesar el turno enemigo.
if (fase_actual != FASE_BATALLA.ENEMIGO_TURNO)
{
    exit;
}


var _total_en =
    array_length(enemigos);


if (
    turno_enemigo_idx < 0
    ||
    turno_enemigo_idx >= _total_en
)
{
    exit;
}


var _en =
    enemigos[turno_enemigo_idx];


if (!is_struct(_en))
{
    exit;
}


// Un enemigo muerto será saltado normalmente por el Step.
if (
    variable_struct_exists(_en, "vida_actual")
    &&
    _en.vida_actual <= 0
)
{
    exit;
}


// =========================================================
// EL STUN EXISTENTE TIENE PRIORIDAD
// =========================================================
//
// Si está aturdido, dejamos que el Step normal consuma el
// stun y NO hacemos una tirada de precisión ese turno.
// =========================================================

if (
    variable_struct_exists(_en, "turnos_stun")
    &&
    _en.turnos_stun > 0
)
{
    exit;
}


// =========================================================
// PRECISIÓN REDUCIDA
// =========================================================

var _precision_down =
    variable_struct_exists(_en, "precision_reducida")
    ?
    clamp(_en.precision_reducida, 0, 0.95)
    :
    0;


if (_precision_down <= 0)
{
    exit;
}


// =========================================================
// EVITAR MÁS DE UNA TIRADA EN EL MISMO TURNO
// =========================================================
//
// turno_batalla identifica la ronda completa.
// Guardamos también el índice del enemigo para que varios
// enemigos puedan tirar precisión durante la misma ronda.
// =========================================================

if (!variable_struct_exists(_en, "precision_ultimo_turno"))
{
    _en.precision_ultimo_turno =
        -1;
}


if (
    _en.precision_ultimo_turno
    ==
    turno_batalla
)
{
    exit;
}


_en.precision_ultimo_turno =
    turno_batalla;


// =========================================================
// TIRADA DE FALLO
// =========================================================

var _fallo_por_precision =
    random(1.0)
    <
    _precision_down;


if (!_fallo_por_precision)
{
    exit;
}


// =========================================================
// ATAQUE FALLIDO
// =========================================================
//
// Cambiamos a ENEMIGO_ATACANDO ANTES del Step normal.
// De esta manera el ataque real, su daño y el parry NO se
// ejecutan. La UI conserva el mismo flujo de confirmación.
// =========================================================

if (instance_exists(obj_batalla_ui))
{
    obj_batalla_ui.en_resultado_ataque =
        true;


    obj_batalla_ui.f_procesar_dialogo(
        scr_locf(
            "* {enemy} intenta atacar, ¡pero falla!",
            {
                enemy:
                    scr_loc(
                        _en.nombre
                    )
            }
        )
    );
}


fase_actual =
    FASE_BATALLA.ENEMIGO_ATACANDO;
