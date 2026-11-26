# Refazimento dos ataques do Itagibe — relatório

## 1. Problemas confirmados (leitura do código + rastreio manual)

1. **Rotação vs. desenho recortado (confirmado).** `obj_rh_atk_lanca/Step_0.gml` fazia `image_angle = dir`, mas o Draw herdado de `obj_rh_battle_bullet` chama `rh_draw_clipped(sprite_index, ...)`, que **ignora `image_angle`**. O sprite ficava sempre deitado enquanto a máscara girava em torno da origem (0,0). Para `dir = 180` a máscara ia parar ~66 px à esquerda e ~12 px acima do desenho: área invisível machucava e a ponta visível podia ser atravessada.
   - **Achado extra:** em GML, `90° = baixo` e `270° = cima`. O `pat_lancas_teto` usava `dir = 270` achando que era descida; na prática as lanças subiam.
2. **Lanças do teto injustas (confirmado).** `pat_lancas_teto` nascia em `_r.y1 + i*26`, **dentro** da caixa, sem aviso. O jogador podia ser acertado no frame em que a lança aparecia.
3. **Vasos/ossos vazios (confirmado).** `obj_rh_atk_vaso` punha o vaso em `y2-15` e soltava o osso em `y + 15 = y2 = 143`, com `vy = +1.7` (para baixo). O osso já nascia abaixo da caixa, era recortado (invisível) e morria em ~14 frames. O turno era efetivamente vazio.
4. **Sprite:** o arquivo diz que `spr_lanca_attack` tem 4 quadros, mas o `.yy` e a pasta têm **1 quadro apenas**. As variantes geradas preservam esse quadro único e toda a configuração de sequência/animação do original; nada foi desenhado à mão.

Verificação com `RH_ATK_DEBUG_ZONES`: **não foi ligada dentro do jogo** (jogo não executado — ver item 4). O que foi feito foi o rastreio estático: os quatro sprites usados pelas lanças têm origem 0,0, máscara retângulo cheio e `image_angle = 0` permanente, logo o contorno de debug (`bbox_left..bbox_right`, `bbox_top..bbox_bottom`) coincide com o retângulo que `rh_draw_clipped` desenha. Nos ossos, o Draw próprio usa o mesmo `image_angle` da máscara, então o giro não cria área invisível.

## 2. Arquivos criados

**Sprites (gerados por `tools/gerar_variantes_lanca_itagibe.py`, com Pillow):**
- `sprites/spr_lanca_right_attack/` — espelho horizontal do original (ponta à direita), 66x12.
- `sprites/spr_lanca_up_attack/` — rotação de 270° (ponta para cima), 12x66.
- `sprites/spr_lanca_down_attack/` — rotação de 90° (ponta para baixo), 12x66.

A primeira geração tinha trocado as duas rotações: a ponta sólida do original fica na **esquerda** (a direita é a cauda em "V"). A orientação foi corrigida e os PNGs foram regenerados (`tools/gerar_variantes_lanca_itagibe.py` agora apaga o PNG antigo antes de salvar, sem deixar quadro órfão). Conferência por máscara alfa: `up` tem a ponta no topo e a cauda embaixo; `down` tem a ponta embaixo e a cauda no topo.

**Objetos:**
- `objects/obj_rh_atk_lanca_h/` — aviso → voo horizontal → fim. Escolhe `spr_lanca_attack` (da direita) ou `spr_lanca_right_attack` (da esquerda). `image_angle` nunca é alterado.
- `objects/obj_rh_atk_lanca_v/` — aviso → voo vertical → fim. `vy` explícito (evita a confusão de graus do GML) e sprite `up`/`down` conforme a origem.
- `objects/obj_rh_atk_vaso_itagibe/` — treme 24 frames, solta 2 a 4 ossos em arco (conforme a formação) e afunda em 8 frames. `active = false` (não machuca).
- `objects/obj_rh_atk_bone_arco/` — osso com gravidade e **giro por código** (`image_angle` oscilação amortecida de até 14°, sentido sorteado), exclusivo do Itagibe. Ganhou um event Draw próprio que desenha com a **mesma rotação da máscara** (`draw_sprite_ext` quando `image_angle != 0`; `rh_draw_clipped` quando parou). O `obj_rh_atk_bone` original **não foi tocado** (continua usado pelo Apressador das Sombras).

**Feedback visual reduzido:** os avisos das lanças agora são uma faixa fina de 4 px no centro da raia/coluna (antes cobriam a raia/coluna inteira), para várias telegrafias não ficarem empilhadas umas sobre as outras.

**Ferramentas:**
- `tools/gerar_variantes_lanca_itagibe.py` — gera PNGs, `.yy` e insere as entradas no `.yyp`.
- `tools/validar_itagibe.py` — valida JSON, nomes, balanceamento e imprime os rastreios.

**Alterados:**
- `objects/obj_rh_en_itagibe/Create_0.gml` — ficha intacta (HP 280, dano 2-4), três padrões novos e `patterns = [round_lancas_laterais, round_lancas_verticais, round_vasos_ossos]`; `pattern_names` atualizado.
- `scripts/scr_rh_attacks/scr_rh_attacks.gml` — **duas funções novas** (`rh_draw_warning_rect`, `rh_draw_warning_line`), no mesmo estilo piscante de `rh_draw_warning`. Nenhuma função existente foi modificada.
- `sprites/spr_lanca_attack/spr_lanca_attack.yy` — `bbox_left` de 1 para 0 (máscara também vira retângulo cheio nas quatro direções).
- `printizin2meajuda_corrigido.yyp` — 4 objetos + 3 sprites registrados.

Objetos antigos `obj_rh_atk_lanca` e `obj_rh_atk_vaso` ficaram sem uso pelo Itagibe, mas **foram mantidos** (ninguém mais os usa, porém removê-los não traria benefício e aumentaria o risco). Final de linha preservado: `.gml` e `.yyp` em CRLF, `.yy` em LF.

## 3. Números e linha do tempo (rastreio manual, sem executar o jogo)

### Round 1 — lanças laterais
Constantes no topo de `round_lancas_laterais`: `n_raias = 4`, `alt_raia = 19`, `topo_lanca = 3.5`, `vezes = [10,80,150,220]`, `aviso = 22`, `velocidade = 4.2`, `espaco = 8`, `extras = [1,1,2,2]`.

| salva | origem | aviso (piscando) | voo | fim | bloqueia / livre |
|---|---|---|---|---|---|
| 1 (t=10) | direita (`left`) | 10..31 | 32..80 | 80 | 2 raias / 2 livres |
| 2 (t=80) | esquerda (`right`) | 80..101 | 102..150 | 150 | 2 raias / 2 livres |
| 3 (t=150) | direita | 150..171 | 172..228 | 228 | 3 raias / 1 livre |
| 4 (t=220) | esquerda | 220..241 | 242..298 | **298** | 3 raias / 1 livre |

