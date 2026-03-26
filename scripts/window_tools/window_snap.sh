#!/bin/bash
# =============================================================================
# window_snap.sh - Snap de ventanas tipo Windows (tiling dinámico)
# Parte del sistema de ventanas dinámicas para Hyprland - Parrot OS
# =============================================================================
#
# Uso:
#   ./window_snap.sh <posición> [window_regex]
#
# Posiciones disponibles:
#   left, right, top, bottom        - Mitad de pantalla
#   top_left, top_right             - Cuarto de pantalla
#   bottom_left, bottom_right       - Cuarto de pantalla
#   full                            - Pantalla completa
#   center                          - Centrar ventana
#   third_left, third_right         - Tercio de pantalla
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
${BLUE}Window Snap - Sistema de Ventanas Dinámicas${NC}

${YELLOW}USO:${NC}
    $0 <posición> [window_regex]

${YELLOW}POSICIONES:${NC}
    left            Mitad izquierda de pantalla
    right           Mitad derecha de pantalla
    top             Mitad superior de pantalla
    bottom          Mitad inferior de pantalla
    
    top_left        Cuarto superior izquierdo
    top_right       Cuarto superior derecho
    bottom_left     Cuarto inferior izquierdo
    bottom_right    Cuarto inferior derecho
    
    third_left      Tercio izquierdo
    third_center    Tercio central
    third_right     Tercio derecho
    
    full            Pantalla completa
    center          Centrar ventana
    
    maximize        Maximizar (sin cubrir barra de tareas)
    
${YELLOW}EJEMPLOS:${NC}
    $0 left                       # Snap ventana activa a izquierda
    $0 top_right "firefox"        # Snap Firefox a esquina superior derecha
    $0 full "kitty"               # Pantalla completa para kitty
    $0 third_left                 # Tercio izquierdo

${YELLOW}ATALLOS SUGERIDOS (en hyprland.conf):${NC}
    bind = SUPER, Left, exec, $0 left
    bind = SUPER, Right, exec, $0 right
    bind = SUPER, Up, exec, $0 top
    bind = SUPER, Down, exec, $0 bottom
    bind = SUPER SHIFT, Left, exec, $0 top_left
    bind = SUPER SHIFT, Right, exec, $0 top_right
    bind = SUPER SHIFT, Down, exec, $0 bottom_left

EOF
}

# Función para obtener información del monitor
get_monitor_info() {
    hyprctl monitors -j | jq -r '.[] | select(.focused == true) | "\(.x) \(.y) \(.width) \(.height) \(.scale)"'
}

# Función para obtener tamaño de ventana
get_window_size() {
    local window_regex="$1"
    if [ -z "$window_regex" ]; then
        hyprctl clients -j | jq -r '.[] | select(.focused == true) | "\(.w) \(.h)"' | head -n1
    else
        hyprctl clients -j | jq -r --arg regex "$window_regex" '.[] | select(.class | test($regex)) | "\(.w) \(.h)"' | head -n1
    fi
}

# Función para hacer snap de ventana
snap_window() {
    local position="$1"
    local window_regex="$2"
    
    # Obtener información del monitor
    local monitor_info=$(get_monitor_info)
    local mon_x=$(echo "$monitor_info" | cut -d' ' -f1)
    local mon_y=$(echo "$monitor_info" | cut -d' ' -f2)
    local mon_width=$(echo "$monitor_info" | cut -d' ' -f3)
    local mon_height=$(echo "$monitor_info" | cut -d' ' -f4)
    local scale=$(echo "$monitor_info" | cut -d' ' -f5)
    
    # Calcular posición y tamaño según la posición solicitada
    local x y width height
    
    case "$position" in
        "left")
            x=$mon_x
            y=$mon_y
            width=$((mon_width / 2))
            height=$mon_height
            ;;
        "right")
            x=$((mon_x + mon_width / 2))
            y=$mon_y
            width=$((mon_width / 2))
            height=$mon_height
            ;;
        "top")
            x=$mon_x
            y=$mon_y
            width=$mon_width
            height=$((mon_height / 2))
            ;;
        "bottom")
            x=$mon_x
            y=$((mon_y + mon_height / 2))
            width=$mon_width
            height=$((mon_height / 2))
            ;;
        "top_left"|"top-left")
            x=$mon_x
            y=$mon_y
            width=$((mon_width / 2))
            height=$((mon_height / 2))
            ;;
        "top_right"|"top-right")
            x=$((mon_x + mon_width / 2))
            y=$mon_y
            width=$((mon_width / 2))
            height=$((mon_height / 2))
            ;;
        "bottom_left"|"bottom-left")
            x=$mon_x
            y=$((mon_y + mon_height / 2))
            width=$((mon_width / 2))
            height=$((mon_height / 2))
            ;;
        "bottom_right"|"bottom-right")
            x=$((mon_x + mon_width / 2))
            y=$((mon_y + mon_height / 2))
            width=$((mon_width / 2))
            height=$((mon_height / 2))
            ;;
        "third_left"|"third-left")
            x=$mon_x
            y=$mon_y
            width=$((mon_width / 3))
            height=$mon_height
            ;;
        "third_center"|"third-center")
            x=$((mon_x + mon_width / 3))
            y=$mon_y
            width=$((mon_width / 3))
            height=$mon_height
            ;;
        "third_right"|"third-right")
            x=$((mon_x + mon_width * 2 / 3))
            y=$mon_y
            width=$((mon_width / 3))
            height=$mon_height
            ;;
        "full"|"maximize")
            x=$mon_x
            y=$mon_y
            width=$mon_width
            height=$mon_height
            ;;
        "center")
            local win_size=$(get_window_size "$window_regex")
            local win_w=$(echo "$win_size" | cut -d' ' -f1)
            local win_h=$(echo "$win_size" | cut -d' ' -f2)
            x=$((mon_x + (mon_width - win_w) / 2))
            y=$((mon_y + (mon_height - win_h) / 2))
            width=$win_w
            height=$win_h
            ;;
        *)
            echo -e "${RED}Error: Posición '$position' no reconocida${NC}" >&2
            echo -e "${YELLOW}Usa '$0 --help' para ver posiciones disponibles${NC}" >&2
            exit 1
            ;;
    esac
    
    # Construir comando hyprctl
    if [ -z "$window_regex" ]; then
        echo -e "${GREEN}Snap ventana activa a: $position${NC}"
        echo -e "${YELLOW}  Posición: ($x, $y)${NC}"
        echo -e "${YELLOW}  Tamaño: ${width}x${height}${NC}"
        
        # Mover y redimensionar
        hyprctl dispatch moveactive "$x $y"
        hyprctl dispatch resizeactive "$width $height"
    else
        echo -e "${GREEN}Snap ventana '$window_regex' a: $position${NC}"
        echo -e "${YELLOW}  Posición: ($x, $y)${NC}"
        echo -e "${YELLOW}  Tamaño: ${width}x${height}${NC}"
        
        # Mover y redimensionar
        hyprctl dispatch movewindow "$x $y,$window_regex"
        hyprctl dispatch resizewindow "$width $height,$window_regex"
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
    
    if [ $# -lt 1 ]; then
        echo -e "${RED}Error: Se requiere una posición${NC}" >&2
        echo -e "${YELLOW}Usa '$0 --help' para más información${NC}" >&2
        exit 1
    fi
    
    local position="$1"
    local window_regex="${2:-}"
    
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
    
    # Hacer snap de ventana
    snap_window "$position" "$window_regex"
}

main "$@"
