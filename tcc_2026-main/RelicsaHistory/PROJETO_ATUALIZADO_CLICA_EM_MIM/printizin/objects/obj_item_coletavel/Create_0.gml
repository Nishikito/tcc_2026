// ── CONFIGURAÇÃO POR INSTÂNCIA ────────────────────────────────────
// Defina no Creation Code de cada instância na sala:
//   text_id  = "item_teste_erva";   // qual diálogo/item é
//   item_uid = "erva_sala_teste";   // opcional: ID único desta instância
//   raio     = 24;                  // opcional: alcance da interação

text_id  = "";    // definido no Creation Code de cada instância na sala
item_uid = "";    // se ficar vazio, cai pro text_id (veja o Step)
raio     = 24;    // distância em pixels pra conseguir interagir
coletado = false;
no_alcance = false;

// Sprite placeholder — troque pelo sprite real do item quando tiver.
// Sem sprite o objeto fica invisível E sem máscara de colisão, que era
// exatamente o motivo do place_meeting nunca dar true antes.
if (sprite_index == -1 || sprite_index == noone) {
    sprite_index = SprGema;
}

// Animação de "flutuar" no chão, só pra chamar atenção
base_y      = y;
float_timer = irandom(360); // fase aleatória: itens não sobem em sincronia