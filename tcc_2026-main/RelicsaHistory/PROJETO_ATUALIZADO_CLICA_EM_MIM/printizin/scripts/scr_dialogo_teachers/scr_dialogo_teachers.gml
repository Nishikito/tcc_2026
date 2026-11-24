/// Diálogos da sala dos professores. O prefixo "teachers" do ID escolhe este script.
function scr_dialogo_teachers(_text_id) {
    switch (_text_id) {

        case "teachers_livro1":
            scr_text("Um livro?", "");
            break;

        case "teachers_livro2":
            scr_text("O que tá acontecendo!?", "");
            break;
    }
}
