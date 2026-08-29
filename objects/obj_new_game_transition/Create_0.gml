/// =========================================================
/// OBJ_NEW_GAME_TRANSITION
/// CREATE
/// =========================================================

// Sobrevivirá al cambio de habitación.
persistent = true;

// Debe poder dibujar.
visible = true;

// Por encima de todo.
depth = -1000000;


// =========================================================
// TRANSICIÓN
// =========================================================
//
// 0 = cubrir pantalla
// 1 = esperando Room Start
// 2 = descubrir pantalla
// =========================================================

fase = 0;

transicion_progreso = 0;
transicion_velocidad = 0.04;


// =========================================================
// DESTINO DE NUEVA PARTIDA
// =========================================================

destino_room = pasillo_school;
destino_x = 668;
destino_y = 194;