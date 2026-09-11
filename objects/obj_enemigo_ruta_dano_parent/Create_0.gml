/// =========================================================
/// OBJ_ENEMIGO_RUTA_DANO_PARENT
/// CREATE
/// =========================================================
///
/// IMPORTANTE SOBRE LA JERARQUÍA:
///
/// Parent de ESTE objeto:
///
///     obj_enemigo_mapa_parent
///
/// PERO este Create SOBRESCRIBE el Create del parent.
/// NO añadas event_inherited() aquí.
///
/// Así obtenemos dos cosas:
///
///     1. NO heredamos disparos/ataques del enemigo volador.
///     2. obj_mapa_combate_fx sí nos reconoce como miembro
///        de obj_enemigo_mapa_parent para el oscurecimiento.
///
/// Los objetos de ruta reales serán hijos de ESTE objeto.
///
/// =========================================================


// =========================================================
// ID DE DATOS
// =========================================================

if (
    !variable_instance_exists(
        id,
        "enemigo_ruta_dano_id"
    )
)
{
    enemigo_ruta_dano_id =
        "ruta_dano_01";
}


// =========================================================
// CARGAR DATOS
// =========================================================

datos_ruta =
    scr_enemigos_ruta_dano_data(
        enemigo_ruta_dano_id
    );


ruta_puntos =
    datos_ruta.ruta_puntos;


ruta_velocidad =
    max(
        0,
        datos_ruta.ruta_velocidad
    );


rango_peligro =
    max(
        0,
        datos_ruta.rango_peligro
    );


oscuridad =
    clamp(
        datos_ruta.oscuridad,
        0,
        1
    );


dano_contacto =
    max(
        0,
        datos_ruta.dano_contacto
    );


invulnerabilidad_frames =
    max(
        1,
        round(
            datos_ruta.invulnerabilidad_frames
        )
    );


// =========================================================
// VARIABLES COMPATIBLES CON OBJ_MAPA_COMBATE_FX
// =========================================================
//
// obj_mapa_combate_fx ya busca estas variables en todos los
// hijos de obj_enemigo_mapa_parent:
//
//     en_alerta
//     oscuridad
//
// Por eso podemos reutilizar exactamente su efecto.
// =========================================================

en_alerta =
    false;


// =========================================================
// SPRITE
// =========================================================
//
// El sprite viene directamente del OBJETO.
// No se configura en el script.
// =========================================================

sprite_normal =
    sprite_index;


image_speed_normal =
    image_speed;


// =========================================================
// RUTA
// =========================================================

ruta_total =
    array_length(
        ruta_puntos
    );


ruta_indice =
    0;


ruta_t =
    0;


// La ruta usa coordenadas ABSOLUTAS.
//
// El enemigo aparece exactamente en el primer punto.
if (ruta_total > 0)
{
    x =
        ruta_puntos[0].x;


    y =
        ruta_puntos[0].y;
}


// =========================================================
// CREAR EL MISMO GESTOR VISUAL DE LOS ENEMIGOS DE MAPA
// =========================================================
//
// Como NO ejecutamos el Create heredado de
// obj_enemigo_mapa_parent, creamos nosotros el gestor si aún
// no existe.
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
// DEBUG
// =========================================================

if (ruta_total < 2)
{
    show_debug_message(
        "[ENEMIGO RUTA DAÑO] "
        +
        enemigo_ruta_dano_id
        +
        " necesita al menos 2 puntos."
    );
}


if (
    sprite_normal == -1
    ||
    !sprite_exists(
        sprite_normal
    )
)
{
    show_debug_message(
        "[ENEMIGO RUTA DAÑO] "
        +
        object_get_name(
            object_index
        )
        +
        " no tiene sprite asignado."
    );
}


// =========================================================
// Y-SORT
// =========================================================

scr_depth_sort_register(
    id
);
