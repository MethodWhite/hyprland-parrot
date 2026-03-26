# Guía de Configuración - Hyprland para Parrot OS

## Estructura de Archivos

```
~/.config/
├── hypr/
│   ├── hyprland.conf      # Configuración principal
│   ├── hyprpaper.conf     # Fondos de pantalla
│   └── scripts/
│       └── security_status.sh
├── waybar/
│   ├── config             # Configuración de módulos
│   └── style.css          # Estilos CSS
├── wofi/
│   └── style.css          # Estilo del launcher
└── kitty/
    └── kitty.conf         # Configuración de terminal
```

## Personalización de Hyprland

### Cambiar tecla modificadora

En `~/.config/hypr/hyprland.conf`:

```bash
# Cambiar de SUPER (Windows) a ALT
$mainMod = ALT

# O usar CTRL
$mainMod = CTRL
```

### Cambiar distribución de teclado

```bash
input {
    kb_layout = us         # Inglés
    kb_layout = es         # Español
    kb_layout = latam      # Latinoamericano
    kb_layout = fr         # Francés
    kb_layout = de         # Alemán
}
```

### Ajustar gaps y bordes

```bash
general {
    gaps_in = 5            # Gap entre ventanas
    gaps_out = 10          # Gap con bordes de pantalla
    border_size = 2        # Grosor del borde
}
```

### Cambiar colores del tema

```bash
general {
    # Borde activo (gradiente)
    col.active_border = rgb(ff2e63) rgb(00ff9f) 90deg
    
    # Borde inactivo
    col.inactive_border = rgba(58, 58, 92, 170)
}
```

### Configurar múltiples monitores

```bash
# Formato: monitor=NOMBRE,RESOLUCION@REFRESH,X,Y,ESCALA
monitor=DP-1,2560x1440@144,0x0,1
monitor=eDP-1,1920x1080@60,2560x0,1

# O usar nombres de salida
monitor=HDMI-A-1,1920x1080@60,0x0,1
monitor=DP-1,1920x1080@144,1920x0,1
```

### Desactivar animaciones (mejorar rendimiento)

```bash
animations {
    enabled = false
}

decoration {
    drop_shadow = false
    blur {
        enabled = false
    }
}
```

## Personalización de Waybar

### Cambiar módulos

En `~/.config/waybar/config`, editar `modules-left`, `modules-center`, `modules-right`:

```json
{
    "modules-left": ["hyprland/workspaces", "hyprland/window"],
    "modules-center": [],
    "modules-right": ["pulseaudio", "network", "clock"]
}
```

### Cambiar formato del reloj

```json
"clock": {
    "format": "📅 {d}/{m} 🕐 {H:%M}",
    "tooltip": true
}
```

### Agregar módulo personalizado

```json
"custom/weather": {
    "format": "🌤️ {}",
    "exec": "curl -s wttr.in?format=1",
    "interval": 600,
    "tooltip": false
}
```

### Cambiar colores

En `~/.config/waybar/style.css`:

```css
#clock {
    background: #00ff9f;
    color: #000000;
}

#workspaces button.active {
    background: #ff2e63;
    color: #ffffff;
}
```

## Personalización de Kitty

### Cambiar tamaño de fuente

En `~/.config/kitty/kitty.conf`:

```bash
font_size 14.0
```

### Cambiar tema de colores

```bash
# Usar tema predefinido
include catppuccin-mocha.conf

# O colores personalizados
foreground #ffffff
background #000000
```

### Configurar splits

```bash
# Nuevo split horizontal
map ctrl+shift+h launch --location=hsplit

# Nuevo split vertical
map ctrl+shift+v launch --location=vsplit
```

## Scripts Personalizados

### Agregar script de autostart

En `~/.config/hypr/hyprland.conf`:

```bash
# Ejecutar al inicio
exec-once = nombre-del-app

# Con delay
exec-once = sleep 3 && comando

# Script personalizado
exec-once = ~/.config/hypr/scripts/mi_script.sh
```

