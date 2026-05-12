#!/bin/bash
#===============================================================================
# Instalador de Emergencia - Hyprland para Parrot OS
# Cuando los paquetes oficiales tienen dependencias rotas
#
# Versión: 3.0.0 (Mayo 2026)
#   - Hyprland v0.54.3 target
#   - Integra fix EGL dual-GPU (Intel + NVIDIA)
#   - Versiones actualizadas de todas las librerías Hypr*
#===============================================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info()  { echo -e "${BLUE}[INFO]${NC} $1"; }
log_ok()    { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${CYAN}"
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  Hyprland - Instalador de Emergencia para Parrot OS      ║"
echo "║  Versión 3.0.0 - Hyprland v0.54.3                       ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo -e "${NC}"

log_info "Este script compila Hyprland + todas sus dependencias desde fuente"
log_info "para Parrot OS cuando los paquetes oficiales tienen problemas"

# Verificar sudo
if ! sudo -n true 2>/dev/null; then
    log_info "Se requiere acceso sudo para instalar dependencias"
fi

BUILD_DIR="$HOME/hyprland-build"
PARROT_CONFIG_DIR="$(dirname "$SCRIPT_DIR")"

mkdir -p "$BUILD_DIR"

# Instalar dependencias de compilación
log_info "Instalando dependencias de compilación..."
sudo apt install -y \
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
    libre2-dev libudis86-dev \
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
        git clone --recursive "$url" "$name"
    fi
    
    cd "$name"
    git fetch --tags 2>/dev/null || true
    git checkout "$version" 2>/dev/null || true
    
    rm -rf build
    cmake --no-warn-unused-cli \
        -DCMAKE_BUILD_TYPE:STRING=Release \
        -DCMAKE_INSTALL_PREFIX:STRING=/usr \
        -S . -B ./build
    
    cmake --build build --config Release -j$(nproc)
    sudo cmake --install build
    
    log_ok "$name v$version instalado"
}

# Compilar en orden (dependencias -> Hyprland)
build_and_install "hyprcursor" "https://github.com/hyprwm/hyprcursor.git" "v0.1.13"
build_and_install "hyprutils" "https://github.com/hyprwm/hyprutils.git" "v0.11.1"
build_and_install "hyprlang" "https://github.com/hyprwm/hyprlang.git" "v0.6.8"
build_and_install "hyprgraphics" "https://github.com/hyprwm/hyprgraphics.git" "v0.5.0"
build_and_install "aquamarine" "https://github.com/hyprwm/aquamarine.git" "v0.10.0"
build_and_install "Hyprland" "https://github.com/hyprwm/Hyprland.git" "v0.54.3"

# Aplicar fix EGL para sistemas dual-GPU (Intel + NVIDIA)
log_info "Verificando configuración EGL..."
if [[ -f "$SCRIPT_DIR/fix-egl-dualgpu.sh" ]]; then
    sudo bash "$SCRIPT_DIR/fix-egl-dualgpu.sh"
else
    log_warn "fix-egl-dualgpu.sh no encontrado"
    log_info "Ejecutá manualmente si Hyprland crashea:"
    log_info "  sudo bash scripts/fix-egl-dualgpu.sh"
fi

# Instalar configuraciones
log_info "Instalando configuraciones..."
"$PARROT_CONFIG_DIR/scripts/install-config.sh"

echo -e "${GREEN}"
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║     ¡Instalación de Emergencia Completada!                ║"
echo "║     Hyprland v0.54.3 + fix EGL dual-GPU                  ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo -e "${NC}"
log_info "Reinicia tu sesión y selecciona 'Hyprland' en el login manager"
log_info "O desde TTY (Ctrl+Alt+F3): Hyprland"
