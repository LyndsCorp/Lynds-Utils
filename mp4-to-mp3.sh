#!/usr/bin/bash

if [[ $# -ne 1 ]]; then
    echo "Uso: $0 archivo.mp4"
    exit 1
fi

archivo="$1"

if [[ ! -f "$archivo" ]]; then
    echo "Error: el archivo no existe"
    exit 1
fi

if ! command -v ffmpeg >/dev/null 2>&1; then
    echo "Error: ffmpeg no está instalado"
    echo "Instálalo con: sudo apt install ffmpeg"
    exit 1
fi

salida="${archivo%.*}.mp3"

ffmpeg -i "$archivo" -vn -codec:a libmp3lame -q:a 2 "$salida"

if [[ $? -eq 0 ]]; then
    echo "Convertido correctamente:"
    echo "$salida"
else
    echo "Error al convertir"
    exit 1
fi
