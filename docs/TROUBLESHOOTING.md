# Troubleshooting - Hyprland para Parrot OS

## Problemas de Inicio

### Hyprland no inicia desde el display manager

**Síntoma:** Seleccionas Hyprland en SDDM/GDM pero vuelve al login

**Solución:**

1. Verifica los logs:
```bash
journalctl -b | grep -i hyprland
```

2. Intenta iniciar desde TTY:
```bash
Ctrl+Alt+F3  # Cambiar a TTY
# Login
Hyprland
```

3. Si funciona desde TTY, el problema es el display manager

### Pantalla negra al iniciar

**Síntoma:** Hyprland inicia pero solo se ve pantalla negra

**Soluciones:**

1. **Forzar modo compatible:**
```bash
export WLR_NO_HARDWARE_CURSORS=1
export WLR_RENDERER=vulkan
Hyprland
```

2. **Para NVIDIA:**
```bash
# En /etc/environment agregar:
__GLX_VENDOR_LIBRARY_NAME=nvidia
__GL_GSYNC_ALLOWED=0
```

3. **Verificar GPU compatible:**
```bash
glxinfo | grep "OpenGL renderer"
vulkaninfo | grep "GPU id"
```

### Cursor no se ve

**Solución:**
```bash
# En hyprland.conf agregar:
cursor {
    no_hardware_cursors = true
}
```

## Problemas de Waybar

### Waybar no se muestra

**Síntoma:** Waybar corre pero no se ve

**Soluciones:**

1. **Verificar que corre:**
```bash
pgrep -a waybar
```

2. **Reiniciar con debug:**
```bash
pkill waybar
waybar --config ~/.config/waybar/config --style ~/.config/waybar/style.css
```

3. **Probar capa overlay:**
```bash
# En config de waybar cambiar:
"layer": "overlay"
```

4. **Verificar GTK:**
```bash
# Instalar tema GTK
sudo apt install -y adwaita-qt

# Forzar tema
export GTK_THEME=Adwaita-dark
waybar &
```

### Waybar muestra errores de módulos

**Síntoma:** "Module 'hyprland/workspaces' not found"

**Solución:**
- Asegúrate de estar corriendo Hyprland, no Sway
- Los módulos `hyprland/` solo funcionan en Hyprland
- Para Sway usar `sway/` en su lugar

## Problemas de Audio

### Sin sonido

**Solución:**

1. **Verificar PipeWire:**
```bash
systemctl --user status pipewire
systemctl --user status wireplumber
```

2. **Reiniciar audio:**
```bash
systemctl --user restart pipewire wireplumber
```

3. **Verificar sink:**
```bash
wpctl status
pavucontrol
```

### Micrófono no funciona

**Solución:**
```bash
# Verificar entrada
wpctl status

# Desmutear
wpctl set-mute @DEFAULT_AUDIO_SOURCE@ 0

# Ajustar volumen
wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 0.8
```

## Problemas de Red

### WiFi no conecta

**Solución:**

1. **Verificar NetworkManager:**
```bash
systemctl status NetworkManager
```

2. **Usar nmtui:**
```bash
kitty -e nmtui
```

3. **Reiniciar red:**
```bash
sudo systemctl restart NetworkManager
```

### Bluetooth no funciona

**Solución:**
```bash
# Instalar si no está
sudo apt install -y bluez bluez-tools blueman

# Habilitar servicio
sudo systemctl enable bluetooth
sudo systemctl start bluetooth

# GUI
blueman-applet &
```

## Problemas de Rendimiento

### Hyprland lento/laggy

**Soluciones:**

1. **Reducir animaciones:**
```bash
# En hyprland.conf:
animations {
    enabled = false
}
```

2. **Reducir blur:**
```bash
decoration {
    blur {
        enabled = false
    }
}
```

3. **Forzar VFR:**
```bash
misc {
    vfr = true
}
```

### Alto uso de CPU

**Solución:**
```bash
# Verificar procesos
top -bn1 | head -20

# Desactivar apps en autostart innecesarias
# Editar ~/.config/hypr/hyprland.conf
```

## Problemas de Teclado/Touchpad

### Distribución incorrecta

**Solución:**
```bash
# En hyprland.conf:
input {
    kb_layout = latam  # us, es, fr, de, etc.
}
```

### Touchpad no responde

**Solución:**
```bash
# En hyprland.conf:
input {
    touchpad {
        natural_scroll = true
        tap_to_click = true
        scroll_method = two_finger
    }
}
```

## Problemas con Aplicaciones

### Aplicaciones X11 no funcionan

**Solución:**
```bash
# Instalar XWayland
sudo apt install -y xwayland

# En hyprland.conf:
env = XCURSOR_SIZE,24
```

### Firefox/Chrome se ven mal

**Solución:**
```bash
# Forzar Wayland en Firefox
export MOZ_ENABLE_WAYLAND=1

# En Chrome/Chromium
google-chrome --enable-features=UseOzonePlatform --ozone-platform=wayland
```

### Juegos no funcionan

**Solución:**
```bash
# Instalar Steam con soporte Wayland
sudo apt install -y steam

# Para juegos de Lutris/Heroic
# Usar Wine-GE con soporte Wayland
```

## Errores de Compilación

### Error: "libxxx not found"

**Solución:**
```bash
# Instalar dependencias faltantes
sudo ./scripts/install-deps.sh
```

### Error: "cmake failed"

**Solución:**
```bash
# Limpiar build
cd ~/hyprland-build/[componente]
rm -rf build

# Reintentar
cmake --no-warn-unused-cli -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_INSTALL_PREFIX:STRING=/usr -S . -B ./build
cmake --build build --config Release
```

## Recuperación

### Hyprland completamente roto

**Opción 1: Reinstalar**
```bash
cd ~/hyprland-build
sudo rm -rf *
./scripts/build-hyprland.sh
```

**Opción 2: Volver a Sway**
```bash
# En login manager seleccionar Sway
# o desde TTY:
sway
```

## Comandos Útiles de Debug

```bash
# Ver logs de Hyprland
hyprctl systeminfo

# Ver ventanas abiertas
hyprctl clients

# Ver workspaces
hyprctl workspaces

# Ver configuración actual
hyprctl allbinds

# Recargar configuración
hyprctl reload

# Ver logs en tiempo real
journalctl -f | grep -i hyprland
```

## Obtener Ayuda

1. **Logs completos:**
```bash
journalctl -b > ~/logs.txt
```

2. **Información del sistema:**
```bash
neofetch > ~/system.txt
```

3. **Unir Discord de Hyprland:** https://discord.gg/hyprland

4. **GitHub Issues:** https://github.com/hyprwm/Hyprland/issues
