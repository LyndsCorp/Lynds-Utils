#!/usr/bin/env bash

mostrar_ayuda() {
    cat <<EOF
Uso: $0 [--baja-calidad] archivo1 [archivo2 ...]
Descripción: Convierte archivos MP4 a MP3 extrayendo el audio.
Opciones:
  --baja-calidad    Reduce la calidad del MP3 para obtener archivos más ligeros.
  --help            Muestra esta ayuda.
EOF
}

# Procesar opciones
for arg in "$@"; do
    if [[ "$arg" == "--help" ]]; then
        mostrar_ayuda
        exit 0
    fi
done

baja_calidad=false
if [[ "$1" == "--baja-calidad" ]]; then
    baja_calidad=true
    shift
fi

if [[ $# -eq 0 ]]; then
    echo "Error: no se especificaron archivos."
    mostrar_ayuda
    exit 1
fi

if ! command -v ffmpeg >/dev/null 2>&1; then
    echo "Error: ffmpeg no está instalado"
    echo "Instálalo con: sudo apt install ffmpeg"
    exit 1
fi

error=0

for archivo in "$@"; do
    if [[ ! -f "$archivo" ]]; then
        echo "Error: el archivo '$archivo' no existe"
        error=1
        continue
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

    ffmpeg -i "$archivo" -vn -codec:a libmp3lame -q:a "$calidad" "$salida"

    if [[ $? -eq 0 ]]; then
        echo "Conversión completada correctamente."
    else
        echo "Error durante la conversión de '$archivo'."
        error=1
    fi
done

exit $error
