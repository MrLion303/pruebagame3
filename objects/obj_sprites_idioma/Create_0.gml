/// =========================================================
/// OBJ_SPRITES_IDIOMA
/// CREATE
/// =========================================================


// Evitar duplicados.
if (instance_number(object_index) > 1) {

    instance_destroy();
    exit;

}


// Inicializar registro.
scr_sprites_idioma_init();