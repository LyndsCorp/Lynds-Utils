#!/usr/bin/env bash

mostrar_ayuda() {
    cat <<EOF
Uso: $0 archivo1 [archivo2 ...]
Descripción: Verifica que los archivos JSON tengan sintaxis válida usando jq.
Ejemplo:
  $0 datos.json config.json
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

if ! command -v jq >/dev/null 2>&1; then
    echo "Error: jq no está instalado."
    echo "Instálalo con: sudo apt install jq"
    exit 1
fi

error=0

for archivo in "$@"; do
    if [[ ! -f "$archivo" ]]; then
        echo "Error: '$archivo' no existe."
        error=1
        continue
    fi

    if jq empty "$archivo" 2>/dev/null; then
        echo "$archivo: JSON válido."
    else
        echo "$archivo: JSON inválido."
        error=1
    fi
done

exit $error
