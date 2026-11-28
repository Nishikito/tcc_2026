"""Validações estáticas do rework do Itagibe (rode: python tools/validar_itagibe.py).

Checa:
- todo .yy/.yyp continua sendo JSON válido (aceitando vírgula final);
- todo obj_/spr_/rh_ citado nos .gml tocados existe;
- parênteses e chaves balanceados nos .gml tocados;
- linha do tempo aproximada dos 3 rounds (rastreio manual, sem rodar o jogo).
"""

from __future__ import annotations

import json
import math
import random
import re
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
TOCADOS = [
    "objects/obj_rh_battle_player/Create_0.gml",
    "objects/obj_rh_battle_player/Step_0.gml",
    "objects/obj_rh_battle_player/Draw_0.gml",
    "objects/obj_rh_battle_enemy/Create_0.gml",
    "objects/obj_rh_battle_enemy/Draw_0.gml",
    "objects/obj_battle_transition/Create_0.gml",
    "objects/obj_battle_transition/Draw_73.gml",
    "scripts/scr_damage_calculator/scr_damage_calculator.gml",
    "objects/obj_rh_en_itagibe/Create_0.gml",
    "objects/obj_rh_en_guarana/Create_0.gml",
    "objects/obj_rh_en_monstro_das_mocoes/Create_0.gml",
    "objects/obj_rh_atk_lanca_h/Create_0.gml",
    "objects/obj_rh_atk_lanca_h/Step_0.gml",
    "objects/obj_rh_atk_lanca_h/Draw_0.gml",
    "objects/obj_rh_atk_lanca_v/Create_0.gml",
    "objects/obj_rh_atk_lanca_v/Step_0.gml",
    "objects/obj_rh_atk_lanca_v/Draw_0.gml",
    "objects/obj_rh_atk_vaso_itagibe/Create_0.gml",
    "objects/obj_rh_atk_vaso_itagibe/Step_0.gml",
    "objects/obj_rh_atk_vaso_itagibe/Draw_0.gml",
    "objects/obj_rh_atk_bone_arco/Create_0.gml",
    "objects/obj_rh_atk_bone_arco/Step_0.gml",
    "objects/obj_rh_atk_bone_arco/Draw_0.gml",
    "scripts/scr_rh_attacks/scr_rh_attacks.gml",
    "objects/obj_fade_intro/Step_0.gml",
    "scripts/scr_game_text/scr_game_text.gml",
    "scripts/scr_text/scr_text.gml",
    "scripts/scr_visual_novel/scr_visual_novel.gml",
    "scripts/scr_cena_teachers/scr_cena_teachers.gml",
    "objects/obj_save_slots/Create_0.gml",
    "objects/obj_textbox/Draw_0.gml",
    "objects/ObjPlayer/Step_0.gml",
    "objects/ObjPlayer/Other_4.gml",
    "rooms/RoomRefeitorio/InstanceCreationCode_inst_9AA662.gml",
    "scripts/scr_cutscene_actions/scr_cutscene_actions.gml",
    "scripts/scr_cena_mundo/scr_cena_mundo.gml",
    "rooms/rm_inicio/InstanceCreationCode_inst_39ECD459.gml",
    "rooms/rm_inicio/InstanceCreationCode_inst_1B9162E2.gml",
    "objects/obj_settings/Create_0.gml",
    "objects/obj_settings/Step_0.gml",
    "objects/obj_battle_transition/Step_0.gml",
    "objects/obj_rh_battle_controller/Step_0.gml",
    "scripts/scr_save_system/scr_save_system.gml",
    "objects/obj_save_point/Step_0.gml",
    "scripts/scr_party/scr_party.gml",
    "objects/obj_warp/Step_0.gml",
    "objects/obj_warp1/Step_0.gml",
    "objects/obj_warpClick/Step_0.gml",
]


def carregar_json(caminho: Path) -> object:
    texto = caminho.read_text(encoding="utf-8")
    texto = re.sub(r",(\s*[}\]])", r"\1", texto)  # GameMaker aceita vírgula final
    return json.loads(texto)


def validar_json() -> set[str]:
    arquivos = list(RAIZ.glob("**/*.yy")) + list(RAIZ.glob("**/*.yyp"))
    nomes: set[str] = set()
    for arquivo in arquivos:
        dados = carregar_json(arquivo)
        if not isinstance(dados, dict):
            raise RuntimeError(f"JSON inesperado em {arquivo}")
        for chave in ("%Name", "name"):
            valor = dados.get(chave)
            if isinstance(valor, str) and valor:
                nomes.add(valor)
    print(f"[ok] {len(arquivos)} arquivos .yy/.yyp são JSON válidos")
    return nomes


def validar_camadas_sprites() -> None:
    """O GameMaker 2.3+ exige layers/<frame>/<layer>.png além do PNG na raiz."""
    faltando: list[str] = []
    for yy in RAIZ.glob("sprites/*/*.yy"):
        dados = carregar_json(yy)
        if not isinstance(dados, dict):
            continue
        layers = [camada.get("%Name") for camada in dados.get("layers", [])]
        for frame in dados.get("frames", []):
            nome_frame = frame.get("%Name")
            for nome_layer in layers:
                if not nome_frame or not nome_layer:
                    continue
                alvo = yy.parent / "layers" / nome_frame / f"{nome_layer}.png"
                if not alvo.is_file():
                    faltando.append(str(alvo.relative_to(RAIZ)))
    if faltando:
        raise RuntimeError("PNG de camada faltando: " + ", ".join(faltando))
    print("[ok] todos os sprites têm o PNG em layers/<frame>/<layer>.png")


def codigo_sem_comentarios(texto: str) -> str:
    # Remove comentários e strings para contar colchetes sem falsos positivos.
    texto = re.sub(r"/\*.*?\*/", "", texto, flags=re.S)
    texto = re.sub(r"//[^\r\n]*", "", texto)
    texto = re.sub(r'"(?:\\.|[^"\\])*"', '""', texto)
    texto = re.sub(r"'(?:\\.|[^'\\])*'", "''", texto)
    return texto


def validar_balanceamento() -> None:
    for rel in TOCADOS:
        codigo = codigo_sem_comentarios((RAIZ / rel).read_text(encoding="utf-8"))
        pares = {")": "(", "]": "[", "}": "{"}
        pilha: list[str] = []
        for pos, ch in enumerate(codigo):
            if ch in "([{":
                pilha.append(ch)
            elif ch in ")]}":
                if not pilha or pilha.pop() != pares[ch]:
                    raise RuntimeError(f"Desbalanceado em {rel} perto do caractere {pos}")
        if pilha:
            raise RuntimeError(f"Colchetes abertos em {rel}: {pilha}")
    print(f"[ok] {len(TOCADOS)} arquivos .gml com parênteses/chaves balanceados")


def validar_nomes(nomes_recursos: set[str]) -> None:
    funcoes: set[str] = set()
    for arquivo in RAIZ.glob("**/*.gml"):
        funcoes.update(re.findall(r"\bfunction\s+(\w+)", arquivo.read_text(encoding="utf-8")))

    usados: set[str] = set()
    for rel in TOCADOS:
        codigo = codigo_sem_comentarios((RAIZ / rel).read_text(encoding="utf-8"))
        usados.update(re.findall(r"\b(?:obj|spr|scr)_[A-Za-z0-9_]+\b", codigo))
        usados.update(re.findall(r"\brh_[a-z][A-Za-z0-9_]*\b", codigo))

    # spr_hit/spr_defeated são variáveis de instância que guardam sprites, não nomes de asset;
    # rh_clip_surf* são globais da surface de recorte, também não são assets.
    variaveis_ok = {"spr_hit", "spr_defeated",
                    "rh_clip_surf", "rh_clip_surf_w", "rh_clip_surf_h"}
    faltando = sorted(u for u in usados
                      if u not in nomes_recursos and u not in funcoes and u not in variaveis_ok)
    if faltando:
        raise RuntimeError("Nomes usados que não existem: " + ", ".join(faltando))
    print(f"[ok] {len(usados)} nomes obj_/spr_/rh_ citados existem (funções: {len(funcoes)})")


