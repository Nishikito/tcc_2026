# Relatório — correção dos ataques de batalha (turnos vazios, Juiz, Monções, Apressador)

**Idioma:** português. **Data:** 25/11/2026.
**Método:** leitura e edição direta dos arquivos do projeto. **Não foi possível compilar nem rodar o jogo** —
todas as confirmações abaixo são estáticas (código + JSON + balanceamento de sintaxe). Ver a última seção.

---

## 1. Diagnóstico dos "turnos vazios" (Tarefa 1)

### 1.1 Juiz das Armas — causa raiz confirmada

- Arquivo: `objects/obj_rh_en_juiz_das_armas/Create_0.gml`, padrão antigo `pat_clones` (linhas 17–30 antes da reescrita).
- O clone "verdadeiro" era o índice `i == 4` e nascia em
  `x = rh_box_inner().x1 - 40 - i * 34 = 106 - 40 - 136 = -70`.
- O sprite `spr_juiz_voador_attack` tem **61 px de largura**; a caixa colisora ficava em `x = -70..-9`,
  inteiramente fora da room (320 px de largura).
- Consequência: `objects/obj_rh_battle_bullet/Other_0.gml:1` (linha 2 depois da instrumentação)
  chamava `instance_destroy()` no evento **Outside Room** no mesmo frame em que o clone nascia.
- Os outros 11 clones nasciam dentro da room, mas eram falsos (`active = false`), então o turno
  parecia "não ter ataque nenhum": o único que podia machucar morria ao nascer.

**Correção:** o anel agora nasce centrado em `(155, 104)` (centro real da Battle Box), com raio 88 e
escala 0.6; nenhum clone nasce fora da room, e o gerenciador/clone têm evento **Other** próprio
(sobrescrevem o Outside Room do pai e cuidam da própria saída de tela).

### 1.2 Carumaru — causa raiz confirmada

- Arquivo: `objects/obj_rh_en_carumaru/Create_0.gml`, padrão antigo `pat_misto` (linha 45 antes da reescrita).
- Guarda antiga: `if (instance_exists(obj_rh_atk_drop) || instance_exists(obj_rh_atk_fantasma_carumaru)) exit;`
- `obj_rh_atk_fantasma_carumaru` vive **220 frames** (`life = 220`); uma vez criado, a guarda impedia
  novos spawns por praticamente o turno inteiro (300 frames).
- **Correção:** guardas trocadas por agendamento por tempo (t=10 e t=46 em ciclo de 72 frames).

### 1.3 Trono Vazio — causa provável (não reproduzida em jogo)

- Arquivo: `objects/obj_rh_en_trono_vazio/Create_0.gml`, padrão antigo `pat_chifres_cartas` (linha 47
  antes da reescrita): guarda `instance_exists(obj_rh_atk_chifre) || instance_exists(obj_rh_atk_carta)`
  com `life = 120` em ambos os projéteis — o mesmo mecanismo de "fome de spawn" do Carumaru.
- Além disso, `pat_espadas` fazia a espada nascer em `y = rh_box_inner().y1 - 100 = -35` e
  `pat_icebergs` nascia abaixo da caixa; como esses ataques usam `rh_draw_clipped()`, só apareciam
  depois de atravessar a borda da caixa, reforçando a impressão de turno vazio.
- **Não consegui provar por execução qual dos dois mecanismos produziu exatamente o "nenhum padrão"
  relatado.** A reescrita eliminou os dois: agora chifre/carta/espada/iceberg nascem dentro da room
  (`y = 35` para espada, `y = 149` para iceberg) e o perigo reaparece a cada ≤ 48 frames.

### 1.4 Instrumentação de diagnóstico

- `scripts/scr_rh_attacks/scr_rh_attacks.gml`: macros `RH_DEBUG` (padrão `false`) e
  `RH_DEBUG_FORCE_PATTERN` (padrão `-1`), além de `rh_debug()`, `rh_debug_spawn()` e `rh_debug_destroy()`.