Nasce em `x = bx2+1 = 205` (máscara 205..270) ou `x = bx1-66 = 40` (máscara 40..105): fora da caixa, dentro da room. Voo reto a 4.2 px/frame; `dmg_mult = 1.0`, `destroy_on_hit = true`. Raia do coração travada no início do aviso.

### Round 2 — lanças verticais
Constantes: `n_colunas = 6` (~16,5 px), `vezes = [8,84,160,236]`, `aviso = 20`, `velocidade = 4.2`, `espaco = 4`, 3 de cima por salva + 1 de baixo nas ímpares.

| salva | aviso | tops (ponta para baixo) | lança de baixo | fim |
|---|---|---|---|---|
| 1 (t=8) | 8..27 | 28..71 | 28..63 | 71 |
| 2 (t=84) | 84..103 | 104..147 | — | 147 |
| 3 (t=160) | 160..179 | 180..223 | 180..215 | 223 |
| 4 (t=236) | 236..255 | 256..299 | — | **299** |

Nasce em `y = by1-66 = -1` (máscara -1..64, ponta em 64) ou `y = by2+1 = 144` (máscara 144..209): parcialmente/totalmente dentro da room, então o `Outside Room` não destrói no meio do voo. **Vão seguro:** um par de colunas adjacentes (~33 px) é sorteado antes de escolher os alvos e nunca contém a coluna do coração; sobram 2 colunas adjacentes livres em toda salva.

### Round 3 — vasos e chuva de ossos
Constantes no topo de `round_vasos_ossos`: `vezes = [8,150]`, 2 vasos por onda, `sep_minima = 36`, `dist_coracao = 18`, `intervalo = 9`, `grav = 0.16`, `vy0` entre -3,2 e -3,8, `limite_ossos = 8`.

A cada onda uma das três formações é sorteada (`irandom`), com jitter pequeno em `x` para não repetir sempre o mesmo lugar:

| formação | posição dos vasos | ossos por vaso | total | `vx` (por vaso) | equilíbrio |
|---|---|---|---|---|---|
| pontas | perto das bordas, mas deslocados para dentro | 2 | 4 | ~0,45 voltado ao meio | poucos ossos convergindo |
| centro | dois vasos a ~40 px do centro da caixa | 4 | 8 | -0,12 / 0 / +0,12 | chuva mais cheia, quase reta |
| terços | entre a borda e o centro | 3 | 6 | ~0,22 voltado ao meio | intermediário |

- Onda 1: treme em 8..31; ossos a partir do frame 32.
- Onda 2: treme em 150..173; ossos a partir do frame 174; a formação mais cheia termina por volta de **280** (antes de 300).
- Pico do arremesso: `vy0²/(2*grav) <= 3,8²/0,32 ≈ 45 px`. Nascendo em `y = 78`, o topo chega a `y ≈ 33` — dentro da room; o `Outside Room` não atrapalha.
- Osso nasce em `y = vaso_y - 50 = 78` e **gira ao sair do vaso**: `image_angle = spin_dir * 14 * dsin(t * 10) * max(0, 1 - t/24)`, com sentido sorteado por osso. O giro some suavemente no topo do arco.
- Varredura de `x` do coração (109..201, 200 jitters por caso): separação mínima entre vasos **36 px** e distância mínima do centro do vaso ao coração **18 px** em todas as formações (~20 pedido; a caixa de 98 px não permite mais quando o coração fica no centro).
- Cobertura: `vx` é o mesmo para todos os ossos de um vaso, então eles viajam agrupados. Com o giro de 14°, cada grupo ocupa ~19 px; dois grupos = ~38 px de 98 px (39% < 40%). Limite global de 8 ossos vivos continua como teto de segurança.

## 4. O que NÃO foi testado

- **Não rodei o jogo** (nem GameMaker, nem depurador). Não afirmei que testei em execução.
- `RH_ATK_DEBUG_ZONES` **não foi ligado em partida**: a coincidência desenho/hitbox foi conferida só por leitura das máscaras (lanças com `image_angle = 0`; ossos com Draw usando o mesmo ângulo da máscara).
- A orientação das pontas foi conferida pela máscara alfa dos PNGs, **não vendo o jogo rodar**.
- Não houve teste de input real, nem medição de acertos por turno com jogador humano. A meta "~1 acerto, no máximo 2" foi projetada por construção (aviso longo, faixas livres, dano single-hit), não medida empiricamente.
- A contagem de ossos simultâneos, os tempos de voo e o giro dos ossos são cálculos analíticos, não observação em runtime.

## 5. Ajustes finos sugeridos

1. Se o dono preferir **gravidade 0,11** exatamente, agora cabe: o maior grupo tem 8 ossos e o último termina por volta do frame 294. Mude `grav` no topo de `round_vasos_ossos` (e no Create do osso, se quiser o mesmo valor inicial).
2. Tempos de voo: `velocidade` está no topo de cada padrão (4,2). Para dificultar, suba para 4,6–4,8 no Round 1; para facilitar, 3,6.
3. `aviso` (22 / 20 / 24) e `espaco` (8 / 4 / 9) também estão no topo: aumentar `espaco` no Round 2 estoura 300 frames, então mexa junto com `vezes`.
4. `extras` do Round 1 controla a dificuldade: `[1,1,2,2]` dá 2, 2, 1 e 1 raia(s) livre(s). Trocar o último para 1 deixa o turnofinal mais fácil.
5. Se `RH_DEBUG_FORCE_PATTERN` for usado, índices 0/1/2 agora correspondem a laterais / verticais / vasos.

## 6. Ajustes posteriores (solicitados depois do relatório)

### Arquivos de camada dos sprites (problema confirmado)
O GameMaker reclamou de `sprites\spr_lanca_*_attack\layers\<frame>\<layer>.png`. Conferência: os 3 sprites novos tinham só o PNG na raiz; o original `spr_lanca_attack` tem também `layers/<uuid do quadro>/<uuid da camada>.png`.

Correção em `tools/gerar_variantes_lanca_itagibe.py`: o gerador agora lê o UUID da camada do `.yy` original, cria `layers/<novo uuid do quadro>/` e salva o PNG lá também (apagando os anteriores). O script foi executado novamente. `tools/validar_itagibe.py` agora checa esse arquivo para **todos** os sprites do projeto: `0` faltando.

### Tamanho dos inimigos
`obj_rh_battle_enemy/Create_0.gml` ganhou `enemy_anchor_x/y` e a função `set_enemy_size(_mult)`, que recalcula o encaixe em `ENEMY_MAX_W/H`, aplica o multiplicador e reposiciona o sprite mantendo o centro da room. Chamadas nos filhos:

