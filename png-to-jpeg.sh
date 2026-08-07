#!/usr/bin/env bash

mostrar_ayuda() {
    cat <<EOF
Uso: $0 archivo1 [archivo2 ...]
Descripción: Convierte archivos PNG a JPEG.
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

if ! command -v magick >/dev/null 2>&1; then
    echo "Error: ImageMagick no está instalado"
    echo "Instálalo con: sudo apt install imagemagick"
    exit 1
fi

error=0

for archivo in "$@"; do
    if [[ ! -f "$archivo" ]]; then
        echo "Error: el archivo '$archivo' no existe"
        error=1
        continue
    fi

    salida="${archivo%.*}.jpg"

    echo "Convirtiendo:"
    echo "  Entrada: $archivo"
    echo "  Salida:  $salida"

    magick "$archivo" "$salida"

    if [[ $? -eq 0 ]]; then
        echo "Conversión completada correctamente."
    else
        echo "Error durante la conversión de '$archivo'."
        error=1
    fi
done

exit $error
