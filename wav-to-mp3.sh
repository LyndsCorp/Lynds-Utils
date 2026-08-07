#!/usr/bin/env bash

baja_calidad=false

if [[ "$1" == "--baja-calidad" ]]; then
    baja_calidad=true
    shift
fi

if [[ $# -ne 1 ]]; then
    echo "Uso: $0 archivo.wav"
    echo "Otro uso: $0 --baja-calidad archivo.wav. Para que el archivo mp3 sea más ligero pero de menor calidad.
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

if $baja_calidad; then
    calidad=7
    echo "Modo: baja calidad"
else
    calidad=2
    echo "Modo: calidad normal"
fi

echo "Convirtiendo:"
echo "  Entrada: $archivo"
echo "  Salida:  $salida"

ffmpeg -i "$archivo" -codec:a libmp3lame -q:a "$calidad" "$salida"

if [[ $? -eq 0 ]]; then
    echo "Conversión completada correctamente."
else
    echo "Error durante la conversión."
    exit 1
fi
