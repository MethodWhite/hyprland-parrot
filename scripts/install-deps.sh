#!/bin/bash
#===============================================================================
# Script de Instalación de Dependencias para Hyprland
# Parrot Security OS 7.x
#===============================================================================

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Funciones de logging
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Verificar si es root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "Este script debe ejecutarse como root (usa sudo)"
        exit 1
    fi
}

# Verificar Parrot OS
check_parrot() {
    if ! grep -q "Parrot" /etc/os-release; then
        log_warn "Esto no parece ser Parrot OS. La compatibilidad no está garantizada."
        read -p "¿Continuar de todos modos? (y/n): " response
        if [[ "$response" != "y" ]]; then
            exit 1
        fi
    fi
    log_info "Parrot OS detectado: $(grep PRETTY_NAME /etc/os-release | cut -d'"' -f2)"
}

# Actualizar sistema
update_system() {
    log_info "Actualizando lista de paquetes..."
    apt update
    
    log_info "Actualizando sistema..."
    apt upgrade -y
}

# Instalar dependencias base
install_base_deps() {
    log_info "Instalando dependencias base de compilación..."
    
    apt install -y \
        build-essential \
        cmake \
        cmake-data \
        cmake-extras \
        ninja-build \
        meson \
        pkg-config \
        git \
        curl \
        wget \
        python3 \
        python3-pip
}

# Instalar dependencias de Wayland
install_wayland_deps() {
    log_info "Instalando dependencias de Wayland..."
    
    apt install -y \
        libwayland-dev \
        wayland-protocols \
        libxkbcommon-dev \
        libxcb1-dev \
        libxcb-render0-dev \
        libxcb-shape0-dev \
        libxcb-xfixes0-dev \
        libxcb-render-util0-dev \
        libxcb-image0-dev \
        libxcb-icccm4-dev \
        libxcb-keysyms1-dev \
        libxcb-randr0-dev \
        libxcb-cursor-dev \
        libxkbcommon-x11-dev
}

# Instalar dependencias gráficas
install_graphics_deps() {
    log_info "Instalando dependencias gráficas..."
    
    apt install -y \
        libpixman-1-dev \
        libdrm-dev \
        libgbm-dev \
        libegl-dev \
        libgles2 \
        libglvnd-dev \
        libopengl-dev \
        libglx-dev \
        libgl1-mesa-dev \
        libvulkan-dev \
        vulkan-tools \
        libre2-dev \
        libudis86-dev
}

# Instalar dependencias de entrada
install_input_deps() {
    log_info "Instalando dependencias de entrada..."
    
    apt install -y \
        libinput-dev \
        libinput-bin \
        libudev-dev \
        libevdev-dev \
        libmtdev-dev \
        libwacom-dev \
        libdbus-1-dev \
        libsystemd-dev
}

# Instalar dependencias de audio/video
install_av_deps() {
    log_info "Instalando dependencias de audio/video..."
    
    apt install -y \
        libpipewire-0.3-dev \
        libspa-0.2-dev \
        libpulse-dev \
        libsndfile1-dev \
        libavutil-dev \
        libavcodec-dev \
        libavformat-dev \
        libswscale-dev
}

# Instalar dependencias de GTK/Cairo
install_gtk_deps() {
    log_info "Instalando dependencias GTK/Cairo..."
    
    apt install -y \
        libcairo2-dev \
        libpango1.0-dev \
        libglib2.0-dev \
        libgtk-3-dev \
        libgtkmm-3.0-dev \
        libsigc++-2.0-dev \
        libgdk-pixbuf2.0-dev \
        libgirepository1.0-dev
}

# Instalar dependencias de imagen
install_image_deps() {
    log_info "Instalando dependencias de imagen..."
    
    apt install -y \
        libjpeg-dev \
        libwebp-dev \
        libpng-dev \
        libfreetype6-dev \
        libfontconfig1-dev \
        libharfbuzz-dev \
        librsvg2-dev
}

# Instalar aplicaciones y utilidades
install_apps() {
    log_info "Instalando aplicaciones y utilidades..."
    
    apt install -y \
        kitty \
        waybar \
        wofi \
        grim \
        slurp \
        wl-clipboard \
        pavucontrol \
        brightnessctl \
        polkit-kde-agent-1 \
        dunst \
        swww \
        imagemagick \
        feh
}

# Instalar fuentes
install_fonts() {
    log_info "Instalando fuentes..."
    
    apt install -y \
        fonts-jetbrains-mono \
        fonts-font-awesome \
        fonts-noto-color-emoji \
        fonts-noto-core
    
    # Crear directorio de fuentes local
    mkdir -p /usr/local/share/fonts
}

# Configurar entorno Wayland
configure_wayland() {
    log_info "Configurando entorno Wayland..."
    
    # Crear archivo de entorno para SDDM/GDM
    cat > /etc/profile.d/wayland.sh << 'EOF'
export XDG_SESSION_TYPE=wayland
export XDG_CURRENT_DESKTOP=Hyprland
export GDK_BACKEND=wayland
export QT_QPA_PLATFORM=wayland
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
export _JAVA_AWT_WM_NONREPARENTING=1
export MOZ_ENABLE_WAYLAND=1
export CLUTTER_BACKEND=wayland
export NIXOS_OZONE_WL=1
EOF
    
    chmod +x /etc/profile.d/wayland.sh
}

# Limpiar caché
cleanup() {
    log_info "Limpiando caché de paquetes..."
    apt autoremove -y
    apt autoclean
}

# Main
main() {
    echo -e "${CYAN}"
    echo "========================================"
    echo "  Hyprland para Parrot OS"
    echo "  Instalación de Dependencias"
    echo "========================================"
    echo -e "${NC}"
    
    check_root
    check_parrot
    update_system
    
    log_info "Iniciando instalación de dependencias..."
    
    install_base_deps
    install_wayland_deps
    install_graphics_deps
    install_input_deps
    install_av_deps
    install_gtk_deps
    install_image_deps
    install_apps
    install_fonts
    configure_wayland
    
    cleanup
    
    echo -e "${GREEN}"
    echo "========================================"
    echo "  ¡Dependencias instaladas!"
    echo "========================================"
    echo -e "${NC}"
    log_info "Ahora ejecuta: ./scripts/build-hyprland.sh"
}

main "$@"
