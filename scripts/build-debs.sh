#!/bin/bash
#===============================================================================
# Script de Construcción de Paquetes .deb para Hyprland
# Parrot Security OS
#===============================================================================

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Directorios
BUILD_DIR="/home/methodwhite/hyprland-build"
DEB_DIR="/home/methodwhite/hyprland-parrot/debian"
REPO_DIR="/home/methodwhite/hyprland-parrot/repo"

# Crear directorio de repositorio
mkdir -p "$REPO_DIR"

# Función para construir paquete
build_package() {
    local name=$1
    local version=$2
    local repo_url=$3
    
    log_info "Construyendo paquete: $name $version"
    
    cd "$DEB_DIR/$name"
    
    # Clonar fuente si no existe
    if [ ! -d "src" ]; then
        git clone --recursive --branch "$version" "$repo_url" src
    fi
    
    # Copiar archivos de origen al directorio de construcción
    cp -r src/* ../build-$name/ 2>/dev/null || true
    
    # Construir paquete
    cd "$DEB_DIR/$name"
    debuild -us -uc -b
    
    # Mover paquetes al repositorio
    mv ../*.deb "$REPO_DIR/" 2>/dev/null || true
    
    log_success "Paquete $name construido"
}

# Main
main() {
    echo -e "${CYAN}"
    echo "========================================"
    echo "  Construcción de Paquetes Hyprland"
    echo "  Para Parrot Security OS"
    echo "========================================"
    echo -e "${NC}"
    
    # Instalar herramientas de construcción
    log_info "Instalando herramientas de construcción..."
    echo "Vitis_101" | sudo -S apt install -y debhelper devscripts cmake ninja-build
    
    # Construir en orden
    build_package "hyprcursor" "v0.1.9" "https://github.com/hyprwm/hyprcursor.git"
    build_package "hyprutils" "v0.11.1" "https://github.com/hyprwm/hyprutils.git"
    build_package "hyprlang" "v0.6.7" "https://github.com/hyprwm/hyprlang.git"
    build_package "hyprgraphics" "v0.4.0" "https://github.com/hyprwm/hyprgraphics.git"
    build_package "aquamarine" "v0.7.0" "https://github.com/hyprwm/aquamarine.git"
    build_package "hyprland" "v0.44.0" "https://github.com/hyprwm/Hyprland.git"
    
    # Crear índice del repositorio
    log_info "Creando índice del repositorio..."
    cd "$REPO_DIR"
    dpkg-scanpackages . /dev/null | gzip -9c > Packages.gz
    
    echo -e "${GREEN}"
    echo "========================================"
    echo "  ¡Paquetes Construidos!"
    echo "========================================"
    echo -e "${NC}"
    log_info "Repositorio en: $REPO_DIR"
    log_info "Para instalar: sudo apt install ./repo/*.deb"
}

main "$@"
