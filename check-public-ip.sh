#!/usr/bin/env bash

mostrar_ayuda() {
    cat <<EOF
Uso: $0
Descripción: Muestra la dirección IP pública actual.
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

if ! command -v curl >/dev/null 2>&1; then
    echo "Error: curl no está instalado."
    echo "Instálalo con: sudo apt install curl"
    exit 1
fi

ip=$(curl -s -4 https://ifconfig.me 2>/dev/null || curl -s -4 https://api.ipify.org 2>/dev/null)

if [[ -n "$ip" ]]; then
    echo "Tu dirección IP pública: $ip"
else
    echo "Error: no se pudo obtener la IP. Comprueba tu conexión."
    exit 1
fi
