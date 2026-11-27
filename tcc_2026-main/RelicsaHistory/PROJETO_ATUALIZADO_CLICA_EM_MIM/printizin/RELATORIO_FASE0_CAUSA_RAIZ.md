# Fase 0 — causa raiz dos turnos vazios e instrumentação

## Como o turno é medido

- `obj_rh_battle_controller` entra em `BATTLE_STATE.ENEMY_TURN` com `enemy_turn_timer = 300`.
- `obj_rh_battle_box` leva 26 frames para abrir; `is_open` só vira `true` no fim da abertura.
- `obj_rh_battle_enemy/Step_0.gml` só chama `pattern_current(pattern_timer)` quando a caixa está 100% aberta. O `_t` recebido começa em 1.
- O mesmo Step conta `instance_number(obj_rh_battle_bullet)` por frame. Como **todos** os `obj_rh_atk_*` herdam de `obj_rh_battle_bullet`, um "turno vazio" é, por definição, um intervalo em que nenhuma instância de ataque existe — mesmo que um aviso esteja sendo desenhado por código.

## Causa raiz (cadeia confirmada por leitura do código)

1. **Spawn fora da room + `Other/Outside Room` do pai.**
   `obj_rh_battle_bullet/Other_0.gml` destrói **qualquer** filho que saia da room, sem condição. O padrão antigo de Trono criava espadas em `y = -35`; nesse caso o `rh_spawn_attack` até logava o nascimento, mas no frame seguinte o `Outside Room` apagava a instância antes de ela entrar na caixa. O contador de turno continuava em zero. O mesmo mecanismo aparecia no clone do Juiz (`x = -70`, fora do escopo desta correção).

2. **Guardas `instance_exists` no lugar de tempo.**
   Vários padrões antigos só soltavam a próxima leva se `!instance_exists(obj_rh_atk_...)`, mas os objetos usados viviam 200–220 frames (fantasma do Carumaru) ou tinham ciclo longo (martelo/slam do Intenente). As levas agendadas para `t = 40, 80, 120...` eram simplesmente ignoradas, deixando janelas longas sem nenhuma instância. O `pat_sentenca` do Intenente tinha esse guarda explicitamente.

3. **Aviso não é instância de dano quando desenhado só por função.**
   `rh_draw_warning*` desenha a faixa, mas não cria ataque. Se o padrão só chama a função de desenho e adia o `rh_spawn_attack`, o frames de aviso entram na métrica como vazios. Isso é esperado e curto; o problema real era quando o spawn seguinte também era cancelado pelas causas 1 e 2.

4. **Geometria e desenho divergentes (agravante, não causa do contador zero).**
   Cartas giravam `image_angle`, mas `rh_draw_clipped` ignorava rotação; espadas e martelos tinham máscara de sprite diferente da área realmente desenhada. Isso explica relatos de "ataque passou e não machucou" / "machucou fora do desenho", mas não zera o `instance_number`.

## Instrumentação implantada

Todas as mensagens usam o prefixo `[RH]` e ficam mudas com `RH_DEBUG = false`.

| Onde | O que registra |
|---|---|
| `scr_rh_attacks` — `rh_debug`, `rh_debug_spawn`, `rh_debug_destroy` | base dos logs |
| `scr_rh_attacks` — `rh_spawn_attack` | **novo:** aviso imediato se `x/y` estiver fora da room, apontando a causa 1 antes da destruição pelo `Outside Room` |
| `obj_rh_battle_enemy/Step_0.gml` | `INICIO DO TURNO`, `FIM DO TURNO` com `turn_empty_frames`, `turn_max_empty_streak`, `pattern_timer`;log a cada 60 frames e em `t = 300` |
| `obj_rh_battle_player/Step_0.gml` → `rh_hurt_heart` | `ACERTO por <obj> | dano | iframes` |
| `obj_rh_battle_bullet/Other_0.gml` | `DESTROY ... motivo: Outside Room` |
| `obj_rh_atk_zone/Step_0.gml` | `DESTROY ... motivo: fim da vida` |
| `obj_rh_battle_controller/Step_0.gml` | **novo:** `DESTROY ... motivo: limpeza: HP do coração zerou` e `limpeza: fim do turno (300 frames)` — antes essas destruições em massa não tinham log |
| cada ataque novo | `rh_debug_destroy` com motivo próprio (`fim da vida`, `saiu da caixa`, `rebote 3`, etc.) |

### Como reproduzir

Em `scripts/scr_rh_attacks/scr_rh_attacks.gml`:

```gml
#macro RH_DEBUG             true
#macro RH_DEBUG_FORCE_PATTERN 0   // 0..n-1; -1 = normal
#macro RH_ATK_DEBUG_ZONES   true  // contorna em vermelho o que machuca
```

A sequência esperada em um turno sadio é:

```
[RH] INICIO DO TURNO ... padrao_1
[RH][SPAWN] obj_rh_atk_... @ x,y     // x,y dentro de 0..320 / 0..240
...
[RH] pattern_current RODOU t=60 | bullets=N>0
...
[RH] FIM DO TURNO ... max_empty_streak pequena
[RH][DESTROY] ... motivo: limpeza: fim do turno (300 frames)
```

Se aparecer `SPAWN` fora da room seguido de `DESTROY ... Outside Room` no mesmo frame, a causa 1 está ativa. Se o log mostrar `INICIO` e depois vários `pattern_current RODOU` com `bullets=0` sem nenhum `SPAWN`, é a causa 2 (guarda que pulou a leva).

## Correções estruturais já aplicadas na Fase 0

- Dano do coração extraído para `rh_hurt_heart(bullet)`: uma única fonte para `active`, `was_hit`, `destroy_on_hit`, `dmg_mult`, iframes, knockback e log. Geometria própria usa `active = false` e chama a função direto.
- `kb_dir` inicializado no Create do coração (antes o Draw lia uma variável inexistente).
- Helpers de geometria: `rh_heart_rect`, `rh_rect_hits_heart`, `rh_rot_rect_hits_heart`, `rh_segment_hits_heart`.
- `rh_draw_clipped_ext` (rotação em torno do centro geométrico) e `rh_draw_clipped_pivot` (pivô arbitrário), ambos com surface de recorte recriada se perdida.
- `rh_draw_warning_line(x1,y1,x2,y2,largura,t)` com compatibilidade para chamadas antigas de 5 argumentos.

## Contradição do enunciado

O pedido diz "sem frames de invencibilidade", mas o projeto já usa `iframe_max = 60` no coração e todo o sistema de dano (inclusive o antigo) depende disso para não aplicar vários acertos no mesmo frame. **Mantive 60 frames** para não quebrar a batalha e centralizei a atribuição em `rh_hurt_heart`. Se o objetivo for zerar, basta trocar `iframe_max` no Create de `obj_rh_battle_player` — a lógica já não está duplicada em outro arquivo.

## O que não foi testado

Não foi possível executar o GameMaker neste ambiente. O diagnóstico acima é estático (leitura do código + instrumentação pronta); a confirmação em jogo com `RH_DEBUG = true`, os force patterns e o contador `turn_max_empty_streak` ainda precisa ser feita por você.
