/// =========================================================
/// OBJ_ENEMIGO_BATALLA_MAPA_PARENT
/// STEP
/// =========================================================


// =========================================================
// SEGURIDAD
// =========================================================

if (
    batalla_iniciada
    ||
    room == bbs
    ||
    room == game_over
)
{
    exit;
}


// =========================================================
// PAUSA PREVIA A BATALLA - ENEMIGO DE CONTACTO
// =========================================================
//
// IMPORTANTE:
// Este bloque va ANTES de scr_cutscene_world_locked().
//
// Durante esta pausa nosotros mismos activamos
// global.cutscene_active para bloquear el mundo. Si esta
// sección estuviera después, este objeto también se quedaría
// bloqueado y nunca podría terminar su cuenta regresiva.
//
// El enemigo NO se mueve durante este segundo.
// El sprite de alerta sí puede seguir animándose.
// =========================================================

if (pausa_contacto_activa)
{
    mostrar_sprite_alerta();


    if (alerta_timer > 0)
    {
        alerta_timer--;
    }


    if (alerta_timer > 0)
    {
        exit;
    }


    pausa_contacto_activa =
        false;


    // Ya terminó la pausa. Recuperamos al jugador y entramos
    // inmediatamente a BBS.
    if (instance_exists(obj_player))
    {
        var _p_contacto =
            instance_find(
                obj_player,
                0
            );


        iniciar_batalla_bbs(
            _p_contacto
        );
    }
    else
    {
        // Seguridad: si por alguna razón Maya ya no existe,
        // liberamos el bloqueo del mundo.
        global.cutscene_active =
            false;
    }


    exit;
}


// =========================================================
// BLOQUEOS NORMALES DEL MUNDO
// =========================================================

if (
    scr_cutscene_world_locked()
    ||
    instance_exists(obj_pauser)
)
{
    image_speed =
        0;

    exit;
}


if (contacto_cooldown > 0)
{
    contacto_cooldown--;
}


// =========================================================
// PLAYER
// =========================================================

if (!instance_exists(obj_player))
{
    image_speed =
        0;

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
    !instance_exists(_p)
)
{
    exit;
}


// =========================================================
// ESPERA DE ALERTA - ENEMIGO DE PERSECUCIÓN
// =========================================================
//
// Cuando detecta a Maya:
//
//     1. cambia al sprite de alerta;
//     2. se queda completamente quieto;
//     3. espera alerta_persecucion_frames;
//     4. después empieza a perseguir.
//
// Maya NO se congela. Solo se detiene este enemigo.
// =========================================================

if (
    modo_activacion == "persecucion"
    &&
    esperando_persecucion
)
{
    mostrar_sprite_alerta();


    if (alerta_timer > 0)
    {
        alerta_timer--;
    }


    if (alerta_timer > 0)
    {
        exit;
    }


    esperando_persecucion =
        false;

    persiguiendo =
        true;
}


// =========================================================
// DETECTAR PERSECUCIÓN
// =========================================================
//
// Entrar una sola vez en el rango activa la alerta.
//
// Una vez detectada Maya, aunque se aleje durante esos
// 0.5 segundos, al terminar la espera el enemigo comenzará a
// perseguirla y no dejará de hacerlo hasta:
//     - tocarla;
//     - o abandonar la habitación.
// =========================================================

if (
    modo_activacion == "persecucion"
    &&
    !alerta_activa
    &&
    !persiguiendo
    &&
    !esperando_persecucion
)
{
    var _dist_rango =
        point_distance(
            x,
            y,
            _p.x,
            _p.y
        );


    if (_dist_rango <= rango_persecucion)
    {
        alerta_activa =
            true;

        esperando_persecucion =
            true;

        alerta_timer =
            alerta_persecucion_frames;


        mostrar_sprite_alerta();


        // Si el tiempo configurado es 0, perseguirá desde el
        // próximo bloque en el siguiente Step.
        if (alerta_timer <= 0)
        {
            esperando_persecucion =
                false;

            persiguiendo =
                true;
        }
        else
        {
            exit;
        }
    }
}


// =========================================================
// ELEGIR OBJETIVO DE MOVIMIENTO
// =========================================================

var _target_x =
    x;

var _target_y =
    y;

var _move_speed =
    0;


if (
    modo_activacion == "persecucion"
    &&
    persiguiendo
)
{
    // -----------------------------------------------------
    // PERSEGUIR A MAYA
    // -----------------------------------------------------

    _target_x =
        _p.x;

    _target_y =
        _p.y;

    _move_speed =
        persecucion_velocidad;
}
else
{
    // -----------------------------------------------------
    // PATRULLA A <-> B
    // -----------------------------------------------------

    if (patrulla_objetivo == 0)
    {
        _target_x =
            patrulla_x1;

        _target_y =
            patrulla_y1;
    }
    else
    {
        _target_x =
            patrulla_x2;

        _target_y =
            patrulla_y2;
    }


    _move_speed =
        patrulla_velocidad;
}


// =========================================================
// MOVER
// =========================================================

var _old_x =
    x;

var _old_y =
    y;


var _dist_objetivo =
    point_distance(
        x,
        y,
        _target_x,
        _target_y
    );