- `objects/obj_rh_battle_enemy/Step_0.gml:49-68`: loga início de turno, índice/nome do padrão,
  contagem de frames sem ataque e maior sequência vazia; `pattern_current()` é chamado na linha 68.
- `rh_spawn_attack()` loga objeto e posição; o Outside Room e as destruições dos ataques logam o motivo.
- **Como usar:** mude `RH_DEBUG` para `true` e, se quiser testar um padrão específico,
  `RH_DEBUG_FORCE_PATTERN` para `0`, `1` ou `2`. O Output mostrará `[RH][SPAWN]`, `[RH][DESTROY]`
  e `[RH][...]` com o caminho completo do turno.

---

## 2. Dois ataques novos do Juiz (Tarefa 2)

Arquivo do inimigo: `objects/obj_rh_en_juiz_das_armas/Create_0.gml:17-44`.
Ficha mantida: **HP 500, dano 3–5**.

### 2.1 "Martelo que tomba" — `obj_rh_atk_hammer_tomba`

Substitui o antigo `obj_rh_atk_hammer_giro` (objeto removido do projeto e do `.yyp`).
Pivô feito por código (`rh_draw_sprite_pivot`), porque a haste do sprite começa no canto do arquivo.

| Parâmetro | Valor |
|---|---|
| Fica em pé (telegrafia) | 30 frames |
| Aceleração angular | 0,8°/frame, +0,25°/frame até 90° |
| Tomba em | ~54 frames |
| Zona de impacto | 52 × 18 px, 10 frames, `dmg_mult = 1.4` (≈ 4–7 de dano) |
| Single-hit | sim (`was_hit` no `obj_rh_atk_zone`) |

**Linha do tempo (frames desde o spawn):**
- 1–30: martelo em pé no chão da caixa, retângulo vermelho piscando marcando a área, tremida leve.
- 31–~54: tombamento acelerado (não é girote contínuo — tem direção e fim previstos).
- ~54: cabeça chega ao chão; cria a zona de dano por 10 frames e dá um flash curto.
- ~64: zona desaparece; martelo some em 70.

### 2.2 "Círculo de juízes" — `obj_rh_atk_juiz_circle` + `obj_rh_atk_juiz_clone`

| Parâmetro | Valor |
|---|---|
| Clones no anel | 12 (raio 88 px em torno de `(155, 104)`) |
| Verdadeiro | 1 dos 12, sorteado (`irandom(11)`) |
| Escala dos clones | 0,6 (61 × 51 px → ~37 × 31 px) |
| Telegrafia | 18 frames por clone, um por vez (linha vermelha + tremida) |
| Início de cada aviso | t = 7, 29, 51, ..., 249 (intervalo de 22) |
| Investida | 8,5 px/frame por 12 frames (102 px), direção travada no início do aviso |
| Dano | 1× (3–5); só o verdadeiro machuca e empurra o coração (`kb_power = 3,4`) |
| Knockback | 12 frames de velocidade com atrito 0,82, clampado dentro da caixa |

**Linha do tempo:** t=1 anel completo; t=2–6 fade-in; t=7 primeiro aviso; investidas em
t=25, 47, 69, 91, 113, 135, 157, 179, 201, 223, 245 e 267; gerenciador destrói em t=286
(cabe nos 300 frames do turno). Nunca há dois avisos simultâneos e o alvo é travado antes da investida.

---

## 3. Monstro das Monções rebalanceado (Tarefa 3)

> ⚠️ O formato do canhão descrito aqui foi substituído na seção 9 (5 balas, sem laser).

Arquivo: `objects/obj_rh_en_monstro_das_mocoes/Create_0.gml`.

