#!/bin/bash
# =============================================================================
# window_layout.sh - Guardar y restaurar layouts de ventanas
# Parte del sistema de ventanas dinámicas para Hyprland - Parrot OS
# =============================================================================
#
# Uso:
#   ./window_layout.sh save <layout_name>     # Guardar layout actual
#   ./window_layout.sh load <layout_name>     # Restaurar layout guardado
#   ./window_layout.sh list                   # Listar layouts guardados
#   ./window_layout.sh delete <layout_name>   # Eliminar layout guardado
#
# =============================================================================

set -e

# Directorio para guardar layouts
LAYOUTS_DIR="$HOME/.config/hypr/layouts"

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para mostrar ayuda
show_help() {
    cat << EOF
${BLUE}Window Layout - Sistema de Ventanas Dinámicas${NC}

${YELLOW}USO:${NC}
    $0 <comando> [argumentos]

${YELLOW}COMANDOS:${NC}
    save <layout_name>    Guardar layout actual
    load <layout_name>    Restaurar layout guardado
    list                  Listar layouts guardados
    delete <layout_name>  Eliminar layout guardado
    show <layout_name>    Mostrar contenido de un layout

${YELLOW}EJEMPLOS:${NC}
    $0 save coding        # Guarda el layout actual como "coding"
    $0 load coding        # Restaura el layout "coding"
    $0 list               # Muestra todos los layouts guardados
    $0 delete coding      # Elimina el layout "coding"

${YELLOW}DIRECTORIO:${NC}
    Los layouts se guardan en: $LAYOUTS_DIR

EOF
}

# Función para guardar layout
save_layout() {
    local layout_name="$1"
    local layout_file="$LAYOUTS_DIR/${layout_name}.json"
    
    # Crear directorio si no existe
    mkdir -p "$LAYOUTS_DIR"
    
    echo -e "${BLUE}Guardando layout '$layout_name'...${NC}"
    
    # Obtener información de todas las ventanas
    hyprctl clients -j | jq '{
        timestamp: now,
        monitor_count: (input | .[] | select(.focused == true) | .id),
        windows: [.[] | {
            class: .class,
            title: .title,
            address: .address,
            workspace: .workspace.id,
            monitor: .monitor,
            x: .at[0],
            y: .at[1],
            width: .w,
            height: .h,
            floating: .floating,
            fullscreen: .fullscreen,
            pinned: .pinned
        }]
    }' > "$layout_file"
    
    if [ $? -eq 0 ]; then
        local window_count=$(jq '.windows | length' "$layout_file")
        echo -e "${GREEN}✓ Layout '$layout_name' guardado con $window_count ventanas${NC}"
        echo -e "${YELLOW}  Archivo: $layout_file${NC}"
    else
        echo -e "${RED}✗ Error al guardar layout${NC}"
        exit 1
    fi
}

# Función para cargar layout
load_layout() {
    local layout_name="$1"
    local layout_file="$LAYOUTS_DIR/${layout_name}.json"
    
    # Verificar que el archivo existe
    if [ ! -f "$layout_file" ]; then
        echo -e "${RED}✗ Error: Layout '$layout_name' no encontrado${NC}"
        echo -e "${YELLOW}  Usá '$0 list' para ver layouts disponibles${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}Cargando layout '$layout_name'...${NC}"
    
    # Leer ventanas del layout
    local windows=$(jq -c '.windows[]' "$layout_file")
    local count=0
    local success=0
    
    while IFS= read -r window; do
        count=$((count + 1))
        
        local class=$(echo "$window" | jq -r '.class')
        local title=$(echo "$window" | jq -r '.title')
        local x=$(echo "$window" | jq -r '.x')
        local y=$(echo "$window" | jq -r '.y')
        local width=$(echo "$window" | jq -r '.width')
        local height=$(echo "$window" | jq -r '.height')
        local floating=$(echo "$window" | jq -r '.floating')
        
        echo -e "${YELLOW}  Restaurando: $class - $title${NC}"
        
        # Intentar encontrar la ventana por clase y título
        local window_regex="$class"
        
        # Mover ventana a posición
        hyprctl dispatch movewindow "$x $y,$window_regex" 2>/dev/null || true
        
        # Redimensionar ventana
        hyprctl dispatch resizewindow "$width $height,$window_regex" 2>/dev/null || true
        
        # Si era floating, asegurar que siga siendo floating
        if [ "$floating" == "true" ]; then
            hyprctl dispatch setfloating "$window_regex" 2>/dev/null || true
        fi
        
        success=$((success + 1))
        
        # Pequeña pausa para permitir que las ventanas se muevan
        sleep 0.1
        
    done <<< "$windows"
    
    echo -e "${GREEN}✓ Layout cargado: $success/$count ventanas restauradas${NC}"
}

