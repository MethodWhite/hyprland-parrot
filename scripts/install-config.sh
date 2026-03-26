#!/bin/bash
#===============================================================================
# Script de Instalación de Configuraciones
# Copia todas las configuraciones al directorio home del usuario
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

# Verificar que no sea root
if [[ $EUID -eq 0 ]]; then
    log_error "Este script NO debe ejecutarse como root"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo -e "${CYAN}"
echo "========================================="
echo "  Instalando Configuraciones"
echo "========================================="
echo -e "${NC}"

# Crear directorios
log_info "Creando directorios..."
mkdir -p ~/.config/hypr
mkdir -p ~/.config/waybar
mkdir -p ~/.config/wofi
mkdir -p ~/.config/kitty
mkdir -p ~/.config/hypr/scripts
mkdir -p ~/.config/hypr/wallpapers
mkdir -p ~/.config/gtk-3.0

# Copiar configuraciones de Hyprland
log_info "Copiando configuración de Hyprland..."
cp "$PROJECT_DIR/config/hypr/hyprland.conf" ~/.config/hypr/
cp "$PROJECT_DIR/config/hypr/hyprpaper.conf" ~/.config/hypr/
log_success "Hyprland config instalada"

# Copiar configuración de Waybar
log_info "Copiando configuración de Waybar..."
cp "$PROJECT_DIR/config/waybar/config" ~/.config/waybar/
cp "$PROJECT_DIR/config/waybar/style.css" ~/.config/waybar/
log_success "Waybar config instalada"

# Copiar configuración de Wofi
log_info "Copiando configuración de Wofi..."
cp "$PROJECT_DIR/config/wofi/style.css" ~/.config/wofi/
log_success "Wofi config instalada"

# Copiar configuración de Kitty
log_info "Copiando configuración de Kitty..."
cp "$PROJECT_DIR/config/kitty/kitty.conf" ~/.config/kitty/
log_success "Kitty config instalada"

# Copiar scripts
log_info "Copiando scripts..."
if [ -f "$PROJECT_DIR/scripts/security_status.sh" ]; then
    cp "$PROJECT_DIR/scripts/security_status.sh" ~/.config/hypr/scripts/
    chmod +x ~/.config/hypr/scripts/security_status.sh
    log_success "Scripts instalados"
fi

# Crear configuración GTK
log_info "Creando configuración GTK..."
cat > ~/.config/gtk-3.0/settings.ini << 'EOF'
[Settings]
gtk-theme-name=Adwaita-dark
gtk-icon-theme-name=Papirus-Dark
gtk-font-name=JetBrainsMono Nerd Font 11
gtk-cursor-theme-name=Adwaita
gtk-cursor-theme-size=24
gtk-toolbar-style=GTK_TOOLBAR_ICONS
gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
gtk-button-images=0
gtk-menu-images=0
gtk-enable-event-sounds=0
gtk-enable-input-feedback-sounds=0
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle=hintslight
gtk-xft-rgba=rgb
EOF
log_success "GTK config creada"

# Crear archivo de entorno para Wayland
log_info "Creando variables de entorno..."
cat > ~/.config/hypr/environment << 'EOF'
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
log_success "Variables de entorno creadas"

# Hacer scripts ejecutables
chmod +x ~/.config/hypr/scripts/*.sh 2>/dev/null || true

echo ""
echo -e "${GREEN}"
echo "========================================="
echo "  ¡Configuraciones Instaladas!"
echo "========================================="
echo -e "${NC}"
echo ""
log_info "Las configuraciones se han instalado en:"
echo "  ~/.config/hypr/"
echo "  ~/.config/waybar/"
echo "  ~/.config/wofi/"
echo "  ~/.config/kitty/"
echo ""
log_info "Reinicia Hyprland (SUPER+SHIFT+E) para aplicar los cambios"