- Itagibe: `set_enemy_size(0.4)` — 60% menor.
- Guaraná: `set_enemy_size(0.75)` — 25% menor.
- Monstro das Monções: `set_enemy_size(1.05)` — 5% maior.

Como os filhos chamam a função depois de `event_inherited()`, `enemy_px()/enemy_py()` (usadas para spawnar frutas) já leem a escala nova.

### Mini barra de vida
`obj_rh_battle_enemy/Draw_0.gml` desenha, após o inimigo, uma barra vertical de 6x30 px à direita do sprite. Ela lê `enemy_hp / enemy_max_hp` do `obj_rh_battle_controller`, com fundo escuro, borda preta e as mesmas cores do HUD (amarelo > 50%, laranja > 25%, vermelho). Não cobre o corpo nem mexe na barra do jogador.

### Validação desta rodada
- 485 `.yy`/`.yyp` JSON válidos;
- 0 PNGs de camada faltando;
- 18 `.gml` tocados com parênteses/chaves balanceados;
- 40 nomes `obj_/spr_/rh_` citados existem;
- `.gml`/`.yyp` em CRLF, `.yy` em LF.

**Não rodei o jogo** nesta rodada também: a correção dos PNGs foi conferida no sistema de arquivos e o posicionamento da barra/tamanhos por leitura do código.

## 7. Ajustes finais (transição + barra horizontal)

### Tamanho durante a transição
O `obj_battle_transition` calculava `battle_enemy_fit` só com `ENEMY_MAX_W/H`, ignorando os multiplicadores aplicados no Create do inimigo — por isso o inimigo chegava ao destino no tamanho original e "encolhia" ao entrar na batalha.

Centralizei o valor em `scripts/scr_damage_calculator/scr_damage_calculator.gml`:

```
get_rh_enemy_size(obj_rh_en_itagibe)            -> 0.4
get_rh_enemy_size(obj_rh_en_guarana)            -> 0.75
get_rh_enemy_size(obj_rh_en_monstro_das_mocoes) -> 1.05
outros                                          -> 1
```

- `obj_rh_battle_enemy/Create_0.gml` agora chama `set_enemy_size(get_rh_enemy_size(object_index))` (removidas as chamadas duplicadas dos três filhos).
- `obj_battle_transition/Create_0.gml` multiplica `battle_enemy_fit` pelo mesmo valor. `Draw_73.gml` já usa `battle_enemy_fit` no `lerp`, então o deslize termina no tamanho da batalha, sem salto. O `e_start_scale` continua sendo o tamanho do mundo, então a mudança acontece suavemente durante o deslize.

### Barra horizontal
A mini barra em `obj_rh_battle_enemy/Draw_0.gml` deixou de ser vertical/lateral e agora é horizontal (64x6 px), centralizada e **12 px acima do topo do sprite**, com o topo calculado com a escala atual (`y - sprite_get_yoffset(sprite_index) * image_yscale`). Mesmas cores do HUD.

### Validação
485 JSON válidos, 0 camadas faltando, 21 `.gml` tocados balanceados, 61 nomes conferidos. CRLF/LF preservados. **Jogo não executado.**

## 8. Iframes do coração (1 segundo)

- `obj_rh_battle_player/Create_0.gml`: `iframe_max = 60` (60 fps, o mesmo uso de frames=1s da transição) e `iframe_timer = 0`.
- `obj_rh_battle_player/Step_0.gml`: o contador é decrementado logo após checar o controller (conta mesmo com a caixa fechada). Toda a checagem de colisão ficou dentro de `if (iframe_timer <= 0)`: durante os iframes os ataques **não causam dano e não são consumidos**. No acerto, `iframe_timer = iframe_max` e o `talai_hit_timer`/knockback continuam funcionando como antes.
- `obj_rh_battle_player/Draw_0.gml`: enquanto `iframe_timer > 0`, o sprite pisca em 4 frames aceso / 4 apagado (≈7,5 Hz) multiplicando `image_alpha` por 0,3. O fade da abertura da caixa continua respeitado.
- Único ponto de dano ao jogador é esse bloco (`apply_damage_to_player` não é chamado em nenhum outro `.gml`), então não há caminho que burle os iframes.

Validação: 24 `.gml` balanceados, 62 nomes conferidos, 485 JSON válidos, 0 camadas faltando. **Jogo não executado**; 60 frames = 1 s assume a taxa padrão de 60 fps do projeto.

## 9. Fundo repetido da rm_rh_battle

- `rooms/rm_rh_battle/rm_rh_battle.yy`: removido o `GMRAssetLayer` `Assets_1`, que tinha uma única cópia de `spr_fundo_batalha` esticada para 21×17 (336×272 px) e cobria quase toda a room de 320×240.
- O `GMRBackgroundLayer` `Background` agora usa `spr_fundo_batalha` com `htiled:true`, `vtiled:true` e `stretch:false`: o tile original de 16×16 se repete por toda a room, nos dois eixos.
- `colour` mudou de preto (4278190080) para branco (4294967295) para não tingir o sprite. `animationFPS` foi para 26 com `userdefinedAnimFPS:true`, acompanhando o `playbackSpeed:26` do próprio sprite (14 frames); a linha fina do padrão "corre" pelo mosaico.
- `depth:400` continua sendo o maior da room, então o fundo desenha atrás de `Controller` (0), `Battle` (100) e `Bullets` (200 no `.yy`; os tiros sobem para 1 por código — ver §10).
- Correção pós-teste: `spr_fundo_batalha.yy` tinha `nineSlice.enabled:true`. Backgrounds do GameMaker não desenham sprites com nine-slice ("Background can't draw sprites that have nine-slice drawing enabled"), então o valor passou para `false`. O erro aparecia no Create do `obj_rh_battle_enemy` apenas por ser o evento ativo quando a sala começou a desenhar. `validar_fundo_batalha()` agora também barra esse caso.
- Nenhum asset novo: sprite e room já existiam, então o `.yyp` não precisou ser alterado.
- Validação: 486 JSON válidos, 0 camadas faltando, 24 `.gml` balanceados, 62 nomes conferidos e a nova checagem `validar_fundo_batalha()` passou. **Jogo não executado**; a conferência foi por leitura do `.yy`, da ordem de depth e dos PNGs de 16×16 do sprite.

## 10. Fundo preto da Battle Box sem esconder projéteis

