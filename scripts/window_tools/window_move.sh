#!/bin/bash
# =============================================================================
# window_move.sh - Mover ventanas a coordenadas específicas
# Parte del sistema de ventanas dinámicas para Hyprland - Parrot OS
# =============================================================================
#
# Uso:
#   ./window_move.sh <x> <y> [window_regex]
#
# Ejemplos:
#   ./window_move.sh 100 200                    # Mueve ventana activa a (100, 200)
#   ./window_move.sh 0 0 "firefox"              # Mueve Firefox a esquina superior izquierda
#   ./window_move.sh 1920 0 "kitty"             # Mueve kitty al segundo monitor
#
# =============================================================================

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para mostrar ayuda
show_help() {
    cat << EOF
${BLUE}Window Move - Sistema de Ventanas Dinámicas${NC}

${YELLOW}USO:${NC}
    $0 <x> <y> [window_regex]

${YELLOW}ARGUMENTOS:${NC}
    x             Coordenada X (píxeles desde el borde izquierdo)
    y             Coordenada Y (píxeles desde el borde superior)
    window_regex  (Opcional) Regex para identificar la ventana
                  Si no se especifica, usa la ventana activa

${YELLOW}EJEMPLOS:${NC}
    $0 100 200                      # Mueve ventana activa a (100, 200)
    $0 0 0 "firefox"                # Mueve Firefox a (0, 0)
    $0 1920 1080 "kitty"            # Mueve kitty a (1920, 1080)
    $0 center center                # Centra la ventana en el monitor

${YELLOW}POSICIONES ESPECIALES:${NC}
    center center                   # Centrar ventana
    top_left, top_right             # Esquinas superiores
    bottom_left, bottom_right       # Esquinas inferiores
    top_center, bottom_center       # Centros superior/inferior

${YELLOW}SALIDA:${NC}
    Exit code 0: Éxito
    Exit code 1: Error (ventana no encontrada, argumentos inválidos)

EOF
}

# Función para obtener tamaño del monitor actual
get_monitor_size() {
    hyprctl monitors -j | jq -r '.[] | select(.focused == true) | "\(.width) \(.height)"'
}

# Función para obtener tamaño de la ventana
get_window_size() {
    local window_regex="$1"
    hyprctl clients -j | jq -r --arg regex "$window_regex" '
        .[] | select(.title | test($regex)) | 
        select(.focused == true) | 
        "\(.w) \(.h)"
    ' | head -n1
}

# Función para mover ventana
move_window() {
    local x="$1"
    local y="$2"
    local window_regex="$3"
    
    # Obtener información del monitor
    local monitor_info=$(get_monitor_size)
    local monitor_width=$(echo "$monitor_info" | cut -d' ' -f1)
    local monitor_height=$(echo "$monitor_info" | cut -d' ' -f2)
    
    # Manejar posiciones especiales
    case "$x" in
        "center")
            local window_size=$(get_window_size "$window_regex")
            local win_w=$(echo "$window_size" | cut -d' ' -f1)
            x=$(( (monitor_width - win_w) / 2 ))
            ;;
        "top_left")
            x=0
            y=0
            ;;
        "top_right")
            local window_size=$(get_window_size "$window_regex")
            local win_w=$(echo "$window_size" | cut -d' ' -f1)
            x=$((monitor_width - win_w))
            y=0
            ;;
        "bottom_left")
            x=0
            local window_size=$(get_window_size "$window_regex")
            local win_h=$(echo "$window_size" | cut -d' ' -f1)
            y=$((monitor_height - win_h))
            ;;
        "bottom_right")
            local window_size=$(get_window_size "$window_regex")
            local win_w=$(echo "$window_size" | cut -d' ' -f1)
            local win_h=$(echo "$window_size" | cut -d' ' -f2)
            x=$((monitor_width - win_w))
            y=$((monitor_height - win_h))
            ;;
        "top_center")
            local window_size=$(get_window_size "$window_regex")
            local win_w=$(echo "$window_size" | cut -d' ' -f1)
            x=$(( (monitor_width - win_w) / 2 ))
            y=0
            ;;
        "bottom_center")
            local window_size=$(get_window_size "$window_regex")
            local win_w=$(echo "$window_size" | cut -d' ' -f1)
            x=$(( (monitor_width - win_w) / 2 ))
            local win_h=$(echo "$window_size" | cut -d' ' -f2)
            y=$((monitor_height - win_h))
            ;;
    esac
    
    # Construir comando hyprctl
    if [ -z "$window_regex" ]; then
        # Mover ventana activa
        echo -e "${GREEN}Moviendo ventana activa a (${x}, ${y})${NC}"
        hyprctl dispatch moveactive "$x $y"
    else
        # Mover ventana específica
        echo -e "${GREEN}Moviendo ventana '$window_regex' a (${x}, ${y})${NC}"
        hyprctl dispatch movewindow "$x $y,$window_regex"
    fi
    
    return 0
}

# Main
main() {
    # Verificar argumentos
    if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
        show_help
        exit 0
    fi
    
    if [ $# -lt 2 ]; then
        echo -e "${RED}Error: Se requieren al menos 2 argumentos (x, y)${NC}" >&2
        echo -e "${YELLOW}Usa '$0 --help' para más información${NC}" >&2
        exit 1
    fi
    
    local x="$1"
    local y="$2"
    local window_regex="${3:-}"
    
    # Verificar que hyprctl esté disponible
    if ! command -v hyprctl &> /dev/null; then
        echo -e "${RED}Error: hyprctl no encontrado. ¿Está Hyprland instalado?${NC}" >&2
        exit 1
    fi
    
    # Verificar que jq esté disponible
    if ! command -v jq &> /dev/null; then
        echo -e "${RED}Error: jq no encontrado. Instálalo con: sudo apt install jq${NC}" >&2
        exit 1
    fi
    
    # Mover ventana
    move_window "$x" "$y" "$window_regex"
}

main "$@"
