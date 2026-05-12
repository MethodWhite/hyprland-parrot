#!/bin/bash
#===============================================================================
# Security Status — Session-aware system info (S4vitar Style)
# Detecta X11 vs Wayland vs TTY y muestra info apropiada.
# Rápido (no bloquea en red), no hace clear, no usa top.
#===============================================================================

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; MAGENTA='\033[0;35m'; NC='\033[0m'

# ── Detectar sesión ──────────────────────────────────────────────
detect_session() {
    if [[ -n "$WAYLAND_DISPLAY" ]]; then
        SESSION_TYPE="Wayland"
        SESSION_WM="${XDG_CURRENT_DESKTOP:-unknown}"
    elif [[ -n "$DISPLAY" ]]; then
        SESSION_TYPE="X11"
        SESSION_WM="${XDG_CURRENT_DESKTOP:-unknown}"
    elif [[ "$TTY" == /dev/tty* ]] && [[ -z "$DISPLAY" ]]; then
        SESSION_TYPE="TTY"
        SESSION_WM="none"
    else
        SESSION_TYPE="unknown"
        SESSION_WM="unknown"
    fi
}

# ── Banner contextual ─────────────────────────────────────────────
show_banner() {
    local edition=""
    case "$SESSION_TYPE" in
        Wayland) edition="WAYLAND · ${SESSION_WM}" ;;
        X11)     edition="X11 · ${SESSION_WM}" ;;
        TTY)     edition="TTY Console" ;;
        *)       edition="Terminal" ;;
    esac

    echo -e "${CYAN}"
    echo "╔═══════════════════════════════════════════════════════════╗"
    printf "║  %-54s ║\n" "PARROT SECURITY OS · ${edition}"
    echo "╚═══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# ── Sistema ───────────────────────────────────────────────────────
show_system_info() {
    local os kernel uptime cpu mem
    os=$(grep PRETTY_NAME /etc/os-release | cut -d'"' -f2)
    kernel=$(uname -r)
    uptime=$(uptime -p 2>/dev/null | sed 's/up //')

    # CPU usage from /proc (instant, no top)
    read -r _ cpu_usage _ < <(grep 'cpu ' /proc/stat)
    read -r _ _ _ _ idle _ < <(grep 'cpu ' /proc/stat)
    local cpu_pct=$(( 100 - (idle * 100 / (cpu_usage + idle)) ))

    # RAM from /proc/meminfo (instant)
    local mem_total_kb mem_avail_kb
    read -r _ mem_total_kb _ < <(grep MemTotal /proc/meminfo)
    read -r _ mem_avail_kb _ < <(grep MemAvailable /proc/meminfo)
    local mem_used_gb=$(( (mem_total_kb - mem_avail_kb) / 1024 / 1024 ))
    local mem_total_gb=$(( mem_total_kb / 1024 / 1024 ))
    local mem_pct=$(( (mem_total_kb - mem_avail_kb) * 100 / mem_total_kb ))

    echo -e "${BLUE}  OS${NC}    ${os}"
    echo -e "${BLUE}  Kernel${NC} ${kernel}"
    echo -e "${BLUE}  Uptime${NC} ${uptime}"
    echo -e "${BLUE}  CPU${NC}    ${YELLOW}${cpu_pct}%${NC}"
    echo -e "${BLUE}  RAM${NC}    ${MAGENTA}${mem_used_gb}G / ${mem_total_gb}G (${mem_pct}%)${NC}"
    echo ""
}

# ── Red (no bloqueante, timeout 1s) ───────────────────────────────
show_network_info() {
    local local_ip interface external_ip
    local_ip=$(hostname -I 2>/dev/null | awk '{print $1}')
    interface=$(ip route 2>/dev/null | grep default | awk '{print $5}' | head -1)
    external_ip=$(timeout 1 curl -s ifconfig.me 2>/dev/null || echo "offline")

    [[ -n "$local_ip" ]] || return 0

    echo -e "${BLUE}  IP Local${NC}    ${GREEN}${local_ip}${NC}"
    echo -e "${BLUE}  IP Externa${NC}   ${CYAN}${external_ip}${NC}"
    echo -e "${BLUE}  Interfaz${NC}     ${YELLOW}${interface}${NC}"
    echo ""
}

# ── Sesión actual ─────────────────────────────────────────────────
show_session_info() {
    echo -e "${BLUE}  Sesión${NC}   ${SESSION_TYPE}"
    echo -e "${BLUE}  Entorno${NC}  ${SESSION_WM}"

    # Hyprland específico
    if command -v Hyprland &>/dev/null; then
        local hv; hv=$(Hyprland --version 2>/dev/null | head -1 | grep -oP 'Hyprland \S+')
        echo -e "${BLUE}  Hyprland${NC} ${GREEN}${hv:-instalado}${NC}"
    fi
    echo ""
}

# ── Seguridad ─────────────────────────────────────────────────────
show_security_info() {
    local ufw_status="N/A" ssh_status="N/A"

    if command -v ufw &>/dev/null; then
        ufw_status=$(ufw status 2>/dev/null | grep "Status:" | awk '{print $2}')
        [[ "$ufw_status" == "active" ]] && ufw_status="${GREEN}ACTIVO${NC}" || ufw_status="${RED}${ufw_status}${NC}"
    fi

    if systemctl is-active --quiet ssh 2>/dev/null; then
        ssh_status="${GREEN}ACTIVO${NC}"
    else
        ssh_status="${YELLOW}inactivo${NC}"
    fi

    echo -e "${BLUE}  Firewall${NC} ${ufw_status}"
    echo -e "${BLUE}  SSH${NC}      ${ssh_status}"
    echo ""
}

# ── Disco ─────────────────────────────────────────────────────────
show_disk_info() {
    local disk_info disk_used disk_total disk_pct
    disk_info=$(df -h / 2>/dev/null | tail -1)
    disk_used=$(echo "$disk_info" | awk '{print $3}')
    disk_total=$(echo "$disk_info" | awk '{print $2}')
    disk_pct=$(echo "$disk_info" | awk '{print $5}')

    echo -e "${BLUE}  Disco /${NC}  ${CYAN}${disk_used} / ${disk_total} (${disk_pct})${NC}"
    echo ""
}

# ── Main ──────────────────────────────────────────────────────────
main() {
    detect_session

    show_banner
    show_system_info
    show_session_info
    show_network_info
    show_security_info
    show_disk_info

    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  Sistema listo                                           ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Solo ejecutar si se llama directamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
