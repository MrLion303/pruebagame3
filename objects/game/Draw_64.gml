draw_set_color(c_white);

var jugador = instance_find(obj_player, 0);

if (jugador != noone)
{
    draw_text(20, 20, "Jugador X: " + string(jugador.x));
    draw_text(20, 40, "Jugador Y: " + string(jugador.y));
    draw_text(20, 60, "Room: " + string(room_get_name(room)));
}