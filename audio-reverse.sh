#!/usr/bin/env bash

mostrar_ayuda() {
    cat <<EOF
Uso: $0 archivo1 [archivo2 ...]
Descripción: Invierte archivos de audio (efecto reverso).
Ejemplo:
  $0 cancion.mp3
Opciones:
  --help    Muestra esta ayuda.
EOF
}

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

    base="${archivo%.*}"
    ext="${archivo##*.}"
    salida="${base}_reverse.${ext}"

    echo "Procesando: $archivo -> $salida"
    if ffmpeg -i "$archivo" -filter:a "areverse" "$salida" >/dev/null 2>&1; then
        echo "Conversión completada."
    else
        echo "Error al procesar '$archivo'."
        error=1
    fi
done

exit $error
