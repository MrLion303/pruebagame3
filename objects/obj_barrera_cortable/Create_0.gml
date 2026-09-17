/// =========================================================
/// OBJ_BARRERA_CORTABLE
/// CREATE COMPLETO
/// =========================================================
///
/// IMPORTANTE:
///
/// En el Object Editor asígnale al objeto el sprite que quieras
/// usar COMO COLISIÓN. Tú dijiste que será de 20x20.
///
/// Ese sprite base se guarda aquí en sprite_colision y NO cambia
/// aunque luego el visual sea lianas/cables/cuerdas.
///
/// Si escalas la instancia en el room, por ejemplo:
///
///     image_xscale = 3;
///     image_yscale = 2;
///
/// la colisión 20x20 pasa a comportarse como 60x40.
///
/// ---------------------------------------------------------
/// Creation Code de ejemplo:
/// ---------------------------------------------------------
///
///     tipo_barrera = "lianas";
///     sprite_lianas = spr_lianas_bosque;
///     dialogo_sin_tijeras = "lianas";
///
/// o:
///
///     tipo_barrera = "cables";
///     sprite_cables = spr_cables_laboratorio;
///
/// o:
///
///     tipo_barrera = "cuerdas";
///     sprite_cuerdas = spr_cuerdas_viejas;
///
/// También puedes forzar un sprite solo para esta instancia:
///
///     tipo_barrera = "cables";
///     sprite_personalizado = spr_cables_rojos;
///
/// Opcional para persistencia manual:
///
///     barrera_id = "entrada_bosque";
///
/// Si barrera_id queda vacío, se usa room + posición inicial.
/// =========================================================


// =========================================================
// SPRITE DE COLISIÓN BASE
// =========================================================
//
// Se captura ANTES del Creation Code de la instancia.
// Debe ser el sprite 20x20 asignado a obj_barrera_cortable.
// =========================================================

sprite_colision =
    sprite_index;


mask_index =
    sprite_colision;


// =========================================================
// CONFIGURACIÓN VISUAL
// =========================================================

tipo_barrera =
    "lianas";


// Puedes cambiar cualquiera de estos tres desde Creation Code.
sprite_lianas =
    -1;

sprite_cables =
    -1;

sprite_cuerdas =
    -1;


// Si no es -1, tiene prioridad sobre el sprite del tipo.
sprite_personalizado =
    -1;




// =========================================================
// DIÁLOGO SI NO TIENES TIJERAS
// =========================================================
//
// Se puede cambiar individualmente desde Creation Code.
// IDs disponibles en scr_notijeras_dialogos:
//
//     "olvido_importante"
//     "no_olvidas_importante"
//     "falta_algo_mas"
//     "olvidaste_algo_mas"
//     "lianas"
//     "cables"
//     "cuerdas"
//     "tipo_barrera"   -> automático según tipo_barrera
//
// Ejemplo:
//
//     dialogo_sin_tijeras = "lianas";
// =========================================================

dialogo_sin_tijeras =
    "olvido_importante";

// =========================================================
// PERSISTENCIA
// =========================================================

barrera_id =
    "";

barrera_room =
    room;

barrera_start_x =
    x;

barrera_start_y =
    y;

barrera_save_key =
    "";


// =========================================================
// RUNTIME
// =========================================================

barrera_inicializada =
    false;

collision_proxy =
    noone;


// Fade al cortarla.
cortando =
    false;

fade_velocidad =
    0.08;

image_alpha =
    1;

image_speed =
    0;
