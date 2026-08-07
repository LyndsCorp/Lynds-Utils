#!/usr/bin/env bash

mostrar_ayuda() {
    cat <<EOF
Uso: $0 factor archivo1 [archivo2 ...]
Descripción: Cambia la velocidad de archivos de audio.
  factor: número mayor que 0 (ej. 0.5 = mitad de velocidad, 2.0 = doble).
Ejemplo:
  $0 1.5 cancion.mp3
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

    echo "Procesando: $archivo -> $salida"
    # atempo solo acepta valores entre 0.5 y 2.0, para factores fuera de rango se encadenan
    # Usamos un cálculo simple: si >2 o <0.5, encadenamos múltiples atempo
    tempo="$factor"
    filters=""
    while (( $(echo "$tempo > 2.0" | bc -l) )); do
        filters="${filters}atempo=2.0,"
        tempo=$(echo "$tempo / 2.0" | bc -l)
    done
    while (( $(echo "$tempo < 0.5" | bc -l) )); do
        filters="${filters}atempo=0.5,"
        tempo=$(echo "$tempo / 0.5" | bc -l)
    done
    filters="${filters}atempo=$tempo"

    if ffmpeg -i "$archivo" -filter:a "$filters" "$salida" >/dev/null 2>&1; then
        echo "Conversión completada."
    else
        echo "Error al procesar '$archivo'."
        error=1
    fi
done

exit $error
