#!/bin/bash
#===============================================================================
# Instalador Principal de Hyprland para Parrot Security OS
# Script automático que ejecuta todos los pasos de instalación
#===============================================================================

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Logging
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_step() { echo -e "${CYAN}[STEP]${NC} $1"; }

# Banner
show_banner() {
    echo -e "${CYAN}"
    echo "╔═══════════════════════════════════════════════════════════╗"
    echo "║                                                           ║"
    echo "║     ███╗   ███╗ █████╗ ██╗  ██╗██╗███╗   ██╗              ║"
    echo "║     ████╗ ████║██╔══██╗██║  ██║██║████╗  ██║              ║"
    echo "║     ██╔████╔██║███████║███████║██║██╔██╗ ██║              ║"
    echo "║     ██║╚██╔╝██║██╔══██║██╔══██║██║██║╚██╗██║              ║"
    echo "║     ██║ ╚═╝ ██║██║  ██║██║  ██║██║██║ ╚████║              ║"
    echo "║     ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝  LAND        ║"
    echo "║                                                           ║"
    echo "║         Para Parrot Security OS - S4vitar Style           ║"
    echo "╚═══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Verificar root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "Este script debe ejecutarse como root (usa sudo)"
        exit 1
    fi
}

# Verificar Parrot OS
check_parrot() {
    if ! grep -qi "parrot" /etc/os-release; then
        log_warn "Esto no parece ser Parrot OS. La compatibilidad no está garantizada."
        read -p "¿Continuar de todos modos? (y/n): " response
        if [[ "$response" != "y" && "$response" != "Y" ]]; then
            exit 1
        fi
    fi
}

# Menú principal
show_menu() {
    echo -e "${MAGENTA}"
    echo "========================================="
    echo "  MENÚ DE INSTALACIÓN"
    echo "========================================="
    echo -e "${NC}"
    echo "1) Instalar dependencias"
    echo "2) Compilar Hyprland (puede tomar 30-60 min)"
    echo "3) Instalar configuraciones"
    echo "4) Instalación completa (automático)"
    echo "5) Salir"
    echo ""
}

# Instalar dependencias
install_deps() {
    log_step "Instalando dependencias..."
    chmod +x scripts/install-deps.sh
    ./scripts/install-deps.sh
    log_success "Dependencias instaladas"
}

# Compilar Hyprland
build_hyprland() {
    log_step "Compilando Hyprland..."
    chmod +x scripts/build-hyprland.sh
    ./scripts/build-hyprland.sh
    log_success "Hyprland compilado"
}

# Instalar configuraciones
install_config() {
    log_step "Instalando configuraciones..."
    
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    HOME_DIR="$HOME"
    
    # Crear directorios
    mkdir -p "$HOME_DIR/.config/hypr"
    mkdir -p "$HOME_DIR/.config/waybar"
    mkdir -p "$HOME_DIR/.config/wofi"
    mkdir -p "$HOME_DIR/.config/kitty"
    mkdir -p "$HOME_DIR/.config/hypr/scripts"
    mkdir -p "$HOME_DIR/.config/hypr/wallpapers"
    
    # Copiar configuraciones
    cp "$SCRIPT_DIR/config/hypr/hyprland.conf" "$HOME_DIR/.config/hypr/"
    cp "$SCRIPT_DIR/config/hypr/hyprpaper.conf" "$HOME_DIR/.config/hypr/"
    cp "$SCRIPT_DIR/config/waybar/config" "$HOME_DIR/.config/waybar/"
    cp "$SCRIPT_DIR/config/waybar/style.css" "$HOME_DIR/.config/waybar/"
    cp "$SCRIPT_DIR/config/wofi/style.css" "$HOME_DIR/.config/wofi/"
    cp "$SCRIPT_DIR/config/kitty/kitty.conf" "$HOME_DIR/.config/kitty/"
    
    # Copiar scripts
    if [ -f "$SCRIPT_DIR/scripts/security_status.sh" ]; then
        cp "$SCRIPT_DIR/scripts/security_status.sh" "$HOME_DIR/.config/hypr/scripts/"
        chmod +x "$HOME_DIR/.config/hypr/scripts/security_status.sh"
    fi
    
    # Copiar wallpaper por defecto (si existe)
    if [ -f "$SCRIPT_DIR/assets/wallpapers/default.jpg" ]; then
        cp "$SCRIPT_DIR/assets/wallpapers/default.jpg" "$HOME_DIR/.config/hypr/wallpapers/"
    fi
    
    log_success "Configuraciones instaladas en ~/.config/"
}

# Instalación completa
full_install() {
    log_info "Iniciando instalación completa..."
    log_warn "Este proceso tomará aproximadamente 1 hora"
    
    read -p "¿Continuar? (y/n): " response
    if [[ "$response" != "y" && "$response" != "Y" ]]; then
        exit 0
    fi
    
    install_deps
    build_hyprland
    install_config
    
    echo -e "${GREEN}"
    echo "========================================="
    echo "  ¡INSTALACIÓN COMPLETADA!"
    echo "========================================="
    echo -e "${NC}"
    log_info "Reinicia tu sesión y selecciona 'Hyprland' en el login manager"
}

# Main
main() {
    show_banner
    
    check_root
    check_parrot
    
    while true; do
        show_menu
        read -p "Selecciona una opción [1-5]: " option
        
        case $option in
            1)
                install_deps
                ;;
            2)
                build_hyprland
                ;;
            3)
                install_config
                ;;
            4)
                full_install
                ;;
            5)
                log_info "Saliendo..."
                exit 0
                ;;
            *)
                log_error "Opción inválida"
                ;;
        esac
        
        echo ""
        read -p "Presiona Enter para continuar..."
    done
}

main "$@"
