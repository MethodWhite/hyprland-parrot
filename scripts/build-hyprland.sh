#!/bin/bash
#===============================================================================
# Script de Compilación de Hyprland para Parrot Security OS
# Compila Hyprland y todos sus componentes desde código fuente
#===============================================================================

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Logging
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Directorios
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$HOME/hyprland-build"
INSTALL_PREFIX="/usr"

# Crear directorio de build
setup_build_dir() {
    log_info "Creando directorio de compilación: $BUILD_DIR"
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"
}

# Clonar repositorios
clone_repos() {
    log_info "Clonando repositorios de Hyprland..."
    
    # Versiones estables - actualizadas a Mayo 2026
    # Compatibles con Hyprland v0.54.3 (target Debian/Parrot backports)
    local HYPRLAND_VERSION="v0.54.3"
    local HYPRCURSOR_VERSION="v0.1.13"
    local HYPRUTILS_VERSION="v0.11.1"
    local HYPRGRAPHICS_VERSION="v0.5.0"
    local HYPRLANG_VERSION="v0.6.8"
    local AQUAMARINE_VERSION="v0.10.0"
    local HYPRPAPER_VERSION="v0.8.4"
    local HYPRLOCK_VERSION="v0.9.5"
    local HYPRIDLE_VERSION="v0.1.7"
    local XDPH_VERSION="v1.3.12"
    
    # Si se pasa --stable-latest, usar tags más recientes
    # (pueden requerir dependencias más nuevas del sistema)
    if [[ "$1" == "--latest" ]]; then
        HYPRLAND_VERSION="v0.55.0"
        HYPRGRAPHICS_VERSION="v0.5.1"
        AQUAMARINE_VERSION="v0.11.0"
        HYPRUTILS_VERSION="v0.12.0"
        log_warn "Usando versiones latest - pueden requerir dependencias bleeding-edge"
    fi
    
    # Hyprcursor (gestión de cursores)
    if [ ! -d "hyprcursor" ]; then
        git clone --recursive https://github.com/hyprwm/hyprcursor.git
        cd hyprcursor && git checkout "$HYPRCURSOR_VERSION" && cd ..
    fi
    
    # Hyprutils (utilidades base)
    if [ ! -d "hyprutils" ]; then
        git clone --recursive https://github.com/hyprwm/hyprutils.git
        cd hyprutils && git checkout "$HYPRUTILS_VERSION" && cd ..
    fi
    
    # Hyprgraphics (renderizado gráfico)
    if [ ! -d "hyprgraphics" ]; then
        git clone --recursive https://github.com/hyprwm/hyprgraphics.git
        cd hyprgraphics && git checkout "$HYPRGRAPHICS_VERSION" && cd ..
    fi
    
    # Hyprlang (configuración)
    if [ ! -d "hyprlang" ]; then
        git clone --recursive https://github.com/hyprwm/hyprlang.git
        cd hyprlang && git checkout "$HYPRLANG_VERSION" && cd ..
    fi
    
    # Aquamarine (backend de renderizado)
    if [ ! -d "aquamarine" ]; then
        git clone --recursive https://github.com/hyprwm/aquamarine.git
        cd aquamarine && git checkout "$AQUAMARINE_VERSION" && cd ..
    fi
    
    # Hyprland (compositor principal)
    if [ ! -d "Hyprland" ]; then
        git clone --recursive https://github.com/hyprwm/Hyprland.git
        cd Hyprland && git checkout "$HYPRLAND_VERSION" && cd ..
    fi
    
    # Hyprpaper (fondos de pantalla)
    if [ ! -d "hyprpaper" ]; then
        git clone --recursive https://github.com/hyprwm/hyprpaper.git
        cd hyprpaper && git checkout "$HYPRPAPER_VERSION" && cd ..
    fi
    
    # Hyprlock (lock screen)
    if [ ! -d "hyprlock" ]; then
        git clone --recursive https://github.com/hyprwm/hyprlock.git
        cd hyprlock && git checkout "$HYPRLOCK_VERSION" && cd ..
    fi
    
    # Hypridle (idle daemon)
    if [ ! -d "hypridle" ]; then
        git clone --recursive https://github.com/hyprwm/hypridle.git
        cd hypridle && git checkout "$HYPRIDLE_VERSION" && cd ..
    fi
    
    # xdg-desktop-portal-hyprland
    if [ ! -d "xdg-desktop-portal-hyprland" ]; then
        git clone --recursive https://github.com/hyprwm/xdg-desktop-portal-hyprland.git
        cd xdg-desktop-portal-hyprland && git checkout "$XDPH_VERSION" && cd ..
    fi
    
    log_success "Repositorios clonados"
}

