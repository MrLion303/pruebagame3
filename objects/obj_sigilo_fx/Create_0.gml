/// =========================================================
/// OBJ_SIGILO_FX
/// CREATE - NUEVO
/// =========================================================
///
/// **PARENT: ninguno**
///
/// No se coloca manualmente.
/// scr_habilidades_system lo crea cuando Sigilo está obtenido.
///
/// Dibuja oscuridad en el MUNDO dejando un círculo de luz
/// alrededor de Maya.
/// =========================================================

persistent = false;

depth = -1500000;


// 0..1.
sigilo_anim = 0;


// Aproximadamente 0.33 s a 30 FPS.
sigilo_anim_speed = 1 / 10;


// Oscuridad final.
sigilo_oscuridad = 0.58;


// Radio completamente iluminado alrededor de Maya.
sigilo_radio_luz = 72;


// Borde suave entre luz y oscuridad.
sigilo_borde_suave = 16;


// Resolución del círculo.
sigilo_segmentos = 64;