| Antes | Depois |
|---|---|
| HP 420 | HP 420 (mantido) |
| Dano 5–6 | **Dano 3–4** (`dmg_min`/`dmg_max`, linhas 6–7) |
| Canhão: 5 balas de 7 em 7 frames, mira perseguidora | 2 Gaster Blasters, mira travada, 1 raio cada |
| 3 tentáculos, aviso 22 frames | no máximo 2, aviso 34 frames |

- **Canhão** (`obj_rh_atk_canhao` + `obj_rh_atk_beam`): nasce em uma das 4 bordas **dentro da room**,
  avisa por 30 frames (linha/cone vermelho de 420 px, largura 16), trava a direção e dispara um raio
  de 620 × 16 px por 12 frames. O dano é por **geometria do segmento** (`rh_dist_to_segment`), não
  pela máscara girada do sprite — isso evita o hit "fantasma" do retângulo rotacionado.
  `was_hit` garante um único acerto por raio. Tempos: 2 canhões em t=14 e t=104 (90 frames de diferença).
- **Tentáculos** (`obj_rh_atk_tentacle`): aviso 34, sobe 8, fica 12, desce 10; zona de 18 px de
  largura com 20 frames de janela e `was_hit`. No padrão 2 aparecem em t=12 e t=112 (sem sobreposição).
- **Maré:** 3 ondas deixando uma faixa livre, ou 2 colunas separadas (36 px bloqueados no máximo),
  com avisos de 32/38 frames.

---

## 4. Apressador das Sombras (Tarefa 4)

Arquivo: `objects/obj_rh_en_apressador_das_sombras/Create_0.gml:12-14` e `:63-74`.

- **Corpo:** mantidos os sprites originais `spr_apressador_aberto_attack` /
  `spr_apressador_fechado_attack`. O placeholder de bandeirante que eu havia criado foi
  **removido** (pasta, `.yy`, PNGs e entradas no `.yyp`/`resource_order`), a pedido, por ter
  causado erro de resource faltante ao abrir o projeto. Nenhum sprite de visual novel,
  talaiB, textbox ou save foi tocado.
- Ficha mantida: **HP 360, dano 3–4**.

### Mordida — `obj_rh_atk_mordida`

| Parâmetro | Valor |
|---|---|
| Aviso | 24 frames (linha vermelha na frente) |
| Bote | 8 frames × 5 px = 40 px, mira travada no fim do aviso |
| Mordida | 6 frames; zona de 22 × 18 px na frente da boca |
| Recuo | 16 frames × 3,2 px de volta ao ponto inicial |
| Dano | 3–4 (`dmg_mult = 1.0`), single-hit via `was_hit` |
| Agendamento | t=12 e t=210 do padrão 4 |

**Linha do tempo:** 1–24 aviso (ainda acompanha o coração); 24 mira travada; 25–32 bote;
33–38 mordida (zona ativa); 39–54 recuo; destruição em 54. A zona é pequena e o sprite inteiro
não machuca, então não há "caixa invisível" gigante.

---

## 5. Arquivos alterados

**Criados**
- `objects/obj_rh_atk_juiz_circle/` (`.yy`, Create, Step, Other)
- `objects/obj_rh_atk_hammer_tomba/` (`.yy`, Create, Step, Draw, Other)
- `objects/obj_rh_atk_mordida/` (`.yy`, Create, Step, Draw)

**Reescritos / ajustados**
- `scripts/scr_rh_attacks/scr_rh_attacks.gml` (helpers de debug/geometria/pivô)
- `objects/obj_rh_battle_enemy/Create_0.gml`, `Step_0.gml`
- `objects/obj_rh_battle_bullet/Create_0.gml`, `Other_0.gml`
- `objects/obj_rh_battle_player/Create_0.gml`, `Step_0.gml`, `Draw_0.gml` (novo) e `.yy`
- `objects/obj_rh_atk_juiz_clone/` (Create, Step, Draw, Other e `.yy`)
- `objects/obj_rh_atk_canhao/`, `obj_rh_atk_beam/` (Create, Step, Draw, Other e `.yy`)
- `objects/obj_rh_atk_tentacle/Create_0.gml`, `Step_0.gml`
- `objects/obj_rh_en_trono_vazio/Create_0.gml`, `obj_rh_en_carumaru/Create_0.gml`,
  `obj_rh_en_juiz_das_armas/Create_0.gml`, `obj_rh_en_monstro_das_mocoes/Create_0.gml`,
  `obj_rh_en_apressador_das_sombras/Create_0.gml`
