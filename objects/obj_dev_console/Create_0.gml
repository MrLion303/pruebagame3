
/// =========================================================
/// OBJ_DEV_CONSOLE - CREATE
/// =========================================================

persistent = true;
visible = true;
depth = -10000000;

if (instance_number(object_index) > 1)
{
    instance_destroy();
    exit;
}

console_open = false;
global.dev_console_open = false;

console_log = [];
console_suggestions = [];
console_suggestion_index = 0;
console_last_input = "";

ctrl_f3_pending = false;
ctrl_f3_used_for_console = false;

console_prev_player = noone;
console_prev_puede = true;
console_prev_can = true;

console_tp_pending = false;
console_tp_room = -1;
console_tp_x = 0;
console_tp_y = 0;

console_max_input = 140;
console_max_suggestions_draw = 8;
console_scale = 0.5;
