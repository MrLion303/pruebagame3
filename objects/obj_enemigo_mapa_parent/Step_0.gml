/// =========================================================
/// OBJ_ENEMIGO_MAPA_PARENT
/// STEP
/// =========================================================


// =========================================================
// SEGURIDAD
// =========================================================

if (
    room == bbs
    ||
    room == game_over
)
{
    exit;
}


if (
    variable_global_exists(
        "gameover_death_freeze_active"
    )
    &&
    global.gameover_death_freeze_active
)
{
    exit;
}


// =========================================================
// PAUSAR DURANTE BLOQUEOS DEL MUNDO
// =========================================================

var _mundo_bloqueado =
(
    scr_cutscene_world_locked()
    ||
    instance_exists(
        obj_pauser
    )
);


if (_mundo_bloqueado)
{
    if (en_alerta)
    {
        en_alerta =
            false;


        timer_ataque =
            retraso_inicial;


        if (sprite_idle != -1)
        {
            sprite_index =
                sprite_idle;

            image_index =
                0;
        }


        var _owner_lock =
            id;


        with (obj_proyectil_mapa)
        {
            if (
                owner_enemy
                ==
                _owner_lock
            )
            {
                instance_destroy();
            }
        }
    }


    exit;
}




// =========================================================
// MOVIMIENTO CONFIGURABLE
// =========================================================
//
// Se actualiza ANTES de medir el rango contra Maya.
// Así el radio de ataque siempre sigue la posición actual
// del enemigo.
//
// movimiento_solo_alerta = true:
//     solo se moverá mientras esté atacando.
//
// movimiento_solo_alerta = false:
//     se moverá siempre que el mundo no esté bloqueado.
// =========================================================

var _puede_actualizar_movimiento =
(
    puede_moverse
    &&
    movimiento_velocidad > 0
    &&
    (
        !movimiento_solo_alerta
        ||
        en_alerta
    )
);


