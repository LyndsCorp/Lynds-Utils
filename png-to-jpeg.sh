#!/usr/bin/bash

if [[ $# -ne 1 ]]; then
    echo "Uso: $0 archivo.png"
    exit 1
fi

archivo="$1"

if [[ ! -f "$archivo" ]]; then
    echo "Error: el archivo no existe"
    exit 1
fi

if ! command -v magick >/dev/null 2>&1; then
    echo "Error: ImageMagick no está instalado"
    echo "Instálalo con: sudo apt install imagemagick"
    exit 1
fi

salida="${archivo%.*}.jpg"

echo "Convirtiendo:"
echo "  Entrada: $archivo"
echo "  Salida:  $salida"

magick "$archivo" "$salida"

if [[ $? -eq 0 ]]; then
    echo "Conversión completada correctamente."
else
    echo "Error durante la conversión."
    exit 1
fi
