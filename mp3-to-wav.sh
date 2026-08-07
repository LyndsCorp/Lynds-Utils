#!/usr/bin/env bash

mostrar_ayuda() {
    cat <<EOF
Uso: $0 [--baja-calidad] archivo1 [archivo2 ...]
Descripción: Convierte archivos MP3 a WAV.
Opciones:
  --baja-calidad    Reduce la frecuencia de muestreo (22050 Hz) para obtener archivos más ligeros.
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
        echo "Error durante la conversión de '$archivo'."
        error=1
    fi
done

exit $error