if (_puede_actualizar_movimiento)
{
    // -----------------------------------------------------
    // IDA Y VUELTA CON EASE-IN-OUT REAL
    // -----------------------------------------------------
    //
    // Presets:
    //
    //     "izquierda_derecha"
    //     "arriba_abajo"
    //     "diagonal"
    //
    // Usamos SMOOTHERSTEP:
    //
    //     6t^5 - 15t^4 + 10t^3
    //
    // Ventaja:
    //
    //     - velocidad 0 en ambos extremos;
    //     - aceleración también 0 justo en los extremos;
    //     - frenado mucho más perceptible;
    //     - regreso sin rebote.
    // -----------------------------------------------------

    if (
        movimiento_preset == "izquierda_derecha"
        ||
        movimiento_preset == "arriba_abajo"
        ||
        movimiento_preset == "diagonal"
    )
    {
        var _distancia_recorrido =
            max(
                1,
                movimiento_distancia
            );


        // -------------------------------------------------
        // CALIBRAR movimiento_velocidad
        // -------------------------------------------------
        //
        // El trayecto completo va de:
        //
        //     -distancia  ->  +distancia
        //
        // La derivada máxima de smootherstep es 1.875.
        //
        // Por eso usamos:
        //
        //     paso_t = velocidad /
        //              (3.75 * distancia)
        //
        // Así movimiento_velocidad sigue siendo
        // aproximadamente la VELOCIDAD MÁXIMA.
        // -------------------------------------------------

        var _paso_t =
            movimiento_velocidad
            /
            (
                3.75
                *
                _distancia_recorrido
            );


        movimiento_trayecto_t +=
            _paso_t
            *
            movimiento_trayecto_sentido;


        // -------------------------------------------------
        // EXTREMO POSITIVO
        // -------------------------------------------------

        if (movimiento_trayecto_t >= 1)
        {
            movimiento_trayecto_t =
                1;


            movimiento_trayecto_sentido =
                -1;
        }


        // -------------------------------------------------
        // EXTREMO NEGATIVO
        // -------------------------------------------------

        else if (movimiento_trayecto_t <= 0)
        {
            movimiento_trayecto_t =
                0;


            movimiento_trayecto_sentido =
                1;
        }


        var _t =
            clamp(
                movimiento_trayecto_t,
                0,
                1
            );


        // smootherstep:
        // 6t^5 - 15t^4 + 10t^3
        var _ease =
            (
                6
                *
                power(
                    _t,
                    5
                )
            )
            -
            (
                15
                *
                power(
                    _t,
                    4
                )
            )
            +
            (
                10
                *
                power(
                    _t,
                    3
                )
            );


        // Convertir 0..1 a -distancia..+distancia.
        var _offset =
            lerp(
                -_distancia_recorrido,
                _distancia_recorrido,
                _ease
            );


        // ---------------------------------------------
        // HORIZONTAL
        // ---------------------------------------------

        if (
            movimiento_preset
            ==
            "izquierda_derecha"
        )
        {
            x =
                movimiento_origen_x
                +
                _offset;


            y =
                movimiento_origen_y;
        }


        // ---------------------------------------------
        // VERTICAL
        // ---------------------------------------------

        else if (
            movimiento_preset
            ==
            "arriba_abajo"
        )
        {
            x =
                movimiento_origen_x;


            y =
                movimiento_origen_y
                +
                _offset;
        }


        // ---------------------------------------------
        // DIAGONAL
        // ---------------------------------------------

        else
        {
            x =
                movimiento_origen_x
                +
                lengthdir_x(
                    _offset,
                    movimiento_diagonal_angulo
                );


            y =
                movimiento_origen_y
                +
                lengthdir_y(
                    _offset,
                    movimiento_diagonal_angulo
                );
        }
    }


    // -----------------------------------------------------
    // CÍRCULO
    // -----------------------------------------------------
    //
    // La velocidad se interpreta como velocidad tangencial
    // aproximada en píxeles por frame.
    //
    // El punto colocado en la room es el punto inicial
    // superior de la trayectoria, así no hay un salto
    // instantáneo al comenzar.
    // -----------------------------------------------------

    else if (movimiento_preset == "circulo")
    {
        var _radio =
            max(
                1,
                movimiento_radio
            );


        var _paso_angular =
            (
                movimiento_velocidad
                /
                _radio
            )
            *
            (
                180
                /
                pi
            );


        movimiento_angulo_actual +=
            _paso_angular
            *
            movimiento_sentido;


        movimiento_angulo_actual =
            movimiento_angulo_actual
            mod
            360;


        x =
            movimiento_centro_x
            +
            lengthdir_x(
                _radio,
                movimiento_angulo_actual
            );


        y =
            movimiento_centro_y
            +
            lengthdir_y(
                _radio,
                movimiento_angulo_actual
            );
    }


    // -----------------------------------------------------
    // MOVIMIENTO CONTINUO
    // -----------------------------------------------------
    //
    // movimiento_direccion acepta:
    //
    //     "derecha"
    //     "izquierda"
    //     "arriba"
    //     "abajo"
    //     "angulo"
    //
    // Si usas "angulo", movimiento_angulo usa los grados
    // normales de GameMaker:
    //
    //     0   = derecha
    //     90  = arriba
    //     180 = izquierda
    //     270 = abajo
    // -----------------------------------------------------

    else if (movimiento_preset == "continuo")
    {
        var _angulo_mov =
            movimiento_angulo;


        switch (movimiento_direccion)
        {
            case "derecha":
                _angulo_mov =
                    0;
                break;


            case "arriba":
                _angulo_mov =
                    90;
                break;


            case "izquierda":
                _angulo_mov =
                    180;
                break;


            case "abajo":
                _angulo_mov =
                    270;
                break;
        }


        x +=
            lengthdir_x(
                movimiento_velocidad,
                _angulo_mov
            );


        y +=
            lengthdir_y(
                movimiento_velocidad,
                _angulo_mov
            );
    }
}


// =========================================================
// SIN PLAYER
// =========================================================

if (
    !instance_exists(
        obj_player
    )
)
{
    en_alerta =
        false;

    exit;
}


var _p =
    instance_find(
        obj_player,
        0
    );


var _distancia =
    point_distance(
        x,
        y,
        _p.x,
        _p.y
    );


var _debe_alertarse =
    (
        _distancia
        <=
        rango_ataque
    );


// =========================================================
// ENTRAR EN RANGO
// =========================================================

if (
    _debe_alertarse
    &&
    !en_alerta
)
{
    en_alerta =
        true;


    timer_ataque =
        retraso_inicial;


    if (sprite_alerta != -1)
    {
        sprite_index =
            sprite_alerta;

        image_index =
            0;
    }
}


// =========================================================
// SALIR DEL RANGO
// =========================================================

if (
    !_debe_alertarse
    &&
    en_alerta
)
{
    en_alerta =
        false;


    timer_ataque =
        retraso_inicial;


    if (sprite_idle != -1)
    {
        sprite_index =
            sprite_idle;

        image_index =
            0;
    }


    // Las balas pertenecen a este pequeño encuentro.
    // Al escapar de su rango desaparecen.
    var _owner_out =
        id;


    with (obj_proyectil_mapa)
    {
        if (
            owner_enemy
            ==
            _owner_out
        )
        {
            instance_destroy();
        }
    }


    exit;
}


