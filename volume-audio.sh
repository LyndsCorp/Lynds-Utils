#!/usr/bin/env bash

mostrar_ayuda() {
cat <<EOF
Uso:
  $0 up|down porcentaje archivo1 [archivo2 ...]

Descripción:
  Sube o baja el volumen de archivos de audio.

Ejemplos:
  $0 down 50 cancion.mp3
  $0 up 150 cancion.wav

Opciones:
  --help        Muestra esta ayuda.
EOF
}

if [[ "${1:-}" == "--help" ]]; then
    mostrar_ayuda
    exit 0
fi

if ! command -v ffmpeg >/dev/null 2>&1; then
    echo "Error: ffmpeg no está instalado."
    echo "Instálalo con: sudo apt install ffmpeg"
    exit 1
fi

if [[ $# -lt 3 ]]; then
    echo "Error: faltan argumentos."
    mostrar_ayuda
    exit 1
fi

accion="$1"
porcentaje="$2"
shift 2

if [[ ! "$porcentaje" =~ ^[0-9]+$ ]]; then
    echo "Error: el porcentaje debe ser un número."
    exit 1
fi

case "$accion" in
    down)
        volumen=$(awk "BEGIN {print $porcentaje/100}")
        ;;
    up)
        volumen=$(awk "BEGIN {print $porcentaje/100}")
        ;;
    *)
        echo "Error: usa 'up' o 'down'."
        exit 1
        ;;
esac

error=0

for archivo in "$@"; do
    if [[ ! -f "$archivo" ]]; then
        echo "Error: '$archivo' no existe."
        error=1
        continue
    fi

    salida="${archivo%.*}-volume.${archivo##*.}"

    echo "Procesando:"
    echo "  Entrada: $archivo"
    echo "  Salida:  $salida"

    if ffmpeg -i "$archivo" -filter:a "volume=$volumen" "$salida"; then
        echo "Completado."
    else
        echo "Error procesando '$archivo'."
        error=1
    fi
done

exit $error