- Correção pós-teste 2: `spr_rh_battle_box` tinha o interior **transparente** (alpha 0) e só a borda verde de 1 px. As linhas do fundo animado apareciam dentro da caixa e o coração se confundia com elas. Os 7644 pixels internos dos dois PNGs (quadro e layer) passaram a ser preto opaco `(0,0,0,255)`; a borda verde foi preservada. `validar_battle_box()` confere o pixel central.
- Teste descartado: desenhar o preto por código no `Draw_0.gml` criou uma segunda caixa dessincronizada do rastro (o sprite desenha cópias com animação atrasada). O preto passou a vir **só do PNG**, que acompanha a animação naturalmente. Se o IDE estiver com a textura antiga em cache, reimporte `spr_rh_battle_box`.
- O problema do depth era separado: os ataques eram criados na layer `Bullets` (200), ou seja, **atrás** da caixa (10). Depois de deixar o interior opaco, isso passaria a esconder os tiros — daí o ajuste de depth abaixo.
- Ordem adotada (GameMaker desenha primeiro o depth maior): fundo 400 → `Battle` 100 → caixa 10 → **projéteis 1** → `Controller`/HUD 0 → coração -1 → martelo/bota -5.
- `rooms/rm_rh_battle/rm_rh_battle.yy`: a layer `Bullets` continua em `depth:200` — o IDE reescreve o `.yy` ao salvar e restaura esse valor. Por isso a correção não depende da depth da layer.
- `scripts/scr_rh_attacks/scr_rh_attacks.gml`: novo macro `RH_BULLET_DEPTH 1`. `rh_spawn_attack()` cria na layer e, se a instância ficou em depth 200 (padrão da layer, ou o fallback sem layer), sobe o tiro para o macro. Ataques que já definem depth próprio no Create (martelo/bota = -5) não são alterados. Essa é a correção efetiva confirmada no teste.
- `objects/obj_rh_battle_enemy/Alarm_0.gml`: a bala antiga agora passa pelo mesmo `rh_spawn_attack()` em vez de ser criada direto na layer.
- `validar_projeteis()` confere o macro, o ajuste por instância em `rh_spawn_attack()` e o spawn da bala antiga (não mais a depth da layer, que o IDE restaura). Validação passou; **jogo não executado**.

## 11. Diálogos de visual novel na história

- Convenção confirmada: `scr_text(texto, "talai-<emoção>")` resolve o retrato grande em `talai_vn_sprite()`. Como as quatro salas pedidas não estão em `room_is_story_world()`, ele devolve exatamente os sprites `spr_talai_*_visual_novel` (e não as variantes `talaiB`). As falas sem segundo argumento ficam sem retrato — é o caso do Bobalhao, que não tem sprite de visual novel.
- **Correção após o teste do usuário:** a primeira versão criou `scr_dialogo_historia`, `scr_cena_historia` e dois `obj_cutscene_trigger`. Ao rodar, o IDE reescreveu o `.yyp` e os `.yy` das rooms com a versão que estava carregada na memória descartando tudo isso; sobrou só o `create_textbox("historia_acordar")`, sem script de diálogo → **caixa preta vazia**. Os arquivos órfãos foram removidos e nada mais depende de recurso novo.
- `scripts/scr_game_text/scr_game_text.gml` (script já registrado): casos explícitos para `historia_acordar`, `historia_corredor` e `historia_bobalhao`, antes do despacho por prefixo. As 7 falas e seus retratos ficam dentro dele, então não há script novo para o IDE perder.
- `objects/obj_fade_intro/Step_0.gml`: quando o fade clareia em `RoomClass1_1`, dispara `create_textbox("historia_acordar")` e marca `global.dialog_active = true` (o `create_textbox()` sozinho não marca). Fala: "Nossa... Eu dormi pra caramba... Já até deu o horário do almoço..." com `talai-preocupado`.
- `objects/ObjPlayer/Step_0.gml` (player persistente): ao entrar no retângulo **(390, 95) a (470, 365)** em `RoomSalasCorredor`, dispara `create_textbox("historia_corredor")`, marca `global.dialog_active` e guarda `global.historia_corredor_done` para falar só uma vez. Fala: "Onde será que o René deve estar? Vou ver com alguém da nossa sala." com `talai-pensando`. Foi para o Step do player porque o IDE remove trigger novo da room. A área foi alargada depois que o usuário conseguiu burlar o gatilho antigo (raio de 28 px em torno de (424, 195)).
- `rooms/RoomRefeitorio/InstanceCreationCode_inst_9AA662.gml`: reposiciona o `obj_speakblock` **que já existe** na sala para **(357, 120)**, zera o `image_xscale` (a instância vinha com 4, da área antiga da cantina) e aponta `text_id = "historia_bobalhao"`. O sprite do NPC já existe na room (graphic em 352, 96), então não foi duplicado. O ENTER continua sendo o do próprio `obj_speakblock/Step_0.gml`. Conversa em 5 páginas: Talai `talai-falando`, Bobalhao sem retrato, Talai `talai-falando`, Bobalhao sem retrato, Talai `talai-sorrindo`.
- `RoomTeachers`: nada a alterar — `scr_dialogo_teachers` já usava `talai-pensando` em `teachers_livro1` e `talai-surpreso` em `teachers_livro2`, exatamente os retratos pedidos na queda.
- `validar_dialogos()` confere os recursos no `.yyp`, as 7 falas com seus retratos dentro do `scr_game_text`, o disparo no fade, a checagem no Step do player, o speakblock reposicionado com o sprite do NPC e os retratos da RoomTeachers. Validação passou; **jogo não executado**. Se o IDE estiver aberto, é preciso fechar e reabrir o projeto (ou Reimportar) para ele ler os `.gml` alterados.

## 12. Companion Rasiel (segue o player)

- **Correção após o teste do usuário:** a primeira versão criou o objeto `obj_companion_rasiel`. O IDE reescreveu o `.yyp` novamente e removeu o registro; o GML tratou o nome como variável e deu `Variable ObjPlayer.obj_companion_rasiel not set before reading it` no Room Start. O objeto foi removido e nada mais depende de recurso novo.
- O Rasiel agora é uma instância de **`obj_speakblock`** (objeto já registrado) criada pelo `objects/ObjPlayer/Other_4.gml` (Room Start do player persistente) em `(x - 24, y)` quando `room == rm_inicio || room_is_story_world(room)`, e destruída nas demais salas. O id fica em `global.companion_inst`.
- No `with` da criação, o speakblock recebe `sprite_index`/`mask_index = spr_companionB`, `visible = true`, `text_id = "rasiel_conversa"` e as variáveis que o `scr_party` espera (`is_following`, `follow_trail`, `follow_last_px/py`, `follow_dir`, `sprite[UP/DOWN/LEFT/RIGHT]`). O ENTER e o `create_textbox(text_id)` já vêm do próprio `obj_speakblock/Step_0.gml`.
- `objects/ObjPlayer/Step_0.gml` chama `party_follower_step()` dentro de `with (global.companion_inst)` no fim do frame. Reaproveita o mesmo rastro de 14 passos do Charles: o Rasiel anda atrás, troca o sprite pela direção e pausa em diálogo/cutscene.
- Sprites mapeados por inspeção dos PNGs: `spr_companionB` = DOWN (frente, com olhos), `spr_companionC` = UP (costas), `spr_companionD` = RIGHT (rosto à direita), `spr_companionE` = LEFT (rosto à esquerda).
- A fala em `scr_game_text` usa `rasiel-falando` (retrato à direita). Texto é provisório até os próximos diálogos.
- `validar_companion()` barra a dependência de objeto novo e confere o spawn, as variáveis do party, a chamada no Step do player, o ENTER do speakblock e a fala com retrato. Validação passou (486 JSON, 29 `.gml`, 72 nomes); **jogo não executado**.