- `objects/obj_rh_atk_*/Step_0.gml`: log de destruição adicionado nos pontos de `instance_destroy()`
- `printizin2meajuda_corrigido.yyp` e `printizin2meajuda_corrigido.resource_order`

**Removido:** `objects/obj_rh_atk_hammer_giro/` (substituído por `obj_rh_atk_hammer_tomba`; entrada
removida do `.yyp` e do `resource_order`).

Preservadas as correções anteriores: `obj_rh_atk_zone` com `was_hit`, fantasma do Espelho,
frutas sem `spr_pe_guarana_attack`, inimigos centralizados, fases 3 do Trono afrouxadas.

---

## 6. Validações executadas

1. **JSON:** 480 arquivos `.yy`/`.yyp` + `resource_order` parseados com parser tolerante a vírgula final
   (o formato do projeto usa vírgulas finais). **0 erros de JSON.**
2. **Registro de assets:** 468 recursos no `.yyp`; todos os 4 assets novos presentes no `.yyp` e no
   `resource_order`; nenhuma referência restante a `obj_rh_atk_hammer_giro`.
3. **Nomes usados no GML:** nenhum nome `spr_*`/`obj_*` novo aponta para recurso inexistente.
   (O validador aponta 18 nomes antigos em comentários/variáveis — `spr_hit`, `spr_defeated`,
   `obj_rh_atk_*`, `spr_talaiB_*` etc. — todos pré-existentes e fora do escopo desta mudança.)
4. **Eventos:** todo evento declarado no `.yy` dos objetos tocados tem o `.gml` correspondente, e todo
   `.gml` de evento tem o evento declarado. Removido um evento Alarm órfão de `obj_rh_atk_canhao`.
5. **Sintaxe estrutural:** parênteses, chaves e colchetes balanceados (ignorando strings e comentários)
   em todos os GML tocados e no script de ataques.
6. **Geometria:** centro da caixa confirmado em `(155, 104)` (room: box em `105,64`, sprite 100 × 80,
   borda 1 px → interior `106..204`, `65..143`). Todos os spawns novos ficam dentro da room 320 × 240.

---

## 7. O que NÃO foi testado (importantíssimo)

- O usuário tentou rodar e recebeu erros de compilação no Trono (`unexpected symbol "?"`) e
  recurso faltante do bandeirante; **ambos foram corrigidos nesta revisão**. Ainda não houve
  confirmação de execução bem-sucedida depois da correção.
- Linhas do tempo acima são **rastreio manual frame a frame do código**, não observação em jogo.
- Não validei: colisão real com o coração, Knockback na prática, "justiça" percebida pelo jogador,
  desempenho com 12 clones + zonas, aparência do placeholder em batalha, nem compatibilidade com
  eventos de outros sistemas (save/visual novel — que não foram modificados).
- A causa do Trono (seção 1.3) não foi reproduzida; está marcada como provável, não confirmada.
- Recomendo: abrir o projeto, ativar `RH_DEBUG`, forçar cada padrão com `RH_DEBUG_FORCE_PATTERN`
  (0/1/2) e conferir o Output antes de considerar fechado.


---

## 8. Correções após o primeiro teste de execução (usuário)

O usuário rodou o jogo e encontrou dois problemas novos; ambos foram corrigidos:

