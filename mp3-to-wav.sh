#!/usr/bin/bash

baja_calidad=false

if [[ "$1" == "--baja-calidad" ]]; then
    baja_calidad=true
    shift
fi

if [[ $# -ne 1 ]]; then
    echo "Uso: $0 archivo.mp3"
    echo "Otro uso: $0 --baja-calidad archivo.mp3. Para que el archivo wav tenga más baja la frecuencia de muestreo y reducir tamaño."
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

salida="${archivo%.*}.wav"

if $baja_calidad; then
    echo "Modo: baja calidad (22050 Hz)"
    ffmpeg -i "$archivo" -ar 22050 "$salida"
else
    echo "Modo: calidad normal"
    ffmpeg -i "$archivo" "$salida"
fi

if [[ $? -eq 0 ]]; then
    echo "Conversión completada correctamente."
else
    echo "Error durante la conversión."
    exit 1
fi