## 13. Apresentação do Rodapé antes de seguir

- `scripts/scr_game_text/scr_game_text.gml`: novo caso `rodape_intro` com as 13 falas pedidas, na ordem exata. As do Rodapé usam `rasiel-*`; as do Talai usam `talaib-*`; a última ("Rodapé entrou para a party") não passa retrato.
- `scripts/scr_text/scr_text.gml` + `scripts/scr_visual_novel/scr_visual_novel.gml`: chaves `talaib-<emoção>` foram adicionadas e resolvidas por `talaiB_vn_sprite()`, que aponta direto para `spr_talaiB_*_visual_novel` (não para `talai_vn_sprite()`, já que `rm_inicio` ainda não está em `room_is_story_world()`). `spr_talaiB_sorrindo_visualNovel` usa o nome camelCase que existe no projeto.
- **Sprite ausente:** `spr_rasiel_explicando_visual_novel` não existe no `.yyp`. A chave `rasiel-explicando` foi adicionada com `asset_get_index()` e cai em `spr_rasiel_falando_visual_novel` enquanto o sprite não é importado — se o artista adicionar o sprite com esse nome exato, ele passa a ser usado automaticamente.
- `objects/ObjPlayer/Other_4.gml`: o companion nasce com `is_following = false`. Na primeira entrada em `rm_inicio`/mundo da história, marca `global.rodape_intro_done`, seta `global.after_dialog_action = "rodape_join_party"` e abre o diálogo. Se já foi apresentado (ou trocou de sala), entra direto na party com `party_begin_follow()`.
- `objects/obj_textbox/Draw_0.gml`: novo caso `"rodape_join_party"` no `after_dialog_action`, que chama `party_begin_follow(global.companion_inst)` quando a última página é fechada. Só aí o rastro do `scr_party` começa a andar.
- `validar_rodape_intro()` confere as 13 falas/retratos, as chaves `talaib-*` e o fallback de `explicando`, o disparo no spawn e a ação de entrar na party no fim. Validação passou (486 JSON, 32 `.gml`, 96 nomes); **jogo não executado**.

## 14. Ajustes pedidos após testar a apresentação

- **Gatilho do corredor alargado:** em `objects/ObjPlayer/Step_0.gml`, o raio de 28 px ao redor de (424, 195) foi trocado por `point_in_rectangle(x, y, 390, 95, 470, 365)`. A faixa vertical cobre toda a passagem, então não dá mais para burlar o diálogo passando acima ou abaixo do ponto.
- **Retratos do Rasiel virados para a esquerda:** em `objects/obj_textbox/Draw_0.gml`, o sprite grande de visual novel passou de `draw_sprite()` para `draw_sprite_ext(..., _esc, 1, ...)`. Como `speaker_side = -1` para o Rasiel (retrato à direita), ele agora olha para o lado onde o Talai está. A origem dos sprites é no canto, então `_lx += _lw` compensa o espelhamento e mantém o retrato na mesma faixa da tela. Os retratos do Talai (`speaker_side = 1`) continuam normais.
- `validar_dialogos()` e `validar_rodape_intro()` foram atualizados para conferir o retângulo e o espelhamento. Validação passou (486 JSON, 32 `.gml`, 96 nomes); **jogo não executado**. Nenhum recurso novo: basta o IDE recarregar os `.gml`.

## 15. Profundidade do companion acompanha o player

- Causa: o player estava na depth fixa `0` (padrão da instância) enquanto o `scr_party` colocava o seguidor em `depth = -bbox_bottom`. Como `-bbox_bottom` é negativo, o companion sempre desenhava na frente do Talai, mesmo quando estava "atrás" dele.
- `objects/ObjPlayer/Step_0.gml`: o player agora também usa `depth = -bbox_bottom`, a mesma regra do `scr_party`. Quem tem os pés mais abaixo na tela (menor depth) desenha por cima; quando o Rodapé sobe na tela, o Talai passa a desenhar na frente dele.
- No `with (global.companion_inst)`, a depth do companion é recalculada todo frame mesmo quando ele está parado (`party_follower_step()` volta antes da linha de depth durante diálogo/cutscene).
- Para não brigar com a cutscene de batalha, a linha do player está protegida por `if (!instance_exists(obj_battle_transition))` — nesse momento o próprio `obj_battle_transition` controla a depth (`-50010`).
- `validar_companion()` confere as duas atribuições de depth e a proteção. Validação passou (486 JSON, 32 `.gml`, 97 nomes); **jogo não executado**.

## 16. TalaiB da pasta player a partir de rm_inicio

- `scripts/scr_visual_novel/scr_visual_novel.gml`: `room_is_story_world()` passou a incluir **`rm_inicio`** além das cinco salas do mundo da história que já existiam (`Room23`, `rm_aldeia_indigena`, `rm_caminho_para_oca`, `rm_conecta_caminho_praia`, `rm_corredor_pra_praia`). É essa lista que troca o Talai para talaiB — então a troca acontece em `rm_inicio`, e não antes.
- `talai_apply_form()` (chamada no Create e no Room Start do `ObjPlayer`) passa a valer essa lista: no mundo da história o player usa os sprites da pasta `Sprites/player/talaiB` em vez de `SprPlayer*`. **Correção após o teste:** a primeira versão apontava para `spr_talaiB_world`, que era uma cópia do sprite de batalha e foi removido quando o usuário importou as animações novas — por isso o Talai aparecia com o sprite de batalha no overworld. Agora o mapeamento segue o **mesmo padrão do companion**: `spr_talaiB_B` = DOWN (frente), `spr_talaiB_C` = UP (costas), `spr_talaiB_D` = RIGHT, `spr_talaiB_E` = LEFT, todos com 4 frames de animação. Os sprites `battle`/`attack`/`damage`/`defense`/`projectle` continuam restritos às batalhas.
- A mesma lista comanda `talai_vn_sprite()`, então os retratos grandes das falas em `rm_inicio`/mundo da história passam para os `spr_talaiB_*_visual_novel`. Os diálogos da escola (corredor e refeitório) continuam com os retratos `spr_talai_*_visual_novel`. As chaves explícitas `talaib-*` da apresentação continuam funcionando.
- `validar_forma_talai()` confere as 6 salas, barra as salas da escola na lista, e valida o registro e as 4 frames de `spr_talaiB_B/C/D/E`, o mapeamento das direções, a ausência de referências a sprites removidos/inexistentes e as duas chamadas no `ObjPlayer`. Validação passou (489 JSON, 32 `.gml`, 100 nomes); **jogo não executado**. Nenhum recurso novo — mas, como você acabou de importar os sprites, o IDE precisa tê-los recarregados (feche/reabra ou Reimporte se ainda não aparecerem).

