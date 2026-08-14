// Comprobar si el jugador esta colisionando con este objeto
var _p = instance_place(x, y, obj_player);

if (_p != noone) {
    timer_dano++;
    
    if (timer_dano >= tiempo_intervalo) {
        timer_dano = 0; // Reiniciar contador
        
        // 1. Obtener la defensa total actual del jugador
        var _defensa_actual = 0;
        with (_p) {
            _defensa_actual = get_jugador_defensa();
        }
        
        // 2. Aplicar la nueva regla: 5 de defensa reduce el daño un 8% (1.6% por cada punto).
        // Tope maximo de reduccion del 50%.
        var _porcentaje_reduccion = min(_defensa_actual * 1.6, 50);
        
        // 3. Calcular el daño final aplicando la reduccion y redondeando sin decimales
        var _dano_reducido = round(dano_base * (1 - (_porcentaje_reduccion / 100)));
        
        // Asegurar que la trampa siempre quite al menos 1 de vida si la defensa no anula todo
        _dano_reducido = max(1, _dano_reducido);
        
        // 4. Restar la vida al jugador (sin bajar de 0)
        _p.hp = max(0, _p.hp - _dano_reducido);
        
        // Mensaje en consola para verificar los calculos exactos
        show_debug_message("¡Dano recibido! Base: " + string(dano_base) + " | Def: " + string(_defensa_actual) + " | Reduccion: " + string(_porcentaje_reduccion) + "% | Dano final: " + string(_dano_reducido));
    }
} else {
    // Si el jugador sale del objeto, reiniciamos el temporizador
    timer_dano = 0;
}