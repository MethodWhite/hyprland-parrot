# Sistema de Ventanas Dinámicas para Hyprland - Parrot OS

> Control preciso de ventanas tipo Windows con la potencia de Hyprland Wayland

## 🚀 Características

- **Window Snap**: Ajustar ventanas a zonas de pantalla (mitades, cuartos, tercios)
- **Window Move**: Mover ventanas a coordenadas específicas (x, y)
- **Window Resize**: Redimensionar ventanas a tamaños específicos
- **Window Layout**: Guardar y restaurar layouts de ventanas
- **Atajos de teclado**: Control rápido desde el teclado
- **Scripts CLI**: Automatización desde terminal

## 📁 Estructura

```
scripts/window_tools/
├── window_move.sh      # Mover ventanas a coordenadas (x, y)
├── window_resize.sh    # Redimensionar ventanas (width x height)
├── window_snap.sh      # Snap de ventanas (tipo Windows)
└── window_layout.sh    # Guardar/restaurar layouts
```

## 📦 Instalación

### Opción 1: Script automático

```bash
cd hyprland-parrot
./scripts/install-window-tools.sh
```

### Opción 2: Manual

```bash
# Crear directorio
mkdir -p ~/.config/hypr/scripts/window_tools

# Copiar scripts
cp scripts/window_tools/*.sh ~/.config/hypr/scripts/window_tools/

# Hacer ejecutables
chmod +x ~/.config/hypr/scripts/window_tools/*.sh
```

## ⌨️ Atajos de Teclado

### Window Snap (tipo Windows)

| Atajo | Acción |
|-------|--------|
| `SUPER + SHIFT + ←` | Snap a mitad izquierda |
| `SUPER + SHIFT + →` | Snap a mitad derecha |
| `SUPER + SHIFT + ↑` | Snap a mitad superior |
| `SUPER + SHIFT + ↓` | Snap a mitad inferior |
| `SUPER + CTRL + ←` | Snap a esquina superior izquierda |
| `SUPER + CTRL + →` | Snap a esquina superior derecha |
| `SUPER + CTRL + SHIFT + ←` | Snap a esquina inferior izquierda |
| `SUPER + CTRL + SHIFT + →` | Snap a esquina inferior derecha |
| `SUPER + ALT + ←` | Snap a tercio izquierdo |
| `SUPER + ALT + →` | Snap a tercio derecho |
| `SUPER + Z` | Pantalla completa |

### Mover Ventanas

| Atajo | Acción |
|-------|--------|
| `SUPER + CTRL + SHIFT + K` | Mover a (0, 0) |
| `SUPER + CTRL + SHIFT + J` | Centrar ventana |

### Redimensionar Ventanas

| Atajo | Acción |
|-------|--------|
| `SUPER + CTRL + K` | 50% del tamaño |
| `SUPER + CTRL + J` | Tamaño completo |

### Layouts

| Atajo | Acción |
|-------|--------|
| `SUPER + SHIFT + G` | Guardar layout actual |
| `SUPER + G` | Cargar layout guardado |

## 📖 Uso de Scripts

### window_move.sh

Mover ventanas a coordenadas específicas.

```bash
# Mover ventana activa a (100, 200)
~/.config/hypr/scripts/window_tools/window_move.sh 100 200

# Mover Firefox a esquina superior izquierda
~/.config/hypr/scripts/window_tools/window_move.sh 0 0 "firefox"

# Centrar ventana
~/.config/hypr/scripts/window_tools/window_move.sh center center

# Mover a posiciones predefinidas
~/.config/hypr/scripts/window_tools/window_move.sh top_left
~/.config/hypr/scripts/window_tools/window_move.sh top_right
~/.config/hypr/scripts/window_tools/window_move.sh bottom_left
~/.config/hypr/scripts/window_tools/window_move.sh bottom_right
~/.config/hypr/scripts/window_tools/window_move.sh top_center
~/.config/hypr/scripts/window_tools/window_move.sh bottom_center
```

### window_resize.sh

Redimensionar ventanas a tamaño específico.

```bash
# Redimensionar ventana activa a 800x600
~/.config/hypr/scripts/window_tools/window_resize.sh 800 600

# Redimensionar Firefox a 1920x1080
~/.config/hypr/scripts/window_tools/window_resize.sh 1920 1080 "firefox"

# Usar valores especiales
~/.config/hypr/scripts/window_tools/window_resize.sh half half      # 50%
~/.config/hypr/scripts/window_tools/window_resize.sh third third    # 33%
~/.config/hypr/scripts/window_tools/window_resize.sh quarter quarter # 25%
~/.config/hypr/scripts/window_tools/window_resize.sh full full      # 100%
~/.config/hypr/scripts/window_tools/window_resize.sh golden golden  # Proporción áurea
```

### window_snap.sh

Snap de ventanas tipo Windows (tiling dinámico).

