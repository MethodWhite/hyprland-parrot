#!/bin/bash
#===============================================================================
# Fix EGL + Dual-GPU (Intel/NVIDIA) para Hyprland en Parrot OS
# 
# Problema: En sistemas dual-GPU (Intel iGPU + NVIDIA dGPU), la cadena
# de alternativas de Debian puede dejar libEGL.so.1 apuntando a NVIDIA
# en vez de a Mesa. Hyprland renderiza con la GPU conectada al display
# (normalmente la Intel), por lo que necesita EGL via Mesa, no NVIDIA.
#
# Síntomas:
#   - Hyprland crashea al iniciar (eglInitialize failed)
#   - glxinfo muestra llvmpipe (software rendering)
#   - Crash reports en ~/.local/share/hyprland/
#
# Este fix es seguro y reversible: solo ajusta symlinks de alternativas.
#===============================================================================
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info()  { echo -e "${BLUE}[INFO]${NC} $1"; }
log_ok()    { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "Este script debe ejecutarse como root (sudo $0)"
        exit 1
    fi
}

# Detectar si hay dual-GPU Intel + NVIDIA
detect_dual_gpu() {
    local has_intel=0
    local has_nvidia=0

    lspci | grep -qi "VGA.*Intel" && has_intel=1
    lspci | grep -qi "VGA.*NVIDIA" && has_nvidia=1

    if [[ $has_intel -eq 1 && $has_nvidia -eq 1 ]]; then
        log_info "Dual-GPU Intel + NVIDIA detectado"
        return 0
    elif [[ $has_nvidia -eq 1 ]]; then
        log_warn "Solo NVIDIA detectado - usa el driver propietario directamente"
        return 1
    else
        log_info "Solo Intel detectado - no debería necesitar este fix"
        return 1
    fi
}

# Verificar si EGL está roto
check_egl_broken() {
    log_info "Verificando estado actual de EGL..."

    local egl_target
    egl_target=$(readlink -f /usr/lib/x86_64-linux-gnu/libEGL.so.1 2>/dev/null || echo "no-encontrado")

    echo "  libEGL.so.1 -> $egl_target"

    if echo "$egl_target" | grep -qi "nvidia"; then
        log_warn "EGL apunta a NVIDIA - ESTO ESTÁ ROTO PARA HYPRLAND"
        return 0
    elif echo "$egl_target" | grep -qi "mesa"; then
        log_ok "EGL apunta a Mesa - correcto"
        return 1
    else
        log_warn "EGL no apunta a una ubicación reconocible"
        return 0
    fi
}

# Reparar cadena EGL
fix_egl_chain() {
    log_info "Reparando cadena EGL (NVIDIA -> Mesa)..."

    local ALTERNATIVES_LINK="/etc/alternatives/glx--libEGL.so.1-x86_64-linux-gnu"
    local EGL_SO="/usr/lib/x86_64-linux-gnu/libEGL.so.1"

    # 1. Eliminar symlink roto que apunta directo a NVIDIA
    #    update-alternatives no puede sobreescribir un symlink manual previo
    rm -f "$EGL_SO"

    # 2. Recrear via alternatives (auto detecta la mejor opción)
    update-alternatives --auto glx 2>/dev/null || true
    ldconfig

    # 3. Si alternatives no recreó, forzamos manualmente
    if [[ ! -L "$EGL_SO" ]]; then
        ln -sf "$ALTERNATIVES_LINK" "$EGL_SO"
    fi

    log_ok "Cadena EGL reparada"
}

# Deshabilitar backend GBM de NVIDIA (interfiere con Mesa/Intel)
disable_nvidia_gbm() {
    local nvidia_gbm="/usr/lib/x86_64-linux-gnu/gbm/nvidia-drm_gbm.so"
    
    if [[ -f "$nvidia_gbm" ]]; then
        log_warn "Backend NVIDIA GBM detectado - interfiere con Mesa/Intel GBM"
        mv "$nvidia_gbm" "${nvidia_gbm}.disabled"
        log_ok "nvidia-drm_gbm.so deshabilitado (respaldo: .disabled)"
        log_info "Si necesitás NVIDIA para CUDA/compute, no se ve afectado"
        log_info "Solo GBM (usado por Wayland/Hyprland) usará Mesa/Intel"
    fi
}

# Verificar reparación
verify_fix() {
    log_info "Verificando reparación..."

    local new_target
    new_target=$(readlink -f /usr/lib/x86_64-linux-gnu/libEGL.so.1)

    echo "  libEGL.so.1 -> $new_target"

    if echo "$new_target" | grep -qi "nvidia"; then
        log_error "El fix NO se aplicó correctamente"
        return 1
    fi

    # Probar EGL surfaceless (la plataforma más básica)
    if EGL_PLATFORM=surfaceless eglinfo 2>&1 | grep -q "eglInitialize failed"; then
        log_error "EGL sigue fallando incluso después del fix"
        echo ""
        log_info "Posibles causas adicionales:"
        echo "  1. Falta libgl1-mesa-dri: apt install libgl1-mesa-dri"
        echo "  2. Permisos de /dev/dri: el usuario debe estar en grupo 'render'"
        echo "  3. NVIDIA GBM conflict: intentá con __EGL_VENDOR_LIBRARY_FILENAMES=/usr/share/glvnd/egl_vendor.d/50_mesa.json"
        return 1
    fi

    log_ok "EGL funciona correctamente"
    return 0
}

# Mostrar estado del grupo render
check_render_group() {
    if id -nG "$SUDO_USER" 2>/dev/null | grep -qw "render"; then
        log_ok "Usuario $SUDO_USER está en el grupo render"
    else
        log_warn "Usuario no está en grupo render. Ejecutar:"
        echo "  sudo usermod -aG render $SUDO_USER"
        echo "  (requiere cerrar sesión para que surta efecto)"
    fi
}

# Limpiar crash reports viejos
cleanup_crashes() {
    local crash_dir="$HOME/.local/share/hyprland"
    if [[ -d "$crash_dir" ]] && [[ -n "$SUDO_USER" ]]; then
        local user_home
        user_home=$(eval echo "~$SUDO_USER")
        crash_dir="$user_home/.local/share/hyprland"
        if [[ -d "$crash_dir" ]]; then
            local count
            count=$(ls "$crash_dir"/hyprlandCrashReport*.txt 2>/dev/null | wc -l)
            if [[ $count -gt 0 ]]; then
                log_info "Se encontraron $count crash reports viejos en $crash_dir"
                read -p "  ¿Eliminarlos? (s/N): " resp
                if [[ "$resp" =~ ^[Ss]$ ]]; then
                    rm -f "$crash_dir"/hyprlandCrashReport*.txt
                    log_ok "$count crash reports eliminados"
                fi
            fi
        fi
    fi
}

# Main
main() {
    echo -e "${CYAN}"
    echo "╔═══════════════════════════════════════════════════════════╗"
    echo "║  Hyprland EGL Fix - Dual GPU (Intel + NVIDIA)             ║"
    echo "║  Parte del proyecto hyprland-parrot                      ║"
    echo "╚═══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"

    check_root

    if ! detect_dual_gpu; then
        # Si no es dual-GPU, ofrecemos verificar igual
        if ! check_egl_broken; then
            log_ok "EGL parece estar bien configurado"
            exit 0
        fi
    fi

    check_egl_broken
    fix_egl_chain
    disable_nvidia_gbm
    verify_fix
    check_render_group
    cleanup_crashes

    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  Fix completado. Hyprland ahora debería iniciar.          ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
}

main "$@"
