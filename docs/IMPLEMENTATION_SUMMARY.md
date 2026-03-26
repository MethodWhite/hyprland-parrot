# Sistema de Ventanas Dinámicas - Resumen de Implementación

## 📋 Visión General

Este documento resume la implementación del sistema de ventanas dinámicas para Hyprland en Parrot OS, permitiendo control preciso de ventanas similar a Windows pero con la potencia de Hyprland Wayland Compositor.

## 🎯 Objetivos Cumplidos

✅ **Window Snap**: Ajustar ventanas a zonas de pantalla (mitades, cuartos, tercios)
✅ **Window Move**: Mover ventanas a coordenadas específicas (x, y)
✅ **Window Resize**: Redimensionar ventanas a tamaños específicos
✅ **Window Layout**: Guardar y restaurar layouts de ventanas
✅ **Atajos de teclado**: Control rápido desde el teclado
✅ **Integración con Waybar**: Módulo para información y control
✅ **Scripts CLI**: Automatización desde terminal
✅ **Documentación completa**: Guías de uso e instalación

## 📁 Archivos Creados

### Scripts Principales

1. **`scripts/window_tools/window_move.sh`**
   - Mueve ventanas a coordenadas específicas
   - Soporta posiciones predefinidas (center, top_left, etc.)
   - Uso: `window_move.sh <x> <y> [window_regex]`

2. **`scripts/window_tools/window_resize.sh`**
   - Redimensiona ventanas a tamaño específico
   - Soporta valores especiales (half, full, golden, etc.)
   - Uso: `window_resize.sh <width> <height> [window_regex]`

3. **`scripts/window_tools/window_snap.sh`**
   - Snap de ventanas tipo Windows
   - Soporta múltiples zonas (left, right, top_left, third_left, etc.)
   - Uso: `window_snap.sh <position> [window_regex]`

4. **`scripts/window_tools/window_layout.sh`**
   - Guarda y restaura layouts de ventanas
   - Almacena configuración en JSON
   - Uso: `window_layout.sh <save|load|list|delete> [layout_name]`

5. **`scripts/window_tools/waybar_window_info.sh`**
   - Módulo para waybar
   - Muestra información de ventana activa
   - Proporciona acceso rápido a funciones

### Scripts de Instalación

6. **`scripts/install-window-tools.sh`**
   - Instalador automático del sistema
   - Copia scripts, actualiza configuración
   - Crea backups de configuración existente

### Configuración

7. **`config/hypr/hyprland.conf`** (actualizado)
   - Añadidos +15 atajos de teclado nuevos
   - Sección: "SISTEMA DE VENTANAS DINÁMICAS"

8. **`config/waybar/config`** (actualizado)
   - Añadidos módulos: custom/window_info, custom/window_snap
   - Integración con clicks y scroll

### Documentación

9. **`docs/WINDOW_SYSTEM.md`**
   - Guía completa del sistema
   - Ejemplos de uso
   - Referencia de comandos
   - Troubleshooting

10. **`README.md`** (actualizado)
    - Sección nueva: "Sistema de Ventanas Dinámicas"
    - Tablas de atajos actualizadas
    - Estructura del proyecto actualizada

## ⌨️ Atajos de Teclado Implementados

### Window Snap (11 atajos)
- `SUPER + SHIFT + ←/→/↑/↓` - Mitades de pantalla
- `SUPER + CTRL + ←/→` - Esquinas superiores
- `SUPER + CTRL + SHIFT + ←/→` - Esquinas inferiores
- `SUPER + ALT + ←/→` - Tercios laterales
- `SUPER + Z` - Pantalla completa

### Control Directo (4 atajos)
- `SUPER + CTRL + SHIFT + K` - Mover a (0, 0)
- `SUPER + CTRL + SHIFT + J` - Centrar ventana
- `SUPER + CTRL + K` - Redimensionar a 50%
- `SUPER + CTRL + J` - Redimensionar a 100%

### Layouts (2 atajos)
- `SUPER + SHIFT + G` - Guardar layout actual
- `SUPER + G` - Cargar layout guardado

**Total: 17 atajos nuevos**

## 🎨 Características Técnicas

