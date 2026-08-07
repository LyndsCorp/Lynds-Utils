#!/usr/bin/bash

if [[ $# -ne 1 ]]; then
    echo "Uso: $0 archivo.mkv"
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

echo "Convirtiendo:"
echo "  Entrada: $archivo"
echo "  Salida:  $salida"

ffmpeg -i "$archivo" -vn -codec:a libmp3lame -q:a 2 "$salida"

if [[ $? -eq 0 ]]; then
    echo "Conversión completada correctamente."
else
    echo "Error durante la conversión."
    exit 1
fi
