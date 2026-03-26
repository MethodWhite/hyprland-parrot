# Guía de Instalación - Hyprland para Parrot OS

## Requisitos Previos

- **Parrot Security OS 7.x** (también funciona en Parrot Home Edition)
- **Mínimo 8GB RAM** (16GB recomendado para compilación)
- **10GB de espacio libre** en disco
- **Conexión a internet estable**
- **GPU compatible con Wayland** (Intel, AMD, o NVIDIA con drivers propietarios)

## Paso 1: Clonar el Repositorio

```bash
git clone https://github.com/TU_USUARIO/hyprland-parrot.git
cd hyprland-parrot
```

## Paso 2: Preparar el Sistema

### Actualizar el sistema

```bash
sudo apt update && sudo apt upgrade -y
```

### Instalar herramientas básicas (si no están instaladas)

```bash
sudo apt install -y git curl wget
```

## Paso 3: Instalación de Dependencias

### Opción A: Usando el script automático (Recomendada)

```bash
sudo ./scripts/install-deps.sh
```

### Opción B: Manual

```bash
sudo apt install -y \
    build-essential cmake ninja-build meson pkg-config \
    libwayland-dev wayland-protocols libxkbcommon-dev \
    libpixman-1-dev libdrm-dev libgbm-dev \
    libegl-dev libgles2 libglvnd-dev libvulkan-dev \
    libinput-dev libudev-dev libdbus-1-dev libsystemd-dev \
    libpipewire-0.3-dev libpulse-dev \
    libcairo2-dev libpango1.0-dev libgtk-3-dev \
    kitty waybar wofi grim slurp wl-clipboard \
    pavucontrol brightnessctl polkit-kde-agent-1 dunst
```

## Paso 4: Compilar Hyprland

**⚠️ ADVERTENCIA:** Este proceso puede tomar 30-60 minutos dependiendo del hardware.

```bash
./scripts/build-hyprland.sh
```

El script:
1. Clona todos los repositorios necesarios
2. Compila cada componente en el orden correcto
3. Instala los binarios en `/usr`

### Componentes que se compilan:
- hyprcursor
- hyprutils
- hyprgraphics
- hyprlang
- aquamarine
- **Hyprland** (compositor principal)
- hyprpaper (fondos de pantalla)
- hyprlock (pantalla de bloqueo)
- hypridle (gestor de inactividad)
- xdg-desktop-portal-hyprland

## Paso 5: Instalar Configuraciones

```bash
./scripts/install-config.sh
```

Esto copia:
- `hyprland.conf` - Configuración principal
- `hyprpaper.conf` - Fondos de pantalla
- `waybar/config` y `style.css` - Barra de tareas
- `wofi/style.css` - Launcher
- `kitty/kitty.conf` - Terminal
- Scripts de utilidades

## Paso 6: Configurar Display Manager

### Para SDDM (recomendado)

```bash
sudo apt install -y sddm
sudo systemctl enable sddm
sudo systemctl set-default graphical.target
```

### Para GDM

```bash
sudo apt install -y gdm3
sudo systemctl enable gdm3
```

## Paso 7: Reiniciar

```bash
sudo reboot
```

## Paso 8: Iniciar Sesión

1. En la pantalla de login, selecciona **Hyprland** como sesión
2. Ingresa tus credenciales
3. ¡Deberías ver el escritorio de Hyprland!

## Primeros Pasos en Hyprland

### Atajos Esenciales

| Tecla | Acción |
|-------|--------|
| `SUPER + Enter` | Abrir terminal |
| `SUPER + D` | Abrir menú de aplicaciones |
| `SUPER + Q` | Cerrar ventana |
| `SUPER + E` | Abrir administrador de archivos |
| `SUPER + 1-0` | Cambiar de workspace |
| `SUPER + SHIFT + Q` | Salir de Hyprland |

### Verificar que todo funciona

```bash
# Ver versión de Hyprland
Hyprland --version

# Ver logs
journalctl -b | grep -i hyprland

# Ver estado de waybar
pgrep -a waybar
```

## Solución de Problemas Comunes

### Hyprland no inicia

1. Verifica que tu GPU sea compatible con Wayland
2. Para NVIDIA, asegúrate de tener drivers propietarios instalados
3. Intenta iniciar desde TTY: `Ctrl+Alt+F3`, login, luego `Hyprland`

### Pantalla negra

```bash
# Forzar modo compatible
export WLR_NO_HARDWARE_CURSORS=1
Hyprland
```

### Waybar no se muestra

```bash
# Reiniciar waybar
pkill waybar
waybar &

# Ver errores
waybar --config ~/.config/waybar/config --style ~/.config/waybar/style.css
```

### Teclado no funciona correctamente

Edita `~/.config/hypr/hyprland.conf` y cambia:

```
kb_layout = latam  # o tu distribución
```

## Actualización

Para actualizar Hyprland en el futuro:

```bash
cd ~/hyprland-build/Hyprland
git pull
sudo cmake --install build
```

## Recursos Adicionales

- [Wiki oficial de Hyprland](https://wiki.hyprland.org/)
- [Configuraciones de ejemplo](https://github.com/hyprwm/Hyprland/wiki/Useful-Configs)
- [Discord de Hyprland](https://discord.gg/hyprland)

---

**Nota:** Esta configuración está optimizada para Parrot Security OS. Para otras distribuciones puede requerir ajustes.
