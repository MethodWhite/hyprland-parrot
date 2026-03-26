#!/bin/bash
#===============================================================================
# Instalador Rápido de Hyprland para Parrot OS
# Usa los paquetes disponibles en los repositorios de Parrot
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
echo "║     Hyprland para Parrot OS - Instalador Rápido          ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Verificar root
if [[ $EUID -ne 0 ]]; then
    log_error "Ejecutar con sudo"
    exit 1
fi

# Actualizar
log_info "Actualizando sistema..."
apt update
apt upgrade -y

# Instalar Hyprland desde repositorios de Parrot
log_info "Instalando Hyprland desde repositorios de Parrot..."
apt install -y hyprland

# Instalar componentes adicionales
log_info "Instalando componentes adicionales..."
apt install -y \
    hyprcursor-util \
    hyprland-backgrounds \
    hyprland-protocols \
    hyprwayland-scanner \
    waybar \
    kitty \
    wofi \
    grim \
    slurp \
    wl-clipboard \
    pavucontrol \
    brightnessctl \
    polkit-kde-agent-1 \
    dunst \
    swww \
    imagemagick

# Instalar fuentes
log_info "Instalando fuentes..."
apt install -y \
    fonts-jetbrains-mono \
    fonts-font-awesome \
    fonts-noto-color-emoji

# Crear archivo de sesión
log_info "Creando archivo de sesión..."
cat > /usr/share/wayland-sessions/hyprland.desktop << 'EOF'
[Desktop Entry]
Name=Hyprland
Comment=An intelligent dynamic tiling Wayland compositor
Exec=Hyprland
Type=Application
DesktopNames=Hyprland
Keywords=wayland;tiling;compositor;
EOF

# Instalar configuraciones
log_info "Instalando configuraciones..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Para cada usuario
for user_home in /home/*; do
    if [ -d "$user_home" ]; then
        user=$(basename "$user_home")
        log_info "Configurando para usuario: $user"
        
        # Crear directorios
        mkdir -p "$user_home/.config/hypr"
        mkdir -p "$user_home/.config/waybar"
        mkdir -p "$user_home/.config/wofi"
        mkdir -p "$user_home/.config/kitty"
        
        # Copiar configuraciones
        if [ -f "$PROJECT_DIR/config/hypr/hyprland.conf" ]; then
            cp "$PROJECT_DIR/config/hypr/hyprland.conf" "$user_home/.config/hypr/"
            cp "$PROJECT_DIR/config/hypr/hyprpaper.conf" "$user_home/.config/hypr/"
        fi
        
        if [ -f "$PROJECT_DIR/config/waybar/config" ]; then
            cp "$PROJECT_DIR/config/waybar/config" "$user_home/.config/waybar/"
        fi
        
        if [ -f "$PROJECT_DIR/config/waybar/style.css" ]; then
            cp "$PROJECT_DIR/config/waybar/style.css" "$user_home/.config/waybar/"
        fi
        
        if [ -f "$PROJECT_DIR/config/wofi/style.css" ]; then
            cp "$PROJECT_DIR/config/wofi/style.css" "$user_home/.config/wofi/"
        fi
        
        if [ -f "$PROJECT_DIR/config/kitty/kitty.conf" ]; then
            cp "$PROJECT_DIR/config/kitty/kitty.conf" "$user_home/.config/kitty/"
        fi
        
        # Establecer permisos
        chown -R $user:$user "$user_home/.config"
    fi
done

log_success "¡Instalación completada!"
echo ""
echo -e "${CYAN}=========================================${NC}"
echo -e "${GREEN}Hyprland ha sido instalado${NC}"
echo -e "${CYAN}=========================================${NC}"
echo ""
log_info "Reinicia tu sesión y selecciona 'Hyprland' en el login manager"
log_info "O ejecuta 'Hyprland' desde TTY (Ctrl+Alt+F3)"
