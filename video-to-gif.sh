#!/usr/bin/env bash

mostrar_ayuda() {
    cat <<EOF
Uso: $0 [--fps N] [--scale WxH] archivo1 [archivo2 ...]
Descripción: Convierte videos a GIF animado.
Opciones:
  --fps N        Establece los fotogramas por segundo (por defecto 10).
  --scale WxH    Escala el video (ej. 320x240) manteniendo proporción si se omite altura.
  --help         Muestra esta ayuda.
Ejemplo:
  $0 --fps 15 --scale 320x240 video.mp4
EOF
}

fps=10
scale=""
args=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        --help)
            mostrar_ayuda
            exit 0
            ;;
        --fps)
            fps="$2"
            shift 2
            ;;
        --scale)
            scale="$2"
            shift 2
            ;;
        *)
            args+=("$1")
            shift
            ;;
    esac
done

set -- "${args[@]}"

if [[ $# -eq 0 ]]; then
    echo "Error: no se especificaron archivos."
    mostrar_ayuda
    exit 1
fi

if ! command -v ffmpeg >/dev/null 2>&1; then
    echo "Error: ffmpeg no está instalado."
    echo "Instálalo con: sudo apt install ffmpeg"
    exit 1
fi

error=0

for archivo in "$@"; do
    if [[ ! -f "$archivo" ]]; then
        echo "Error: '$archivo' no existe."
        error=1
        continue
    fi

    base="${archivo%.*}"
    salida="${base}.gif"

    echo "Procesando: $archivo -> $salida"
    cmd="ffmpeg -i '$archivo' -vf 'fps=$fps"

    if [[ -n "$scale" ]]; then
        cmd="$cmd,scale=$scale"
    fi

    cmd="$cmd' '$salida'"

    eval $cmd >/dev/null 2>&1

    if [[ $? -eq 0 ]]; then
        echo "Conversión completada."
    else
        echo "Error al procesar '$archivo'."
        error=1
    fi
done

exit $error
