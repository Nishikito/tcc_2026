# Relatório final — Trono Vazio, Carumaru, Intenente de Ferro e Quinto do Inferno

Todos os horários abaixo são frames do `_t` recebido por `pattern_current(_t)`, que começa em **1** quando `obj_rh_battle_box.is_open` fica `true` (a caixa leva 26 frames para abrir). O turno do controller termina em 300 frames.

A causa raiz dos turnos vazios e a instrumentação estão em `RELATORIO_FASE0_CAUSA_RAIZ.md`. As macros de diagnóstico ficaram em `RH_DEBUG = false` e `RH_DEBUG_FORCE_PATTERN = -1` (modo normal) ao final. Validação estática automatizada: `python tools/validar_ataques_rh.py` — **resultado final: OK (0 erros, 0 avisos)**. Reaplicação do registro no projeto (o IDE descarta entradas manuais ao salvar): `python tools/registrar_assets_novos.py`.

---

## 1. Infraestrutura comum (Fase 0)

### Arquivos alterados

| Arquivo | Mudança |
|---|---|
| `scripts/scr_rh_attacks/scr_rh_attacks.gml` | Macros `RH_HEART_SHRINK = 0.85`, `RH_BAU_DENTRO = false`; `rh_hurt_heart()`; `rh_heart_rect()`, `rh_rect_hits_heart()`, `rh_rot_rect_hits_heart()`, `rh_segment_hits_heart()`; `rh_draw_clipped_ext()`, `rh_draw_clipped_pivot()`, `rh_draw_warning_line(..., largura, t)`; aviso de spawn fora da room em `rh_spawn_attack()` |
| `objects/obj_rh_battle_player/Step_0.gml` | Laço de dano substituído por `rh_hurt_heart(_b)` — uma única fonte de dano |
| `objects/obj_rh_battle_player/Create_0.gml` | `kb_dir = 0` (o Draw já lia a variável, mas ela não existia) |
| `objects/obj_rh_battle_controller/Step_0.gml` | Limpeza de ataques no fim do turno e na derrota agora registra motivo via `rh_debug_destroy()` |
| `scripts/scr_damage_calculator/scr_damage_calculator.gml` | `case "QuintoDoInferno": return obj_rh_en_quinto_do_inferno;` |
| `printizin2meajuda_corrigido.yyp` / `.resource_order` | 13 novos recursos registrados |
| `rooms/rm_teste/rm_teste.yy` | `inst_5E00000B` de `ObjMonsterQuintoDoInferno` em `(1120, 416)` |

### Regra de ouro adotada

Ataques com geometria própria (rotação, faixa, barra rastejante, fumaça) nascem com `active = false`, `destroy_on_hit = false` e chamam `rh_hurt_heart(id)` no Step. `was_hit` garante single-hit. A colisão por máscara do coração ignora `active = false`, portanto nada "machuca fora do desenho". O recorte rotacionado usa uma surface do tamanho da caixa, recriada se o GameMaker a perder.

`RH_HEART_SHRINK = 0.85` encolhe o coração nas geometrias próprias: folga de ~15% a favor do jogador.

---

## 2. Trono Vazio

`objects/obj_rh_en_trono_vazio/Create_0.gml` — HP 560, dano 3–4, `spr_trono_vazio`/`_damage`/`_defeated`, `sway_y = 2`, `alarm[0] = -1`. O antigo `pat_espadas` foi substituído por T1–T6. `trono_phase()` lê `global.battle_enemy_hp` (espelhado pelo controller a cada dano), sem guarda `instance_exists`: `> 66%` → fase 1, `≤ 66%` → fase 2, `≤ 33%` → fase 3.

### Fases

| Fase | T1 | T2 | T3 | T4 | T5 | T6 |
|---|---|---|---|---|---|---|
| 1 (> 66%) | 6 espadas @ 3,4 | 8 espadas, brecha 3 @ 2,8 | 2 cortes | 10 espadas @ 3,2 | chifre 2,5 · 2 cartas @ 2,0 | vy −2,0 |
| 2 (33–66%) | 8 @ 3,8 | 10, brecha 2 @ 3,2 | 3 cortes | @ 3,6 | chifre 2,5 · 2 cartas | vy −2,0 |
| 3 (≤ 33%) | 9 @ 4,2 | 12, brecha 2 @ 3,6 | 4 cortes | @ 4,0 | chifre 3,1 · 3 cartas @ 2,0/2,15/2,30 | vy −2,6 |

### Linha do tempo (turno de 300 frames)

