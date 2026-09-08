/// =========================================================
/// OBJ_PROYECTIL_MAPA
/// CREATE
/// =========================================================

owner_enemy =
    noone;


// "vuelo"
// "espiral"
estado_bala =
    "vuelo";


dano_base =
    5;


velocidad_bala =
    5;


vida_frames =
    0;


vida_max_frames =
    180;


invulnerabilidad_frames =
    16;


puede_danar =
    true;


homing =
    false;


rotar_bala =
    false;


colisiona_paredes =
    false;


// =========================================================
// ESPIRAL
// =========================================================

espiral_timer =
    0;


espiral_formacion_frames =
    24;


espiral_espera_frames =
    10;


espiral_angulo_base =
    0;


espiral_giro_formacion =
    90;


espiral_radio_objetivo =
    32;


// Deben quedar delante de la mayoría del mapa.
// El FX vuelve a dibujarlas encima del oscurecimiento.
depth =
    -999999;
