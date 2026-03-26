#!/bin/bash
#===============================================================================
# Instalador de Emergencia - Hyprland para Parrot OS
# Cuando los paquetes oficiales tienen dependencias rotas
#===============================================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

echo -e "${CYAN}"
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  Hyprland - Instalador de Emergencia para Parrot OS      ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo -e "${NC}"

log_info "Este script instala Hyprland cuando los paquetes oficiales fallan"
log_info "Se compilarán las librerías necesarias desde código fuente"

BUILD_DIR="/home/methodwhite/hyprland-build"
PARROT_CONFIG_DIR="/home/methodwhite/hyprland-parrot"

mkdir -p "$BUILD_DIR"

# Instalar dependencias de compilación
log_info "Instalando dependencias de compilación..."
echo "Vitis_101" | sudo -S apt install -y \
    build-essential cmake ninja-build meson pkg-config git \
    libwayland-dev wayland-protocols libxkbcommon-dev \
    libpixman-1-dev libdrm-dev libgbm-dev \
    libegl-dev libgles2 libglvnd-dev libvulkan-dev \
    libinput-dev libudev-dev libdbus-1-dev libsystemd-dev \
    libpipewire-0.3-dev libpulse-dev \
    libcairo2-dev libpango1.0-dev libgtk-3-dev \
    libjpeg-dev libwebp-dev libpng-dev \
    libfreetype6-dev libfontconfig1-dev libharfbuzz-dev \
    libzip-dev librsvg2-dev libtomlplusplus-dev \
    hyprwayland-scanner glslang-dev libmagic-dev \
    libseat-dev libdisplay-info-dev hwdata \
    kitty waybar wofi grim slurp wl-clipboard \
    pavucontrol brightnessctl polkit-kde-agent-1 dunst

# Función para clonar y compilar
build_and_install() {
    local name=$1
    local url=$2
    local version=$3
    
    log_info "Compilando e instalando: $name ($version)"
    
    cd "$BUILD_DIR"
    
    if [ ! -d "$name" ]; then
        git clone --recursive --branch "$version" "$url" "$name"
    fi
    
    cd "$name"
    git checkout "$version" 2>/dev/null || true
    
    rm -rf build
    cmake --no-warn-unused-cli \
        -DCMAKE_BUILD_TYPE:STRING=Release \
        -DCMAKE_INSTALL_PREFIX:STRING=/usr \
        -S . -B ./build
    
    cmake --build build --config Release -j4
    echo "Vitis_101" | sudo -S cmake --install build
    
    log_success "$name instalado"
}

# Compilar en orden
build_and_install "hyprcursor" "https://github.com/hyprwm/hyprcursor.git" "v0.1.9"
build_and_install "hyprutils" "https://github.com/hyprwm/hyprutils.git" "v0.11.1"
build_and_install "hyprlang" "https://github.com/hyprwm/hyprlang.git" "v0.6.7"
build_and_install "hyprgraphics" "https://github.com/hyprwm/hyprgraphics.git" "v0.4.0"
build_and_install "aquamarine" "https://github.com/hyprwm/aquamarine.git" "v0.7.0"

# Ahora instalar Hyprland
log_info "Las librerías están instaladas. Ahora puedes instalar Hyprland:"
log_info "sudo apt install -y hyprland"

# Instalar configuraciones
log_info "Instalando configuraciones..."
"$PARROT_CONFIG_DIR/scripts/install-config.sh"

echo -e "${GREEN}"
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║         ¡Instalación de Emergencia Completada!           ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo -e "${NC}"
log_info "Reinicia tu sesión y selecciona 'Hyprland'"