### Window Move
- Coordenadas absolutas y relativas
- Posiciones predefinidas (center, top_left, etc.)
- Soporte para regex de ventanas
- Cálculo automático basado en monitor

### Window Resize
- Tamaño absoluto en píxeles
- Valores porcentuales (half, third, quarter)
- Proporción áurea (golden)
- Tamaño completo (full)

### Window Snap
- Mitades: left, right, top, bottom
- Cuartos: top_left, top_right, bottom_left, bottom_right
- Tercios: third_left, third_center, third_right
- Completo: full
- Centrado: center

### Window Layout
- Formato JSON para almacenamiento
- Guarda: clase, título, posición, tamaño, estado (floating/fullscreen)
- Restauración automática de múltiples ventanas
- Listado y visualización de layouts

## 🔧 Integración con Waybar

### Módulo Window Info
- Muestra información de ventana activa
- Icono según estado (fullscreen, floating)
- Click: Ver layouts guardados
- Right-click: Guardar layout actual
- Middle-click: Centrar ventana

### Módulo Window Snap
- Botón "🋐 Snap" accesible
- Click izquierdo: Snap izquierda
- Click derecho: Snap derecha
- Click medio: Pantalla completa
- Scroll arriba/abajo: Snap arriba/abajo

## 📦 Dependencias

- `hyprctl` - Comunicación con Hyprland
- `jq` - Procesamiento de JSON
- `bash` - Ejecución de scripts

## 🚀 Instalación

### Automática
```bash
./scripts/install-window-tools.sh
```

### Manual
```bash
# Copiar scripts
mkdir -p ~/.config/hypr/scripts/window_tools
cp scripts/window_tools/*.sh ~/.config/hypr/scripts/window_tools/
chmod +x ~/.config/hypr/scripts/window_tools/*.sh

# Recargar Hyprland
hyprctl reload
```

## 📊 Estadísticas

- **Scripts creados**: 6
- **Atajos de teclado**: 17
- **Líneas de código bash**: ~900
- **Líneas de documentación**: ~500
- **Archivos modificados**: 3
- **Archivos creados**: 7

## 🎯 Casos de Uso

### Programación
```bash
# Terminal izquierda (50%)
window_snap.sh left

# Editor derecha (50%)
window_snap.sh right "code"

# Guardar layout
window_layout.sh save programming
```

### Navegación
```bash
# Navegador arriba derecha (25%)
window_snap.sh top_right "firefox"

# Documentación abajo derecha (25%)
window_snap.sh bottom_right "kitty"
```

### Automatización
```bash
#!/bin/bash
# setup_workspace.sh
kitty & firefox & code &
sleep 2
window_snap.sh left "kitty"
window_snap.sh top_right "firefox"
window_snap.sh bottom_right "code"
```

## 🔄 Flujo de Trabajo Sugerido

1. **Instalar** el sistema con el instalador automático
2. **Personalizar** atajos según preferencias
3. **Configurar** layouts para diferentes actividades
4. **Usar** waybar para acceso rápido
5. **Automatizar** con scripts personalizados

## 📈 Mejoras Futuras

- [ ] Animaciones personalizadas para snap
- [ ] Integración con menú contextual
- [ ] Soporte para múltiples monitores mejorado
- [ ] Layouts predefinidos (programación, gaming, diseño)
- [ ] GUI para gestión de layouts
- [ ] Plugin nativo de Hyprland

## 🐛 Problemas Conocidos

- Ventanas X11 pueden requerir tratamiento especial
- Algunas aplicaciones no respetan redimensionamiento
- Animaciones pueden interferir con movimiento rápido

## 📚 Recursos

- [Hyprland Wiki - hyprctl](https://wiki.hyprland.org/Configuring/Using-hyprctl/)
- [Hyprland Wiki - Window Rules](https://wiki.hyprland.org/Configuring/Window-Rules/)
- [Documentación completa](docs/WINDOW_SYSTEM.md)

## ✅ Testing

Probado en:
- Parrot Security OS 7.x
- Hyprland latest (desde fuente)
- Waybar 0.9.x
- Múltiples configuraciones de monitor

## 📄 Licencia

MIT - Mismo que el proyecto principal

---

**Implementación completada**: 2026-03-26
**Estado**: ✅ Funcional y documentado
**Próximos pasos**: Publicar en GitHub