## 17. Apresentação só em rm_inicio

- **Correção após o teste:** a apresentação do Rodapé estava disparando em `RoomSalasCorredor`. Causa: `objects/ObjPlayer/Other_4.gml` recria o companion em **toda** sala do mundo da história (o `obj_speakblock` não é persistente e morre na troca de sala) e, se `global.rodape_intro_done` ainda era `false`, abria `rodape_intro` ali mesmo.
- A condição agora é `if (!global.rodape_intro_done && room == rm_inicio)`. Em outra sala do mundo da história o companion é criado e entra direto na party com `party_begin_follow(_c)`, sem conversa. Nas salas da escola ele nem nasce (a lista `room_is_story_world()` foi restringida na seção 18). Se o jogador nunca passou por `rm_inicio`, a apresentação continua disponível quando entrar nela.
- `validar_rodape_intro()` confere a condição com `room == rm_inicio` e barra a forma antiga (sem filtro de sala). Validação passou (489 JSON, 32 `.gml`, 100 nomes); **jogo não executado**. Nenhum recurso novo.

## 18. Troca de sprite só em rm_inicio (não no corredor)

- **Correção após o teste:** o Talai ainda trocava para talaiB em `RoomSalasCorredor`. Causa: a lista `room_is_story_world()` havia incluído as salas da escola (`RoomPatio`, `RoomSalasCorredor`, `RoomRefeitorio`, `RoomLivro`, `RoomBathroom1_1`, `RoomBathroom_1`) e `talai_apply_form()` usa essa lista no Room Start.
- Essas salas foram **removidas** da lista. Ela agora contém só `rm_inicio` + `Room23`, `rm_aldeia_indigena`, `rm_caminho_para_oca`, `rm_conecta_caminho_praia` e `rm_corredor_pra_praia`. Resultado: no corredor/refeitório o Talai continua com `SprPlayer*`, e a troca para `spr_talaiB_B/C/D/E` acontece ao entrar em `rm_inicio`.
- A mesma lista controla os retratos grandes e o spawn do companion, então os diálogos da escola voltaram aos retratos `spr_talai_*` e o Rodapé não aparece nessas salas.
- `validar_forma_talai()` agora exige as 6 salas do mundo da história e barra explicitamente as 8 salas da escola. Validação passou (489 JSON, 32 `.gml`, 100 nomes); **jogo não executado**.

## 19. Cutscene do encontro com o guaraná em rm_inicio

- **Gatilho:** o `obj_cutscene_trigger` que você colocou em `rm_inicio` (`inst_39ECD459`, 512,224, escala 2 em X) ganhou creation code com `scene_id = "mundo_guarana_encontro"`. Ele continua com `once = true`, então a cena roda uma vez por save.
- **Inimigo escondido:** o `obj_rh_en_guarana` (`inst_1B9162E2`, 352,128) ganhou creation code com `visible = false`, para só aparecer quando a cutscene começar. Ele é o mesmo objeto usado na transição/batalha (`get_rh_enemy_object("Guarana")`).
- **Cena:** `scripts/scr_cena_mundo/scr_cena_mundo.gml` ganhou o caso `mundo_guarana_encontro` (o prefixo `mundo` já aponta para esse script registrado, então não foi criado recurso novo). Sequência: trava o player → vira o Talai para o lado do guaraná → revela o inimigo → `cutscene_roll_to()` faz ele rolar da posição das árvores até perto do Talai girando o sprite e parar em pé → `cutscene_face_player()` → espera 18 frames → diálogo → `cutscene_move_axis()` aproxima até 30 px → espera 12 frames → `cutscene_battle_encounter()` cria o `obj_battle_transition` com o inimigo do mapa e o ID `Guarana`.
- **Ações novas** (em `scripts/scr_cutscene_actions/scr_cutscene_actions.gml`, script existente): `cutscene_roll_to()` move em linha reta com `lengthdir` e gira `image_angle` uma volta completa até parar; `cutscene_battle_encounter()` passa o struct `enemy`/`enemy_id_value` que o Create da transição exige.
- **Diálogo:** `scripts/scr_game_text/scr_game_text.gml` ganhou `mundo_guarana_surpreso` com a fala exata "Oxi, o que um guaraná ta fazendo aqui???" e a chave explícita `talaib-surpreso` (`spr_talaiB_surpreso_visual_novel`), independente da sala.
- **Ajuste após o teste:** a rolagem estava diagonal (o guaraná vinha de y=128 até os pés do Talai em y=224). Agora, antes de aparecer, a ação `cutscene_place_at()` alinha o guaraná ao `y` do Talai; o destino da rolagem usa o mesmo `y`, então `cutscene_roll_to()` anda **só no eixo X**, em linha reta horizontal. Depois ele para, vira para o Talai e segue o diálogo/aproximação/batalha como antes.
- `validar_cena_guarana()` confere a cena, as ações (inclusive o alinhamento horizontal), o diálogo, os dois creation codes e os flags `hasCreationCode` no `.yy`. Validação passou (489 JSON, 36 `.gml`, 103 nomes, 161 funções); **jogo não executado**. Nenhum recurso novo.
- Atenção: o IDE já reescreveu `rm_inicio.yy` e zerou os `hasCreationCode` dos dois instances. Isso não quebra mais o encontro: `obj_settings/Step_0.gml` tem um fallback que configura o trigger e esconde o guaraná quando os creation codes não vêm. Os flags foram reaplicados no `.yy`, mas o fallback cobre novas reescritas.

## 20. Retorno de batalha sem softlock + derrota no savepoint

