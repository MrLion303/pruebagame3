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
// COLISIÓN DE DAÑO CON MAYA
// =========================================================
//
// IMPORTANTE:
//
// Esto NO modifica la máscara de colisión normal de
// obj_player.
//
// Para recibir daño usamos una hitbox independiente que
// ocupa TODO el rectángulo visual del sprite actual de Maya.
//
// Así:
//
//     movimiento / paredes:
//         siguen usando la colisión normal del player.
//
//     proyectiles de mapa:
//         pueden golpear cualquier parte visible del sprite.
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
    instance_find(
        obj_player,
        0
    );


if (
    _p == noone
    ||
    _p.sprite_index == -1
)
{
    exit;
}


// =========================================================
// RECTÁNGULO VISUAL COMPLETO DEL SPRITE DEL PLAYER
// =========================================================
//
// Consideramos:
//
//     - ancho completo del sprite
//     - alto completo del sprite
//     - origen del sprite
//     - image_xscale
//     - image_yscale
//
// Maya normalmente no rota en el mapa, por eso no es
// necesario alterar su colisión normal ni generar una máscara.
// =========================================================

var _p_sprite_w =
    sprite_get_width(
        _p.sprite_index
    );


var _p_sprite_h =
    sprite_get_height(
        _p.sprite_index
    );


var _p_origin_x =
    sprite_get_xoffset(
        _p.sprite_index
    );


var _p_origin_y =
    sprite_get_yoffset(
        _p.sprite_index
    );


var _p_x1 =
    _p.x
    -
    (
        _p_origin_x
        *
        _p.image_xscale
    );


var _p_y1 =
    _p.y
    -
    (
        _p_origin_y
        *
        _p.image_yscale
    );


var _p_x2 =
    _p_x1
    +
    (
        _p_sprite_w
        *
        _p.image_xscale
    );


var _p_y2 =
    _p_y1
    +
    (
        _p_sprite_h
        *
        _p.image_yscale
    );


// Soporte por si algún sprite se dibuja invertido.
var _p_left =
    min(
        _p_x1,
        _p_x2
    );


var _p_right =
    max(
        _p_x1,
        _p_x2
    );


var _p_top =
    min(
        _p_y1,
        _p_y2
    );


var _p_bottom =
    max(
        _p_y1,
        _p_y2
    );


// =========================================================
// HITBOX DEL PROYECTIL
// =========================================================
//
// Aquí conservamos la hitbox/máscara normal de la bala.
// Solo estamos ampliando el lado del PLAYER.
//
// bbox_* pertenece al proyectil actual.
// =========================================================

var _impacta_player =
(
    bbox_right
    >=
    _p_left

    &&
    bbox_left
    <=
    _p_right

    &&
    bbox_bottom
    >=
    _p_top

    &&
    bbox_top
    <=
    _p_bottom
);


if (!_impacta_player)
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


    // =====================================================
    // SCREEN SHAKE UNIVERSAL
    // =====================================================
    //
    // Solo llegamos aquí si ESTA bala realmente consiguió
    // aplicar daño; los impactos bloqueados por i-frames no
    // reinician la sacudida.
    // =====================================================

    scr_screen_shake_start(
        3,
        8
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
