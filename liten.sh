#!/bin/bash

# Function to search programs on AUR using the api web
search_aur() {
    local query="$1"
    local url="https://aur.archlinux.org/rpc/?v=5&type=search&arg=$query"
    local response=$(curl -s "$url")

    # Verify if showing errors on answer
    if [[ "$response" == *"error"* ]]; then
        echo "Error: No se pudo realizar la búsqueda en el AUR."
        exit 1
    fi

    # Show names of the programs related with the input of user
    echo "Resultados de la búsqueda en el AUR para '$query':"
    echo "$response" | jq -r '.results[] | select(.Name | contains($query)) | .Name' --arg query "$query"
}

# Function to download and install a program of AUR
install_aur_package() {
    local package_name="$1"
    local aur_url="https://aur.archlinux.org/$package_name.git"
    local temp_dir

    # Validate the package name
    if ! [[ "$package_name" =~ ^[a-zA-Z0-9._-]+$ ]]; then
        echo "Error: El nombre del paquete es inválido."
        exit 1
    fi

    # Create a temporal directory of safe way 
    temp_dir="$(mktemp -d)" || { echo "Error: No se pudo crear el directorio temporal."; exit 1; }

    # Cloning the repo of AUR of safe way
    git clone "$aur_url" "$temp_dir" >/dev/null 2>&1 || { echo "Error: No se pudo clonar el repositorio del AUR."; exit 1; }

    # Change to package directory
    cd "$temp_dir" || { echo "Error: No se pudo cambiar al directorio del paquete."; exit 1; }

    # Compile and install the package
    makepkg -si --noconfirm || { echo "Error: No se pudo compilar e instalar el paquete."; exit 1; }

    # Return to original directoy
    cd - >/dev/null || exit

    # Delete the temp directory
    rm -rf "$temp_dir"
}

# Checking arguments
if [ $# -eq 0 ]; then
    echo "Uso: $0 <nombre_del_programa>"
    exit 1
fi

# Calling to search function
search_aur "$1"

# Ask the user to select a program to install
read -p "Ingrese el nombre del programa que desea instalar: " program_to_install

# Call to function to install the select program
install_aur_package "$program_to_install"