| Padrão | Frames | Ação |
|---|---|---|
| **T1 barreira** | `10`, `150` | espadas em posições/ângulos sorteados → fade 12f → telegrafia 26f (linha até a borda) → atraso 0–8f → avanço reto |
| **T2 anel** | `12`, `156` | espadas em raio 40 ao redor do coração, com brecha no lado com mais espaço → fade 8f → telegrafia 28f (linhas convergindo) → convergência |
| **T3 cortes** | `10`, `110`, `210` | 2/3/4 faixas diagonais recortadas → fio vermelho 32f → faixa branca ativa 7f → fade 8f; linhas escalonadas de 14f |
| **T4 chuva diagonal** | `8`, `100`, `192` | 10 espadas, direções 70°/110°/70° → aviso 22f + fade 4f → descida; corredor central novo a cada leva |
| **T5 chifres + cartas** | chifre `30`, `110`, `190`; cartas `70`, `150`, `230` | chifre avisa 20f na altura travada (faixa vermelha) e só então entra; cartas em leva de 2/3 |
| **T6 icebergs** | `16`, `90`, `164`, `238` | 2 icebergs em `y = 149/165`, aviso 22f na base (faixa vermelha) → subida |

Ataques novos: `obj_rh_atk_trono_espada` e `obj_rh_atk_trono_slash`. Também foram reescritos `obj_rh_atk_chifre`, `obj_rh_atk_carta` e `obj_rh_atk_iceberg` (aviso antes do dano, `Other_0` vazio, recorte por `rh_draw_clipped_ext` nas cartas).

Justiça: nenhum `instance_exists` nos padrões; todo projétil nasce dentro da room (espadas `x` em 10..310 e `y` em 30..52; chifre ≈66/184; cartas em `x1+4`; icebergs em `y = 149/165`); `Other_0` vazio; geometria própria com `active=false` + `rh_hurt_heart(id)` + `was_hit`. T1 exige ≥30% de células livres numa grade de 6 px e célula segura a ≤56 px do coração (25 tentativas, remoção gulosa, fallback de dois eixos opostos); T2 abre sempre para o lado com mais espaço; T3 passa a 12–18 px do coração (nunca sobre ele); T4 deixa ≈30 px de corredor entre grupos; T6 mantém centros ≥32 px. Hitboxes encolhidas em 15% por `RH_HEART_SHRINK`.

---

## 3. Carumaru

`objects/obj_rh_en_carumaru/Create_0.gml` — HP 240, dano 2–4, `spr_carumaru`/`_damage`/`_defeated`, `sway_y = 6`, `alarm[0] = -1`.

### C1 — `pat_lagrimas`

| Frame | Ação |
|---|---|
| `t = 10, 46, 82, 118, 154, 190, 226, 262` | 5 lágrimas em fileira em `y = by1 - 16` |
| `t+1 … t+18` | paradas no topo, aviso vermelho, `active = false` |
| `t+19 …` | queda com `vy = 0.8 → 3.0`, gravidade `0.05`/frame |
| ao tocar `by2` | duas gotas `splash` do mesmo objeto, `vx = ±1.7`, vida 22 |

- Passo entre centros: `10 + 28 = 38 px` ⇒ **vão livre de 28 px**.
- Deriva por fileira: `[0, +1, 0, -1, 0, +1, 0, -1]` colunas.
- Hitbox: 85% do sprite 10×17 (≈8.5×14.45).

### C2 — `pat_fantasmas`

| Frame | Ação |
|---|---|
| `t = 10` | 1 seguidor + 1 eco |
| `t = 120` | 1 parede (máx. 3 simultâneos) |
| `0 … 29` | semi-transparente e inofensivo (alpha `0.15 → 0.85`) |
| `30 … 179` | ativo (parede a partir de 31) |
| `180 … 199` | fade final inofensivo |
| `200` | destruição por tempo |

- Spawn com até 20 tentativas para ficar a **≥40 px do coração**; se falhar, usa o ponto mais distante.
- SEGUIDOR: `0.8 px/frame` em linha reta. ECO: alvo = posição do coração **40 frames atrás** (buffer de 41 structs, atualizado todo frame). PAREDE: borda da caixa, troca de borda/direção a cada 60 frames.
- Sprites: `spr_ghost_attack` 22×46 (seguidor/eco), `spr_fantasma_carumaru_attack` 33×65 (parede). Hitbox 80%.

### C3 — `pat_choro`

| Frame | Ação |
|---|---|
| `10, 100, 190` | 3 lágrimas em arco, cantos superiores alternados, aviso de 16 frames |
| `55` | 1 seguidor |
| `145` | 1 eco |

Arco: `vx = ±1.6 … 2.2`, `vy0 = -1.5`, gravidade `0.06`, `vy_max = 4`, vida 170. Sem guardas `instance_exists`.

---

## 4. Intenente de Ferro

`objects/obj_rh_en_intenente_de_ferro/Create_0.gml` — HP 400, dano **4–5**, mesmos sprites/sway. Contadores próprios `martelo_step` e `sentenca_step`.

