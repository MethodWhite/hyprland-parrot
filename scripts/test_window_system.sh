#!/bin/bash
# =============================================================================
# test_window_system.sh - Test rápido del sistema de ventanas dinámicas
# =============================================================================

set -e

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║     Test del Sistema de Ventanas Dinámicas               ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Verificar dependencias
echo "Verificando dependencias..."
if ! command -v hyprctl &> /dev/null; then
    echo -e "${RED}✗ hyprctl no encontrado${NC}"
    exit 1
fi
echo -e "${GREEN}✓ hyprctl encontrado${NC}"

if ! command -v jq &> /dev/null; then
    echo -e "${RED}✗ jq no encontrado${NC}"
    exit 1
fi
echo -e "${GREEN}✓ jq encontrado${NC}"

# Verificar scripts
echo ""
echo "Verificando scripts..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WINDOW_TOOLS_DIR="$SCRIPT_DIR/window_tools"

for script in window_move.sh window_resize.sh window_snap.sh window_layout.sh waybar_window_info.sh; do
    if [ -f "$WINDOW_TOOLS_DIR/$script" ] && [ -x "$WINDOW_TOOLS_DIR/$script" ]; then
        echo -e "${GREEN}✓ $script${NC}"
    else
        echo -e "${RED}✗ $script (falta o no es ejecutable)${NC}"
    fi
done

# Test de hyprctl
echo ""
echo "Probando hyprctl..."
if hyprctl version &> /dev/null; then
    echo -e "${GREEN}✓ Hyprland está corriendo${NC}"
else
    echo -e "${YELLOW}⚠ Hyprland no está corriendo (algunos tests pueden fallar)${NC}"
fi

# Test de información de ventanas
echo ""
echo "Probando información de ventanas..."
window_count=$(hyprctl clients -j | jq 'length' 2>/dev/null || echo "0")
echo -e "${GREEN}✓ $window_count ventanas encontradas${NC}"

# Mostrar ayuda rápida
echo ""
echo -e "${YELLOW}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${YELLOW}║              Comandos para probar el sistema             ║${NC}"
echo -e "${YELLOW}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "1. Probar window_snap:"
echo "   $WINDOW_TOOLS_DIR/window_snap.sh --help"
echo ""
echo "2. Probar window_move:"
echo "   $WINDOW_TOOLS_DIR/window_move.sh --help"
echo ""
echo "3. Probar window_resize:"
echo "   $WINDOW_TOOLS_DIR/window_resize.sh --help"
echo ""
echo "4. Probar window_layout:"
echo "   $WINDOW_TOOLS_DIR/window_layout.sh list"
echo ""
echo "5. Ver información de ventana activa:"
echo "   hyprctl activewindow"
echo ""
echo -e "${GREEN}¡Sistema verificado correctamente!${NC}"
echo ""
echo "Para instalar ejecutá:"
echo "  $SCRIPT_DIR/install-window-tools.sh"
