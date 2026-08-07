#!/usr/bin/env bash

mostrar_ayuda() {
    cat <<EOF
Uso: $0 archivo1 [archivo2 ...]
Descripción: Elimina el audio de archivos de video, conservando solo la pista de video.
Ejemplo:
  $0 video.mp4 video2.mkv
Opciones:
  --help    Muestra esta ayuda.
EOF
}

# Procesar opciones
for arg in "$@"; do
    if [[ "$arg" == "--help" ]]; then
        mostrar_ayuda
        exit 0
    fi
done

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

    # Comprobar si el archivo tiene audio
    if ! ffprobe -v error -select_streams a -show_entries stream=codec_type -of default=noprint_wrappers=1:nokey=1 "$archivo" | grep -q audio; then
        echo "Advertencia: '$archivo' no tiene pista de audio. Se omite."
        continue
    fi

    base="${archivo%.*}"
    ext="${archivo##*.}"
    salida="${base}_mute.${ext}"

    echo "Procesando:"
    echo "  Entrada: $archivo"
    echo "  Salida:  $salida"

    if ffmpeg -i "$archivo" -an -c:v copy "$salida" >/dev/null 2>&1; then
        echo "Audio eliminado correctamente."
    else
        echo "Error al procesar '$archivo'."
        error=1
    fi
done

exit $error
