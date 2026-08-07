#!/usr/bin/env bash

mostrar_ayuda() {
    cat <<EOF
Uso: $0 [CRF] [--preset slow|medium|fast] [--codec h264|h265] [--audio-bitrate N] [--size-limit MB] archivo1 [archivo2 ...]

Descripción: Comprime archivos de video reduciendo calidad/tamaño.

Parámetros:
  CRF               Valor entre 0 y 51 (0 = sin pérdida, 23 = calidad alta, 28 = calidad media, 35 = alta compresión). Por defecto: 28.

Opciones:
  --preset          slow | medium | fast  (por defecto: medium)
  --codec           h264 | h265           (por defecto: h264, pero prueba h265 si está disponible)
  --audio-bitrate   Bitrate de audio en kbps (por defecto: 128)
  --size-limit      Tamaño máximo en MB (opcional, detiene la codificación si se supera)
  --help            Muestra esta ayuda.

Ejemplos:
  $0 video.mp4                         # Comprime con CRF 28, preset medium
  $0 23 video.mp4                      # Mayor calidad
  $0 32 --preset slow video.mp4        # Más compresión, mejor calidad por bitrate
  $0 --codec h265 video.mp4            # Usa HEVC para mejor compresión
EOF
}

# Procesar opciones
crf=28
preset="medium"
codec="h264"
audio_bitrate=128
size_limit=""
args=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        --help)
            mostrar_ayuda
            exit 0
            ;;
        --preset)
            preset="$2"
            shift 2
            ;;
        --codec)
            codec="$2"
            shift 2
            ;;
        --audio-bitrate)
            audio_bitrate="$2"
            shift 2
            ;;
        --size-limit)
            size_limit="$2"
            shift 2
            ;;
        *)
            args+=("$1")
            shift
            ;;
    esac
done

set -- "${args[@]}"

# Si el primer argumento es un número entre 0 y 51, lo tomamos como CRF
if [[ $# -gt 0 && "$1" =~ ^[0-9]+$ ]] && (( $1 >= 0 && $1 <= 51 )); then
    crf="$1"
    shift
fi

if [[ $# -eq 0 ]]; then
    echo "Error: no se especificaron archivos."
    mostrar_ayuda
    exit 1
fi

# Verificar dependencias
if ! command -v ffmpeg >/dev/null 2>&1; then
    echo "Error: ffmpeg no está instalado."
    echo "Instálalo con: sudo apt install ffmpeg"
    exit 1
fi

# Comprobar disponibilidad de códec
if [[ "$codec" == "h265" ]]; then
    if ! ffmpeg -encoders 2>/dev/null | grep -q libx265; then
        echo "Advertencia: libx265 no está disponible, usando h264 en su lugar."
        codec="h264"
    fi
fi

# Ajustar preset válido
case "$preset" in
    slow|medium|fast) ;;
    *) echo "Advertencia: preset no reconocido, usando 'medium'."; preset="medium" ;;
esac

# Configurar códec y opciones
if [[ "$codec" == "h265" ]]; then
    vcodec="libx265"
    # Para h265, el CRF suele ser 0-51, similar a h264
else
    vcodec="libx264"
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
    salida="${base}_compressed_${crf}.${ext}"

    echo "Procesando: $archivo -> $salida"
    echo "  CRF: $crf | Preset: $preset | Códec: $codec | Audio: ${audio_bitrate}k"

    # Comando ffmpeg
    cmd=("ffmpeg" "-i" "$archivo" "-c:v" "$vcodec" "-preset" "$preset" "-crf" "$crf" "-c:a" "aac" "-b:a" "${audio_bitrate}k")

    if [[ -n "$size_limit" ]]; then
        # Añadir límite de tamaño en bytes (MB * 1024 * 1024)
        cmd+=("-fs" "$(($size_limit * 1024 * 1024))")
    fi

    cmd+=("$salida")

    # Ejecutar con redirección de salida para no saturar
    if "${cmd[@]}" >/dev/null 2>&1; then
        echo "Compresión completada."
    else
        echo "Error al procesar '$archivo'."
        error=1
    fi
done

exit $error
