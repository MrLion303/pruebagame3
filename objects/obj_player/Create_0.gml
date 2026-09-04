velocidad = 4;
movimiento = false;
direccion = "abajo";

face = DOWN;
facing_direction = 2;

// --- NUEVAS ESTADÍSTICAS Y EQUIPAMIENTO ---
hp = 80;
hp_max = 80;
nivel = 1;
ataque_base = 0;
defensa_base = 0;
exp_actual = 0;
exp_siguiente = 100;

// Slots de equipo activo
equipo_arma = -1;        
equipo_armadura = -1;

// Bandera maestra de control de movimiento
// por defecto true, se apaga al viajar a batalla
puede_moverse = true;


// --- RECUPERAR POSICIÓN DE RETORNO (BATALLAS / TELETRANSPORTE) ---

if (variable_global_exists("return_x") && variable_global_exists("return_y"))
{
    // Restaurar exactamente la posición anterior a la batalla
    x = global.return_x;
    y = global.return_y;
    
    // Bloquear movimiento mientras termina el fade
    puede_moverse = false;
    
    // IMPORTANTE:
    // NO borramos global.return_room aquí.
    // La transición de salida todavía necesita
    // saber a qué room debe regresar.
    
    variable_global_del("return_x");
    variable_global_del("return_y");
}


// --- INVENTARIO DEL JUGADOR UNIFICADO (12 ESPACIOS) ---

inventory = [
    "agua", "manzana", -1, -1, 
    -1, -1, -1, -1, 
    -1, -1, -1, -1
]; 

inv_max_slots = 12;
inv_scroll = 0;
inv_x = 0;
inv_y = 0;

// --- CARGAR DATOS SI ES CONTINUAR ---
if (!global.new_game) {
    scr_aplicar_datos_cargados(id);
}

// --- SISTEMA DE AUDIO DE PASOS ---
paso_timer = 0;


// =========================================================
// ANIMACIÓN AL HACER MOVIMIENTOS CORTOS
// =========================================================
//
// Evita volver al frame 0 inmediatamente si el jugador
// toca repetidamente las flechas en vez de mantenerlas.
//
walk_anim_hold =
    0;

// Más corto que antes.
// Solo sirve como pequeño margen entre "taps".
walk_anim_hold_max =
    6;


// Indica si en el frame ANTERIOR Maya estaba moviéndose.
walk_anim_was_moving =
    false;


// =========================================================
// DEPTH SORT AUTOMÁTICO
// =========================================================

scr_depth_sort_register(
    id
);



// =========================================================
// SISTEMA DE HIELO
// =========================================================

// ---------------------------------------------------------
// HIELO NORMAL
// ---------------------------------------------------------
//
// Velocidad acumulada.
// No son hspeed/vspeed porque el proyecto mueve al player
// manualmente píxel por píxel.
//
ice_vx =
    0;

ice_vy =
    0;


// Fracciones de píxel acumuladas.
ice_accum_x =
    0;

ice_accum_y =
    0;


// Cuánto tarda en coger velocidad.
ice_acceleration =
    0.75;


// Cuánto tarda en detenerse al soltar las flechas.
//
// Menor número = resbala más.
// Mayor número = frena antes.
//
ice_friction =
    0.32;


// ---------------------------------------------------------
// HIELO AZUL
// ---------------------------------------------------------

blue_ice_sliding =
    false;


// Después de chocar contra una pared, Maya queda detenida
// hasta que pulses una nueva dirección.
blue_ice_waiting_input =
    false;


blue_ice_dx =
    0;

blue_ice_dy =
    0;


// Velocidad fija del deslizamiento continuo.
blue_ice_speed =
    4;



// =========================================================
// ANIMACIÓN SOBRE HIELO
// =========================================================
//
// Mientras sea true:
//
//     Maya puede desplazarse físicamente,
//     pero su sprite permanece en idle.
//
ice_anim_lock =
    false;



// =========================================================
// REACCIÓN DE ANIMACIÓN - HIELO NORMAL
// =========================================================
//
// Cada NUEVA pulsación de una flecha muestra brevemente
// uno de los frames de caminar.
//
// Mantener la flecha NO mantiene la animación.
//
ice_on_normal =
    false;

ice_on_blue =
    false;


// Cuántos frames permanece visible la reacción.
// Juego a 30 FPS: 4 frames ≈ 0.13 s.
ice_normal_tap_timer =
    0;

ice_normal_tap_duration =
    4;


// Frame no-idle que se irá alternando con cada pulsación.
ice_normal_tap_frame =
    0;
