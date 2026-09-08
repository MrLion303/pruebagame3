/// =========================================================
/// OBJ_ENEMIGO_MAPA_PARENT
/// CREATE
/// =========================================================
///
/// Parent universal para enemigos voladores del mapa.
/// NO tiene HP.
/// NO puede ser atacado.
/// NO inicia una batalla BBS.
/// =========================================================


// =========================================================
// ID DE CONFIGURACIÓN
// =========================================================
//
// Los objetos hijos lo establecen ANTES de llamar
// event_inherited().
//
// Si colocas directamente el parent, usa el enemigo directo
// como fallback.
// =========================================================

if (
    !variable_instance_exists(
        id,
        "enemigo_mapa_id"
    )
)
{
    enemigo_mapa_id =
        "volador_directo_01";
}


// =========================================================
// CARGAR DATOS
// =========================================================

datos_mapa =
    scr_enemigos_mapa_data(
        enemigo_mapa_id
    );


tipo_ataque =
    datos_mapa.tipo_ataque;


sprite_idle =
    datos_mapa.sprite_idle;


sprite_alerta =
    datos_mapa.sprite_alerta;


sprite_bala =
    datos_mapa.sprite_bala;


rango_ataque =
    datos_mapa.rango_ataque;


retraso_inicial =
    datos_mapa.retraso_inicial;


intervalo_ataque =
    datos_mapa.intervalo_ataque;


velocidad_bala =
    datos_mapa.velocidad_bala;


dano_bala =
    datos_mapa.dano_bala;


vida_bala_frames =
    datos_mapa.vida_bala_frames;


escala_bala =
    datos_mapa.escala_bala;


invulnerabilidad_frames =
    datos_mapa.invulnerabilidad_frames;


bala_homing =
    datos_mapa.bala_homing;


rotar_bala =
    datos_mapa.rotar_bala;


colisiona_paredes =
    datos_mapa.colisiona_paredes;


offset_bala_x =
    datos_mapa.offset_bala_x;


offset_bala_y =
    datos_mapa.offset_bala_y;


oscuridad =
    datos_mapa.oscuridad;




// =========================================================
// MOVIMIENTO DEL ENEMIGO
// =========================================================
//
// PRESETS DISPONIBLES EN scr_enemigos_mapa_data:
//
//     "ninguno"
//     "izquierda_derecha"
//     "arriba_abajo"
//     "circulo"
//     "continuo"
//
// Los enemigos son voladores, por lo que este movimiento
// no usa las colisiones del suelo del jugador.
// =========================================================

puede_moverse =
    variable_struct_exists(
        datos_mapa,
        "puede_moverse"
    )
    ?
    datos_mapa.puede_moverse
    :
    false;


movimiento_preset =
    variable_struct_exists(
        datos_mapa,
        "movimiento_preset"
    )
    ?
    datos_mapa.movimiento_preset
    :
    "ninguno";


movimiento_velocidad =
    variable_struct_exists(
        datos_mapa,
        "movimiento_velocidad"
    )
    ?
    max(
        0,
        datos_mapa.movimiento_velocidad
    )
    :
    0;


movimiento_distancia =
    variable_struct_exists(
        datos_mapa,
        "movimiento_distancia"
    )
    ?
    max(
        0,
        datos_mapa.movimiento_distancia
    )
    :
    64;


movimiento_radio =
    variable_struct_exists(
        datos_mapa,
        "movimiento_radio"
    )
    ?
    max(
        1,
        datos_mapa.movimiento_radio
    )
    :
    64;


movimiento_direccion =
    variable_struct_exists(
        datos_mapa,
        "movimiento_direccion"
    )
    ?
    datos_mapa.movimiento_direccion
    :
    "derecha";


movimiento_angulo =
    variable_struct_exists(
        datos_mapa,
        "movimiento_angulo"
    )
    ?
    datos_mapa.movimiento_angulo
    :
    0;


movimiento_sentido =
    variable_struct_exists(
        datos_mapa,
        "movimiento_sentido"
    )
    ?
    datos_mapa.movimiento_sentido
    :
    1;


movimiento_sentido =
    (
        movimiento_sentido < 0
    )
    ?
    -1
    :
    1;


movimiento_solo_alerta =
    variable_struct_exists(
        datos_mapa,
        "movimiento_solo_alerta"
    )
    ?
    datos_mapa.movimiento_solo_alerta
    :
    false;


// Punto donde el objeto fue colocado en la room.
movimiento_origen_x =
    x;