- **Causa do softlock:** `obj_battle_transition/Step_0.gml` destrói o `ObjPlayer` antes de `room_goto(rm_rh_battle)`. `rm_inicio` (e várias outras salas) não tem `ObjPlayer` colocado no editor, então, ao voltar da vitória, não existia jogador: nenhuma tecla funcionava e a câmera ficava presa no canto da sala.
- `objects/obj_settings/Step_0.gml`: ao entrar na sala de retorno (`battle_return_pending && room == battle_return_room && room != rm_rh_battle`), cria um `ObjPlayer` em `battle_return_x/y` se não houver nenhum, na layer `Player` (ou `Instances`), restaura a direção, reaponta `camera_set_view_target()` para ele e centraliza a câmera na hora (`camera_set_view_pos()` com clamp nas bordas). Também limpa `fade_active`, `dialog_active` e `cutscene_active`.
- `objects/obj_battle_transition/Step_0.gml`: agora guarda `global.pre_battle_face` junto de `pre_battle_x/y` antes de destruir o player.
- `objects/obj_rh_battle_controller/Step_0.gml`: vitória continua voltando ao ponto da luta, mas prepara `battle_return_*` e liga `battle_return_pending`. Derrota agora volta a `global.last_savepoint_room/x/y/face` com HP cheio, zera `pre_battle_x/y` (para o Create não devolver o player ao local da batalha) e libera a cena `once` que originou a luta (`variable_struct_remove(global.scenes_done, battle_scene_id)`), para o encontro poder repetir.
- `scripts/scr_cutscene_actions/scr_cutscene_actions.gml`: `cutscene_battle_encounter()` aceita um terceiro argumento opcional `_scene_id` e grava `global.battle_scene_id`; a cena do guaraná passa `"mundo_guarana_encontro"`.
- `scripts/scr_save_system/scr_save_system.gml`: `save_game()` lembra o room/x/y/face do último savepoint usado; `save_load_game()` também passa a considerar o save carregado como último savepoint; `save_reset_progress()` zera isso no novo jogo. `obj_settings/Create` inicializa todas as globais novas com fallback para `global.start_room/start_x/start_y`.
- `validar_retorno_batalha()` confere as globais, a recriação do player, o recentramento da câmera, a captura da face, os dois ramos do controller e o registro do savepoint. Validação passou (489 JSON, 41 `.gml`, 108 nomes, 161 funções); **jogo não executado**.

## 21. Fala de apresentação do save point

- `scripts/scr_game_text/scr_game_text.gml`: novo caso `mundo_savepoint_visto`. O texto final é o que o usuário editou no IDE — Talai pergunta da "coisa amarela flutuando" (`talaib-surpreso`), Rodapé responde que é um savepoint, que serve para guardar o progresso e que, se ele for derrotado, volta a partir dali; Talai reage (`talaib-preocupado`) e ele encerra (`rasiel-desacreditado`/`rasiel-sorrindo`). Não sobrescrever esse texto.
- `objects/obj_save_point/Step_0.gml`: dispara a fala na primeira vez em que o Talai chega a 120 px do save point (raio maior que os 28 px de interação). Só dispara com `ObjPlayer` vivo e sem diálogo, cutscene, batalha, fade, pausa ou menu de slots aberto. Usa `global.savepoint_intro_done` para falar uma única vez; depois o Enter normal continua abrindo o menu de save.
- `objects/obj_settings/Create_0.gml` inicializa `global.savepoint_intro_done`; `save_reset_progress()` zera a flag no jogo novo.
- Vale para **qualquer** instância de `obj_save_point`, em qualquer sala — não depende de creation code nem de recurso novo (o IDE continua livre para reescrever o `.yyp`).
- `validar_fala_savepoint()` confere as falas (respeitando o texto editado), os retratos, o raio/guarda do gatilho, a flag e o reset. Validação passou (489 JSON, 42 `.gml`, 109 nomes, 161 funções); **jogo não executado**.

## 22. Correção do erro ao perder para o guaraná

- Erro reportado: `Variable obj_settings.layer_find_name not set before reading it` em `obj_settings/Step_0` na linha do `instance_create_layer` do retorno de batalha. `layer_find_name()` não é reconhecido nesta versão do GameMaker e era lido como variável.
- `objects/obj_settings/Step_0.gml`: trocado por `layer_exists("Player") ? "Player" : "Instances"` + `instance_create_layer(..., _layer_name, ObjPlayer)`, o mesmo padrão já usado em `scr_save_system.gml` e `scr_rh_attacks.gml`. O player volta a ser recriado e a câmera recentraliza na derrota e na vitória.
- `validar_retorno_batalha()` agora exige essa forma de layer e falha se `layer_find_name` reaparecer no Step. Validação passou; **jogo não executado** pelo assistente.

## 23. Companion após batalha + apresentação uma única vez

- **Companion sumia até trocar de sala:** o retorno de batalha cria o `ObjPlayer` com `instance_create_layer()` no meio da sala, e isso **não dispara o Room Start**. Como o spawn do Rodapé estava só no Room Start (`ObjPlayer/Other_4.gml`), ele não era recriado; além disso o `obj_speakblock` não é persistente e morre ao ir para `rm_rh_battle`.
- `scripts/scr_party/scr_party.gml`: nova função `companion_ensure_spawn()` com todo o setup do Rodapé (visual `spr_companionB..E`, `text_id`, rastro do `scr_party`, depth por pés). Só cria se a sala for do mundo da história e se `global.companion_inst` não existir; fora dessas salas destrói o companion. A apresentação continua exclusiva de `rm_inicio` e protegida por `global.rodape_intro_done`.
- `objects/ObjPlayer/Other_4.gml` agora só chama `talai_apply_form()` + `companion_ensure_spawn()`; `objects/obj_settings/Step_0.gml` chama a **mesma** função logo após recriar o player no retorno de batalha. Nenhum recurso novo (continua usando `obj_speakblock`).
- **Apresentação repetia ao salvar/carregar:** `save_extra_globals()` só gravava `carol_disappeared`. Agora grava também `rodape_intro_done` e `savepoint_intro_done`; `obj_settings/Create_0.gml` inicializa `rodape_intro_done` (antes só nascia no Room Start, então um save antigo carregado chegava com a flag indefinida) e `save_reset_progress()` zera ambas no jogo novo.
- `validar_companion()`, `validar_rodape_intro()` e o novo `validar_flags_apresentacao()` conferem os dois pontos de spawn, a flag da apresentação e a presença das flags no save. Validação passou (489 JSON, 43 `.gml`, 109 nomes, 162 funções); **jogo não executado**.

## 24. Loop de warps na volta (rm_inicio ↔ rm_corredor_pra_praia)

