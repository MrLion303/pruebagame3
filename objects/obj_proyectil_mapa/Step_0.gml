/// =========================================================
/// OBJ_PROYECTIL_MAPA
/// STEP
/// =========================================================


// =========================================================
// LIMPIEZA
// =========================================================

if (
    room == bbs
    ||
    room == game_over
)
{
    instance_destroy();

    exit;
}


if (
    owner_enemy == noone
    ||
    !instance_exists(
        owner_enemy
    )
)
{
    instance_destroy();

    exit;
}


if (
    !variable_instance_exists(
        owner_enemy,
        "en_alerta"
    )
    ||
    !owner_enemy.en_alerta
)
{
    instance_destroy();

    exit;
}


// =========================================================
// CONGELAR DURANTE GAME OVER
// =========================================================

if (
    variable_global_exists(
        "gameover_death_freeze_active"
    )
    &&
    global.gameover_death_freeze_active
)
{
    speed =
        0;

    exit;
}


// =========================================================
// ESPIRAL EN FORMACIÓN
// =========================================================

if (estado_bala == "espiral")
{
    speed =
        0;


    espiral_timer++;


    var _t =
        clamp(
            espiral_timer
            /
            max(
                1,
                espiral_formacion_frames
            ),
            0,
            1
        );


    var _radio_actual =
        lerp(
            0,
            espiral_radio_objetivo,
            _t
        );


    var _angulo_actual =
        espiral_angulo_base
        +
        (
            espiral_giro_formacion
            *
            _t
        );


    x =
        owner_enemy.x
        +
        lengthdir_x(
            _radio_actual,
            _angulo_actual
        );


    y =
        owner_enemy.y
        +
        lengthdir_y(
            _radio_actual,
            _angulo_actual
        );


    if (rotar_bala)
    {
        image_angle =
            _angulo_actual;
    }


    var _momento_lanzamiento =
        espiral_formacion_frames
        +
        espiral_espera_frames;


    if (
        espiral_timer
        >=
        _momento_lanzamiento
    )
    {
        estado_bala =
            "vuelo";


        direction =
            point_direction(
                owner_enemy.x,
                owner_enemy.y,
                x,
                y
            );


        speed =
            velocidad_bala;


        puede_danar =
            true;


        if (rotar_bala)
        {
            image_angle =
                direction;
        }
    }


    exit;
}


// =========================================================
// VUELO
// =========================================================

vida_frames++;


if (
    vida_frames
    >=
    vida_max_frames
)
{
    instance_destroy();

    exit;
}


// =========================================================
// HOMING OPCIONAL
// =========================================================

if (
    homing
    &&
    instance_exists(
        obj_player
    )
)
{
    var _p_homing =
        instance_find(
            obj_player,
            0
        );


    direction =
        point_direction(
            x,
            y,
            _p_homing.x,
            _p_homing.y
        );


    speed =
        velocidad_bala;
}


if (rotar_bala)
{
    image_angle =
        direction;
}


// =========================================================
// PAREDES OPCIONALES
// =========================================================

if (
    colisiona_paredes
    &&
    place_meeting(
        x,
        y,
        colision
    )
)
{
    instance_destroy();

    exit;
}


// =========================================================
// COLISIÓN CON MAYA
// =========================================================

if (
    !puede_danar
    ||
    !instance_exists(
        obj_player
    )
)
{
    exit;
}


var _p =
    instance_place(
        x,
        y,
        obj_player
    );


if (_p == noone)
{
    exit;
}


// La bala se consume siempre al tocar a Maya.
// Esto evita que se quede encima de ella durante i-frames.
var _puede_recibir =
    true;


if (
    variable_instance_exists(
        _p,
        "map_battle_iframes"
    )
    &&
    _p.map_battle_iframes > 0
)
{
    _puede_recibir =
        false;
}


if (_puede_recibir)
{
    // =====================================================
    // DEFENSA - MISMA FÓRMULA QUE OBJ_DAMAGE_TEST
    // =====================================================

    var _defensa_actual =
        0;


    with (_p)
    {
        _defensa_actual =
            get_jugador_defensa();
    }


    var _porcentaje_reduccion =
        min(
            _defensa_actual
            *
            1.6,
            50
        );


    var _dano_final =
        round(
            dano_base
            *
            (
                1
                -
                (
                    _porcentaje_reduccion
                    /
                    100
                )
            )
        );


    _dano_final =
        max(
            1,
            _dano_final
        );


    _p.hp =
        max(
            0,
            _p.hp
            -
            _dano_final
        );


    _p.map_battle_iframes =
        max(
            1,
            invulnerabilidad_frames
        );


    global.player_hp_current =
        _p.hp;


    if (
        audio_exists(
            snd_atacado
        )
    )
    {
        if (
            audio_is_playing(
                snd_atacado
            )
        )
        {
            audio_stop_sound(
                snd_atacado
            );
        }


        audio_play_sound(
            snd_atacado,
            10,
            false
        );
    }


    show_debug_message(
        "[BATALLA MAPA] Daño: "
        +
        string(_dano_final)
        +
        " | HP: "
        +
        string(_p.hp)
    );
}


instance_destroy();
