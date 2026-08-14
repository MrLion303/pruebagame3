// Cuando la animación en reversa llega al inicio (0), se destruye limpiamente en la nueva room
if (image_speed < 0) {
    instance_destroy();
}