def validar_fundo_batalha() -> None:
    """Confere se o fundo da rm_rh_battle é o sprite em mosaico, atrás de tudo."""
    sala = RAIZ / "rooms/rm_rh_battle/rm_rh_battle.yy"
    dados = carregar_json(sala)
    if not isinstance(dados, dict):
        raise RuntimeError(f"JSON inesperado em {sala}")

    fundos = [camada for camada in dados.get("layers", [])
              if camada.get("resourceType") == "GMRBackgroundLayer"]
    if len(fundos) != 1:
        raise RuntimeError(f"rm_rh_battle deve ter 1 Background layer, achei {len(fundos)}")
    fundo = fundos[0]

    sprite = fundo.get("spriteId") or {}
    if sprite.get("name") != "spr_fundo_batalha":
        raise RuntimeError("o Background da rm_rh_battle não usa spr_fundo_batalha")

    # Background do GameMaker não desenha sprite com nine-slice ligado.
    arquivo_sprite = RAIZ / "sprites/spr_fundo_batalha/spr_fundo_batalha.yy"
    dados_sprite = carregar_json(arquivo_sprite)
    nove_fatias = (dados_sprite.get("nineSlice") or {}) if isinstance(dados_sprite, dict) else {}
    if nove_fatias.get("enabled"):
        raise RuntimeError("spr_fundo_batalha não pode ter nine-slice habilitado")

    if not fundo.get("htiled") or not fundo.get("vtiled"):
        raise RuntimeError("o fundo precisa repetir nos dois eixos (htiled/vtiled)")
    if fundo.get("stretch"):
        raise RuntimeError("stretch deve ficar false para o sprite repetir em 16x16")
    if fundo.get("colour") != 4294967295:
        raise RuntimeError("a cor do fundo precisa ser branca para não tingir o sprite")

    # Nenhum graphic antigo escalado pode sobrar na frente do Background.
    escalados = []
    for camada in dados.get("layers", []):
        for graphic in camada.get("assets", []):
            ref = graphic.get("spriteId") or {}
            if ref.get("name") == "spr_fundo_batalha":
                escalados.append(graphic)
    if escalados:
        raise RuntimeError("ainda existe sprite graphic de spr_fundo_batalha na room")

    profundidade_fundo = fundo["depth"]
    outros = [camada["depth"] for camada in dados.get("layers", [])
              if camada is not fundo and "depth" in camada]
    if outros and profundidade_fundo <= max(outros):
        raise RuntimeError("o Background precisa ter o maior depth (desenhar atrás)")

    print("[ok] rm_rh_battle: spr_fundo_batalha repetido nos dois eixos, sem graphic escalado")


def validar_projeteis() -> None:
    """Os tiros precisam ficar na frente do fundo preto da Battle Box."""
    ataques = (RAIZ / "scripts/scr_rh_attacks/scr_rh_attacks.gml").read_text(encoding="utf-8")
    macro = re.search(r"#macro\s+RH_BULLET_DEPTH\s+(-?\d+)", ataques)
    if not macro:
        raise RuntimeError("falta o macro RH_BULLET_DEPTH")
    profundidade = int(macro.group(1))
    if "_inst.depth = RH_BULLET_DEPTH" not in ataques:
        raise RuntimeError("rh_spawn_attack não sobe os tiros quando a layer Bullets falta")

    # Não exigir depth da layer no .yy: o IDE pode reescrever o arquivo e voltar
    # para 200. O que garante o desenho é o ajuste por instância em rh_spawn_attack().
    alarme = (RAIZ / "objects/obj_rh_battle_enemy/Alarm_0.gml").read_text(encoding="utf-8")
    if 'instance_create_layer(x, y, "Bullets", obj_rh_battle_bullet)' in alarme:
        raise RuntimeError("a bala antiga ainda é criada direto na layer Bullets (depth 200)")

    print(f"[ok] projéteis em RH_BULLET_DEPTH ({profundidade}): na frente da caixa, atrás do coração")


