switch(global.daniel_sprite_state) {
    case "normal":
        sprite_index = SprBobao;
        break;
    case "feliz":
        sprite_index = SprBobaoTeste;
        break;
    case "assustado":
        // sprite ausente no projeto: usa o normal até ela ser adicionada
        sprite_index = asset_get_index("SprBobaoAssustado");
        if (sprite_index == -1) sprite_index = SprBobao;
        break;
    default:
        sprite_index = SprBobao;
        break;
}