"""Validação estática das correções de batalha (Fase 0 + ataques novos).

Uso: python tools/validar_ataques_rh.py

Verifica:
- JSON dos .yy/.yyp editados (aceita vírgula final, como o GameMaker);
- recursos novos registrados no .yyp uma única vez e com arquivo no disco;
- parênteses/chaves balanceados nos .gml tocados;
- eventos .gml declarados no .yy correspondente;
- PNGs e camadas do sprite espelhado do cachorro.
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
YYP = RAIZ / "printizin2meajuda_corrigido.yyp"

NOVOS_RECURSOS = [
    "obj_rh_en_quinto_do_inferno",
    "ObjMonsterQuintoDoInferno",
    "obj_rh_atk_trono_espada",
    "obj_rh_atk_trono_slash",
    "obj_rh_atk_lagrima_carumaru",
    "obj_rh_atk_fantasma_carumaru2",
    "obj_rh_atk_martelo_ferro",
    "obj_rh_atk_barra_ferro",
    "obj_rh_atk_bau_quinto",
    "obj_rh_atk_fumaca_quinto",
    "obj_rh_atk_cachorro_quinto",
    "obj_rh_atk_fogo_quinto",
    "spr_cachorro_inferno_right_attack",
]

GML_TOCADOS = [
    "scripts/scr_rh_attacks/scr_rh_attacks.gml",
    "objects/obj_rh_battle_player/Step_0.gml",
    "objects/obj_rh_battle_player/Create_0.gml",
    "objects/obj_rh_battle_controller/Step_0.gml",
    "scripts/scr_damage_calculator/scr_damage_calculator.gml",
    "objects/obj_rh_en_trono_vazio/Create_0.gml",
    "objects/obj_rh_en_carumaru/Create_0.gml",
    "objects/obj_rh_en_intenente_de_ferro/Create_0.gml",
]


def sem_virgula_final(texto: str) -> str:
    return re.sub(r",\s*([}\]])", r"\1", texto)


def carregar_json(caminho: Path):
    return json.loads(sem_virgula_final(caminho.read_text(encoding="utf-8")))


def sem_comentarios(codigo: str) -> str:
    """Remove //, /* */ e strings para conferir só a estrutura do código."""
    saida: list[str] = []
    i = 0
    n = len(codigo)
    while i < n:
        c = codigo[i]
        if c == "/" and i + 1 < n and codigo[i + 1] == "/":
            while i < n and codigo[i] != "\n":
                i += 1
            continue
        if c == "/" and i + 1 < n and codigo[i + 1] == "*":
            i += 2
            while i + 1 < n and not (codigo[i] == "*" and codigo[i + 1] == "/"):
                i += 1
            i += 2
            continue
        if c == '"':
            i += 1
            while i < n:
                if codigo[i] == "\\":
                    i += 2
                    continue
                if codigo[i] == '"':
                    i += 1
                    break
                i += 1
            saida.append(" ")
            continue
        saida.append(c)
        i += 1
    return "".join(saida)


def balanceado(codigo: str) -> tuple[bool, str]:
    pilha: list[tuple[str, int]] = []
    pares = {")": "(", "]": "[", "}": "{"}
    linha = 1
    for ch in sem_comentarios(codigo):
        if ch == "\n":
            linha += 1
        elif ch in "([{":
            pilha.append((ch, linha))
        elif ch in ")]}":
            if not pilha or pilha[-1][0] != pares[ch]:
                return False, f"fechamento '{ch}' sem abrir na linha {linha}"
            pilha.pop()
    if pilha:
        abertos = ", ".join(f"'{c}' (linha {l})" for c, l in pilha[-3:])
        return False, f"sem fechar: {abertos}"
    return True, "ok"


