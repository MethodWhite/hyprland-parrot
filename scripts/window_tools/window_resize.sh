#!/bin/bash
# =============================================================================
# window_resize.sh - Redimensionar ventanas a tamaño específico
# Parte del sistema de ventanas dinámicas para Hyprland - Parrot OS
# =============================================================================
#
# Uso:
#   ./window_resize.sh <width> <height> [window_regex]
#
# Ejemplos:
#   ./window_resize.sh 800 600                  # Redimensiona ventana activa a 800x600
#   ./window_resize.sh 1920 1080 "firefox"      # Redimensiona Firefox a pantalla completa
#   ./window_resize.sh half half                # Mitad del monitor
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
${BLUE}Window Resize - Sistema de Ventanas Dinámicas${NC}

${YELLOW}USO:${NC}
    $0 <width> <height> [window_regex]

${YELLOW}ARGUMENTOS:${NC}
    width         Ancho de la ventana (píxeles o valor especial)
    height        Alto de la ventana (píxeles o valor especial)
    window_regex  (Opcional) Regex para identificar la ventana
                  Si no se especifica, usa la ventana activa

${YELLOW}EJEMPLOS:${NC}
    $0 800 600                        # Redimensiona a 800x600
    $0 1920 1080 "firefox"            # Redimensiona Firefox a 1920x1080
    $0 half half                      # Mitad del ancho y alto del monitor
    $0 full full                      # Pantalla completa

${YELLOW}VALORES ESPECIALES:${NC}
    half            50% del tamaño del monitor
    third           33% del tamaño del monitor
    quarter         25% del tamaño del monitor
    full            100% del tamaño del monitor
    max             Tamaño máximo sin cubrir bordes
    golden          Proporción áurea (ancho = alto * 1.618)

${YELLOW}SALIDA:${NC}
    Exit code 0: Éxito
    Exit code 1: Error (ventana no encontrada, argumentos inválidos)

EOF
}

# Función para obtener tamaño del monitor actual
get_monitor_size() {
    hyprctl monitors -j | jq -r '.[] | select(.focused == true) | "\(.width) \(.height)"'
}

# Función para calcular tamaño especial
calculate_size() {
    local value="$1"
    local monitor_dim="$2"
    
    case "$value" in
        "half")
            echo $((monitor_dim / 2))
            ;;
        "third")
            echo $((monitor_dim / 3))
            ;;
        "quarter")
            echo $((monitor_dim / 4))
            ;;
        "full"|"max")
            echo "$monitor_dim"
            ;;
        "golden")
            # Proporción áurea: width = height * 1.618
            if [ "$2" == "width" ]; then
                # Si estamos calculando el ancho, necesitamos el alto primero
                echo "golden_width"
            else
                echo $((monitor_dim))
            fi
            ;;
        *)
            # Asumir que es un número
            echo "$value"
            ;;
    esac
}

# Función para redimensionar ventana
resize_window() {
    local width="$1"
    local height="$2"
    local window_regex="$3"
    
    # Obtener información del monitor
    local monitor_info=$(get_monitor_size)
    local monitor_width=$(echo "$monitor_info" | cut -d' ' -f1)
    local monitor_height=$(echo "$monitor_info" | cut -d' ' -f2)
    
    # Calcular valores especiales para width
    case "$width" in
        "half")
            width=$((monitor_width / 2))
            ;;
        "third")
            width=$((monitor_width / 3))
            ;;
        "quarter")
            width=$((monitor_width / 4))
            ;;
        "full"|"max")
            width=$monitor_width
            ;;
        "golden")
            # Para proporción áurea, calcular basado en height
            if [[ "$height" =~ ^[0-9]+$ ]]; then
                width=$((height * 1618 / 1000))
            else
                width=$((monitor_height * 1618 / 1000))
            fi
            ;;
    esac
    
    # Calcular valores especiales para height
    case "$height" in
        "half")
            height=$((monitor_height / 2))
            ;;
        "third")
            height=$((monitor_height / 3))
            ;;
        "quarter")
            height=$((monitor_height / 4))
            ;;
        "full"|"max")
            height=$monitor_height
            ;;
        "golden")
            # Para proporción áurea, calcular basado en width
            if [[ "$width" =~ ^[0-9]+$ ]]; then
                height=$((width * 1000 / 1618))
            else
                height=$((monitor_width * 1000 / 1618))
            fi
            ;;
    esac
    
    # Construir comando hyprctl
    if [ -z "$window_regex" ]; then
        # Redimensionar ventana activa
        echo -e "${GREEN}Redimensionando ventana activa a ${width}x${height}${NC}"
        hyprctl dispatch resizeactive "$width $height"
    else
        # Redimensionar ventana específica
        echo -e "${GREEN}Redimensionando ventana '$window_regex' a ${width}x${height}${NC}"
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
    
    if [ $# -lt 2 ]; then
        echo -e "${RED}Error: Se requieren al menos 2 argumentos (width, height)${NC}" >&2
        echo -e "${YELLOW}Usa '$0 --help' para más información${NC}" >&2
        exit 1
    fi
    
    local width="$1"
    local height="$2"
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
    
    # Redimensionar ventana
    resize_window "$width" "$height" "$window_regex"
}

main "$@"