// =========================================================
// IDLE
// =========================================================

if (!en_alerta)
{
    if (
        sprite_idle != -1
        &&
        sprite_index != sprite_idle
    )
    {
        sprite_index =
            sprite_idle;

        image_index =
            0;
    }


    exit;
}


// =========================================================
// ALERTA
// =========================================================

if (
    sprite_alerta != -1
    &&
    sprite_index != sprite_alerta
)
{
    sprite_index =
        sprite_alerta;

    image_index =
        0;
}


// =========================================================
// CONTADOR DE ATAQUE
// =========================================================

timer_ataque--;


if (timer_ataque > 0)
{
    exit;
}


timer_ataque =
    max(
        1,
        intervalo_ataque
    );


// =========================================================
// NO CREAR BALAS INVISIBLES
// =========================================================

if (sprite_bala == -1)
{
    exit;
}


// =========================================================
// ATAQUE DIRECTO
// =========================================================
//
// Lanza UN proyectil hacia la posición actual de Maya.
// La bala no persigue después de haber sido disparada.
// =========================================================

if (tipo_ataque == "directo")
{
    var _bx =
        x
        +
        offset_bala_x;


    var _by =
        y
        +
        offset_bala_y;


    var _bala =
        instance_create_depth(
            _bx,
            _by,
            -999999,
            obj_proyectil_mapa
        );


    _bala.owner_enemy =
        id;


    _bala.sprite_index =
        sprite_bala;


    _bala.image_index =
        0;


    _bala.image_speed =
        1;


    _bala.image_xscale =
        escala_bala;


    _bala.image_yscale =
        escala_bala;


    _bala.estado_bala =
        "vuelo";


    _bala.dano_base =
        dano_bala;


    _bala.vida_max_frames =
        vida_bala_frames;


    _bala.invulnerabilidad_frames =
        invulnerabilidad_frames;


    _bala.velocidad_bala =
        velocidad_bala;


    _bala.homing =
        bala_homing;


    _bala.rotar_bala =
        rotar_bala;


    _bala.colisiona_paredes =
        colisiona_paredes;


    _bala.direction =
        point_direction(
            _bx,
            _by,
            _p.x,
            _p.y
        );


    _bala.speed =
        velocidad_bala;


    _bala.puede_danar =
        true;


    exit;
}


// =========================================================
// ATAQUE ESPIRAL
// =========================================================
//
// Forma una espiral alrededor del enemigo.
//
// Durante la formación:
//     las balas NO hacen daño.
//
// Cuando termina:
//     todos los proyectiles salen disparados hacia afuera.
// =========================================================

if (tipo_ataque == "espiral")
{
    var _cantidad =
        max(
            1,
            round(
                espiral_cantidad
            )
        );


    // Rotar cada nueva espiral para que no sea siempre
    // exactamente el mismo dibujo.
    var _angulo_inicio =
        irandom_range(
            0,
            359
        );


    for (
        var _i = 0;
        _i < _cantidad;
        _i++
    )
    {
        var _bala =
            instance_create_depth(
                x,
                y,
                -999999,
                obj_proyectil_mapa
            );


        _bala.owner_enemy =
            id;


        _bala.sprite_index =
            sprite_bala;


        _bala.image_index =
            0;


        _bala.image_speed =
            1;


        _bala.image_xscale =
            escala_bala;


        _bala.image_yscale =
            escala_bala;


        _bala.estado_bala =
            "espiral";


        _bala.dano_base =
            dano_bala;


        _bala.vida_max_frames =
            vida_bala_frames;


        _bala.invulnerabilidad_frames =
            invulnerabilidad_frames;


        _bala.velocidad_bala =
            velocidad_bala;


        _bala.homing =
            false;


        _bala.rotar_bala =
            rotar_bala;


        _bala.colisiona_paredes =
            colisiona_paredes;


        _bala.puede_danar =
            false;


        _bala.espiral_timer =
            0;


        _bala.espiral_formacion_frames =
            max(
                1,
                espiral_formacion_frames
            );


        _bala.espiral_espera_frames =
            max(
                0,
                espiral_espera_frames
            );


        _bala.espiral_angulo_base =
            _angulo_inicio
            +
            (
                _i
                *
                espiral_angulo_paso
            );


        _bala.espiral_giro_formacion =
            espiral_giro_formacion;


        _bala.espiral_radio_objetivo =
            espiral_radio_inicial
            +
            (
                _i
                *
                espiral_radio_paso
            );
    }
}