def main() -> int:
    erros: list[str] = []
    avisos: list[str] = []

    # 1) JSON dos arquivos que podem ter sido editados.
    for caminho in sorted(RAIZ.rglob("*.yy")) + [YYP]:
        try:
            carregar_json(caminho)
        except Exception as exc:  # noqa: BLE001 - relatório amigável
            erros.append(f"JSON inválido: {caminho.relative_to(RAIZ)}: {exc}")

    # 2) Registro único dos recursos novos.
    projeto = carregar_json(YYP)
    recursos = [item["id"]["name"] for item in projeto.get("resources", [])]
    duplicados = {n for n in recursos if recursos.count(n) > 1}
    for nome in NOVOS_RECURSOS:
        qtd = recursos.count(nome)
        if qtd == 0:
            erros.append(f"recurso não registrado no .yyp: {nome}")
        elif qtd > 1:
            erros.append(f"recurso duplicado no .yyp: {nome} ({qtd}x)")
    for nome in sorted(duplicados):
        if nome not in NOVOS_RECURSOS:
            avisos.append(f"nome duplicado pré-existente no .yyp: {nome}")

    # 3) Arquivos no disco para os recursos novos.
    for item in projeto.get("resources", []):
        info = item.get("id", {})
        if info.get("name") not in NOVOS_RECURSOS:
            continue
        caminho = RAIZ / info["path"].replace("/", "\\")
        if not caminho.is_file():
            erros.append(f"arquivo do recurso novo não existe: {info['path']}")

    # 4) Balanceamento dos .gml tocados e de todos os novos objetos de ataque.
    alvos = [RAIZ / p for p in GML_TOCADOS]
    alvos += sorted((RAIZ / "objects").glob("obj_rh_atk_*/*.gml"))
    alvos += sorted((RAIZ / "objects" / "obj_rh_en_quinto_do_inferno").glob("*.gml"))
    alvos += sorted((RAIZ / "objects" / "ObjMonsterQuintoDoInferno").glob("*.gml"))
    for caminho in alvos:
        if not caminho.is_file():
            avisos.append(f".gml ainda não criado: {caminho.relative_to(RAIZ)}")
            continue
        texto = caminho.read_text(encoding="utf-8", errors="replace")
        ok, detalhe = balanceado(texto)
        if not ok:
            erros.append(f"desbalanceado {caminho.relative_to(RAIZ)}: {detalhe}")

    # 4b) Contratos dos padrões novos: sem guardas instance_exists e nomes esperados.
    padroes = {
        "obj_rh_en_trono_vazio": ["pat_barreira", "pat_anel", "pat_cortes", "pat_chuva_diagonal", "pat_chifres_cartas", "pat_icebergs"],
        "obj_rh_en_carumaru": ["pat_lagrimas", "pat_fantasmas", "pat_choro"],
        "obj_rh_en_intenente_de_ferro": ["pat_marteladas", "pat_barras", "pat_sentenca"],
        "obj_rh_en_quinto_do_inferno": ["pat_baus", "pat_cachorro", "pat_cobranca"],
    }
    for objeto, esperados in padroes.items():
        caminho = RAIZ / "objects" / objeto / "Create_0.gml"
        if not caminho.is_file():
            avisos.append(f"Create ainda não criado: {caminho.relative_to(RAIZ)}")
            continue
        texto = caminho.read_text(encoding="utf-8", errors="replace")
        codigo = sem_comentarios(texto)
        if "instance_exists(" in codigo:
            erros.append(f"guarda instance_exists em {objeto}/Create_0.gml (uso permitido só em helpers do coração)")
        for nome in esperados:
            if nome not in texto:
                erros.append(f"padrão ausente em {objeto}: {nome}")

    helpers = (RAIZ / "scripts" / "scr_rh_attacks" / "scr_rh_attacks.gml").read_text(encoding="utf-8", errors="replace")
    for necessario in [
        "function rh_hurt_heart", "function rh_heart_rect", "function rh_rect_hits_heart",
        "function rh_rot_rect_hits_heart", "function rh_segment_hits_heart",
        "function rh_draw_clipped_ext", "function rh_draw_clipped_pivot",
        "function rh_draw_warning_line", "#macro RH_BAU_DENTRO", "#macro RH_HEART_SHRINK",
    ]:
        if necessario not in helpers:
            erros.append(f"helper/macro ausente em scr_rh_attacks: {necessario}")

    # 4c) Ataques novos não podem reativar o Outside Room do pai por acidente.
    for objeto in [
        "obj_rh_atk_trono_espada", "obj_rh_atk_trono_slash",
        "obj_rh_atk_lagrima_carumaru", "obj_rh_atk_fantasma_carumaru2",
        "obj_rh_atk_martelo_ferro", "obj_rh_atk_barra_ferro",
        "obj_rh_atk_bau_quinto", "obj_rh_atk_fumaca_quinto",
        "obj_rh_atk_cachorro_quinto", "obj_rh_atk_fogo_quinto",
    ]:
        other = RAIZ / "objects" / objeto / "Other_0.gml"
        if not other.is_file():
            continue
        codigo_efetivo = sem_comentarios(other.read_text(encoding="utf-8", errors="replace")).strip()
        if codigo_efetivo:
            erros.append(f"{objeto}/Other_0.gml deve ficar vazio; conteúdo efetivo: {codigo_efetivo[:60]!r}")

    # 5) Eventos declarados no .yy têm arquivo .gml correspondente.
    EVENTOS = {0: "Create_0", 2: "Step_0", 3: "Step_0", 7: "Other_0", 8: "Draw_0", 12: "CleanUp_0"}
    for yy in sorted((RAIZ / "objects").glob("*/*.yy")):
        if yy.parent.name not in {
            "obj_rh_en_trono_vazio", "obj_rh_en_carumaru", "obj_rh_en_intenente_de_ferro",
            "obj_rh_en_quinto_do_inferno", "ObjMonsterQuintoDoInferno",
            "obj_rh_atk_trono_espada", "obj_rh_atk_trono_slash",
            "obj_rh_atk_lagrima_carumaru", "obj_rh_atk_fantasma_carumaru2",
            "obj_rh_atk_martelo_ferro", "obj_rh_atk_barra_ferro",
            "obj_rh_atk_bau_quinto", "obj_rh_atk_fumaca_quinto",
            "obj_rh_atk_cachorro_quinto", "obj_rh_atk_fogo_quinto",
            "obj_rh_atk_chifre", "obj_rh_atk_carta", "obj_rh_atk_iceberg",
        }:
            continue
        dados = carregar_json(yy)
        for ev in dados.get("eventList", []):
            arquivo = EVENTOS.get(ev.get("eventType"))
            if arquivo is None:
                continue
            if ev.get("eventType") == 8 and ev.get("eventNum") == 64:
                arquivo = "Draw_64"
            gml = yy.parent / f"{arquivo}.gml"
            if not gml.is_file():
                erros.append(f"evento declarado sem .gml: {yy.parent.name} -> {gml.name}")

    # 6) Sprite espelhado: quadros, camadas e referências da sequência.
    spr = RAIZ / "sprites" / "spr_cachorro_inferno_right_attack"
    yy = spr / "spr_cachorro_inferno_right_attack.yy"
    if yy.is_file():
        dados = carregar_json(yy)
        quadros = [f["name"] for f in dados.get("frames", [])]
        camada = dados["layers"][0]["name"]
        refs = set()
        for track in dados.get("sequence", {}).get("tracks", []):
            for key in track.get("keyframes", {}).get("Keyframes", []):
                for canal in key.get("Channels", {}).values():
                    refs.add(canal.get("Id", {}).get("name"))
        for q in quadros:
            if not (spr / f"{q}.png").is_file():
                erros.append(f"PNG do quadro faltando: {q}")
            if not (spr / "layers" / q / f"{camada}.png").is_file():
                erros.append(f"PNG da camada faltando: {q}/{camada}")
        if refs - set(quadros):
            erros.append(f"sequência referencia quadros inexistentes: {sorted(refs - set(quadros))}")

    print(f"recursos registrados: {len(recursos)} (novos esperados: {len(NOVOS_RECURSOS)})")
    for aviso in avisos:
        print(f"AVISO: {aviso}")
    for erro in erros:
        print(f"ERRO: {erro}")
    print(f"RESULTADO: {'FALHOU' if erros else 'OK'} ({len(erros)} erro(s), {len(avisos)} aviso(s))")
    return 1 if erros else 0


if __name__ == "__main__":
    sys.exit(main())
