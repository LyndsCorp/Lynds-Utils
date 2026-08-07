#!/usr/bin/bash

if [[ $# -ne 2 ]]; then
    echo "Uso: $0 <linea> <archivo>"
    exit 1
fi

linea="$1"
archivo="$2"

[[ "$linea" =~ ^[0-9]+$ ]] || {
    echo "Error: la línea debe ser un número."
    exit 1
}

[[ -f "$archivo" ]] || {
    echo "Error: el archivo no existe."
    exit 1
}

sed -n "${linea}p" "$archivo"
