"""Reaplica (de forma idempotente) o registro dos assets novos no projeto.

Motivo: o GameMaker IDE reescreve .yyp/.resource_order/rooms ao salvar e descarta
entradas feitas à mão fora dele. Rode este script por ÚLTIMO, depois de fechar/salvar
o projeto no IDE:

    python tools/registrar_assets_novos.py

Nada é duplicado se o script rodar mais de uma vez.
"""
from __future__ import annotations

from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent


def linhas(caminho: Path) -> list[str]:
    return caminho.read_text(encoding="utf-8").splitlines(keepends=True)


def fim_de_linha(amostra: str) -> str:
    return "\r\n" if amostra.endswith("\r\n") else "\n"


def inserir_depois(alvo: list[str], trecho: str, novas: list[str]) -> None:
    for i, linha in enumerate(alvo):
        if trecho in linha:
            eol = fim_de_linha(linha)
            bloco = [texto.rstrip("\r\n") + eol for texto in novas]
            alvo[i + 1 : i + 1] = bloco
            return
    raise RuntimeError(f"âncora não encontrada: {trecho}")


def salvar(caminho: Path, conteudo: list[str]) -> None:
    caminho.write_text("".join(conteudo), encoding="utf-8", newline="")


def registrar_yyp() -> None:
    caminho = RAIZ / "printizin2meajuda_corrigido.yyp"
    texto = caminho.read_text(encoding="utf-8")
    recurso = lambda nome, caminho_rel: f'    {{"id":{{"name":"{nome}","path":"{caminho_rel}",}},}},'
    ataques = [
        ("obj_rh_atk_trono_espada", "objects/obj_rh_atk_trono_espada/obj_rh_atk_trono_espada.yy"),
        ("obj_rh_atk_trono_slash", "objects/obj_rh_atk_trono_slash/obj_rh_atk_trono_slash.yy"),
        ("obj_rh_atk_lagrima_carumaru", "objects/obj_rh_atk_lagrima_carumaru/obj_rh_atk_lagrima_carumaru.yy"),
        ("obj_rh_atk_fantasma_carumaru2", "objects/obj_rh_atk_fantasma_carumaru2/obj_rh_atk_fantasma_carumaru2.yy"),
        ("obj_rh_atk_martelo_ferro", "objects/obj_rh_atk_martelo_ferro/obj_rh_atk_martelo_ferro.yy"),
        ("obj_rh_atk_barra_ferro", "objects/obj_rh_atk_barra_ferro/obj_rh_atk_barra_ferro.yy"),
        ("obj_rh_atk_bau_quinto", "objects/obj_rh_atk_bau_quinto/obj_rh_atk_bau_quinto.yy"),
        ("obj_rh_atk_fumaca_quinto", "objects/obj_rh_atk_fumaca_quinto/obj_rh_atk_fumaca_quinto.yy"),
        ("obj_rh_atk_cachorro_quinto", "objects/obj_rh_atk_cachorro_quinto/obj_rh_atk_cachorro_quinto.yy"),
        ("obj_rh_atk_fogo_quinto", "objects/obj_rh_atk_fogo_quinto/obj_rh_atk_fogo_quinto.yy"),
    ]
    extras = [
        ('"name":"obj_rh_atk_slam"', [recurso(n, p) for n, p in ataques]),
        ('"name":"obj_rh_en_trono_vazio"', [recurso(
            "obj_rh_en_quinto_do_inferno", "objects/obj_rh_en_quinto_do_inferno/obj_rh_en_quinto_do_inferno.yy")]),
        ('"name":"ObjMonsterTronoVazio"', [recurso(
            "ObjMonsterQuintoDoInferno", "objects/ObjMonsterQuintoDoInferno/ObjMonsterQuintoDoInferno.yy")]),
        ('"name":"spr_cachorro_inferno_attack"', [recurso(
            "spr_cachorro_inferno_right_attack",
            "sprites/spr_cachorro_inferno_right_attack/spr_cachorro_inferno_right_attack.yy")]),
    ]
    faltando = [(a, linha) for a, blocos in extras for linha in blocos if f'"name":"{linha.split(chr(34))[5]}"' not in texto] if False else []
    # Checagem simples por nome (evita duplicar se o IDE já tiver salvo).
    for _, blocos in extras:
        for bloco in blocos:
            nome = bloco.split('"name":"')[1].split('"')[0]
            if f'"name":"{nome}"' in texto:
                faltando.append((nome, bloco))
    if faltando:
        print(".yyp: todos os recursos já registrados")
        return
    alvo = linhas(caminho)
    for ancora, blocos in extras:
        inserir_depois(alvo, ancora, blocos)
    salvar(caminho, alvo)
    print(".yyp: 13 recursos inseridos")


