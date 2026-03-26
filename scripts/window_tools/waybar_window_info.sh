#!/bin/bash
# =============================================================================
# waybar_window_info.sh - Módulo waybar para información de ventanas
# Muestra información de la ventana activa y acceso rápido a window tools
# =============================================================================

# Obtener información de la ventana activa
get_window_info() {
    local window_info=$(hyprctl activewindow -j 2>/dev/null)
    
    if [ -z "$window_info" ] || [ "$window_info" == "null" ]; then
        echo ""
        return
    fi
    
    local class=$(echo "$window_info" | jq -r '.class // ""')
    local title=$(echo "$window_info" | jq -r '.title // ""')
    local floating=$(echo "$window_info" | jq -r '.floating // false')
    local fullscreen=$(echo "$window_info" | jq -r '.fullscreen // false')
    
    # Icono según estado
    local icon="🪟"
    if [ "$fullscreen" == "true" ]; then
        icon="🖥️"
    elif [ "$floating" == "true" ]; then
        icon="🎈"
    fi
    
    # Truncar título si es muy largo
    if [ ${#title} -gt 30 ]; then
        title="${title:0:27}..."
    fi
    
    # Mostrar información
    if [ -n "$class" ]; then
        echo "$icon $class: $title"
    else
        echo ""
    fi
}

# Main
case "$1" in
    "info")
        get_window_info
        ;;
    "snap_left")
        ~/.config/hypr/scripts/window_tools/window_snap.sh left
        ;;
    "snap_right")
        ~/.config/hypr/scripts/window_tools/window_snap.sh right
        ;;
    "snap_top")
        ~/.config/hypr/scripts/window_tools/window_snap.sh top
        ;;
    "snap_bottom")
        ~/.config/hypr/scripts/window_tools/window_snap.sh bottom
        ;;
    "snap_full")
        ~/.config/hypr/scripts/window_tools/window_snap.sh full
        ;;
    *)
        get_window_info
        ;;
esac