### I1 — `pat_marteladas` (spawns `t = 8, 100, 190`)

| Frame | Ação |
|---|---|
| 1–30 | aviso vermelho na área da cabeça; martelo a `-60°`; na MIRADA o `x` segue o coração até o 30 |
| 31–44 | preparação: `-60° → -82°` com tremida `dsin(t*7)*0.8` |
| 45–50 | descida acelerada: `-82° → 130°` (easing quadrático) |
| 50 | impacto: `shake_t = 8` + flash branco do próprio ataque |
| 51–60 | hitbox rotacionada 36×22 via `rh_rot_rect_hits_heart`, `dmg_mult = 1.5`, single-hit |
| 61–69 | fade e autodestruição (último golpe termina ≈259) |

Ordem: esquerda (`bx1+22`) → direita (`bx2-22`) → MIRADA (trava o `x` do coração 20 frames antes do impacto). Martelo em escala `0.5`, pivô `(2,76)` no arquivo, centro da cabeça `(82,10)`, `ANG_IMPACT = 130°`.

### I2 — `pat_barras` (salvas `t = 10, 100, 190`)

| Frame | Ação |
|---|---|
| 1–22 | aviso vermelho no ponto de pouso; barra parada no topo |
| 23–≈55 | queda: `vy 0 → 3.4`, aceleração `+0.12`/frame |
| ≈56–60 | flash branco de 5 frames, inofensiva, autodestruição |

- Uma barra sobre a coluna do coração (posição travada no aviso); a outra a **32 px de distância entre centros**, sempre para o lado com mais espaço (mantém o vão mesmo com o coração na borda).
- Escala `0.6` ⇒ 25,8×8,4 px; span do par ≈57,8 px ≈59% da caixa (limite de 60% respeitado). `dmg_mult = 1.0`.

> Interpretação adotada: "vão ≥32" = distância entre centros. Se o objetivo fosse vão livre de 32 px entre bordas, o par ocuparia ≈83,6 px (85% da caixa) e quebraria o limite de 60%; para essa leitura seria preciso reduzir a escala.

### I3 — `pat_sentenca` (`t = 10` e `t = 150`)

| Frame | Ação |
|---|---|
| 1–22 | aviso no ponto de pouso |
| 23–≈55 | queda (`vy 0→3.4`, `+0.12`), machuca durante a queda |
| ≈56–85 | repouso de 30 frames, **inofensiva** |
| ≈65–84 | `rh_draw_warning_line` no chão apontando ao lado oposto |
| ≈78–84 | martelo pequeno (modo *smash*, 6 frames, sem dano próprio) |
| ≈85 | martelo esmaga (`shake_t = 6`), `launch_now = true` |
| ≈86–104 | barra rasteja a **5 px/frame** com rastro de 6 posições; dano single-hit `dmg_mult = 1.0`; some ao sair da caixa |

Fim da segunda repetição ≈254 (<300).

---

## 5. Quinto do Inferno

Novo inimigo: `obj_rh_en_quinto_do_inferno` (HP 440, dano 4–5, `spr_quinto_do_inferno`/`_damage`/`_defeated`, `sway_y = 4`, `alarm[0] = -1`) e `ObjMonsterQuintoDoInferno` (mapa, `enemy_id = "QuintoDoInferno"` **antes** de `event_inherited()`, escala para 48 px). `spr_cachorro_inferno_right_attack` foi gerado por `tools/gerar_cachorro_inferno_right.py` (espelho exato do original, 2 quadros).

`RH_BAU_DENTRO = false` alterna os baús fora/ dentro da caixa.

### Q1 — `pat_baus` (`t = 8, 60, 112, 164`)

| Frame | Ação |
|---|---|
| `t = 1` | limpa estado dos 4 baús |
| `8, 60, 112, 164` | spawn de 1–2 baús, escala `0.85`, topo `by2+3 ≈146`, termina antes do HUD (170) |
| `+0 … +89` | tremor `0 → 2 px` e `merge_color(branco, vermelho, progresso)` |
| `98, 150, 202, 254` | abre (`spr_bau_aberto_attack`), flash de 6 frames, fumaça em `by2-8` subindo a `1,1 px/frame` recortada |
| fumaça | `98–138`, `150–190`, `202–242`, `254–294`; machuca só os 32 primeiros frames |
| baú | fecha escurecido em `+8`, destrói em `+30` |

Nunca 3 baús adjacentes explodindo juntos (máx. 2 por grupo), máx. 2 fumaças vivas. Fumaça: hitbox 60% da largura × 80% inferior da altura; últimos 8 frames inofensivos.

### Q2 — `pat_cachorro` (`t = 6`)