if (
    _move_speed > 0
    &&
    _dist_objetivo > 0.01
)
{
    var _paso =
        min(
            _move_speed,
            _dist_objetivo
        );


    var _dir =
        point_direction(
            x,
            y,
            _target_x,
            _target_y
        );


    x +=
        lengthdir_x(
            _paso,
            _dir
        );


    y +=
        lengthdir_y(
            _paso,
            _dir
        );
}


// =========================================================
// CAMBIAR EXTREMO DE PATRULLA
// =========================================================

if (
    !(modo_activacion == "persecucion" && persiguiendo)
    &&
    point_distance(
        x,
        y,
        _target_x,
        _target_y
    )
    <=
    max(
        0.5,
        patrulla_velocidad
    )
)
{
    x =
        _target_x;

    y =
        _target_y;


    patrulla_objetivo =
        1
        -
        patrulla_objetivo;
}


// =========================================================
// SPRITE
// =========================================================
//
// Si está en alerta:
//     SIEMPRE conserva sprite_alerta.
//
// Si no está en alerta:
//     usa los sprites normales/direccionales.
// =========================================================

var _dx =
    x - _old_x;

var _dy =
    y - _old_y;

var _moving =
    abs(_dx) > 0.001
    ||
    abs(_dy) > 0.001;


if (alerta_activa)
{
    mostrar_sprite_alerta();
}
else
{
    if (_moving)
    {
        var _sprite_nuevo =
            sprite_default;


        if (abs(_dx) >= abs(_dy))
        {
            if (_dx > 0)
            {
                if (
                    sprite_derecha != -1
                    &&
                    sprite_exists(sprite_derecha)
                )
                {
                    _sprite_nuevo =
                        sprite_derecha;
                }
            }
            else
            {
                if (
                    sprite_izquierda != -1
                    &&
                    sprite_exists(sprite_izquierda)
                )
                {
                    _sprite_nuevo =
                        sprite_izquierda;
                }
            }
        }
        else
        {
            if (_dy > 0)
            {
                if (
                    sprite_abajo != -1
                    &&
                    sprite_exists(sprite_abajo)
                )
                {
                    _sprite_nuevo =
                        sprite_abajo;
                }
            }
            else
            {
                if (
                    sprite_arriba != -1
                    &&
                    sprite_exists(sprite_arriba)
                )
                {
                    _sprite_nuevo =
                        sprite_arriba;
                }
            }
        }


        if (
            _sprite_nuevo != -1
            &&
            sprite_exists(_sprite_nuevo)
            &&
            sprite_index != _sprite_nuevo
        )
        {
            sprite_index =
                _sprite_nuevo;

            image_index =
                0;
        }


        image_speed =
            image_speed_caminando;
    }
    else
    {
        image_speed =
            0;

        image_index =
            0;
    }
}


// =========================================================
// CONTACTO CON MAYA
// =========================================================

if (contacto_cooldown > 0)
{
    exit;
}


var _dist_contacto =
    point_distance(
        x,
        y,
        _p.x,
        _p.y
    );


if (_dist_contacto > radio_contacto)
{
    exit;
}


// =========================================================
// CONTACTO: ALERTA + 1 SEGUNDO + BATALLA
// =========================================================
//
// NO entra inmediatamente a BBS.
//
// Primero:
//     - cambia al sprite de alerta;
//     - bloquea a Maya;
//     - bloquea el mundo mediante cutscene_active;
//     - espera el tiempo configurado.
//
// Después inicia la batalla.
// =========================================================

if (modo_activacion == "contacto")
{
    alerta_activa =
        true;

    pausa_contacto_activa =
        true;

    alerta_timer =
        alerta_contacto_frames;


    mostrar_sprite_alerta();


    // Bloqueo global del mundo.
    // Los sistemas que ya respetan scr_cutscene_world_locked()
    // se quedan congelados durante esta pausa.
    global.cutscene_active =
        true;


    // Bloquear específicamente al jugador.
    if (
        variable_instance_exists(
            _p,
            "puede_moverse"
        )
    )
    {
        _p.puede_moverse =
            false;
    }


    if (
        variable_instance_exists(
            _p,
            "can_move"
        )
    )
    {
        _p.can_move =
            false;
    }


    if (
        variable_instance_exists(
            _p,
            "cutscene_motion_active"
        )
    )
    {
        _p.cutscene_motion_active =
            false;
    }


    _p.image_index =
        0;


    // Si el tiempo se configuró en 0, entrar inmediatamente.
    if (alerta_timer <= 0)
    {
        pausa_contacto_activa =
            false;

        iniciar_batalla_bbs(
            _p
        );
    }


    exit;
}


// =========================================================
// PERSECUCIÓN: BATALLA INMEDIATA AL TOCAR
// =========================================================
//
// No hay pausa adicional.
//
// La pausa de 0.5 s ya ocurrió cuando el enemigo detectó al
// jugador. Una vez persiguiendo, tocar a Maya entra a BBS
// directamente.
// =========================================================

if (modo_activacion == "persecucion")
{
    iniciar_batalla_bbs(
        _p
    );

    exit;
}
