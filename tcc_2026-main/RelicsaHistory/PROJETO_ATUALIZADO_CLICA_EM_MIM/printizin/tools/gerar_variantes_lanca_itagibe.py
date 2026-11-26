"""Gera, a partir de spr_lanca_attack, as variantes alinhadas aos eixos do Itagibe.

Uso: python tools/gerar_variantes_lanca_itagibe.py

Regras:
- transformações feitas com Pillow (nada de arte desenhada à mão);
- todos os quadros do sprite original são preservados (hoje ele tem 1 quadro);
- origem continua 0,0 e a máscara passa a ser o retângulo inteiro do sprite;
- os .yy novos seguem exatamente o formato do .yy original;
- as entradas novas são inseridas no .yyp do projeto.
"""

from __future__ import annotations

import re
import uuid
from pathlib import Path

from PIL import Image

RAIZ = Path(__file__).resolve().parent.parent
ORIGINAL = RAIZ / "sprites" / "spr_lanca_attack"
YYP = RAIZ / "printizin2meajuda_corrigido.yyp"

# (nome, transformação, largura, altura)
# A PONTA é a extremidade esquerda do original (triângulo sólido que termina em x=1);
# a direita é a cauda em "V". ROTATE_270 coloca essa ponta em cima; ROTATE_90, embaixo.
VARIANTES = [
    ("spr_lanca_right_attack", Image.Transpose.FLIP_LEFT_RIGHT, 66, 12),
    ("spr_lanca_up_attack", Image.Transpose.ROTATE_270, 12, 66),
    ("spr_lanca_down_attack", Image.Transpose.ROTATE_90, 12, 66),
]


def ler_yyp() -> str:
    dados = YYP.read_bytes()
    return dados.decode("utf-8")


def escrever_yyp(texto: str) -> None:
    # O .yyp do projeto usa CRLF: normaliza antes de gravar para não duplicar o \r.
    texto = texto.replace("\r\n", "\n").replace("\n", "\r\n")
    YYP.write_bytes(texto.encode("utf-8"))


def gerar_sprite(nome: str, trans: Image.Transpose, largura: int, altura: int) -> None:
    origem_yy = (ORIGINAL / "spr_lanca_attack.yy").read_text(encoding="utf-8")
    arquivos = sorted(ORIGINAL.glob("*.png"))
    if len(arquivos) != 1:
        raise RuntimeError("Esperado exatamente 1 quadro em spr_lanca_attack")

    img = Image.open(arquivos[0]).convert("RGBA").transpose(trans)
    if img.size != (largura, altura):
        raise RuntimeError(f"Tamanho inesperado após transformação: {img.size}")

    uuid_antigo = re.search(r'"%Name":"([0-9a-f-]{36})"', origem_yy).group(1)
    # O GameMaker 2.3+ também exige o PNG dentro de layers/<frame>/<layer>.png.
    # Sem ele, abre o projeto e reclama "File missing for GMSprite...".
    uuid_layer = re.search(r'"\$GMImageLayer":"","%Name":"([0-9a-f-]{36})"', origem_yy).group(1)
    uuid_novo = str(uuid.uuid4())
    destino = RAIZ / "sprites" / nome
    destino.mkdir(parents=True, exist_ok=True)
    # Remove os PNGs da geração anterior para não deixar quadro órfão na pasta.
    for antigo in destino.glob("*.png"):
        antigo.unlink()
    camada = destino / "layers" / uuid_novo
    if camada.exists():
        for antigo in camada.glob("*.png"):
            antigo.unlink()
    camada.mkdir(parents=True, exist_ok=True)
    img.save(destino / f"{uuid_novo}.png")
    img.save(camada / f"{uuid_layer}.png")

    yy = origem_yy
    yy = yy.replace(uuid_antigo, uuid_novo)
    yy = yy.replace("spr_lanca_attack", nome)
    yy = yy.replace('"bbox_left":1,', '"bbox_left":0,')
    yy = yy.replace('"bbox_right":65,', f'"bbox_right":{largura - 1},')
    yy = yy.replace('"bbox_top":0,', '"bbox_top":0,')
    yy = yy.replace('"bbox_bottom":11,', f'"bbox_bottom":{altura - 1},')
    yy = yy.replace('"width":66,', f'"width":{largura},')
    yy = yy.replace('"height":12,', f'"height":{altura},')
    # A sequência do original tem 1 quadro; garantimos que o novo .yy não ficou com referência velha.
    if uuid_antigo in yy or "spr_lanca_attack" in yy:
        raise RuntimeError(f"Referência antiga sobrou no .yy de {nome}")
    (destino / f"{nome}.yy").write_text(yy, encoding="utf-8", newline="\n")
    print(f"[ok] sprite {nome} ({largura}x{altura})")


def inserir_entradas_yyp() -> None:
    texto = ler_yyp()
    entradas_objetos = [
        ("obj_rh_atk_bone_arco", "objects/obj_rh_atk_bone_arco/obj_rh_atk_bone_arco.yy",
         "obj_rh_atk_bone", "objects/obj_rh_atk_bone/obj_rh_atk_bone.yy"),
        ("obj_rh_atk_lanca_h", "objects/obj_rh_atk_lanca_h/obj_rh_atk_lanca_h.yy",
         "obj_rh_atk_lanca", "objects/obj_rh_atk_lanca/obj_rh_atk_lanca.yy"),
        ("obj_rh_atk_lanca_v", "objects/obj_rh_atk_lanca_v/obj_rh_atk_lanca_v.yy",
         "obj_rh_atk_lanca_h", "objects/obj_rh_atk_lanca_h/obj_rh_atk_lanca_h.yy"),
        ("obj_rh_atk_vaso_itagibe", "objects/obj_rh_atk_vaso_itagibe/obj_rh_atk_vaso_itagibe.yy",
         "obj_rh_atk_vaso", "objects/obj_rh_atk_vaso/obj_rh_atk_vaso.yy"),
    ]
    entradas_sprites = [
        ("spr_lanca_down_attack", "sprites/spr_lanca_down_attack/spr_lanca_down_attack.yy",
         "spr_lanca_attack", "sprites/spr_lanca_attack/spr_lanca_attack.yy"),
        ("spr_lanca_right_attack", "sprites/spr_lanca_right_attack/spr_lanca_right_attack.yy",
         "spr_lanca_down_attack", "sprites/spr_lanca_down_attack/spr_lanca_down_attack.yy"),
        ("spr_lanca_up_attack", "sprites/spr_lanca_up_attack/spr_lanca_up_attack.yy",
         "spr_lanca_right_attack", "sprites/spr_lanca_right_attack/spr_lanca_right_attack.yy"),
    ]

    for nome, caminho, anterior, caminho_anterior in entradas_objetos + entradas_sprites:
        linha_antiga = f'    {{"id":{{"name":"{anterior}","path":"{caminho_anterior}",}},}},\r\n'
        linha_nova = f'    {{"id":{{"name":"{nome}","path":"{caminho}",}},}},\r\n'
        if linha_nova in texto:
            continue
        if linha_antiga not in texto:
            raise RuntimeError(f"Não achei a linha de referência no .yyp: {anterior}")
        texto = texto.replace(linha_antiga, linha_antiga + linha_nova, 1)

    escrever_yyp(texto)
    print("[ok] .yyp atualizado com 4 objetos e 3 sprites")


if __name__ == "__main__":
    gerar_sprite(*VARIANTES[0])
    gerar_sprite(*VARIANTES[1])
    gerar_sprite(*VARIANTES[2])
    inserir_entradas_yyp()