| Frame | Ação |
|---|---|
| `6` | spawn na lateral sorteada (`x ≈47` ou `≈197`, `y ≈108`, dentro da room) |
| `6–27` | aviso no chão (`rh_draw_warning_line` + faixa) |
| ≈`28` | começa a correr a `3,2 px/frame`; sprite espelhado quando vai para a direita |
| ≈`51, 115, 179` | para no meio de cada travessia por 18 frames: tremor, tom quente, squash/stretch da cabeça |
| fim de cada parada | 2 foguinhos (teto de 6 simultâneos) |
| ≈`92, 156, 220` | vira nas bordas / termina a 3ª travessia |
| ≈`226` | some |

Escala `0.75` (48×35, ≈43 px livres acima), hitbox 85%, animação 2 quadros a `0,25`/frame. Foguinhos: escala `0.5`, `~2 px/frame`, ângulos aleatórios para cima/diagonal (não mirados), **3 rebotes** nas paredes da caixa, puff de 6 frames.

### Q3 — `pat_cobranca`

| Frame | Ação |
|---|---|
| `1` | limpa estado dos baús |
| `8` | 1 baú → telegrafia até `97` → explosão `98` → fumaça `98–138` |
| `120` | cachorro sem tiro; aviso `120–141`; travessia única ≈`142–188`; some ≈`194` |
| `160` | 1 baú → telegrafia até `249` → explosão `250` → fumaça `250–290` |

Fim antes de 300, sem explosão coincidindo com a passagem do cachorro.

---

## 6. Validação estática

`python tools/validar_ataques_rh.py` verifica:

- JSON válido em todos os `.yy`/`.yyp` (com vírgula final, como o GameMaker aceita);
- 13 recursos novos registrados **uma única vez** e com arquivo no disco;
- parênteses, colchetes e chaves balanceados nos `.gml` tocados (ignorando strings e comentários);
- ausência de `instance_exists` nos Creates dos quatro inimigos;
- presença dos 14 padrões esperados;
- presença dos helpers de Fase 0;
- `Other_0.gml` dos ataques novos sem código efetivo (não reativam o `Outside Room` do pai);
- PNGs/camadas e referências da sequência do sprite espelhado;
- eventos declarados no `.yy` com `.gml` correspondente.

Os agentes também rodaram checagem local de balanceamento nos `.gml` que escreveram: todos OK. Na integração final, `trono_phase()` deixou de usar `instance_exists(obj_rh_battle_controller)` e passou a ler `global.battle_enemy_hp`; o validador também foi ajustado para ignorar comentários nessa checagem (o texto "instance_exists()" aparecia só em um comentário de regra).

---

## 7. O que NÃO foi testado

- Não conduzi/validei execução no GameMaker. O usuário chegou a rodar a batalha do Intenente e encontrou o erro de asset descrito abaixo (já corrigido), mas o comportamento dos padrões em jogo ainda não foi confirmado. Toda a validação aqui é estática.
- Encaixe visual de `spr_espada_attack` (`image_angle = 270 - dir`), sincronia dos avisos do Trono com o fim do turno de 300 frames e custo do validador de grade de T1 (25 tentativas × células de 6 px).
- A calibração visual do pivô do martelo `(2,76)` / cabeça `(82,10)` e se `ANG_IMPACT = 130°` deixa a cabeça exatamente para baixo.
- A posição real da boca do cachorro nos sprites (assumida origem `0,0`, ~7 px da ponta) e a cadência de 8 fps da fumaça.
- Sensação de dodge, equilíbrio de dano e performance com 6 foguinhos + 2 fumaças simultâneas.
- ECO com movimentos reais do coração e PAREDE com caixas de tamanho diferente do padrão.
- A sincronização martelo → barra na Sentença usa `launch_now` com folga de 1 frame; a ordem de Step entre instâncias não foi validada em jogo.
- Contradição do enunciado: "sem frames de invencibilidade" × `iframe_max = 60` do projeto. Mantive 60 (centralizado em `rh_hurt_heart`); trocar em `obj_rh_battle_player/Create_0.gml` se quiser zerar.
- O IDE pode reescrever `.yyp`, `.resource_order` e `rm_teste` ao salvar. Se isso acontecer, rode `python tools/registrar_assets_novos.py` depois do último save.
- Erro já observado em jogo: `Variable obj_rh_en_intenente_de_ferro.obj_rh_atk_martelo_ferro(...) not set before reading it` em `Create_0` linha 51. Causa: o `.yyp` tinha sido reescrito sem os assets novos, então a constante do objeto não existia na compilação. Correção aplicada: `python tools/registrar_assets_novos.py` (13 recursos) + reiniciar o GameMaker para recarregar o projeto. O mesmo vale para `obj_rh_atk_barra_ferro`, `obj_rh_atk_lagrima_carumaru`, `obj_rh_atk_bau_quinto`, etc.
