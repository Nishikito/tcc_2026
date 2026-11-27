"""Gera spr_cachorro_inferno_right_attack (espelho do cachorro original).

O sprite original olha para a ESQUERDA; rh_draw_clipped nao aceita xscale negativo.
Este script cria os PNGs espelhados (raiz + layers) e o .yy correspondente.
Uso: python tools/gerar_cachorro_inferno_right.py
"""
from pathlib import Path
import json
import re
import uuid

from PIL import Image

RAIZ = Path(__file__).resolve().parent.parent
ORIGEM = RAIZ / "sprites" / "spr_cachorro_inferno_attack"
DESTINO = RAIZ / "sprites" / "spr_cachorro_inferno_right_attack"
NOME = "spr_cachorro_inferno_right_attack"

bruto = (ORIGEM / "spr_cachorro_inferno_attack.yy").read_text(encoding="utf-8")
dados = json.loads(re.sub(r",\s*([}\]])", r"\1", bruto))
dados["%Name"] = NOME
dados["name"] = NOME

# Novos IDs para os quadros (GameMaker nao gosta de UUID repetido entre sprites).
novos = {}
for frame in dados["frames"]:
    antigo = frame["name"]
    novo = str(uuid.uuid4())
    novos[antigo] = novo
    frame["%Name"] = novo
    frame["name"] = novo

camada = dados["layers"][0]["name"]
nova_camada = str(uuid.uuid4())
dados["layers"][0]["%Name"] = nova_camada
dados["layers"][0]["name"] = nova_camada

seq = dados["sequence"]
seq["%Name"] = NOME
seq["name"] = NOME
for track in seq["tracks"]:
    for key in track["keyframes"]["Keyframes"]:
        key["id"] = str(uuid.uuid4())
        for canal in key["Channels"].values():
            antigo = canal["Id"]["name"]
            canal["Id"]["name"] = novos[antigo]
            canal["Id"]["path"] = f"sprites/{NOME}/{NOME}.yy"

DESTINO.mkdir(parents=True, exist_ok=True)
with (DESTINO / f"{NOME}.yy").open("w", encoding="utf-8", newline="\n") as arquivo:
    json.dump(dados, arquivo, ensure_ascii=False, indent=2)
    arquivo.write("\n")

for antigo, novo in novos.items():
    with Image.open(ORIGEM / f"{antigo}.png") as imagem:
        espelhada = imagem.transpose(Image.Transpose.FLIP_LEFT_RIGHT)
        espelhada.save(DESTINO / f"{novo}.png")
    origem_camada = ORIGEM / "layers" / antigo / f"{camada}.png"
    if origem_camada.exists():
        (DESTINO / "layers" / novo).mkdir(parents=True, exist_ok=True)
        with Image.open(origem_camada) as imagem:
            imagem.transpose(Image.Transpose.FLIP_LEFT_RIGHT).save(
                DESTINO / "layers" / novo / f"{nova_camada}.png"
            )

print(f"criado: {DESTINO} ({len(novos)} quadros)")
