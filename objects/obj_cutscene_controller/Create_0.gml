/// =========================================================
/// OBJ_CUTSCENE_CONTROLLER
/// CREATE
/// =========================================================

cutscene_id = "";
actions = [];
action_index = 0;

ready = false;

wait_timer = 0;

waiting_dialogue = false;
dialogue_seen = false;
dialogue_grace = 0;

waiting_sound_instance = -1;

move_tasks = [];
next_task_id = 0;
waiting_task_id = -1;

restore_player_movement = true;
cutscene_finished = false;
suspended_for_battle = false;

missing_end_warned = false;