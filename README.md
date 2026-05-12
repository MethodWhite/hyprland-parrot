# Hyprland para Parrot Security OS v3.0

> Configuración completa de Hyprland Wayland Compositor optimizada para Parrot Security OS 7.x
> **Versión 3.0.0** — Mayo 2026 — Hyprland v0.54.3

![License](https://img.shields.io/badge/license-MIT-green)
![Parrot OS](https://img.shields.io/badge/Parrot-7.x-blue)
![Hyprland](https://img.shields.io/badge/Hyprland-v0.54.3-cyan)
![Version](https://img.shields.io/badge/version-3.0.0-purple)

## 🚀 Características

- **Hyprland v0.54.3** compilado desde fuente para Parrot OS (build estable)
- **Flag `--latest`** para compilar con v0.55.0+ (experimental)
- **🛡️ Fix EGL Dual-GPU**: Reparación automática para sistemas Intel + NVIDIA
- **Waybar** completamente funcional con estilo S4vitar
- **Tema Synapse-Purple**: Colores neón (verde/cyan/purple)
- **Optimizado** para laptops ASUS TUF y hardware similar
- **Scripts automáticos** de instalación y configuración
- **Teclado en español latinoamericano** (latam)
- **✨ NUEVO: Sistema de Ventanas Dinámicas** - Control tipo Windows con snap, move, resize y layouts

## 📋 Requisitos

- Parrot Security OS 7.x (también funciona en Parrot Home)
- Mínimo 8GB RAM (recomendado 16GB)
- 10GB espacio libre en disco
- Conexión a internet estable
- GPU compatible con Wayland (Intel, AMD, NVIDIA con drivers propietarios)

## 🔧 Instalación Rápida

### ⚠️ IMPORTANTE - Problema de Dependencias en Parrot OS 7.1

El paquete `hyprland` en los repositorios oficiales de Parrot tiene dependencias rotas.
Hay 2 soluciones:

### Opción 1: Instalación de Emergencia (Recomendada)

Este script compila las librerías necesarias y luego instala Hyprland:

```bash
# Clonar el repositorio
git clone https://github.com/TU_USUARIO/hyprland-parrot.git
cd hyprland-parrot

# Dar permisos de ejecución
chmod +x scripts/*.sh

# Ejecutar instalador de emergencia (compila dependencias)
sudo ./scripts/emergency-install.sh

# Reiniciar y seleccionar Hyprland en el login manager
```

### Opción 2: Instalación Completa desde Fuente

```bash
# 1. Instalar dependencias
sudo ./scripts/install-deps.sh

# 2. Compilar Hyprland y componentes (30-60 min)
./scripts/build-hyprland.sh

# 3. Instalar configuraciones
./scripts/install-config.sh

# 4. Reiniciar sesión
```

### Opción 3: Instalación Rápida (si los paquetes funcionan)

```bash
sudo ./scripts/quick-install.sh
```

## 📁 Estructura del Proyecto

```
hyprland-parrot/
├── scripts/
│   ├── install.sh          # Instalador principal
│   ├── install-deps.sh     # Instalación de dependencias
│   ├── build-hyprland.sh   # Compilación de Hyprland (--latest para bleeding edge)
│   ├── emergency-install.sh # Instalador de emergencia (compila todo desde fuente)
│   ├── install-config.sh   # Instalación de configuraciones
│   ├── install-window-tools.sh  # ✨ Instalador sistema de ventanas
│   ├── fix-egl-dualgpu.sh  # 🛡️ Fix EGL para sistemas Intel + NVIDIA
│   └── post-install.sh     # Configuración post-instalación
├── scripts/window_tools/   # ✨ Sistema de Ventanas Dinámicas
│   ├── window_move.sh      # Mover ventanas a (x, y)
│   ├── window_resize.sh    # Redimensionar ventanas
│   ├── window_snap.sh      # Snap tipo Windows
│   ├── window_layout.sh    # Guardar/restaurar layouts
│   └── waybar_window_info.sh # Módulo waybar
├── config/
│   ├── hypr/
│   │   ├── hyprland.conf   # Configuración principal
│   │   └── hyprpaper.conf  # Fondos de pantalla
│   ├── waybar/
│   │   ├── config          # Configuración de Waybar
│   │   └── style.css       # Estilos de Waybar
│   ├── wofi/
│   │   └── style.css       # Estilos del launcher
│   └── kitty/
│       └── kitty.conf      # Configuración de terminal
├── assets/
│   └── wallpapers/         # Fondos de pantalla incluidos
└── docs/
    ├── INSTALL.md          # Guía de instalación detallada
    ├── CONFIG.md           # Guía de configuración
    ├── TROUBLESHOOTING.md  # Solución de problemas
    └── WINDOW_SYSTEM.md    # ✨ Sistema de Ventanas Dinámicas
```

## ⌨️ Atajos de Teclado Principales

| Tecla | Acción |
|-------|--------|
| `SUPER + Enter` | Abrir terminal (kitty) |
| `SUPER + D` | Abrir launcher (wofi) |
| `SUPER + Q` | Cerrar ventana activa |
| `SUPER + E` | Abrir administrador de archivos |
| `SUPER + 1-0` | Cambiar entre workspaces |
| `SUPER + Shift + 1-0` | Mover ventana a workspace |
| `SUPER + V` | Toggle floating/tiling |
| `SUPER + F` | Pantalla completa |
| `SUPER + P` | Pseudo-tiling |
| `Print` | Captura de pantalla (seleccionar área) |
| `SUPER + Shift + S` | Captura y guardar |

## ✨ Sistema de Ventanas Dinámicas

El sistema incluye control preciso de ventanas tipo Windows:

### Window Snap (Ajustar ventanas)

| Atajo | Acción |
|-------|--------|
| `SUPER + Shift + ←/→` | Snap izquierda/derecha (50%) |
| `SUPER + Shift + ↑/↓` | Snap arriba/abajo (50%) |
| `SUPER + Ctrl + ←/→` | Snap esquina superior |
| `SUPER + Ctrl + Shift + ←/→` | Snap esquina inferior |
| `SUPER + Alt + ←/→` | Snap tercio izquierdo/derecho |
| `SUPER + Z` | Pantalla completa |

### Layouts (Guardar/restaurar configuración)

| Atajo | Acción |
|-------|--------|
| `SUPER + Shift + G` | Guardar layout actual |
| `SUPER + G` | Cargar layout guardado |

### Waybar - Módulo Window Snap

La barra incluye un módulo "🋐 Snap" con clicks para:
- **Click izquierdo**: Snap izquierda
- **Click derecho**: Snap derecha  
- **Click medio**: Pantalla completa
- **Scroll arriba/abajo**: Snap arriba/abajo

📖 **Documentación completa**: Ver [`docs/WINDOW_SYSTEM.md`](docs/WINDOW_SYSTEM.md)

## 🎨 Tema

El tema **Synapse-Purple** incluye:

- **Color primario**: Verde neón (`#00ff9f`)
- **Color secundario**: Cyan (`#00d4ff`)
- **Acento**: Purple (`#bb9af7`)
- **Urgencia**: Rojo/Rosa (`#ff2e63`)
- **Fondo**: Negro azulado (`#0D0D16`)

## 🛠️ Solución de Problemas

### Hyprland no inicia

```bash
# Verificar logs
journalctl -b | grep -i hyprland

# Verificar GPU compatible
glxinfo | grep "OpenGL renderer"
```

### Waybar no se muestra

```bash
# Reiniciar waybar
pkill waybar && waybar &

# Verificar errores
waybar --config ~/.config/waybar/config --style ~/.config/waybar/style.css
```

### Pantalla negra

```bash
# Forzar modo compatible
export WLR_NO_HARDWARE_CURSORS=1
export WLR_RENDERER=vulkan
Hyprland
```

## 📚 Documentación Completa

- [Guía de Instalación](docs/INSTALL.md)
- [Configuración](docs/CONFIG.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)

## 🤝 Contribuir

1. Fork el proyecto
2. Crea tu rama (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Distribuido bajo la licencia MIT. Ver `LICENSE` para más información.

## 👤 Autor

**S4vitar Style Configuration**
- Basado en la configuración de S4vitar (Parrot OS)
- Adaptado para Parrot Security OS 7.x

## 🔗 Enlaces

- [Hyprland Wiki](https://wiki.hyprland.org/)
- [Parrot OS](https://www.parrotsec.org/)
- [Waybar GitHub](https://github.com/Alexays/Waybar)

## 💡 Notas

Este proyecto está específicamente optimizado para Parrot Security OS. 
Para otras distribuciones basadas en Debian, puede requerir ajustes adicionales.

---

**Hecho con ❤️ para la comunidad de Parrot OS**
