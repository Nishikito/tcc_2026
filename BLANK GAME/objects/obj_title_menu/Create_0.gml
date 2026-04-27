enum MENU_STATE {
    TITLE,
    SAVE_SELECT,
    NEW_SAVE,
    LOAD_SAVE
}

state = MENU_STATE.TITLE;

options = ["Start Game", "Settings", "Exit"];
index = 0;

save_options = ["New Game", "Load Game", "Back"];
save_index = 0;

player_name = "";
max_name_length = 12;