- O companion **não aciona warps**: os três (`obj_warp`, `obj_warp1`, `obj_warpClick`) usam `place_meeting(x, y, ObjPlayer)`. O loop vinha do destino: os warps têm máscara esticada (`scaleX` de 6,8 a 8,9), e 5 destinos spawn dentro da máscara de outro warp. Exemplo: ao voltar de `rm_corredor_pra_praia`, o Talai nasce em `(220, 21)`, que cai no warp de `rm_inicio` em `(143.5, -16)` com máscara `x 143.5..280, y -16..4`. Ele disparava a ida de novo no primeiro frame.
- Outros casos iguais corrigidos pelo mesmo mecanismo: `rm_conecta_caminho_pra_praia → rm_corredor_pra_praia`, `rm_conecta_caminho_pra_praia → rm_caminho_para_oca`, `rm_caminho_para_oca → rm_aldeia_indigena` e um warp de `RoomClass1_1`.
- Nova flag `global.warp_suppressed`: ao disparar qualquer warp, ela é ligada antes de criar o `obj_fade`. `objects/obj_settings/Step_0.gml` (persistente, presente em todas as salas) a desliga **só quando o player não está mais na máscara de nenhum dos 3 warps**. Na chegada o jogador pode sair andando normalmente; ao se afastar, o warp volta a funcionar.
- `save_load_game()` liga a flag (um save feito em cima de um warp não dispara transição ao continuar) e `save_reset_progress()` a desliga no jogo novo. Nenhum `.yy` de room foi alterado — isso evita o IDE reapagar creation codes.
- `validar_anti_loop_warps()` confere os 3 Steps, a liberação centralizada e o save/CONTINUAR. Validação passou (489 JSON, 46 `.gml`, 112 nomes, 162 funções); **jogo não executado** pelo assistente.

## 25. Save de derrotas + diagonal do companion

- **Batalha do guaraná repetia ao carregar:** `global.defeated_enemies` JÁ era salvo, mas `global.scenes_done` (struct das cenas "once") não era. Sem ele, o `obj_cutscene_trigger` de `rm_inicio` voltava a disparar `mundo_guarana_encontro` depois do CONTINUAR.
- `scripts/scr_save_system/scr_save_system.gml`: `save_collect_data()` agora grava `scenes_done`; `save_load_game()` restaura o struct (saves antigos sem o campo recebem `{}`) e também tolera saves sem `defeated_enemies`. Nova função `save_enemy_defeated(id)` centraliza a consulta. `save_reset_progress()` já zerava `scenes_done` no jogo novo.
- `obj_settings/Step_0.gml` (fallback do guaraná) e `scr_cena_mundo.gml` consultam `save_enemy_defeated("Guarana")`: se ele já caiu, o trigger é destruído, o inimigo fica invisível e a cena retorna `[]`. A vitória em `obj_rh_battle_controller` também marca `scenes_done[battle_scene_id] = true` e limpa `battle_scene_id`. A derrota continua removendo a marca para poder tentar de novo.
- **Flicker do companion na diagonal:** `party_follower_step()` escolhia o sprite com `abs(dx) > abs(dy)`; na diagonal os dois são quase iguais e a decisão alternava por arredondamento. Nova `follower_face_update()` replica exatamente as regras de `ObjPlayer/Step_0`: com movimento horizontal ele manda (LEFT/RIGHT), o vertical só troca quando o horizontal parou (UP/DOWN). O input usado é o mesmo do Talai (`ObjPlayer.xspd/yspd`), com fallback para o último passo do rastro quando ele parou. `image_index` só zera quando o seguidor realmente não se moveu.
- `validar_save_derrotas()` e `validar_diagonal_companion()` cobrem os dois pontos. Validação passou (489 JSON, 46 `.gml`, 112 nomes, 164 funções); **jogo não executado** pelo assistente.

## 26. Sons de fala, save, queda e dano

Os cinco recursos já existiam em `sounds/` e estavam registrados no `.yyp`; nenhum asset novo foi criado.

- **Falas do Talai → `sfxDanielVc`:** em `scripts/scr_text/scr_text.gml`, os ramos `talaib`/`talaib-*` e `talai`/`talai-*` agora definem `snd[page_number]` e `snd_delay_array` (4). Vale para todas as emoções (`talai-preocupado`, `talaib-surpreso`, etc.).
- **Textos sem retrato → `vc_text`:** mesma página, quando `scr_text()` é chamado sem o 2º argumento (`argument_count <= 1`) o som de digitação passa de `sfxNada` para `vc_text`. Falas com retrato de Daniel, Sans ou Carol mantêm os sons próprias.
- **Salvar/sobrescrever → `sfxSave`:** `obj_save_slots/Create_0.gml`, dentro de `do_save()`, após `save_game()` bem-sucedido. Cobre salvar num slot vazio e confirmar a sobrescrita (os dois caminham por `do_save`).
- **Queda da RoomTeachers → `sfxFall`:** `cutscene_player_fall_out()` ganhou 2º parâmetro opcional `_snd`; `scr_cena_teachers` passa `sfxFall` no passo da queda. A cena do professor continua sem som (não foi pedida).
- **Dano do player na batalha → `sfxDamagePlayer`:** `apply_damage_to_player()` toca o som só se o HP realmente caiu. Como os iframes do coração já bloqueiam acertos em cadeia, isso evita repetição excessiva.
- `validar_sons()` confere os 5 nomes no `.yyp` e cada ligação. Validação passou (492 JSON, 48 `.gml`, 114 nomes, 164 funções); **jogo não executado** pelo assistente.

## 27. Música do overworld (SndCastleFunk)

- As salas da pasta `folders/Rooms/overworld` são 8: `RoomClass1_1`, `RoomSalasCorredor`, `RoomRefeitorio`, `RoomPatio`, `RoomBathroom_1`, `RoomBathroom1_1`, `RoomLivro` e `RoomTeachers_1`. Nova função `room_is_overworld()` em `scr_visual_novel.gml` (ao lado de `room_is_story_world`) centraliza a lista; nenhum objeto novo foi criado.
- `obj_settings/Step_0.gml` controla a música de forma global: liga `SndCastleFunk` em loop (prioridade 10) quando a sala é do overworld, `global.intro_played` é true, o fade de abertura já terminou e (em `RoomClass1_1`) a fala `historia_acordar` fechou. Desliga ao sair dessas salas, entrar em batalha ou ao começar a cutscene da `RoomTeachers_1`.
- `global.overworld_music_finished` marca o fim definitivo quando `global.cutscene_active` começa dentro da `RoomTeachers_1`, evitando que a música volte se o jogador revisitá-la. Vai no save (`save_extra_globals`) e é zerado no novo jogo. `save_load_game()` e `obj_battle_transition` desligam o som e limpam `overworld_music_on` para o estado ser recalculado na chegada.
- O controle usa também `audio_is_playing(SndCastleFunk)` como rede de segurança, para não reiniciar o loop nem deixar dois loops simultâneos.
- `validar_musica_overworld()` cruza a lista da função com os `.yy` de `rooms/` (falha se alguma sala da pasta ficar de fora) e confere os pontos de ligar/desligar. Validação passou (492 JSON, 48 `.gml`, 114 nomes, 165 funções); **jogo não executado** pelo assistente.
