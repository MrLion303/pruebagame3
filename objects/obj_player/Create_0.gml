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
// COLISIÓN FIJA DEL JUGADOR
// =========================================================
//
// Guardamos UNA sola caja de colisión al crear al jugador.
// Así la física no cambia de tamaño cuando cambia el frame
// de caminar/correr o el sprite direccional.
//
// Los sprites siguen cambiando visualmente como siempre,
// pero las paredes usan esta caja estable.
// =========================================================

_collision_left =
    bbox_left - x;

_collision_top =
    bbox_top - y;

_collision_right =
    bbox_right - x;

_collision_bottom =
    bbox_bottom - y;


f_player_hits_wall =
function(_nx, _ny)
{
    return (
        collision_rectangle(
            _nx + _collision_left,
            _ny + _collision_top,
            _nx + _collision_right,
            _ny + _collision_bottom,
            colision,
            false,
            true
        )
        !=
        noone
    );
};