### Crear script de captura

`~/.config/hypr/scripts/screenshot.sh`:

```bash
#!/bin/bash
grim -g "$(slurp)" ~/Pictures/screenshot-$(date +%Y%m%d-%H%M%S).png
notify-send "Captura guardada"
```

### Script de bloqueo

`~/.config/hypr/scripts/lock.sh`:

```bash
#!/bin/bash
hyprlock
```

## Atajos Personalizados

### Agregar nuevo keybinding

En `~/.config/hypr/hyprland.conf`:

```bash
# Abrir navegador
bind = $mainMod, B, exec, firefox

# Captura de pantalla
bind = $mainMod SHIFT, P, exec, grim ~/screenshot.png

# Mover ventana específica
bind = $mainMod CTRL, T, movetoworkspace, 1, title:(kitty)

# Ejecutar script
bind = $mainMod, X, exec, ~/.config/hypr/scripts/mi_script.sh
```

### Atajos para ventanas flotantes

```bash
# Hacer ventana flotante
bind = $mainMod, V, togglefloating,

# Centrar ventana flotante
bind = $mainMod SHIFT, C, centerwindow

# Redimensionar ventana
bindm = $mainMod ALT, mouse:273, resizewindow
```

## Reglas para Aplicaciones

### Forzar ventana flotante

```bash
# Por clase
windowrule = float, class:org.gnome.Calculator

# Por título
windowrule = float, title:(Floating)

# Tamaño específico
windowrule = float 800 600, class:pavucontrol
```

### Forzar tamaño/posición

```bash
# Tamaño fijo
windowrule = size 1200 800, class:firefox

# Posición fija
windowrule = move 100 100, class:kitty

# Opacidad
windowrule = opacity 0.9, class:.*
```

## Variables de Entorno

### Configurar en hyprland.conf

```bash
# Variables para aplicaciones
env = XDG_SESSION_TYPE,wayland
env = XDG_CURRENT_DESKTOP,Hyprland
env = GDK_BACKEND,wayland
env = QT_QPA_PLATFORM,wayland
env = MOZ_ENABLE_WAYLAND,1
env = _JAVA_AWT_WM_NONREPARENTING,1
```

## Temas e Iconos

### Instalar temas GTK

```bash
sudo apt install -y \
    adwaita-qt \
    papirus-icon-theme \
    arc-theme
```

### Configurar tema

Crear `~/.config/gtk-3.0/settings.ini`:

```ini
[Settings]
gtk-theme-name=Arc-Dark
gtk-icon-theme-name=Papirus-Dark
gtk-font-name=Noto Sans 11
```

## Plugins y Extensiones

### Hyprland plugins

Los plugins se instalan en `~/.config/hypr/plugins/`:

```bash
# Ejemplo: plugin de borders
git clone https://github.com/hyprwm/hyprland-plugins
cd hyprland-plugins
make all
sudo make install
```

### Scripts de comunidad

- [Hyprland-dotfiles](https://github.com/prasanthrangan/hyprdots)
- [S4vitar-dotfiles](https://github.com/S4vitar/dotfiles)

## Backup de Configuración

### Crear backup

```bash
tar -czf hyprland-backup-$(date +%Y%m%d).tar.gz ~/.config/hypr
```

### Restaurar backup

```bash
tar -xzf hyprland-backup-YYYYMMDD.tar.gz -C ~/
```

## Comandos Útiles

```bash
# Recargar configuración
hyprctl reload

# Ver información del sistema
hyprctl systeminfo

# Ver clientes abiertos
hyprctl clients

# Ver workspaces
hyprctl workspaces

# Ver keybinds
hyprctl binds

# Cambiar wallpaper
hyprctl hyprpaper reload

# Mover ventana a workspace
hyprctl dispatch movetoworkspace 1

# Enfocar ventana
hyprctl dispatch focuswindow class:kitty
```
