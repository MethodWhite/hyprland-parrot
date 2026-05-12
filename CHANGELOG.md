# Changelog

## [3.0.0] - 2026-05-12

### 🚀 Actualización Mayor - Hyprland v0.54.3 + Fix Dual-GPU

#### Versiones Actualizadas
- **Hyprland**: v0.45.0 → **v0.54.3** (build `--latest` usa v0.55.0)
- **aquamarine**: v0.7.3 → **v0.10.0**
- **hyprcursor**: v0.1.9 → **v0.1.13**
- **hyprgraphics**: v0.4.0 → **v0.5.0**
- **hyprlang**: v0.6.7 → **v0.6.8**
- **hyprutils**: v0.1.10 → **v0.11.1**
- **hyprpaper**: v1.0.0 → **v0.8.4**
- **hyprlock**: v1.0.0 → **v0.9.5**
- **hypridle**: v0.1.3 → **v0.1.7**
- **xdg-desktop-portal-hyprland**: v1.3.1 → **v1.3.12**

### ✨ Agregado
- **Script `fix-egl-dualgpu.sh`**: Reparación automática de la cadena EGL para sistemas dual-GPU (Intel + NVIDIA)
  - Detecta si `libEGL.so.1` apunta incorrectamente a NVIDIA en vez de Mesa
  - Restaura alternativas de Debian a `mesa-diverted`
  - Verifica permisos del grupo `render`
  - Limpia crash reports viejos de Hyprland
- **Flag `--latest`** en build-hyprland.sh: permite compilar con los tags más recientes de cada componente
- **Integración automática del fix EGL** en post-install de `build-hyprland.sh` y `emergency-install.sh`

### 🔧 Corregido
- **EGL roto en sistemas Intel + NVIDIA**: `libEGL.so.1` apuntaba a NVIDIA causando crashes de Hyprland (`eglInitialize failed`)
- **Crash reports**: 8 crashes documentados en `~/.local/share/hyprland/` causados por el problema EGL
- **Password hardcodeado** en `emergency-install.sh` → reemplazado por sudo normal

### 📦 Nuevas dependencias
- `libre2-dev` (requerido por Hyprland ≥0.52)
- `libudis86-dev` (requerido por Hyprland ≥0.52)
- Se usa `nproc` en vez de `-j4` estático para mejor rendimiento de compilación

### ⚠️ Breaking Changes
- `emergency-install.sh` ya no usa password hardcodeado; requiere sudo interactivo
- Las configuraciones de Hyprland 0.45.0 son forward-compatibles con 0.54.3

---

## [2.0.0] - 2026-03-26

### ✨ Agregado - Sistema de Ventanas Dinámicas

#### Window Snap
- Script `window_snap.sh` para ajustar ventanas a zonas de pantalla
- Soporte para mitades (left, right, top, bottom)
- Soporte para cuartos (top_left, top_right, bottom_left, bottom_right)
- Soporte para tercios (third_left, third_center, third_right)
- Soporte para pantalla completa y centrado
- 11 atajos de teclado para snap rápido

#### Window Move
- Script `window_move.sh` para mover ventanas a coordenadas específicas
- Soporte para coordenadas absolutas (x, y)
- Posiciones predefinidas (center, top_left, top_right, etc.)
- Regex para identificar ventanas específicas
- 2 atajos de teclado para movimiento rápido

#### Window Resize
- Script `window_resize.sh` para redimensionar ventanas
- Tamaño absoluto en píxeles
- Valores porcentuales (half, third, quarter, full)
- Proporción áurea (golden)
- 2 atajos de teclado para redimensionamiento rápido

#### Window Layout
- Script `window_layout.sh` para guardar y restaurar configuraciones
- Formato JSON para almacenamiento
- Guarda posición, tamaño, estado (floating/fullscreen) de cada ventana
- Comandos: save, load, list, delete, show
- 2 atajos de teclado para gestión de layouts

#### Integración con Waybar
- Módulo `custom/window_info` para información de ventana activa
- Módulo `custom/window_snap` para control rápido con mouse
- Click, right-click, middle-click y scroll actions
- Actualización automática cada 2 segundos

#### Scripts de Instalación y Test
- `install-window-tools.sh` - Instalador automático
- `test_window_system.sh` - Script de verificación y test
- Detección automática de dependencias
- Backup de configuración existente

#### Documentación
- `docs/WINDOW_SYSTEM.md` - Guía completa del sistema
- `docs/IMPLEMENTATION_SUMMARY.md` - Resumen técnico de implementación
- `docs/GITHUB_PUBLISHING.md` - Guía para publicar en GitHub
- README.md actualizado con sección del sistema de ventanas

#### Configuración
- `config/hypr/hyprland.conf` - 17 atajos nuevos añadidos
- `config/waybar/config` - 2 módulos custom añadidos

### 🔧 Mejorado
- Estructura del proyecto más clara
- Scripts con ayuda (--help) incluida
- Manejo de errores mejorado
- Colores y output formateado

### 📦 Dependencias
- Requiere `jq` para procesamiento JSON
- Requiere `hyprctl` (incluido con Hyprland)

---

## [1.0.0] - 2026-03-23

### Agregado
- Configuración base de Hyprland para Parrot OS
- Tema Synapse-Purple (verde/cyan/purple)
- Waybar configurado con módulos esenciales
- Kitty como terminal por defecto
- Wofi como launcher
- Hyprpaper para fondos de pantalla
- Scripts de instalación automática
- Documentación básica

### Cambios
- Teclado configurado en español latinoamericano (latam)
- Optimizado para laptops ASUS TUF
- Gaps y bordes personalizados

---

## Versiones Anteriores

No documentadas.

---

## Notas

### Convenciones

- `Agregado` - Nuevas features
- `Cambiado` - Cambios en features existentes
- `Obsoleto` - Features que serán removidas
- `Removido` - Features removidas
- `Corregido` - Corrección de bugs
- `Seguridad` - Parches de seguridad

### Versionado

- **Major** (X.0.0): Cambios incompatibles hacia atrás
- **Minor** (x.X.0): Nuevas features compatibles
- **Patch** (x.x.X): Correcciones y mejoras menores