# Función para listar layouts
list_layouts() {
    echo -e "${BLUE}Layouts guardados:${NC}"
    echo ""
    
    if [ ! -d "$LAYOUTS_DIR" ]; then
        echo -e "${YELLOW}  No hay layouts guardados${NC}"
        return 0
    fi
    
    local count=0
    for layout_file in "$LAYOUTS_DIR"/*.json; do
        if [ -f "$layout_file" ]; then
            count=$((count + 1))
            local layout_name=$(basename "$layout_file" .json)
            local window_count=$(jq '.windows | length' "$layout_file" 2>/dev/null || echo "?")
            local timestamp=$(jq -r '.timestamp | strftime("%Y-%m-%d %H:%M")' "$layout_file" 2>/dev/null || echo "?")
            
            echo -e "${GREEN}  ✓ $layout_name${NC}"
            echo -e "    Ventanas: $window_count | Guardado: $timestamp"
        fi
    done
    
    if [ $count -eq 0 ]; then
        echo -e "${YELLOW}  No hay layouts guardados${NC}"
    fi
    
    echo ""
    echo -e "${BLUE}Total: $count layout(s)${NC}"
}

# Función para eliminar layout
delete_layout() {
    local layout_name="$1"
    local layout_file="$LAYOUTS_DIR/${layout_name}.json"
    
    # Verificar que el archivo existe
    if [ ! -f "$layout_file" ]; then
        echo -e "${RED}✗ Error: Layout '$layout_name' no encontrado${NC}"
        exit 1
    fi
    
    rm "$layout_file"
    echo -e "${GREEN}✓ Layout '$layout_name' eliminado${NC}"
}

# Función para mostrar contenido de layout
show_layout() {
    local layout_name="$1"
    local layout_file="$LAYOUTS_DIR/${layout_name}.json"
    
    # Verificar que el archivo existe
    if [ ! -f "$layout_file" ]; then
        echo -e "${RED}✗ Error: Layout '$layout_name' no encontrado${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}Layout: $layout_name${NC}"
    echo ""
    
    jq -r '.windows[] | "  \(.class) - \(.title)\n    Pos: (\(.x), \(.y)) | Size: \(.width)x\(.height)\n    Workspace: \(.workspace) | Monitor: \(.monitor)\n"' "$layout_file"
}

# Main
main() {
    # Verificar argumentos
    if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
        show_help
        exit 0
    fi
    
    if [ $# -lt 1 ]; then
        echo -e "${RED}Error: Se requiere un comando${NC}" >&2
        echo -e "${YELLOW}Usa '$0 --help' para más información${NC}" >&2
        exit 1
    fi
    
    local command="$1"
    shift
    
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
    
    # Ejecutar comando
    case "$command" in
        "save")
            if [ -z "$1" ]; then
                echo -e "${RED}Error: Se requiere nombre de layout${NC}" >&2
                exit 1
            fi
            save_layout "$1"
            ;;
        "load")
            if [ -z "$1" ]; then
                echo -e "${RED}Error: Se requiere nombre de layout${NC}" >&2
                exit 1
            fi
            load_layout "$1"
            ;;
        "list")
            list_layouts
            ;;
        "delete"|"remove"|"rm")
            if [ -z "$1" ]; then
                echo -e "${RED}Error: Se requiere nombre de layout${NC}" >&2
                exit 1
            fi
            delete_layout "$1"
            ;;
        "show"|"cat"|"view")
            if [ -z "$1" ]; then
                echo -e "${RED}Error: Se requiere nombre de layout${NC}" >&2
                exit 1
            fi
            show_layout "$1"
            ;;
        *)
            echo -e "${RED}Error: Comando desconocido '$command'${NC}" >&2
            echo -e "${YELLOW}Usa '$0 --help' para más información${NC}" >&2
            exit 1
            ;;
    esac
}

main "$@"