```bash
# Mitades de pantalla
~/.config/hypr/scripts/window_tools/window_snap.sh left
~/.config/hypr/scripts/window_tools/window_snap.sh right
~/.config/hypr/scripts/window_tools/window_snap.sh top
~/.config/hypr/scripts/window_tools/window_snap.sh bottom

# Cuartos de pantalla
~/.config/hypr/scripts/window_tools/window_snap.sh top_left
~/.config/hypr/scripts/window_tools/window_snap.sh top_right
~/.config/hypr/scripts/window_tools/window_snap.sh bottom_left
~/.config/hypr/scripts/window_tools/window_snap.sh bottom_right

# Tercios de pantalla
~/.config/hypr/scripts/window_tools/window_snap.sh third_left
~/.config/hypr/scripts/window_tools/window_snap.sh third_center
~/.config/hypr/scripts/window_tools/window_snap.sh third_right

# Otros
~/.config/hypr/scripts/window_tools/window_snap.sh full
~/.config/hypr/scripts/window_tools/window_snap.sh center
```

### window_layout.sh

Guardar y restaurar layouts de ventanas.

```bash
# Guardar layout actual
~/.config/hypr/scripts/window_tools/window_layout.sh save coding

# Cargar layout guardado
~/.config/hypr/scripts/window_tools/window_layout.sh load coding

# Listar layouts guardados
~/.config/hypr/scripts/window_tools/window_layout.sh list

# Ver contenido de layout
~/.config/hypr/scripts/window_tools/window_layout.sh show coding

# Eliminar layout
~/.config/hypr/scripts/window_tools/window_layout.sh delete coding
```

## 🔧 Configuración Personalizada

### Añadir nuevos atajos

Edita `~/.config/hypr/hyprland.conf`:

```ini
# Ejemplo: Snap a zona personalizada (70% ancho)
bind = $mainMod ALT, P, exec, ~/.config/hypr/scripts/window_tools/window_snap.sh custom

# Ejemplo: Mover a coordenada específica
bind = $mainMod CTRL, M, exec, ~/.config/hypr/scripts/window_tools/window_move.sh 500 300
```

### Crear zonas personalizadas

Podés modificar `window_snap.sh` para añadir zonas personalizadas:

```bash
# En window_snap.sh, añadir caso personalizado
case "$position" in
    "custom_zone")
        x=$mon_x
        y=$mon_y
        width=$((mon_width * 70 / 100))  # 70% ancho
        height=$mon_height
        ;;
esac
```

## 📋 Requisitos

- Hyprland instalado
- `jq` para procesar JSON
- `hyprctl` para comunicarse con Hyprland

### Instalar dependencias

```bash
sudo apt install jq
```

## 🎯 Ejemplos de Uso

### Setup para programación

```bash
# Terminal izquierda (50%)
window_snap.sh left

# Editor derecha (50%)
window_snap.sh right "code"

# Navegador arriba a la derecha (25%)
window_snap.sh top_right "firefox"

# Documentación abajo a la derecha (25%)
window_snap.sh bottom_right "firefox"
```

### Guardar setup

```bash
# Guardar configuración actual
window_layout.sh save programming

# Restaurar cuando quieras
window_layout.sh load programming
```

### Automatización con scripts

```bash
#!/bin/bash
# setup_workspace.sh

# Abrir aplicaciones
kitty &
firefox &
code &

sleep 2

# Organizar ventanas
~/.config/hypr/scripts/window_tools/window_snap.sh left "kitty"
~/.config/hypr/scripts/window_tools/window_snap.sh top_right "firefox"
~/.config/hypr/scripts/window_tools/window_snap.sh bottom_right "code"
```

## 🐛 Troubleshooting

### Los scripts no funcionan

1. Verificar que los scripts sean ejecutables:
```bash
chmod +x ~/.config/hypr/scripts/window_tools/*.sh
```

2. Verificar que `jq` esté instalado:
```bash
which jq
```

3. Verificar que Hyprland esté corriendo:
```bash
hyprctl version
```

### Las ventanas no se mueven

1. Asegurarse de que la ventana no esté en fullscreen
2. Verificar que la ventana no tenga reglas que impidan el movimiento
3. Probar con `togglefloating` primero

### Los atajos no responden

1. Recargar configuración de Hyprland:
```bash
hyprctl reload
```

2. Verificar que no haya conflictos con otros atajos

## 📚 Recursos Adicionales

- [Hyprland Wiki](https://wiki.hyprland.org/)
- [hyprctl Documentation](https://wiki.hyprland.org/Configuring/Using-hyprctl/)
- [Window Rules](https://wiki.hyprland.org/Configuring/Window-Rules/)

## 🤝 Contribuir

1. Fork el proyecto
2. Crea tu rama (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Distribuido bajo la licencia MIT. Ver `LICENSE` para más información.

## 💡 Tips

- Usar `window_layout.sh` para guardar diferentes setups (programación, gaming, diseño)
- Combinar con `hyprctl` para scripts más avanzados
- Personalizar los atajos según tu flujo de trabajo
- Usar layouts para restaurar rápidamente después de suspender

---

**Hecho con ❤️ para la comunidad de Parrot OS**