1. **Erro de runtime no começo da batalha do Monstro das Monções**
   `Variable obj_rh_atk_canhao.beam_y2 not set before reading it` em
   `obj_rh_battle_player/Step_0.gml:98`. Causa: o loop de dano dos raios usava
   `with (obj_rh_battle_bullet)`, que inclui o **canhão** (filho do bullet). O canhão tinha
   `beam_w = 16` mas não possui `beam_x1..y2`, então a checagem passava e a leitura estourava.
   Correção: o loop agora é `with (obj_rh_atk_beam)`; `beam_w` do canhão voltou para `0` e
   a ficha do monstro não define mais `beam_w` no canhão.

2. **Canhão e aviso apontando em direções opostas**
   `spr_canhao_attack` tem a boca desenhada apontando para a **esquerda (180°)**. O código
   girava o sprite com `aim` (direção até o coração), então o sprite ficava de costas para a
   linha vermelha e para o raio. Correção: `Draw` gira o sprite com `aim - 180`, e o raio e o
   aviso agora nascem na **boca** (`centro + 15 px na direção travada`), não no centro/olho.
   (Etapa intermediária: a largura foi para `ray_w`. Na revisão final o laser foi removido
   por pedido — ver seção 9.)

**Ainda não compilei nem rodei o jogo.** Estas duas correções vieram do erro reportado pelo
usuário e de análise do sprite; é necessário novo teste em jogo para confirmar.


---

## 9. Correções após o segundo teste (usuário) — valores desta seção prevalecem

1. **`j` não declarado no círculo do Juiz** (`obj_rh_atk_juiz_circle/Step_0.gml:27`):
   o Fisher-Yates criava `var _j` mas usava `ordem[j]`. Corrigido para `ordem[_j]`.
   O centro do anel agora vem de `rh_box_inner()` em vez de `(155,104)` fixo.

2. **Martelo batendo fora da área do player**: o aviso era desenhado em `x=0` (valor
   inicial) enquanto o impacto caía perto do centro. Agora `zone_for_angle(90)` calcula
   a zona de impacto e é usada **tanto no aviso como no dano**. O lado é escolhido pela
   posição do coração (`rh_heart_x()`), e o sprite não recebe mais `side_left/pivot_x`
   sobrescritos pelo padrão. Zona: **58 × 42 px por 12 frames**, dano ×1,4.

3. **Canhão do Monstro das Monções**: o laser foi **removido** (objeto
   removido do canhão e do coração; o objeto `obj_rh_atk_beam` foi **mantido** porque o
   Intenente de Ferro ainda o usa como viga — ele voltou a ser uma barra com aviso de
   20 frames que desce e machuca por colisão normal).
   Novo comportamento: persegue só até o frame **38**, trava a mira e mantém o aviso
   até o frame **52** (14 frames extras para desviar). Dispara **5 balas**
   (`obj_rh_atk_bala_de_canhao`) a cada **10 frames**, velocidade **3,2 px/frame**,
   na direção travada, com dano 3–4 e single-hit pela colisão normal. 4 levas por round
   (t=14, 84, 154, 224).

4. **Ritmo de round contínuo** (inspirado na distribuição de ondas de Undertale/Deltarune,
   sem copiar arte): nenhum padrão fica parado 3 segundos. Novos ataques a cada:
   - Juiz: martelo 42 frames; círculo com **duas levas** (t=6 e t=150), 12 investidas
     por leva com aviso 12 e intervalo 18; bombas 36 frames.
   - Monções: canhão 70; tentáculos 48 (2 por ciclo); maré 64.
   - Trono: espadas 36/30/24 (por fase), chifres+cartas 40, icebergs 36/44.
   - Carumaru: lágrimas 32, fantasmas 48, misto 48.
   - Apressador: pisão 40, ossos 38, diamantes 44, mordida 60.

**Não compilei nem rodei o jogo.** As mudanças vêm do erro reportado e de rastreio manual
do código; é preciso novo teste para validar sensação de dificuldade e desempenho.
