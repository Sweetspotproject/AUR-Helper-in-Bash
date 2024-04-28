#!/bin/bash

# Función para buscar programas en el AUR utilizando la API web
search_aur() {
    local query="$1"
    local url="https://aur.archlinux.org/rpc/?v=5&type=search&arg=$query"
    local response=$(curl -s "$url")

    # Verificar si hay errores en la respuesta
    if [[ "$response" == *"error"* ]]; then
        echo "Error: No se pudo realizar la búsqueda en el AUR."
        exit 1
    fi

    # Mostrar los nombres de los programas relacionados con la entrada proporcionada
    echo "Resultados de la búsqueda en el AUR para '$query':"
    echo "$response" | jq -r '.results[] | select(.Name | contains($query)) | .Name' --arg query "$query"
}

# Función para descargar e instalar un programa del AUR
install_aur_package() {
    local package_name="$1"
    local aur_url="https://aur.archlinux.org/$package_name.git"
    local temp_dir="$(mktemp -d)"

    # Clonar el repositorio del AUR
    git clone "$aur_url" "$temp_dir" >/dev/null 2>&1

    # Cambiar al directorio del paquete
    cd "$temp_dir" || exit

    # Compilar e instalar el paquete
    makepkg -si --noconfirm

    # Regresar al directorio original
    cd - >/dev/null || exit

    # Eliminar el directorio temporal
    rm -rf "$temp_dir"
}

# Comprobación de argumentos
if [ $# -eq 0 ]; then
    echo "Uso: $0 <nombre_del_programa>"
    exit 1
fi

# Llamar a la función de búsqueda
search_aur "$1"

# Pedir al usuario que seleccione un programa para instalar
read -p "Ingrese el nombre del programa que desea instalar: " program_to_install

# Llamar a la función para instalar el programa seleccionado
install_aur_package "$program_to_install"

