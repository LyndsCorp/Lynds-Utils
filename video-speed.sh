#!/usr/bin/env bash

mostrar_ayuda() {
    cat <<EOF
Uso: $0 factor archivo1 [archivo2 ...]
Descripción: Cambia la velocidad de archivos de video (audio y video).
  factor: número mayor que 0 (ej. 0.5 = cámara lenta, 2.0 = acelerado).
Ejemplo:
  $0 1.5 video.mp4
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

if [[ $# -lt 2 ]]; then
    echo "Error: faltan argumentos."
    mostrar_ayuda
    exit 1
fi

factor="$1"
shift

if ! [[ "$factor" =~ ^[0-9]+([.][0-9]+)?$ ]] || (( $(echo "$factor <= 0" | bc -l) )); then
    echo "Error: el factor debe ser un número positivo."
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
    salida="${base}_speed-${factor}.${ext}"

    # Calcular PTS y atempo (similar a audio-speed pero para video)
    # setpts factor = 1/factor, atempo = factor
    video_filter="setpts=$(echo "1/$factor" | bc -l)*PTS"
    audio_filter="atempo=$factor"  # atempo requiere manejo de rangos, pero lo haremos simplificado

    # Manejar atempo >2 o <0.5
    tempo="$factor"
    audio_filters=""
    while (( $(echo "$tempo > 2.0" | bc -l) )); do
        audio_filters="${audio_filters}atempo=2.0,"
        tempo=$(echo "$tempo / 2.0" | bc -l)
    done
    while (( $(echo "$tempo < 0.5" | bc -l) )); do
        audio_filters="${audio_filters}atempo=0.5,"
        tempo=$(echo "$tempo / 0.5" | bc -l)
    done
    audio_filters="${audio_filters}atempo=$tempo"

    echo "Procesando: $archivo -> $salida"
    ffmpeg -i "$archivo" -filter_complex "[0:v]setpts=$(echo "1/$factor" | bc -l)*PTS[v];[0:a]${audio_filters}[a]" -map "[v]" -map "[a]" "$salida" >/dev/null 2>&1

    if [[ $? -eq 0 ]]; then
        echo "Conversión completada."
    else
        echo "Error al procesar '$archivo'."
        error=1
    fi
done

exit $error
