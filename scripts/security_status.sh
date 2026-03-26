#!/bin/bash
#===============================================================================
# Script de Estado de Seguridad - S4vitar Style
# Muestra información del sistema en tiempo real
#===============================================================================

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Función para mostrar banner
show_banner() {
    echo -e "${CYAN}"
    echo "╔═══════════════════════════════════════════════════════════╗"
    echo "║         PARROT SECURITY OS - HYPRLAND EDITION             ║"
    echo "║                    S4vitar Style                          ║"
    echo "╚═══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Información del sistema
show_system_info() {
    echo -e "${BLUE}[+]${NC} Sistema Operativo:"
    echo -e "    $(grep PRETTY_NAME /etc/os-release | cut -d'"' -f2)"
    echo ""
    
    echo -e "${BLUE}[+]${NC} Kernel:"
    echo -e "    $(uname -r)"
    echo ""
    
    echo -e "${BLUE}[+]${NC} Uptime:"
    echo -e "    $(uptime -p)"
    echo ""
}

# Información de red
show_network_info() {
    echo -e "${BLUE}[+]${NC} Red:"
    
    # IP externa
    external_ip=$(curl -s ifconfig.me 2>/dev/null || echo "No disponible")
    echo -e "    IP Externa: ${CYAN}$external_ip${NC}"
    
    # IP local
    local_ip=$(hostname -I | awk '{print $1}')
    echo -e "    IP Local: ${GREEN}$local_ip${NC}"
    
    # Interfaz principal
    interface=$(ip route | grep default | awk '{print $5}' | head -1)
    echo -e "    Interfaz: ${YELLOW}$interface${NC}"
    echo ""
}

# Información de seguridad
show_security_info() {
    echo -e "${BLUE}[+]${NC} Estado de Seguridad:"
    
    # Firewall
    if command -v ufw &> /dev/null; then
        ufw_status=$(ufw status 2>/dev/null | grep "Status:" | awk '{print $2}')
        if [[ "$ufw_status" == "active" ]]; then
            echo -e "    Firewall: ${GREEN}ACTIVO${NC}"
        else
            echo -e "    Firewall: ${RED}INACTIVO${NC}"
        fi
    else
        echo -e "    Firewall: ${YELLOW}NO INSTALADO${NC}"
    fi
    
    # SSH
    if systemctl is-active --quiet ssh 2>/dev/null; then
        echo -e "    SSH: ${GREEN}ACTIVO${NC}"
    else
        echo -e "    SSH: ${YELLOW}INACTIVO${NC}"
    fi
    
    # Servicios activos
    active_services=$(systemctl list-units --type=service --state=running --no-legend | wc -l)
    echo -e "    Servicios Activos: ${CYAN}$active_services${NC}"
    echo ""
}

# Información de recursos
show_resources() {
    echo -e "${BLUE}[+]${NC} Recursos del Sistema:"
    
    # CPU
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
    echo -e "    CPU: ${YELLOW}${cpu_usage}%${NC}"
    
    # Memoria
    mem_info=$(free -h | grep Mem)
    mem_total=$(echo $mem_info | awk '{print $2}')
    mem_used=$(echo $mem_info | awk '{print $3}')
    mem_percent=$(echo $mem_info | awk '{printf "%.0f", ($3/$2)*100}')
    echo -e "    RAM: ${MAGENTA}$mem_used / $mem_total (${mem_percent}%)${NC}"
    
    # Disco
    disk_info=$(df -h / | tail -1)
    disk_used=$(echo $disk_info | awk '{print $3}')
    disk_total=$(echo $disk_info | awk '{print $2}')
    disk_percent=$(echo $disk_info | awk '{print $5}')
    echo -e "    Disco: ${CYAN}$disk_used / $disk_total (${disk_percent})${NC}"
    echo ""
}

# Información de Hyprland
show_hyprland_info() {
    echo -e "${BLUE}[+]${NC} Hyprland:"
    
    if command -v Hyprland &> /dev/null; then
        version=$(Hyprland --version 2>/dev/null | head -1)
        echo -e "    Versión: ${GREEN}$version${NC}"
    else
        echo -e "    Estado: ${RED}NO INSTALADO${NC}"
    fi
    
    if command -v waybar &> /dev/null; then
        echo -e "    Waybar: ${GREEN}INSTALADO${NC}"
    else
        echo -e "    Waybar: ${YELLOW}NO INSTALADO${NC}"
    fi
    echo ""
}

# Main
main() {
    clear
    show_banner
    show_system_info
    show_network_info
    show_security_info
    show_resources
    show_hyprland_info
    
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  Sistema listo para trabajar                              ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Ejecutar solo si se llama directamente (no como script de autostart)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