movimiento_origen_y =
    y;


// =========================================================
// IDA Y VUELTA CON EASE-IN-OUT REAL
// =========================================================
//
// Para los presets:
//
//     "izquierda_derecha"
//     "arriba_abajo"
//     "diagonal"
//
// usamos un progreso 0..1 por cada recorrido completo.
//
// En cada extremo:
//     velocidad = 0
//
// Después invierte el sentido y vuelve a acelerar.
//
// Empezamos en el CENTRO de la trayectoria, porque ese es
// exactamente el punto donde colocaste el objeto en la room.
// =========================================================

movimiento_trayecto_t =
    0.5;


// 1  = avanzando hacia el extremo positivo.
// -1 = volviendo hacia el extremo negativo.
movimiento_trayecto_sentido =
    1;


// Ángulo usado por el preset "diagonal".
movimiento_diagonal_angulo =
    variable_struct_exists(
        datos_mapa,
        "movimiento_diagonal_angulo"
    )
    ?
    datos_mapa.movimiento_diagonal_angulo
    :
    45;


// El punto colocado en la room es el punto inicial
// de la trayectoria circular.
movimiento_centro_x =
    movimiento_origen_x;


movimiento_centro_y =
    movimiento_origen_y
    +
    movimiento_radio;


movimiento_angulo_actual =
    270;


// =========================================================
// DATOS DE ESPIRAL
// =========================================================

espiral_cantidad =
    variable_struct_exists(
        datos_mapa,
        "espiral_cantidad"
    )
    ?
    datos_mapa.espiral_cantidad
    :
    12;


espiral_radio_inicial =
    variable_struct_exists(
        datos_mapa,
        "espiral_radio_inicial"
    )
    ?
    datos_mapa.espiral_radio_inicial
    :
    14;


espiral_radio_paso =
    variable_struct_exists(
        datos_mapa,
        "espiral_radio_paso"
    )
    ?
    datos_mapa.espiral_radio_paso
    :
    4;


espiral_angulo_paso =
    variable_struct_exists(
        datos_mapa,
        "espiral_angulo_paso"
    )
    ?
    datos_mapa.espiral_angulo_paso
    :
    30;


espiral_giro_formacion =
    variable_struct_exists(
        datos_mapa,
        "espiral_giro_formacion"
    )
    ?
    datos_mapa.espiral_giro_formacion
    :
    90;


espiral_formacion_frames =
    variable_struct_exists(
        datos_mapa,
        "espiral_formacion_frames"
    )
    ?
    datos_mapa.espiral_formacion_frames
    :
    24;


espiral_espera_frames =
    variable_struct_exists(
        datos_mapa,
        "espiral_espera_frames"
    )
    ?
    datos_mapa.espiral_espera_frames
    :
    10;


// =========================================================
// ESTADO
// =========================================================

en_alerta =
    false;


timer_ataque =
    retraso_inicial;


image_speed =
    1;


if (sprite_idle != -1)
{
    sprite_index =
        sprite_idle;
}


// =========================================================
// Y-SORT
// =========================================================
//
// Sigue el sistema universal del proyecto.
// =========================================================

scr_depth_sort_register(
    id,
    -20,
    0
);


// =========================================================
// CREAR GESTOR VISUAL
// =========================================================
//
// No necesitas colocar obj_mapa_combate_fx en la room.
// Se crea automáticamente al existir al menos un enemigo.
// =========================================================

if (
    !instance_exists(
        obj_mapa_combate_fx
    )
)
{
    var _layer_instances =
        layer_get_id(
            "Instances"
        );


    if (_layer_instances != -1)
    {
        instance_create_layer(
            0,
            0,
            _layer_instances,
            obj_mapa_combate_fx
        );
    }
    else
    {
        instance_create_depth(
            0,
            0,
            1000000,
            obj_mapa_combate_fx
        );
    }
}


// =========================================================
// DEBUG DE RECURSOS
// =========================================================

if (sprite_idle == -1)
{
    show_debug_message(
        "[ENEMIGO MAPA] Falta sprite_idle para "
        +
        enemigo_mapa_id
    );
}


if (sprite_alerta == -1)
{
    show_debug_message(
        "[ENEMIGO MAPA] Falta sprite_alerta para "
        +
        enemigo_mapa_id
    );
}


if (sprite_bala == -1)
{
    show_debug_message(
        "[ENEMIGO MAPA] Falta sprite_bala para "
        +
        enemigo_mapa_id
    );
}
