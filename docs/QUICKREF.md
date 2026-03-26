# Quick Reference - Comandos Rápidos

## Instalación Rápida

```bash
# Clonar
git clone https://github.com/TU_USUARIO/hyprland-parrot.git
cd hyprland-parrot

# Instalar (como root)
sudo ./scripts/install.sh

# O paso a paso
sudo ./scripts/install-deps.sh      # 1. Dependencias
./scripts/build-hyprland.sh         # 2. Compilar (30-60 min)
./scripts/install-config.sh         # 3. Configurar
```

## Atajos de Teclado Principales

| Tecla | Acción |
|-------|--------|
| `SUPER + Enter` | Terminal (kitty) |
| `SUPER + D` | Launcher (wofi) |
| `SUPER + Q` | Cerrar ventana |
| `SUPER + E` | Dolphin (file manager) |
| `SUPER + V` | Toggle floating |
| `SUPER + F` | Fullscreen |
| `SUPER + 1-0` | Workspaces 1-10 |
| `SUPER + SHIFT + 1-0` | Mover a workspace |
| `SUPER + SHIFT + Q` | Salir de Hyprland |
| `Print` | Screenshot (seleccionar) |
| `XF86AudioRaiseVolume` | Subir volumen |
| `XF86AudioLowerVolume` | Bajar volumen |
| `XF86MonBrightnessUp` | Subir brillo |
| `XF86MonBrightnessDown` | Bajar brillo |

## Comandos Hyprland

```bash
hyprctl systeminfo          # Información del sistema
hyprctl clients             # Ventanas abiertas
hyprctl workspaces          # Workspaces
hyprctl binds               # Keybinds
hyprctl reload              # Recargar config
hyprctl dispatch exec kitty # Ejecutar comando
```

## Comandos Waybar

```bash
pkill waybar                # Matar waybar
waybar &                    # Iniciar waybar
waybar --config ~/.config/waybar/config --style ~/.config/waybar/style.css
```

## Comandos Sistema

```bash
neofetch                    # Info del sistema
htop                        # Monitor de recursos
nmtui                       # Configurar red
pavucontrol                 # Control de audio
brightnessctl set 50%       # Brillo de pantalla
```

## Solución de Problemas

```bash
# Ver logs
journalctl -b | grep -i hyprland

# Iniciar desde TTY
Ctrl+Alt+F3 -> login -> Hyprland

# Forzar modo compatible
export WLR_NO_HARDWARE_CURSORS=1
Hyprland
```

## Colores del Tema

| Color | Hex | Uso |
|-------|-----|-----|
| Verde Neón | `#00ff9f` | Primario |
| Cyan | `#00d4ff` | Secundario |
| Purple | `#bb9af7` | Acento |
| Rosa/Rojo | `#ff2e63` | Urgencia/Error |
| Fondo | `#0D0D16` | Background |

## Archivos de Configuración

```
~/.config/hypr/hyprland.conf    # Config principal
~/.config/waybar/config         # Waybar módulos
~/.config/waybar/style.css      # Waybar estilos
~/.config/wofi/style.css        # Launcher estilo
~/.config/kitty/kitty.conf      # Terminal
```

## Recursos

- Wiki: https://wiki.hyprland.org/
- Discord: https://discord.gg/hyprland
- GitHub: https://github.com/hyprwm/Hyprland