def registrar_resource_order() -> None:
    caminho = RAIZ / "printizin2meajuda_corrigido.resource_order"
    texto = caminho.read_text(encoding="utf-8")
    entrada = lambda nome, caminho_rel: f'    {{"name":"{nome}","order":1,"path":"{caminho_rel}",}},'
    ataques = [
        ("obj_rh_atk_trono_espada", "objects/obj_rh_atk_trono_espada/obj_rh_atk_trono_espada.yy"),
        ("obj_rh_atk_trono_slash", "objects/obj_rh_atk_trono_slash/obj_rh_atk_trono_slash.yy"),
        ("obj_rh_atk_lagrima_carumaru", "objects/obj_rh_atk_lagrima_carumaru/obj_rh_atk_lagrima_carumaru.yy"),
        ("obj_rh_atk_fantasma_carumaru2", "objects/obj_rh_atk_fantasma_carumaru2/obj_rh_atk_fantasma_carumaru2.yy"),
        ("obj_rh_atk_martelo_ferro", "objects/obj_rh_atk_martelo_ferro/obj_rh_atk_martelo_ferro.yy"),
        ("obj_rh_atk_barra_ferro", "objects/obj_rh_atk_barra_ferro/obj_rh_atk_barra_ferro.yy"),
        ("obj_rh_atk_bau_quinto", "objects/obj_rh_atk_bau_quinto/obj_rh_atk_bau_quinto.yy"),
        ("obj_rh_atk_fumaca_quinto", "objects/obj_rh_atk_fumaca_quinto/obj_rh_atk_fumaca_quinto.yy"),
        ("obj_rh_atk_cachorro_quinto", "objects/obj_rh_atk_cachorro_quinto/obj_rh_atk_cachorro_quinto.yy"),
        ("obj_rh_atk_fogo_quinto", "objects/obj_rh_atk_fogo_quinto/obj_rh_atk_fogo_quinto.yy"),
    ]
    extras = [
        ('"name":"obj_rh_atk_espada"', [entrada(n, p) for n, p in ataques]),
        ('"name":"obj_rh_en_trono_vazio"', [entrada(
            "obj_rh_en_quinto_do_inferno", "objects/obj_rh_en_quinto_do_inferno/obj_rh_en_quinto_do_inferno.yy")]),
        ('"name":"ObjMonsterTronoVazio"', [entrada(
            "ObjMonsterQuintoDoInferno", "objects/ObjMonsterQuintoDoInferno/ObjMonsterQuintoDoInferno.yy")]),
        ('"name":"spr_cachoeira"', [entrada(
            "spr_cachorro_inferno_right_attack",
            "sprites/spr_cachorro_inferno_right_attack/spr_cachorro_inferno_right_attack.yy")]),
    ]
    nomes = [bloco.split('"name":"')[1].split('"')[0] for _, blocos in extras for bloco in blocos]
    if any(f'"name":"{nome}"' in texto for nome in nomes):
        print(".resource_order: entradas já presentes")
        return
    alvo = linhas(caminho)
    for ancora, blocos in extras:
        inserir_depois(alvo, ancora, blocos)
    salvar(caminho, alvo)
    print(".resource_order: 13 entradas inseridas")


def registrar_room() -> None:
    caminho = RAIZ / "rooms" / "rm_teste" / "rm_teste.yy"
    texto = caminho.read_text(encoding="utf-8")
    if "inst_5E00000B" in texto:
        print("rm_teste: instância já presente")
        return
    eol = "\r\n" if "\r\n" in texto else "\n"
    ordem = f'    {{"name":"inst_5E00000B","path":"rooms/rm_teste/rm_teste.yy",}},'
    instancia = (
        '        {"$GMRInstance":"v4","%Name":"inst_5E00000B","colour":4294967295,'
        '"frozen":false,"hasCreationCode":false,"ignore":false,"imageIndex":0,'
        '"imageSpeed":1.0,"inheritCode":false,"inheritedItemId":null,'
        '"inheritItemSettings":false,"isDnd":false,"name":"inst_5E00000B",'
        '"objectId":{"name":"ObjMonsterQuintoDoInferno",'
        '"path":"objects/ObjMonsterQuintoDoInferno/ObjMonsterQuintoDoInferno.yy",},'
        '"properties":[],"resourceType":"GMRInstance","resourceVersion":"2.0",'
        '"rotation":0.0,"scaleX":1.0,"scaleY":1.0,"x":1120.0,"y":416.0,},'
    )
    alvo = linhas(caminho)
    inserir_depois(alvo, '{"name":"inst_5E00000A","path":"rooms/rm_teste/rm_teste.yy",}', [ordem])
    inserir_depois(alvo, '"name":"ObjMonsterTronoVazio"', [instancia])
    salvar(caminho, alvo)
    print("rm_teste: inst_5E00000B inserida em (1120, 416)")


def main() -> None:
    registrar_yyp()
    registrar_resource_order()
    registrar_room()


if __name__ == "__main__":
    main()
