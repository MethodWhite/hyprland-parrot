# Contribuir a Hyprland para Parrot OS

¡Gracias por tu interés en contribuir! Este documento te guiará sobre cómo ayudar.

## ¿Cómo Puedes Contribuir?

### 1. Reportar Bugs

Si encuentras un bug, por favor crea un issue en GitHub incluyendo:

- Descripción clara del problema
- Pasos para reproducir
- Capturas de pantalla (si aplica)
- Logs de error (`journalctl -b | grep -i hyprland`)
- Información del sistema (`neofetch` o `hyprctl systeminfo`)

### 2. Sugerir Mejoras

Las sugerencias son bienvenidas. Por favor incluye:

- Descripción de la mejora
- Por qué sería útil
- Posibles implementaciones

### 3. Enviar Código

#### Pasos:

1. **Fork** el repositorio
2. **Crea una rama** para tu feature:
   ```bash
   git checkout -b feature/nueva-funcionalidad
   ```

3. **Haz tus cambios** y asegúrate que funcionan

4. **Commit** tus cambios:
   ```bash
   git commit -m "Agregar nueva funcionalidad"
   ```

5. **Push** a tu rama:
   ```bash
   git push origin feature/nueva-funcionalidad
   ```

6. **Abre un Pull Request** en GitHub

### 4. Mejorar Documentación

- Corregir errores ortográficos
- Agregar ejemplos
- Traducir a otros idiomas
- Mejorar guías existentes

### 5. Compartir Configuraciones

- Temas de colores
- Scripts personalizados
- Configuraciones para hardware específico

## Estándares de Código

### Scripts (Bash)

```bash
#!/bin/bash
# Descripción del script

# Usar funciones con nombres descriptivos
mi_funcion() {
    # Comentario explicativo
    comando --opcion valor
}

# Usar colores para output
RED='\033[0;31m'
echo -e "${RED}Error${NC}: Algo salió mal"
```

### Configuraciones

```bash
# Usar comentarios descriptivos
# === SECCIÓN: KEYBINDINGS ===
bind = $mainMod, RETURN, exec, kitty

# Agrupar configuraciones relacionadas
# Focus
bind = $mainMod, left, movefocus, l
bind = $mainMod, right, movefocus, r
```

### CSS (Waybar)

```css
/* === MÓDULO: CLOCK === */
#clock {
    background: #00ff9f;
    color: #000000;
}
```

## Estándares de Commits

Usa [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: agregar nuevo script de backup
fix: corregir error en waybar config
docs: actualizar README.md
style: mejorar formato de hyprland.conf
refactor: optimizar script de instalación
test: agregar tests para script X
chore: actualizar dependencias
```

## Áreas que Necesitan Ayuda

### Prioritarias

- [ ] Testing en diferentes hardware
- [ ] Documentación para principiantes
- [ ] Scripts de automatización
- [ ] Temas adicionales
- [ ] Soporte para más aplicaciones

### Secundarias

- [ ] Traducciones a otros idiomas
- [ ] Wallpapers personalizados
- [ ] Iconos personalizados
- [ ] Scripts de utilidad

## Testing

Antes de enviar un PR, prueba:

1. **Instalación limpia** en VM o sistema de testing
2. **Todas las configuraciones** incluidas
3. **Documentación** paso a paso
4. **Compatibilidad** con Parrot OS 7.x

## Preguntas Frecuentes

### ¿Necesito saber programar?

No necesariamente. Puedes contribuir con:
- Documentación
- Testing
- Reportes de bugs
- Ideas y sugerencias

### ¿Cuánto tiempo toma revisar un PR?

Generalmente 1-7 días dependiendo de la complejidad.

### ¿Puedo enviar múltiples PRs?

¡Sí! Pero preferiblemente uno por feature/fix.

## Reconocimientos

Los contribuidores serán listados en:
- README.md
- CONTRIBUTORS.md (si se crea)
- Release notes

## Contacto

- GitHub Issues: Para bugs y features
- Discord: (si se crea servidor)
- Email: (si se proporciona)

---

**¡Gracias por contribuir a hacer Hyprland más accesible para la comunidad de Parrot OS!**
