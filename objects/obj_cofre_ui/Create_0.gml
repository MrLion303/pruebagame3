// =========================================================
// OBJ_COFRE_UI
// CREATE
// =========================================================

scr_cofre_init();


// =========================================================
// PANEL ACTUAL
//
// 0 = INVENTARIO
// 1 = COFRE
// =========================================================

panel_actual = 0;


// =========================================================
// INVENTARIO
// =========================================================

inventario_index = 0;
inventario_scroll = 0;


// =========================================================
// COFRE
// =========================================================

cofre_index = 0;
cofre_scroll = 0;


// Filas visibles simultáneamente.
filas_visibles = 8;


// =========================================================
// TRANSFERENCIA INVENTARIO -> COFRE
// =========================================================
//
// Cuando el jugador selecciona un objeto con Z,
// guardamos aquí cuál eligió.
//
// Después pasa al panel del cofre para elegir el slot.
// =========================================================

transferencia_activa = false;

transfer_tipo = "";
transfer_slot = -1;
transfer_key = -1;

// Posición visual dentro de la lista unificada.
transfer_inv_index = -1;


// =========================================================
// BLOQUEAR LA MISMA Z QUE ABRIÓ EL COFRE
// =========================================================

input_lock = 3;


// =========================================================
// BLOQUEAR JUGADOR
// =========================================================

if (instance_exists(obj_player))
{
    obj_player.puede_moverse = false;
}