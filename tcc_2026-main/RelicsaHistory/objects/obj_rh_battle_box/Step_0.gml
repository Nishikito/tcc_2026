if (!instance_exists(obj_rh_battle_controller)) exit;

// A caixa abre durante o turno do inimigo e fecha em qualquer outro estado
var _open = (obj_rh_battle_controller.state == BATTLE_STATE.ENEMY_TURN);
var _prev = anim_frame;

if (_open) {
    anim_frame = min(BOX_ANIM_FRAMES, anim_frame + 1);
    anim_dir   = 1;
} else {
    anim_frame = max(0, anim_frame - 1);
    anim_dir   = -1;
}

anim    = anim_frame / BOX_ANIM_FRAMES;
moving  = (anim_frame != _prev);
is_open = (anim_frame >= BOX_ANIM_FRAMES);