def validar_battle_box() -> None:
    """O interior da Battle Box precisa ser preto opaco, não transparente."""
    try:
        from PIL import Image
    except ImportError:
        print("[aviso] Pillow ausente; checagem visual da Battle Box ignorada")
        return

    base = RAIZ / "sprites/spr_rh_battle_box"
    arquivos = [
        base / "1e940437-57b5-40d7-94b6-a982a4f37de1.png",
        base / "layers/1e940437-57b5-40d7-94b6-a982a4f37de1"
               "/60bbe9af-4de3-42fe-841d-a3ca2e2a3f61.png",
    ]
    for arquivo in arquivos:
        imagem = Image.open(arquivo).convert("RGBA")
        centro = imagem.getpixel((imagem.width // 2, imagem.height // 2))
        if centro != (0, 0, 0, 255):
            raise RuntimeError(
                f"interior da Battle Box não é preto opaco em {arquivo.name}: {centro}")
    print("[ok] Battle Box: interior preto opaco nos 2 PNGs do sprite")


def validar_dialogos() -> None:
    """Diálogos de visual novel: fades, coordenadas, falas e retratos.

    Tudo vive em recursos JÁ registrados no .yyp: o IDE reescreve o projeto ao
    salvar e descarta scripts/instâncias novos criados fora dele (foi exatamente
    o que causou a caixa preta na primeira tentativa).
    """
    yyp = (RAIZ / "printizin2meajuda_corrigido.yyp").read_text(encoding="utf-8")
    for nome in ("scr_game_text", "scr_text", "ObjPlayer", "obj_speakblock",
                 "obj_fade_intro"):
        if f'"name":"{nome}"' not in yyp:
            raise RuntimeError(f"{nome} não está registrado no .yyp")

    dialogo = (RAIZ / "scripts/scr_game_text/scr_game_text.gml").read_text(encoding="utf-8")

    # Cada fala esperada: (texto, retrato). None = sem retrato (Bobalhao).
    falas = [
        ("historia_acordar",
         "Nossa... Eu dormi pra caramba... Já até deu o horário do almoço...",
         "talai-preocupado"),
        ("historia_corredor",
         "Onde será que o René deve estar? Vou ver com alguém da nossa sala.",
         "talai-pensando"),
        ("historia_bobalhao", "E aí mano, tudo bem?", "talai-falando"),
        ("historia_bobalhao", "opa, tô bem.", None),
        ("historia_bobalhao", "Cê ciu pra onde o René foi por acaso?", "talai-falando"),
        ("historia_bobalhao", "acho que ele foi pra sala do professor de matemática", None),
        ("historia_bobalhao", "Ah, valeu", "talai-sorrindo"),
    ]
    for caso, texto, retrato in falas:
        chamada = f'scr_text("{texto}"' + (f', "{retrato}");' if retrato else ");")
        if chamada not in dialogo:
            raise RuntimeError(f"falta a fala {caso}: {chamada}")
    for caso in ("historia_acordar", "historia_corredor", "historia_bobalhao"):
        if f'case "{caso}":' not in dialogo:
            raise RuntimeError(f"scr_game_text não trata {caso}")

    # RoomClass1_1: o diálogo dispara no Step do fade, não num trigger de posição.
    fade = (RAIZ / "objects/obj_fade_intro/Step_0.gml").read_text(encoding="utf-8")
    if 'create_textbox("historia_acordar")' not in fade or "room == RoomClass1_1" not in fade:
        raise RuntimeError("o fade de abertura não dispara a fala do historia_acordar")

    # Corredor: checagem no Step do player, que é persistente e já existe no .yyp.
    jogador = (RAIZ / "objects/ObjPlayer/Step_0.gml").read_text(encoding="utf-8")
    for trecho in ("room == RoomSalasCorredor",
                   "point_in_rectangle(x, y, 390, 95, 470, 365)",
                   'create_textbox("historia_corredor")',
                   "global.historia_corredor_done"):
        if trecho not in jogador:
            raise RuntimeError(f"o Step do player perdeu o gatilho do corredor: {trecho}")

    # Refeitorio: o obj_speakblock existente é reposicionado pelo creation code.
    refeitorio = carregar_json(RAIZ / "rooms/RoomRefeitorio/RoomRefeitorio.yy")
    blocos = [i for camada in refeitorio.get("layers", [])
              for i in camada.get("instances", [])
              if i.get("objectId", {}).get("name") == "obj_speakblock"]
    alvo = [i for i in blocos if i.get("%Name") == "inst_9AA662"]
    if len(alvo) != 1 or not alvo[0].get("hasCreationCode"):
        raise RuntimeError("o speakblock do refeitório não está disponível para falar")
    codigo = (RAIZ / "rooms/RoomRefeitorio/InstanceCreationCode_inst_9AA662.gml").read_text(encoding="utf-8")
    for trecho in ("x = 357;", "y = 120;", 'text_id = "historia_bobalhao";',
                   "image_xscale = 1;"):
        if trecho not in codigo:
            raise RuntimeError(f"o speakblock do Bobalhao perdeu: {trecho}")
    # O visual do NPC já existe na room; o speakblock é invisível e só interage.
    graphics = [g for camada in refeitorio.get("layers", [])
                for g in camada.get("assets", [])
                if g.get("spriteId", {}).get("name") == "SprBobalhao"]
    if not graphics:
        raise RuntimeError("a RoomRefeitorio não tem o graphic de SprBobalhao")
    falar = (RAIZ / "objects/obj_speakblock/Step_0.gml").read_text(encoding="utf-8")
    if "keyboard_check_pressed(vk_enter)" not in falar:
        raise RuntimeError("o speakblock não abre a fala com ENTER")

    # RoomTeachers já usava exatamente os dois retratos pedidos na queda.
    teachers = (RAIZ / "scripts/scr_dialogo_teachers/scr_dialogo_teachers.gml").read_text(encoding="utf-8")
    for retrato in ("talai-pensando", "talai-surpreso"):
        if f'"{retrato}"' not in teachers:
            raise RuntimeError(f"a cutscene da RoomTeachers perdeu o retrato {retrato}")

    print("[ok] diálogos: fade em RoomClass1_1, (424,195) corredor, "
          "(357,120) Bobalhao e retratos da RoomTeachers")


def validar_companion() -> None:
    """Rasiel: usa obj_speakblock (já registrado), rastro do scr_party e ENTER."""
    yyp = (RAIZ / "printizin2meajuda_corrigido.yyp").read_text(encoding="utf-8")
    for nome in ("obj_speakblock", "spr_companionB", "spr_companionC",
                 "spr_companionD", "spr_companionE"):
        if f'"name":"{nome}"' not in yyp:
            raise RuntimeError(f"{nome} não está registrado no .yyp")
    # Não pode haver dependência de objeto novo: o IDE removeu o registro anterior.
    if '"name":"obj_companion_rasiel"' in yyp or (RAIZ / "objects/obj_companion_rasiel").exists():
        raise RuntimeError("o companion ainda depende de um objeto novo; use obj_speakblock")

    party = (RAIZ / "scripts/scr_party/scr_party.gml").read_text(encoding="utf-8")
    for trecho in ("PARTY_FOLLOW_DELAY", "follow_trail", "global.cutscene_active"):
        if trecho not in party:
            raise RuntimeError("o scr_party perdeu a lógica de seguir/pausar")

    # O spawn foi centralizado no scr_party: o Room Start E o retorno de batalha chamam
    # a mesma função (o player recriado no meio da sala não dispara Room Start).
    if "function companion_ensure_spawn()" not in party:
        raise RuntimeError("scr_party não tem companion_ensure_spawn()")
    for trecho in ("room == rm_inicio", "room_is_story_world(room)",
                   "instance_create_depth(_px - 24, _py, -ObjPlayer.bbox_bottom, obj_speakblock)",
                   "instance_destroy(global.companion_inst)",
                   "text_id = \"rasiel_conversa\";",
                   "sprite_index = spr_companionB", "sprite[UP]      = spr_companionC",
                   "sprite[RIGHT]   = spr_companionD", "sprite[LEFT]    = spr_companionE",
                   "follow_trail    = []", "is_following    = false"):
        if trecho not in party:
            raise RuntimeError(f"spawn do companion perdeu: {trecho}")

    inicio = (RAIZ / "objects/ObjPlayer/Other_4.gml").read_text(encoding="utf-8")
    if "companion_ensure_spawn();" not in inicio or "talai_apply_form();" not in inicio:
        raise RuntimeError("o Room Start do player não chama o spawn do companion")
    step = (RAIZ / "objects/obj_settings/Step_0.gml").read_text(encoding="utf-8")
    if "companion_ensure_spawn();" not in step:
        raise RuntimeError("o retorno de batalha não recria o companion")

    passo = (RAIZ / "objects/ObjPlayer/Step_0.gml").read_text(encoding="utf-8")
    for trecho in ("variable_global_exists(\"companion_inst\")",
                   "instance_exists(global.companion_inst)",
                   "with (global.companion_inst)", "party_follower_step();",
                   "depth = -bbox_bottom;",
                   "if (!instance_exists(obj_battle_transition)) depth = -bbox_bottom;"):
        if trecho not in passo:
            raise RuntimeError(f"o Step do player não move o companion: {trecho}")
    # Player e companion precisam usar a MESMA regra de profundidade, senão o
    # companion desenha sempre por cima (player estava na depth fixa 0).
    if passo.count("depth = -bbox_bottom;") < 2:
        raise RuntimeError("a depth dinâmica do player/companion está incompleta")

    falar = (RAIZ / "objects/obj_speakblock/Step_0.gml").read_text(encoding="utf-8")
    for trecho in ("place_meeting(x,y,ObjPlayer)", "keyboard_check_pressed(vk_enter)",
                   "create_textbox(text_id)"):
        if trecho not in falar:
            raise RuntimeError(f"o speakblock não dá o ENTER ao companion: {trecho}")
    dialogo = (RAIZ / "scripts/scr_game_text/scr_game_text.gml").read_text(encoding="utf-8")
    if 'case "rasiel_conversa":' not in dialogo or '"rasiel-falando"' not in dialogo:
        raise RuntimeError("a fala do companion não usa o retrato do Rasiel")

    print("[ok] companion Rasiel: obj_speakblock, scr_party, depth por pés, rm_inicio e ENTER")


def validar_rodape_intro() -> None:
    """Apresentação do Rodapé antes de ele entrar na party."""
    dialogo = (RAIZ / "scripts/scr_game_text/scr_game_text.gml").read_text(encoding="utf-8")
    falas = [
        ("Olá, tudo bem?", "rasiel-sorrindo"),
        ("Você teve uma baita queda, está machucado?", "rasiel-preocupado"),
        ("O-Onde eu tô?!?!", "talaib-preocupado"),
        ("Você tá no Brasil", "rasiel-explicando"),
        ("Como assim???", "talaib-preocupado"),
        ("Você está no Brasil, mas especificamente na época do descobrimento", "rasiel-explicando"),
        ("O QUE??? COMO ISSO É POSSÍVEL?????", "talaib-surpreso"),
        ("(Vish, o muleke vai endoidar)", "rasiel-desacreditado"),
        ("Olha, eu não sei como te explicar isso, mas vou te ajudar a voltar pra casa. E aliás, meu nome é Rodapé!", "rasiel-sorrindo"),
        ("(Rodapé, sério mesmo?)", "talaib-pensando"),
        ("Tá... o meu nome é Talai", "talaib-falando"),
        ("Prazer em te conhecer! Irei te seguir pra te ajudar nessa aventura", "rasiel-sorrindo"),
    ]
    if 'case "rodape_intro":' not in dialogo:
        raise RuntimeError("scr_game_text não tem o caso rodape_intro")
    inicio = dialogo.index('case "rodape_intro":')
    trecho = dialogo[inicio:dialogo.index("\t}", inicio)]
    for texto, retrato in falas:
        chamada = f'scr_text("{texto}", "{retrato}");'
        if chamada not in trecho:
            raise RuntimeError(f"falta a fala da apresentação: {chamada}")
    if 'scr_text("Rodapé entrou para a party");' not in trecho:
        raise RuntimeError("a última fala (sem sprite) não está na apresentação")

    texto = (RAIZ / "scripts/scr_text/scr_text.gml").read_text(encoding="utf-8")
    for trecho in ('string_pos("talaib-", _who) == 1', "talaiB_vn_sprite(",
                   "string_delete(_who, 1, 7)"):
        if trecho not in texto:
            raise RuntimeError("scr_text não entende as chaves talaiB-*")

    vn = (RAIZ / "scripts/scr_visual_novel/scr_visual_novel.gml").read_text(encoding="utf-8")
    for trecho in ("function talaiB_vn_sprite", 'case "explicando":',
                   'asset_get_index("spr_rasiel_explicando_visual_novel")',
                   "spr_rasiel_falando_visual_novel"):
        if trecho not in vn:
            raise RuntimeError(f"scr_visual_novel perdeu o retrato: {trecho}")

    spawn = (RAIZ / "scripts/scr_party/scr_party.gml").read_text(encoding="utf-8")
    for trecho in ("global.rodape_intro_done",
                   "if (!global.rodape_intro_done && room == rm_inicio) {",
                   'global.after_dialog_action = "rodape_join_party";',
                   'create_textbox("rodape_intro")', "global.dialog_active = true"):
        if trecho not in spawn:
            raise RuntimeError(f"o spawn não dispara a apresentação: {trecho}")
    # A apresentação não pode disparar em RoomSalasCorredor nem em outra sala posterior.
    if "if (!global.rodape_intro_done) {" in spawn:
        raise RuntimeError("a apresentação ainda pode disparar fora de rm_inicio")

    caixa = (RAIZ / "objects/obj_textbox/Draw_0.gml").read_text(encoding="utf-8")
    for trecho in ('case "rodape_join_party":', "party_begin_follow(global.companion_inst)"):
        if trecho not in caixa:
            raise RuntimeError("o fim do diálogo não coloca o Rodapé na party")
    # Retrato grande do Rasiel (speaker_side = -1) espelhado, olhando para o Talai.
    for trecho in ("var _esc  = speaker_side[page];", "if (_esc == -1) _lx += _lw;",
                   "draw_sprite_ext(_lspr, 0, _lx,", "_esc, 1, 0, c_white, 1)"):
        if trecho not in caixa:
            raise RuntimeError("o retrato do Rasiel não foi virado para a esquerda")

    party = (RAIZ / "scripts/scr_party/scr_party.gml").read_text(encoding="utf-8")
    if "is_following   = true;" not in party:
        raise RuntimeError("party_begin_follow não liga o seguimento")

    print("[ok] introdução do Rodapé: 13 falas, retratos talaiB e party no fim")


def validar_forma_talai() -> None:
    """TalaiB no mapa e nos retratos a partir de rm_inicio (mundo da história)."""
    vn = (RAIZ / "scripts/scr_visual_novel/scr_visual_novel.gml").read_text(encoding="utf-8")
    if "function room_is_story_world" not in vn:
        raise RuntimeError("room_is_story_world desapareceu")
    inicio = vn.index("function room_is_story_world")
    lista = vn[inicio:vn.index("}", inicio)]
    salas = ("rm_inicio", "rm_aldeia_indigena", "rm_caminho_para_oca",
             "rm_conecta_caminho_praia", "rm_corredor_pra_praia")
    for sala in salas:
        if f"case {sala}:" not in lista:
            raise RuntimeError(f"{sala} não conta como mundo da história")
        if not (RAIZ / "rooms" / sala / f"{sala}.yy").exists():
            raise RuntimeError(f"a sala {sala} não existe no projeto")
    # Nenhum case pode citar sala que saiu do projeto (era o caso da antiga Room23).
    for sala in re.findall(r"case\s+(\w+)\s*:", lista):
        if not (RAIZ / "rooms" / sala / f"{sala}.yy").exists():
            raise RuntimeError(f"case {sala} aponta para uma sala inexistente")
    for arquivo in RAIZ.rglob("*.gml"):
        if "Room23" in arquivo.read_text(encoding="utf-8"):
            raise RuntimeError(f"{arquivo.relative_to(RAIZ)} ainda cita a sala removida Room23")
    # Salas da escola não podem trocar o Talai para talaiB — o corredor era o bug.
    for sala in ("RoomPatio", "RoomSalasCorredor", "RoomRefeitorio", "RoomLivro",
                 "RoomBathroom1_1", "RoomBathroom_1", "RoomClass1_1", "RoomTeachers_1"):
        if f"case {sala}:" in lista:
            raise RuntimeError(f"{sala} não deveria estar no mundo da história")

    yyp = (RAIZ / "printizin2meajuda_corrigido.yyp").read_text(encoding="utf-8")
    for sprite, direcao in (("spr_talaiB_B", "DOWN"), ("spr_talaiB_C", "UP"),
                            ("spr_talaiB_D", "RIGHT"), ("spr_talaiB_E", "LEFT")):
        if f'"name":"{sprite}"' not in yyp:
            raise RuntimeError(f"{sprite} não está registrado no .yyp")
        dados = carregar_json(RAIZ / "sprites" / sprite / f"{sprite}.yy")
        if len(dados.get("frames", [])) < 4:
            raise RuntimeError(f"{sprite} deveria ter as 4 frames da animação")
        if dados.get("parent", {}).get("path") != "folders/Sprites/player/talaiB.yy":
            raise RuntimeError(f"{sprite} saiu da pasta player/talaiB")

    aplicar = vn[vn.index("function talai_apply_form"):]
    for trecho in ("room_is_story_world()",
                   "sprite[DOWN]  = spr_talaiB_B", "sprite[UP]    = spr_talaiB_C",
                   "sprite[RIGHT] = spr_talaiB_D", "sprite[LEFT]  = spr_talaiB_E",
                   "SprPlayer", "mask_index   = sprite[DOWN]",
                   "sprite_index = sprite[face]"):
        if trecho not in aplicar:
            raise RuntimeError(f"talai_apply_form perdeu: {trecho}")
    # spr_talaiB_world não existe mais; os sprites de batalha ficam só na batalha.
    codigo = "\n".join(linha for linha in aplicar.splitlines()
                       if not linha.strip().startswith("//"))
    for proibido in ("spr_talaiB_world", "spr_talaiB_up", "spr_talaiB_left",
                     "spr_talaiB_right"):
        if proibido in codigo:
            raise RuntimeError(f"talai_apply_form ainda usa {proibido} (sprite inexistente)")

    for arquivo in ("objects/ObjPlayer/Create_0.gml", "objects/ObjPlayer/Other_4.gml"):
        texto = (RAIZ / arquivo).read_text(encoding="utf-8")
        if "talai_apply_form();" not in texto:
            raise RuntimeError(f"{arquivo} não aplica a forma do Talai")

    print("[ok] TalaiB B/C/D/E só em rm_inicio/mundo da história (não na escola)")


def validar_cena_guarana() -> None:
    """rm_inicio: o guaraná rola, Talai se surpreende, ele se aproxima e começa a batalha."""
    cena = (RAIZ / "scripts/scr_cena_mundo/scr_cena_mundo.gml").read_text(encoding="utf-8")
    if 'case "mundo_guarana_encontro":' not in cena:
        raise RuntimeError("scr_cena_mundo não tem a cena do guaraná")
    inicio = cena.index('case "mundo_guarana_encontro":')
    trecho = cena[inicio:]
    for acao in ("cutscene_player_lock", "cutscene_face_dir", "cutscene_place_at",
                 "cutscene_set_visible", "cutscene_roll_to", "cutscene_face_player", "cutscene_wait",
                 '[cutscene_dialogue, "mundo_guarana_surpreso"]',
                 "cutscene_move_axis", "cutscene_battle_encounter"):
        if acao not in trecho:
            raise RuntimeError(f"a cena do guaraná perdeu a ação: {acao}")
    # A ação de batalha tem que vir DEPOIS da fala e da aproximação.
    if trecho.index("cutscene_battle_encounter") < trecho.index("mundo_guarana_surpreso"):
        raise RuntimeError("a batalha começa antes do diálogo")

    acoes = (RAIZ / "scripts/scr_cutscene_actions/scr_cutscene_actions.gml").read_text(encoding="utf-8")
    for funcao in ("function cutscene_place_at", "function cutscene_roll_to",
                   "function cutscene_battle_encounter"):
        if funcao not in acoes:
            raise RuntimeError(f"falta a ação {funcao}")
    # A rolagem tem que ser horizontal: o guaraná é alinhado ao y do Talai antes de aparecer.
    if "[cutscene_place_at, _g, _g.x, _stop_y]" not in trecho:
        raise RuntimeError("o guaraná não é alinhado à altura do Talai antes de rolar")
    if "var _stop_y = ObjPlayer.y;" not in trecho:
        raise RuntimeError("o destino da rolagem não está na altura do Talai")
    rolagem = acoes[acoes.index("function cutscene_roll_to"):]
    for trecho2 in ("point_distance(_inst.x, _inst.y, _tx, _ty)",
                    "_inst.image_angle += _inst.roll_spd",
                    "_inst.image_angle = 0"):
        if trecho2 not in rolagem:
            raise RuntimeError(f"a rolagem não gira/para o guaraná: {trecho2}")
    batalha = acoes[acoes.index("function cutscene_battle_encounter"):]
    for trecho2 in ("instance_create_depth(0, 0, -50000, obj_battle_transition, {",
                    "enemy: _enemy", "enemy_id_value: _enemy_id"):
        if trecho2 not in batalha:
            raise RuntimeError(f"a transição de batalha está incompleta: {trecho2}")

    dialogo = (RAIZ / "scripts/scr_game_text/scr_game_text.gml").read_text(encoding="utf-8")
    if 'case "mundo_guarana_surpreso":' not in dialogo:
        raise RuntimeError("falta o diálogo do guaraná em scr_game_text")
    fala = 'scr_text("Oxi, o que um guaraná ta fazendo aqui???", "talaib-surpreso");'
    if fala not in dialogo:
        raise RuntimeError("o diálogo do guaraná não usa o retrato talaiB surpreso")

    sala = carregar_json(RAIZ / "rooms/rm_inicio/rm_inicio.yy")
    insts = {i["%Name"]: i for l in sala["layers"] for i in l.get("instances", [])}
    for nome, objeto in (("inst_39ECD459", "obj_cutscene_trigger"),
                         ("inst_1B9162E2", "obj_rh_en_guarana")):
        inst = insts.get(nome)
        if inst is None or inst["objectId"]["name"] != objeto:
            raise RuntimeError(f"{nome} não é mais um {objeto} em rm_inicio")

    gatilho = (RAIZ / "rooms/rm_inicio/InstanceCreationCode_inst_39ECD459.gml").read_text(encoding="utf-8")
    escondido = (RAIZ / "rooms/rm_inicio/InstanceCreationCode_inst_1B9162E2.gml").read_text(encoding="utf-8")
    nativo = (insts["inst_39ECD459"].get("hasCreationCode")
              and insts["inst_1B9162E2"].get("hasCreationCode")
              and 'scene_id = "mundo_guarana_encontro";' in gatilho
              and "visible = false;" in escondido)
    # O IDE reescreve .yy e pode derrubar os creation codes; o obj_settings cobre isso.
    settings = (RAIZ / "objects/obj_settings/Step_0.gml").read_text(encoding="utf-8")
    fallback = ('_t.scene_id = "mundo_guarana_encontro";' in settings
                and "with (obj_rh_en_guarana) visible = false;" in settings)
    if not (nativo or fallback):
        raise RuntimeError("nem o creation code nem o fallback configuram o encontro")

    print("[ok] cutscene do guaraná: rola, Talai surpreso, aproxima e inicia batalha")


def validar_retorno_batalha() -> None:
    """Vitória volta ao ponto da luta com player recriado; derrota volta ao savepoint."""
    criar = (RAIZ / "objects/obj_settings/Create_0.gml").read_text(encoding="utf-8")
    for trecho in ("battle_return_pending", "battle_return_room", "battle_return_x",
                   "battle_return_y", "battle_return_face", "battle_scene_id",
                   "last_savepoint_room", "last_savepoint_x", "last_savepoint_y",
                   "last_savepoint_face", "pre_battle_face"):
        if trecho not in criar:
            raise RuntimeError(f"obj_settings/Create não inicializa {trecho}")

    passo = (RAIZ / "objects/obj_settings/Step_0.gml").read_text(encoding="utf-8")
    inicio = passo.index("// ── RETORNO DA BATALHA")
    trecho = passo[inicio:passo.index("if (room == RoomTeachers_1", inicio)]
    for exigido in ("room != rm_rh_battle", "if (!instance_exists(ObjPlayer))",
                    "instance_create_layer(global.battle_return_x, global.battle_return_y",
                    "camera_set_view_target(view_camera[0], _p)",
                    "layer_exists(\"Player\") ? \"Player\" : \"Instances\"",
                    "camera_set_view_pos(_cam,", "global.fade_active     = false"):
        if exigido not in trecho:
            raise RuntimeError(f"o retorno de batalha não garante o player/câmera: {exigido}")
    # layer_find_name() quebra nesta versão do GameMaker ("variable not set before reading").
    if "layer_find_name" in passo:
        raise RuntimeError("obj_settings/Step ainda usa layer_find_name()")

    transicao = (RAIZ / "objects/obj_battle_transition/Step_0.gml").read_text(encoding="utf-8")
    if "global.pre_battle_face = ObjPlayer.face;" not in transicao:
        raise RuntimeError("a transição não guarda a direção do player")

    ctrl = (RAIZ / "objects/obj_rh_battle_controller/Step_0.gml").read_text(encoding="utf-8")
    vitoria = ctrl[ctrl.index("case BATTLE_STATE.VICTORY"):ctrl.index("case BATTLE_STATE.DEFEAT")]
    derrota = ctrl[ctrl.index("case BATTLE_STATE.DEFEAT"):]
    for exigido in ("global.battle_return_room = global.pre_battle_room",
                    "global.battle_return_pending = true"):
        if exigido not in vitoria:
            raise RuntimeError(f"a vitória não prepara o retorno: {exigido}")
    for exigido in ("global.battle_return_room = global.last_savepoint_room",
                    "global.battle_return_x    = global.last_savepoint_x",
                    "global.hp = global.max_hp",
                    "global.pre_battle_x  = 0",
                    "variable_struct_remove(global.scenes_done, global.battle_scene_id)"):
        if exigido not in derrota:
            raise RuntimeError(f"a derrota não volta ao savepoint: {exigido}")

    save = (RAIZ / "scripts/scr_save_system/scr_save_system.gml").read_text(encoding="utf-8")
    gravar = save[save.index("function save_game"):save.index("// ── Fluxo de jogo")]
    carregar = save[save.index("function save_load_game"):]
    for exigido in ("global.last_savepoint_room = room", "global.last_savepoint_x    = _snap.x",
                    "global.last_savepoint_face = _snap.face"):
        if exigido not in gravar:
            raise RuntimeError(f"salvar não lembra o savepoint: {exigido}")
    for exigido in ("global.last_savepoint_room = _room", "global.last_savepoint_x    = _d.x",
                    "global.last_savepoint_face = _d.face"):
        if exigido not in carregar:
            raise RuntimeError(f"carregar não lembra o savepoint: {exigido}")
    reset = save[save.index("function save_reset_progress"):save.index("// NOVO JOGO")]
    if "global.last_savepoint_room = variable_global_exists(\"start_room\")" not in reset:
        raise RuntimeError("novo jogo não reseta o savepoint")

    acoes = (RAIZ / "scripts/scr_cutscene_actions/scr_cutscene_actions.gml").read_text(encoding="utf-8")
    if "function cutscene_battle_encounter(_enemy, _enemy_id, _scene_id" not in acoes:
        raise RuntimeError("a batalha por cutscene não informa a cena")
    cena = (RAIZ / "scripts/scr_cena_mundo/scr_cena_mundo.gml").read_text(encoding="utf-8")
    if '"mundo_guarana_encontro"]' not in cena:
        raise RuntimeError("a cena do guaraná não passa o ID da cena para a batalha")

    print("[ok] retorno de batalha: player recriado na vitória, savepoint na derrota")


def validar_fala_savepoint() -> None:
    """Fala única ao avistar o save point: Talai pergunta, Rodapé explica."""
    texto = (RAIZ / "scripts/scr_game_text/scr_game_text.gml").read_text(encoding="utf-8")
    if 'case "mundo_savepoint_visto":' not in texto:
        raise RuntimeError("falta o diálogo mundo_savepoint_visto")
    inicio = texto.index('case "mundo_savepoint_visto":')
    bloco = texto[inicio:texto.index("return;", inicio)]
    # Texto escrito pelo usuário no IDE: não sobrescrever, só conferir a estrutura.
    exigidos = (
        "coisa amarela flutuando", "surpreso",
        "savepoint", "rasiel-explicando", "progresso", "rasiel-falando",
        "derrotado", "rasiel-sorrindo", "talaib",
    )
    for trecho in exigidos:
        if trecho not in bloco:
            raise RuntimeError(f"a fala do save point não contém {trecho!r}")

    passo = (RAIZ / "objects/obj_save_point/Step_0.gml").read_text(encoding="utf-8")
    inicio = passo.index("// ── Primeira vez que o Talai VÊ")
    bloco = passo[inicio:passo.index("// Não abre durante diálogo", inicio)]
    for exigido in ("!global.savepoint_intro_done", "point_distance(x, y, ObjPlayer.x, ObjPlayer.y) < 120",
                    "create_textbox(\"mundo_savepoint_visto\")", "global.dialog_active = true",
                    "!global.dialog_active", "!instance_exists(obj_save_slots)",
                    "!global.cutscene_active", "!global.fade_active"):
        if exigido not in bloco:
            raise RuntimeError(f"o gatilho do save point não garante {exigido}")

    criar = (RAIZ / "objects/obj_settings/Create_0.gml").read_text(encoding="utf-8")
    if 'variable_global_exists("savepoint_intro_done")' not in criar:
        raise RuntimeError("obj_settings não inicializa savepoint_intro_done")
    save = (RAIZ / "scripts/scr_save_system/scr_save_system.gml").read_text(encoding="utf-8")
    if "global.savepoint_intro_done = false;" not in save[save.index("function save_reset_progress"):save.index("// NOVO JOGO")]:
        raise RuntimeError("novo jogo não reseta a fala do save point")

    print("[ok] fala do save point: Talai pergunta, Rodapé explica, dispara uma vez")


def validar_flags_apresentacao() -> None:
    """As falas de apresentação entram no save e valem uma única vez."""
    save = (RAIZ / "scripts/scr_save_system/scr_save_system.gml").read_text(encoding="utf-8")
    inicio = save.index("function save_extra_globals()")
    extras = save[inicio:save.index("// ── Nomes de arquivo", inicio)]
    for nome in ("carol_disappeared", "rodape_intro_done", "savepoint_intro_done"):
        if f'"{nome}"' not in extras:
            raise RuntimeError(f"save_extra_globals não grava {nome}")
    reset = save[save.index("function save_reset_progress"):save.index("// NOVO JOGO")]
    for nome in ("rodape_intro_done", "savepoint_intro_done"):
        if not re.search(rf"global\.{nome}\s*=\s*false;", reset):
            raise RuntimeError(f"novo jogo não reseta {nome}")

    criar = (RAIZ / "objects/obj_settings/Create_0.gml").read_text(encoding="utf-8")
    if 'variable_global_exists("rodape_intro_done")' not in criar:
        raise RuntimeError("obj_settings não inicializa rodape_intro_done antes do CONTINUAR")

    party = (RAIZ / "scripts/scr_party/scr_party.gml").read_text(encoding="utf-8")
    if "if (!global.rodape_intro_done && room == rm_inicio) {" not in party:
        raise RuntimeError("a apresentação do Rodapé não está protegida pela flag")
    print("[ok] flags de apresentação salvas/CONTINUAR: Rodapé e save point uma vez só")


def validar_anti_loop_warps() -> None:
    """Destinos de warp que caem sobre outra máscara não podem re-disparar na chegada."""
    for nome in ("obj_warp", "obj_warp1", "obj_warpClick"):
        passo = (RAIZ / f"objects/{nome}/Step_0.gml").read_text(encoding="utf-8")
        if 'variable_global_exists("warp_suppressed")' not in passo:
            raise RuntimeError(f"{nome} não inicializa warp_suppressed")
        if "if (global.warp_suppressed) exit;" not in passo:
            raise RuntimeError(f"{nome} não respeita o travamento anti-loop")
        if "global.warp_suppressed = true;" not in passo:
            raise RuntimeError(f"{nome} não travava os warps ao disparar")

    passo = (RAIZ / "objects/obj_settings/Step_0.gml").read_text(encoding="utf-8")
    inicio = passo.index("// ── ANTI-LOOP DE WARPS")
    bloco = passo[inicio:passo.index("// ── RETORNO DA BATALHA", inicio)]
    for nome in ("obj_warp", "obj_warp1", "obj_warpClick"):
        if f"with ({nome})" not in bloco:
            raise RuntimeError(f"a liberação do travamento ignora {nome}")
    for trecho in ("place_meeting(x, y, ObjPlayer)", "if (!_on_warp) global.warp_suppressed = false;"):
        if trecho not in bloco:
            raise RuntimeError(f"a liberação do travamento perdeu: {trecho}")

    save = (RAIZ / "scripts/scr_save_system/scr_save_system.gml").read_text(encoding="utf-8")
    reset = save[save.index("function save_reset_progress"):save.index("// NOVO JOGO")]
    if "global.warp_suppressed      = false;" not in reset:
        raise RuntimeError("novo jogo não libera o travamento de warps")
    carregar = save[save.index("function save_load_game"):]
    if "global.warp_suppressed = true;" not in carregar:
        raise RuntimeError("carregar um save sobre um warp pode disparar a transição de novo")

    print("[ok] warps anti-loop: travados ao trocar de sala, liberados ao sair da máscara")


def validar_save_derrotas() -> None:
    """Derrotas e cenas 'once' (guaraná) sobrevivem ao salvar/carregar."""
    save = (RAIZ / "scripts/scr_save_system/scr_save_system.gml").read_text(encoding="utf-8")
    for trecho in ("function save_enemy_defeated(_id)",
                   'scenes_done:       global.scenes_done',
                   'variable_struct_exists(_d, "scenes_done")',
                   'variable_struct_exists(_d, "defeated_enemies")',
                   "global.scenes_done = {};"):
        if trecho not in save:
            raise RuntimeError(f"o save não preserva derrotas/cenas: {trecho}")
    reset = save[save.index("function save_reset_progress"):save.index("// NOVO JOGO")]
    if not re.search(r"global\.scenes_done\s*=\s*\{\};", reset):
        raise RuntimeError("novo jogo não limpa as cenas já tocadas")

    passo = (RAIZ / "objects/obj_settings/Step_0.gml").read_text(encoding="utf-8")
    if 'save_enemy_defeated("Guarana")' not in passo:
        raise RuntimeError("rm_inicio não consulta se o guaraná já foi derrotado")
    cena = (RAIZ / "scripts/scr_cena_mundo/scr_cena_mundo.gml").read_text(encoding="utf-8")
    if 'if (save_enemy_defeated("Guarana")) return [];' not in cena:
        raise RuntimeError("a cena do guaraná pode repetir após a vitória")
    ctrl = (RAIZ / "objects/obj_rh_battle_controller/Step_0.gml").read_text(encoding="utf-8")
    vitoria = ctrl[ctrl.index("case BATTLE_STATE.VICTORY"):ctrl.index("case BATTLE_STATE.DEFEAT")]
    if "variable_struct_set(global.scenes_done, global.battle_scene_id, true);" not in vitoria:
        raise RuntimeError("a vitória não marca a cena 'once' como concluída")
    print("[ok] save de derrotas: inimigo e cena do guaraná não repetem ao carregar")


def validar_diagonal_companion() -> None:
    """O seguidor usa a mesma regra de face do Talai (horizontal manda na diagonal)."""
    party = (RAIZ / "scripts/scr_party/scr_party.gml").read_text(encoding="utf-8")
    for trecho in ("function follower_face_update(_dx, _dy)",
                   "if (_dx > 0 && follow_dir == LEFT)  follow_dir = RIGHT;",
                   "if (_dx < 0 && follow_dir == RIGHT) follow_dir = LEFT;",
                   "if (_dy > 0 && follow_dir == UP)   follow_dir = DOWN;",
                   "if (_dy < 0 && follow_dir == DOWN) follow_dir = UP;",
                   "var _ix = ObjPlayer.xspd, _iy = ObjPlayer.yspd;",
                   "follower_face_update(_ix, _iy);"):
        if trecho not in party:
            raise RuntimeError(f"o companion perdeu a regra diagonal do Talai: {trecho}")
    if "abs(_dx) > abs(_dy)" in party:
        raise RuntimeError("o companion ainda escolhe o sprite comparando abs(dx) > abs(dy)")

    jogador = (RAIZ / "objects/ObjPlayer/Step_0.gml").read_text(encoding="utf-8")
    regras = (
        "if yspd == 0 {",
        "if xspd > 0 && face == LEFT  { face = RIGHT };",
        "if xspd < 0 && face == RIGHT { face = LEFT };",
        "if yspd > 0 && face == UP   { face = DOWN };",
        "if yspd < 0 && face == DOWN { face = UP };",
    )
    for trecho in regras:
        if trecho not in jogador:
            raise RuntimeError(f"a regra de face do Talai mudou: {trecho}")
    print("[ok] companion diagonal: mesma regra de face do Talai, sem flicker")


def validar_sons() -> None:
    """Os 5 sons pedidos existem no .yyp e estão ligados aos eventos certos."""
    yyp = carregar_json(RAIZ / "printizin2meajuda_corrigido.yyp")
    registrados = {r["id"]["name"] for r in yyp["resources"] if r["id"]["path"].startswith("sounds/")}
    for nome in ("sfxDanielVc", "vc_text", "sfxSave", "sfxFall", "sfxDamagePlayer"):
        if nome not in registrados:
            raise RuntimeError(f"som {nome} não está registrado no .yyp")

    texto = (RAIZ / "scripts/scr_text/scr_text.gml").read_text(encoding="utf-8")
    # Talai normal e talaiB (cada um com a sua variante de emoção).
    if len(re.findall(r"snd\[page_number\]\s*=\s*sfxDanielVc;", texto)) < 2:
        raise RuntimeError("as falas do Talai não usam sfxDanielVc")
    if not re.search(r"argument_count\s*<=\s*1", texto) or not re.search(
        r"snd\[page_number\]\s*=\s*vc_text;", texto
    ):
        raise RuntimeError("textos sem retrato não usam vc_text")

    slots = (RAIZ / "objects/obj_save_slots/Create_0.gml").read_text(encoding="utf-8")
    salvar = slots[slots.index("do_save = function"):slots.index("do_copy = function")]
    if "audio_play_sound(sfxSave, 0, false);" not in salvar:
        raise RuntimeError("salvar/sobrescrever não toca sfxSave")

    acoes = (RAIZ / "scripts/scr_cutscene_actions/scr_cutscene_actions.gml").read_text(encoding="utf-8")
    if "function cutscene_player_fall_out(_grav, _snd = noone)" not in acoes:
        raise RuntimeError("a queda da cutscene não aceita som")
    cena = (RAIZ / "scripts/scr_cena_teachers/scr_cena_teachers.gml").read_text(encoding="utf-8")
    if "[cutscene_player_fall_out, 0.3, sfxFall]" not in cena:
        raise RuntimeError("a queda da RoomTeachers não toca sfxFall")

    dano = (RAIZ / "scripts/scr_damage_calculator/scr_damage_calculator.gml").read_text(encoding="utf-8")
    bloco = dano[dano.index("function apply_damage_to_player"):dano.index("function apply_damage_to_enemy")]
    if "audio_play_sound(sfxDamagePlayer, 0, false);" not in bloco:
        raise RuntimeError("o dano do player na batalha não toca sfxDamagePlayer")
    print("[ok] sons:Talai=sfxDanielVc, sem sprite=vc_text, save=sfxSave, queda=sfxFall, dano=sfxDamagePlayer")


def validar_musica_overworld() -> None:
    """SndCastleFunk nas salas da pasta overworld, entre a abertura e a RoomTeachers."""
    vn = (RAIZ / "scripts/scr_visual_novel/scr_visual_novel.gml").read_text(encoding="utf-8")
    inicio = vn.index("function room_is_overworld")
    bloco = vn[inicio:vn.index("/// Sprite de visual novel", inicio)]

    da_pasta = set()
    for p in (RAIZ / "rooms").glob("*/*.yy"):
        dados = carregar_json(p)
        caminho_pasta = dados.get("parent", {}).get("path", "")
        if caminho_pasta.startswith("folders/Rooms/overworld"):
            da_pasta.add(p.parent.name)
    if not da_pasta:
        raise RuntimeError("nenhuma sala da pasta overworld foi encontrada")
    for sala in sorted(da_pasta):
        if f"case {sala}:" not in bloco:
            raise RuntimeError(f"room_is_overworld() não inclui {sala} (pasta overworld)")

    passo = (RAIZ / "objects/obj_settings/Step_0.gml").read_text(encoding="utf-8")
    inicio = passo.index("// ── MÚSICA DO OVERWORLD")
    musica = passo[inicio:passo.index("// ── TEMPO DE JOGO", inicio)]
    for trecho in ("room_is_overworld(room)", "room != RoomTeachers_1",
                   "global.overworld_music_finished", "global.cutscene_active",
                   "!instance_exists(obj_fade_intro)", "!global.dialog_active",
                   "audio_play_sound(SndCastleFunk, 10, true)",
                   "audio_stop_sound(SndCastleFunk)"):
        if trecho not in musica:
            raise RuntimeError(f"a música do overworld perdeu: {trecho}")

    criar = (RAIZ / "objects/obj_settings/Create_0.gml").read_text(encoding="utf-8")
    if 'variable_global_exists("overworld_music_on")' not in criar:
        raise RuntimeError("obj_settings não inicializa o estado da música")
    save = (RAIZ / "scripts/scr_save_system/scr_save_system.gml").read_text(encoding="utf-8")
    if '"overworld_music_finished"' not in save[save.index("function save_extra_globals"):save.index("// ── Nomes de arquivo")]:
        raise RuntimeError("o save não guarda se a música do overworld já terminou")
    transicao = (RAIZ / "objects/obj_battle_transition/Step_0.gml").read_text(encoding="utf-8")
    if "global.overworld_music_on = false;" not in transicao:
        raise RuntimeError("a batalha não libera a música para voltar a tocar")
    print("[ok] música overworld: SndCastleFunk após a abertura, para na RoomTeachers")


def simular() -> None:
    # Round 1: salvas em 10/80/150/220, aviso 22, 8 frames de espaçamento.
    print("\n[linha do tempo] Round 1 — lanças laterais")
    for s, inicio in enumerate([10, 80, 150, 220]):
        extras = [1, 1, 2, 2][s]
        n = 1 + extras
        primeiro = inicio + 22
        ultimo = primeiro + (n - 1) * 8
        fim = ultimo + 40  # 165 px / 4.2 = 40 frames até sair da caixa
        print(f"  salva {s+1}: aviso {inicio}..{primeiro-1} | voo {primeiro}..{fim} (<= {fim < 300})")

    print("\n[linha do tempo] Round 2 — lanças verticais")
    for s, inicio in enumerate([8, 84, 160, 236]):
        n_top = 3
        primeiro = inicio + 20
        ultimo_top = primeiro + (n_top - 1) * 4
        fim_top = ultimo_top + 35  # 144 px / 4.2 = 35 frames
        fim_baixo = inicio + 20 + 35
        mais = f" | baixo ate {fim_baixo}" if s % 2 == 0 else ""
        print(f"  salva {s+1}: aviso {inicio}..{primeiro-1} | tops {primeiro}..{fim_top}{mais} (<= {max(fim_top, fim_baixo) < 300})")

    print("\n[linha do tempo] Round 3 — formações sorteadas")
    # ossos por vaso: pontas=2, centro=4, terços=3 (máximo 8 simultâneos, sem espera)
    for nome, por_vaso in [("pontas", 2), ("centro", 4), ("terços", 3)]:
        total = por_vaso * 2
        ultimo = 24 + por_vaso * 9          # t >= aviso + (dropped-1)*intervalo
        fim = ultimo + 62 + 8               # vy=-3.8 => ~62f de voo + 8f de afundar
        print(f"  {nome:7s}: {total} ossos, aviso 24f, último osso ~{ultimo}f, fim ~{fim}f "
              f"-> onda 2 termina em ~{150 + fim}f ('<' 300: {150 + fim < 300})")

    # Varredura das três formações com jitter, para todos os x possíveis do coração.
    print("\n[vasos] varredura de x do coração 109..201 (200 jitter por caso)")
    bx1, bx2, vw = 106, 204, 27
    meio = (bx1 + bx2) / 2
    lo, hi = bx1 - 18, bx2 - vw + 18
    random.seed(20261125)

    def posicoes(tipo: int) -> tuple[float, float]:
        if tipo == 0:
            return bx1 + 2 + random.randint(0, 8), bx2 - vw - 2 - random.randint(0, 8)
        if tipo == 1:
            return (meio - 20 - vw / 2 + random.randint(-6, 6),
                    meio + 20 - vw / 2 + random.randint(-6, 6))
        return (bx1 + 13.5 + 14 - vw / 2 + random.randint(-6, 6),
                bx2 - 13.5 - 14 - vw / 2 + random.randint(-6, 6))

    def ajustar(x1: float, x2: float, hx: int) -> tuple[float, float]:
        if x1 > x2:
            x1, x2 = x2, x1
        for _ in range(6):
            xs = [x1, x2]
            for i, x in enumerate(xs):
                centro = x + vw / 2
                if abs(centro - hx) < 18:
                    x += (-1 if centro < hx else 1) * (18 - abs(centro - hx))
                    xs[i] = max(lo, min(hi, x))
            x1, x2 = xs
            sep = abs((x2 + vw / 2) - (x1 + vw / 2))
            if sep >= 36:
                break
            falta = 36 - sep + 0.5
            d1, d2 = abs(x1 + vw / 2 - hx), abs(x2 + vw / 2 - hx)
            if d1 >= d2:
                x1 += (-1 if x1 < x2 else 1) * falta
            else:
                x2 += (1 if x2 > x1 else -1) * falta
            x1, x2 = max(lo, min(hi, x1)), max(lo, min(hi, x2))
        return x1, x2

    for tipo, nome in enumerate(["pontas", "centro", "terços"]):
        pior_sep, pior_dist = 999, 999
        for hx in range(109, 202):
            for _ in range(200):
                x1, x2 = ajustar(*posicoes(tipo), hx)
                pior_sep = min(pior_sep, abs((x2 + vw / 2) - (x1 + vw / 2)))
                pior_dist = min(pior_dist, min(abs(x1 + vw / 2 - hx),
                                               abs(x2 + vw / 2 - hx)))
        print(f"  {nome:7s}: separação mínima {pior_sep:.1f} px | distância mínima ao coração {pior_dist:.1f} px")

    # Cobertura: dois agrupamentos com giro máximo de 14 graus.
    largura_giro = 7 * math.cos(math.radians(14)) + 50 * math.sin(math.radians(14))
    print(f"\n[cobertura] 2 agrupamentos com giro de 14° = ~{2 * largura_giro:.0f} px "
          f"de 98 px ({2 * largura_giro / 98 * 100:.0f}% < 40%)")


if __name__ == "__main__":
    recursos = validar_json()
    validar_camadas_sprites()
    validar_balanceamento()
    validar_nomes(recursos)
    validar_fundo_batalha()
    validar_projeteis()
    validar_battle_box()
    validar_dialogos()
    validar_companion()
    validar_rodape_intro()
    validar_forma_talai()
    validar_cena_guarana()
    validar_retorno_batalha()
    validar_fala_savepoint()
    validar_flags_apresentacao()
    validar_anti_loop_warps()
    validar_save_derrotas()
    validar_diagonal_companion()
    validar_sons()
    validar_musica_overworld()
    simular()
