switch(global.daniel_sprite_state) {
    case "normal":
        sprite_index = SprBobao;
        break;
    case "feliz":
        sprite_index = SprBobaoTeste;
        break;
    case "assustado":
        sprite_index = SprBobaoAssustado;
        break;
    default:
        sprite_index = SprBobao;
        break;
}