if (!party_npc_init()) exit;
depth = -bbox_bottom;
// Sprites ausentes no projeto (só existe spr_cgpt_down): cada direção cai para spr_cgpt_down
sprite[DOWN]  = spr_cgpt_down;
sprite[RIGHT] = asset_get_index("spr_cgpt_right");  if (sprite[RIGHT] == -1) sprite[RIGHT] = spr_cgpt_down;
sprite[LEFT]  = asset_get_index("spr_cgpt_left");   if (sprite[LEFT]  == -1) sprite[LEFT]  = spr_cgpt_down;
sprite[UP]    = asset_get_index("spr_cgpt_up");     if (sprite[UP]    == -1) sprite[UP]    = spr_cgpt_down;
