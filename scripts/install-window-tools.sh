#!/bin/bash
# =============================================================================
# install-window-tools.sh - Instalador del sistema de ventanas dinámicas
# Para Hyprland - Parrot Security OS
# =============================================================================

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Directorios
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CONFIG_DIR="$HOME/.config/hypr"
WINDOW_TOOLS_DIR="$CONFIG_DIR/scripts/window_tools"

echo -e "${CYAN}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║     Sistema de Ventanas Dinámicas - Instalador           ║
║     Para Hyprland - Parrot Security OS                   ║
╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Función para mostrar progreso
show_step() {
    echo -e "${BLUE}━━━ $1 ${NC}"
}

show_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

show_error() {
    echo -e "${RED}✗ $1${NC}"
}

show_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

# Verificar dependencias
check_dependencies() {
    show_step "Verificando dependencias..."
    
    local missing=()
    
    # Verificar hyprctl
    if ! command -v hyprctl &> /dev/null; then
        missing+=("hyprctl (hyprland)")
    fi
    
    # Verificar jq
    if ! command -v jq &> /dev/null; then
        missing+=("jq")
    fi
    
    if [ ${#missing[@]} -ne 0 ]; then
        echo -e "${YELLOW}Dependencias faltantes:${NC}"
        for dep in "${missing[@]}"; do
            echo -e "  - $dep"
        done
        echo ""
        echo -e "${YELLOW}¿Instalar dependencias faltantes? (y/n)${NC}"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            install_dependencies
        else
            show_error "Instalación cancelada. Las dependencias son requeridas."
            exit 1
        fi
    else
        show_success "Todas las dependencias están instaladas"
    fi
}

# Instalar dependencias
install_dependencies() {
    show_step "Instalando dependencias..."
    
    if command -v apt &> /dev/null; then
        sudo apt update
        sudo apt install -y jq
        show_success "Dependencias instaladas"
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y jq
        show_success "Dependencias instaladas"
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm jq
        show_success "Dependencias instaladas"
    else
        show_error "Gestor de paquetes no reconocido. Instalá jq manualmente."
        exit 1
    fi
}

# Crear directorios
create_directories() {
    show_step "Creando directorios..."
    
    mkdir -p "$WINDOW_TOOLS_DIR"
    mkdir -p "$CONFIG_DIR/layouts"
    
    show_success "Directorios creados"
}

# Copiar scripts
copy_scripts() {
    show_step "Copiando scripts..."
    
    # Copiar todos los scripts de window_tools
    if [ -d "$PROJECT_ROOT/scripts/window_tools" ]; then
        cp "$PROJECT_ROOT/scripts/window_tools/"*.sh "$WINDOW_TOOLS_DIR/"
        chmod +x "$WINDOW_TOOLS_DIR/"*.sh
        show_success "Scripts copiados a $WINDOW_TOOLS_DIR"
    else
        show_error "Directorio de scripts no encontrado"
        exit 1
    fi
}

# Backup de configuración existente
backup_config() {
    show_step "Verificando configuración existente..."
    
    local config_file="$CONFIG_DIR/hypr/hyprland.conf"
    
    if [ -f "$config_file" ]; then
        # Verificar si ya tiene los keybinds de window tools
        if grep -q "window_tools" "$config_file" 2>/dev/null; then
            show_info "La configuración ya contiene keybinds de window tools"
            echo -e "${YELLOW}¿Sobrescribir? (y/n)${NC}"
            read -r response
            if [[ ! "$response" =~ ^[Yy]$ ]]; then
                show_info "Saltando actualización de configuración"
                return 0
            fi
        fi
        
        # Crear backup
        local backup_file="$CONFIG_DIR/hypr/hyprland.conf.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$config_file" "$backup_file"
        show_success "Backup creado: $backup_file"
    fi
}

# Actualizar hyprland.conf
update_config() {
    show_step "Actualizando configuración de Hyprland..."
    
    local config_file="$CONFIG_DIR/hypr/hyprland.conf"
    local template_file="$PROJECT_ROOT/config/hypr/hyprland.conf"
    
    if [ ! -f "$config_file" ]; then
        show_info "No se encontró configuración existente"
        
        # Si existe el template, copiarlo
        if [ -f "$template_file" ]; then
            mkdir -p "$(dirname "$config_file")"
            cp "$template_file" "$config_file"
            show_success "Configuración template copiada"
        else
            show_error "No se encontró template de configuración"
            return 1
        fi
    else
        # Verificar si ya tiene los keybinds
        if grep -q "SISTEMA DE VENTANAS DINÁMICAS" "$config_file" 2>/dev/null; then
            show_success "Configuración ya actualizada"
            return 0
        fi
        
        # Añadir keybinds al final de la sección de keybinds
        local keybind_section="# === SISTEMA DE VENTANAS DINÁMICAS ==="
        
        # Insertar antes de "=== VOLUMEN ==="
        if grep -q "# === VOLUMEN ===" "$config_file"; then
            sed -i "/# === VOLUMEN ===/i \\
# === SISTEMA DE VENTANAS DINÁMICAS ===\\
# Window Snap (tipo Windows)\\
bind = \$mainMod SHIFT, left, exec, $WINDOW_TOOLS_DIR/window_snap.sh left\\
bind = \$mainMod SHIFT, right, exec, $WINDOW_TOOLS_DIR/window_snap.sh right\\
bind = \$mainMod SHIFT, up, exec, $WINDOW_TOOLS_DIR/window_snap.sh top\\
bind = \$mainMod SHIFT, down, exec, $WINDOW_TOOLS_DIR/window_snap.sh bottom\\
\\
# Window Snap - Esquinas (cuartos de pantalla)\\
bind = \$mainMod CTRL, left, exec, $WINDOW_TOOLS_DIR/window_snap.sh top_left\\
bind = \$mainMod CTRL, right, exec, $WINDOW_TOOLS_DIR/window_snap.sh top_right\\
bind = \$mainMod CTRL SHIFT, left, exec, $WINDOW_TOOLS_DIR/window_snap.sh bottom_left\\
bind = \$mainMod CTRL SHIFT, right, exec, $WINDOW_TOOLS_DIR/window_snap.sh bottom_right\\
\\
# Window Snap - Tercios de pantalla\\
bind = \$mainMod ALT, left, exec, $WINDOW_TOOLS_DIR/window_snap.sh third_left\\
bind = \$mainMod ALT, right, exec, $WINDOW_TOOLS_DIR/window_snap.sh third_right\\
\\
# Window Snap - Pantalla completa\\
bind = \$mainMod, Z, exec, $WINDOW_TOOLS_DIR/window_snap.sh full\\
\\
# Mover ventana a coordenadas específicas\\
bind = \$mainMod CTRL SHIFT, K, exec, $WINDOW_TOOLS_DIR/window_move.sh 0 0\\
bind = \$mainMod CTRL SHIFT, J, exec, $WINDOW_TOOLS_DIR/window_move.sh center center\\
\\
# Redimensionar ventana a tamaños predefinidos\\
bind = \$mainMod CTRL, K, exec, $WINDOW_TOOLS_DIR/window_resize.sh half half\\
bind = \$mainMod CTRL, J, exec, $WINDOW_TOOLS_DIR/window_resize.sh full full\\
\\
# Layouts - Guardar y cargar\\
bind = \$mainMod SHIFT, G, exec, $WINDOW_TOOLS_DIR/window_layout.sh save current\\
bind = \$mainMod, G, exec, $WINDOW_TOOLS_DIR/window_layout.sh load current\\
\\
" "$config_file"
            show_success "Keybinds añadidos a la configuración"
        else
            show_info "No se encontró sección de volumen, añadiendo al final"
            cat >> "$config_file" << EOF

# === SISTEMA DE VENTANAS DINÁMICAS ===
# Window Snap (tipo Windows)
bind = \$mainMod SHIFT, left, exec, $WINDOW_TOOLS_DIR/window_snap.sh left
bind = \$mainMod SHIFT, right, exec, $WINDOW_TOOLS_DIR/window_snap.sh right
bind = \$mainMod SHIFT, up, exec, $WINDOW_TOOLS_DIR/window_snap.sh top
bind = \$mainMod SHIFT, down, exec, $WINDOW_TOOLS_DIR/window_snap.sh bottom

# Window Snap - Esquinas (cuartos de pantalla)
bind = \$mainMod CTRL, left, exec, $WINDOW_TOOLS_DIR/window_snap.sh top_left
bind = \$mainMod CTRL, right, exec, $WINDOW_TOOLS_DIR/window_snap.sh top_right
bind = \$mainMod CTRL SHIFT, left, exec, $WINDOW_TOOLS_DIR/window_snap.sh bottom_left
bind = \$mainMod CTRL SHIFT, right, exec, $WINDOW_TOOLS_DIR/window_snap.sh bottom_right

# Window Snap - Tercios de pantalla
bind = \$mainMod ALT, left, exec, $WINDOW_TOOLS_DIR/window_snap.sh third_left
bind = \$mainMod ALT, right, exec, $WINDOW_TOOLS_DIR/window_snap.sh third_right

# Window Snap - Pantalla completa
bind = \$mainMod, Z, exec, $WINDOW_TOOLS_DIR/window_snap.sh full

# Mover ventana a coordenadas específicas
bind = \$mainMod CTRL SHIFT, K, exec, $WINDOW_TOOLS_DIR/window_move.sh 0 0
bind = \$mainMod CTRL SHIFT, J, exec, $WINDOW_TOOLS_DIR/window_move.sh center center

# Redimensionar ventana a tamaños predefinidos
bind = \$mainMod CTRL, K, exec, $WINDOW_TOOLS_DIR/window_resize.sh half half
bind = \$mainMod CTRL, J, exec, $WINDOW_TOOLS_DIR/window_resize.sh full full

# Layouts - Guardar y cargar
bind = \$mainMod SHIFT, G, exec, $WINDOW_TOOLS_DIR/window_layout.sh save current
bind = \$mainMod, G, exec, $WINDOW_TOOLS_DIR/window_layout.sh load current

EOF
            show_success "Keybinds añadidos al final de la configuración"
        fi
    fi
}

# Mostrar resumen
show_summary() {
    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║          Instalación Completada Exitosamente             ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    show_success "Scripts instalados en: $WINDOW_TOOLS_DIR"
    show_success "Configuración actualizada: $CONFIG_DIR/hypr/hyprland.conf"
    echo ""
    show_info "Próximos pasos:"
    echo ""
    echo "  1. Recargar Hyprland:"
    echo -e "     ${YELLOW}hyprctl reload${NC}"
    echo ""
    echo "  2. Probar los atajos de teclado:"
    echo -e "     ${YELLOW}SUPER + SHIFT + ←/→${NC}  - Snap izquierda/derecha"
    echo -e "     ${YELLOW}SUPER + CTRL + ←/→${NC}   - Snap esquinas"
    echo -e "     ${YELLOW}SUPER + Z${NC}            - Pantalla completa"
    echo -e "     ${YELLOW}SUPER + G${NC}            - Cargar layout"
    echo -e "     ${YELLOW}SUPER + SHIFT + G${NC}    - Guardar layout"
    echo ""
    echo "  3. Ver documentación:"
    echo -e "     ${YELLOW}$PROJECT_ROOT/docs/WINDOW_SYSTEM.md${NC}"
    echo ""
    show_info "Para más información, ejecutá:"
    echo -e "     ${YELLOW}$WINDOW_TOOLS_DIR/window_snap.sh --help${NC}"
    echo -e "     ${YELLOW}$WINDOW_TOOLS_DIR/window_move.sh --help${NC}"
    echo -e "     ${YELLOW}$WINDOW_TOOLS_DIR/window_resize.sh --help${NC}"
    echo -e "     ${YELLOW}$WINDOW_TOOLS_DIR/window_layout.sh --help${NC}"
    echo ""
}

# Main
main() {
    echo ""
    
    check_dependencies
    echo ""
    
    create_directories
    echo ""
    
    copy_scripts
    echo ""
    
    backup_config
    echo ""
    
    update_config
    echo ""
    
    show_summary
    
    echo -e "${GREEN}¡Instalación completada!${NC}"
}

# Ejecutar
main "$@"