# Función genérica para compilar
build_component() {
    local name=$1
    local dir=$2
    
    log_info "Compilando $name..."
    cd "$BUILD_DIR/$dir"
    
    # Limpiar build anterior
    rm -rf build
    
    # Configurar y compilar
    cmake --no-warn-unused-cli \
        -DCMAKE_BUILD_TYPE:STRING=Release \
        -DCMAKE_INSTALL_PREFIX:STRING=$INSTALL_PREFIX \
        -S . -B ./build
    
    cmake --build build --config Release --target all -j$(nproc)
    
    # Instalar
    sudo cmake --install build
    
    cd "$BUILD_DIR"
    log_success "$name compilado e instalado"
}

# Compilar componentes en orden
build_all() {
    log_info "Iniciando compilación de componentes..."
    log_warn "Este proceso puede tomar 30-60 minutos dependiendo del hardware"
    
    # Orden de compilación es importante (dependencias)
    build_component "hyprcursor" "hyprcursor"
    build_component "hyprutils" "hyprutils"
    build_component "hyprgraphics" "hyprgraphics"
    build_component "hyprlang" "hyprlang"
    build_component "aquamarine" "aquamarine"
    
    log_info "Compilando Hyprland (esto puede tardar)..."
    cd "$BUILD_DIR/Hyprland"
    rm -rf build
    cmake --no-warn-unused-cli \
        -DCMAKE_BUILD_TYPE:STRING=Release \
        -DCMAKE_INSTALL_PREFIX:STRING=$INSTALL_PREFIX \
        -S . -B ./build
    cmake --build build --config Release --target all -j$(nproc)
    sudo cmake --install build
    log_success "Hyprland compilado e instalado"
    
    # Componentes adicionales
    build_component "hyprpaper" "hyprpaper"
    build_component "hyprlock" "hyprlock"
    build_component "hypridle" "hypridle"
    build_component "xdg-desktop-portal-hyprland" "xdg-desktop-portal-hyprland"
}

# Verificar instalación
verify_install() {
    log_info "Verificando instalación..."
    
    if command -v Hyprland &> /dev/null; then
        log_success "Hyprland instalado correctamente"
        Hyprland --version
    else
        log_error "Hyprland no se encontró en el PATH"
        exit 1
    fi
    
    if command -v hyprpaper &> /dev/null; then
        log_success "hyprpaper instalado correctamente"
    fi
    
    if command -v hyprlock &> /dev/null; then
        log_success "hyprlock instalado correctamente"
    fi
    
    if command -v hypridle &> /dev/null; then
        log_success "hypridle instalado correctamente"
    fi
}

# Crear archivo de sesión para display manager
create_session_file() {
    log_info "Creando archivo de sesión para display manager..."
    
    sudo mkdir -p /usr/share/wayland-sessions
    
    sudo cat > /usr/share/wayland-sessions/hyprland.desktop << 'EOF'
[Desktop Entry]
Name=Hyprland
Comment=An intelligent dynamic tiling Wayland compositor
Exec=Hyprland
Type=Application
DesktopNames=Hyprland
Keywords=wayland;tiling;compositor;
EOF
    
    log_success "Archivo de sesión creado"
}

# Aplicar fix de EGL para sistemas dual-GPU (Intel + NVIDIA)
apply_egl_fix() {
    log_info "Aplicando fix de EGL para compatibilidad dual-GPU..."
    local fix_script="$SCRIPT_DIR/fix-egl-dualgpu.sh"
    if [[ -f "$fix_script" ]]; then
        sudo bash "$fix_script"
    else
        log_warn "fix-egl-dualgpu.sh no encontrado, salteando..."
        log_info "Ejecutá manualmente: sudo bash scripts/fix-egl-dualgpu.sh"
    fi
}

# Limpiar
cleanup() {
    log_info "¿Deseas eliminar los archivos de compilación para ahorrar espacio? (y/n)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        rm -rf "$BUILD_DIR"
        log_success "Archivos de compilación eliminados"
    else
        log_info "Archivos de compilación conservados en $BUILD_DIR"
    fi
}

# Main
main() {
    echo -e "${CYAN}"
    echo "========================================"
    echo "  Hyprland para Parrot OS"
    echo "  Compilación desde Código Fuente"
    echo "========================================"
    echo -e "${NC}"
    
    log_warn "ADVERTENCIA: Este proceso tomará tiempo"
    log_warn "Asegúrate de tener al menos 10GB libres y batería suficiente"
    
    read -p "¿Continuar? (y/n): " response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        exit 0
    fi
    
    setup_build_dir
    clone_repos
    build_all
    verify_install
    apply_egl_fix
    create_session_file
    
    # Opcional: cleanup
    # cleanup
    
    echo -e "${GREEN}"
    echo "========================================"
    echo "  ¡Compilación completada!"
    echo "========================================"
    echo -e "${NC}"
    log_info "Reinicia tu sesión y selecciona 'Hyprland' en el login manager"
    log_info "O ejecuta 'Hyprland' desde TTY (Ctrl+Alt+F3)"
}

main "$@"
