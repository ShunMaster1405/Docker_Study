# Instructivo: Uso de Scripts de Actividades Prácticas

## Descripción General

Este conjunto de scripts y guías te permite practicar monitoreo de recursos y seguridad en Linux (Ubuntu) mediante la generación de situaciones reales de uso.

## Archivos Incluidos

- **Scripts:**
  - `scripts/generar-actividad-monitoreo.sh` - Genera procesos que consumen CPU, RAM, disco, etc.
  - `scripts/generar-actividad-seguridad.sh` - Crea estructuras de archivos y situaciones para practicar seguridad

- **Guías de Actividades:**
  - `actividades-monitoreo-recursos.md` - Actividades paso a paso para monitoreo
  - `actividades-seguridad-sistema.md` - Actividades paso a paso para seguridad

- **Guías de Referencia:**
  - `guia-monitoreo-recursos.md` - Guía teórica de monitoreo
  - `guia-seguridad-sistema.md` - Guía teórica de seguridad

## Requisitos Previos

### Sistema Operativo
- Ubuntu (o distribución Linux compatible)
- Acceso con permisos de usuario (algunas funciones requieren `sudo`)

### Instalación de Herramientas

**Para Monitoreo:**
```bash
sudo apt-get update
sudo apt-get install -y htop procps sysstat
```

**Para Seguridad:**
```bash
sudo apt-get update
sudo apt-get install -y openssh-server openssh-client fail2ban
```

### Permisos de Ejecución

Los scripts ya deberían tener permisos de ejecución. Si no, ejecuta:

```bash
chmod +x scripts/generar-actividad-monitoreo.sh
chmod +x scripts/generar-actividad-seguridad.sh
```

## Uso Rápido

### Script de Monitoreo

```bash
# Ejecutar el script
./root/scripts/generar-actividad-monitoreo.sh

# El script mostrará un menú interactivo:
# 1. Generar procesos CPU
# 2. Generar procesos RAM
# 3. Crear archivos grandes
# 4. Actividad mixta (recomendado)
# 5. Generar proceso zombie
# 6. Ver procesos activos
# 7. Detener procesos
# 8. Salir y limpiar
```

**Ejemplo de flujo:**
1. Ejecutar el script
2. Seleccionar opción 4 (actividad mixta)
3. Abrir otra terminal
4. Practicar comandos de monitoreo (ver `actividades-monitoreo-recursos.md`)
5. Volver al script y seleccionar opción 7 para detener procesos
6. Seleccionar opción 8 para salir

### Script de Seguridad

```bash
# Ejecutar el script
./root/scripts/generar-actividad-seguridad.sh

# El script mostrará un menú interactivo:
# 1. Crear estructura de permisos
# 2. Crear estructura para chown
# 3. Crear scripts de swap
# 4. Crear estructura SSH keys
# 5. Crear script para fail2ban (cuidado)
# 6. Ver estructura creada
# 7. Limpiar todo
# 8. Salir
```

**Ejemplo de flujo:**
1. Ejecutar el script
2. Seleccionar opción 1 (estructura de permisos)
3. Navegar a `/tmp/seguridad-practica/permisos-practica/`
4. Practicar comandos chmod/chown (ver `actividades-seguridad-sistema.md`)
5. Volver al script y seleccionar opción 7 para limpiar
6. Seleccionar opción 8 para salir

## Flujo de Trabajo Recomendado

### Para Monitoreo

1. **Preparación:**
   ```bash
   # Instalar herramientas
   sudo apt-get install -y htop procps sysstat
   
   # Verificar estado inicial
   free -h
   df -h /
   ```

2. **Ejecutar Script:**
   ```bash
   ./scripts/generar-actividad-monitoreo.sh
   # Seleccionar opción 4 (actividad mixta)
   ```

3. **Abrir Terminal Separada:**
   - Mantén el script corriendo en una terminal
   - Abre otra terminal para ejecutar comandos de monitoreo

4. **Seguir Guía de Actividades:**
   - Abre `actividades-monitoreo-recursos.md`
   - Sigue las actividades en orden
   - Practica los comandos en la segunda terminal

5. **Limpiar:**
   - Volver al script (primera terminal)
   - Opción 7: Detener procesos
   - Opción 8: Salir y limpiar

### Para Seguridad

1. **Preparación:**
   ```bash
   # Instalar herramientas
   sudo apt-get install -y openssh-server openssh-client fail2ban
   ```

2. **Ejecutar Script:**
   ```bash
   ./scripts/generar-actividad-seguridad.sh
   # Seleccionar opción 1 (estructura de permisos)
   ```

3. **Seguir Guía de Actividades:**
   - Abre `actividades-seguridad-sistema.md`
   - Navega a los directorios creados
   - Practica los comandos según la guía

4. **Limpiar:**
   - Volver al script
   - Opción 7: Limpiar todo
   - Opción 8: Salir

## Estructura de Directorios Generados

### Monitoreo
- `/tmp/monitoreo-practica/` - Directorio principal
  - `archivos_grandes/` - Archivos grandes para práctica de disco
  - `procesos.pid` - Archivo con PIDs de procesos generados

### Seguridad
- `/tmp/seguridad-practica/` - Directorio principal
  - `permisos-practica/` - Estructura para practicar chmod
  - `chown-practica/` - Estructura para practicar chown
  - `ssh-keys-practica/` - Scripts y documentación SSH
  - Scripts adicionales (swap, fail2ban)

## Advertencias Importantes

### ⚠️ Script de Monitoreo
- Los procesos generados consumen recursos reales (CPU, RAM, disco)
- Pueden afectar el rendimiento del sistema
- **Siempre detén los procesos** antes de salir (opción 7 u 8)
- No ejecutes en sistemas de producción

### ⚠️ Script de Seguridad
- **fail2ban (opción 5):** Puede bloquear tu propia IP
  - Solo usar en entornos de prueba aislados
  - O ejecutar desde otra máquina
- **Swap de prueba:** Requiere permisos sudo
  - Los cambios de swappiness son temporales por defecto
  - Los archivos de swap de prueba se crean en `/tmp/`
- **SSH keys:** Las claves generadas son reales
  - Eliminar claves de prueba después de practicar
  - No usar en sistemas de producción

### ⚠️ General
- Los scripts crean archivos en `/tmp/`
- Estos archivos pueden ser eliminados al reiniciar
- Siempre limpia los recursos generados después de practicar
- No ejecutar en sistemas de producción sin precaución

## Solución de Problemas

### El script no tiene permisos de ejecución
```bash
chmod +x scripts/generar-actividad-monitoreo.sh
chmod +x scripts/generar-actividad-seguridad.sh
```

### No puedo ver los procesos generados
- Asegúrate de que el script esté corriendo
- Verifica con la opción 6 (ver procesos) del menú
- Usa `ps aux | grep -E "worker|memhog"` en otra terminal

### Los archivos no se crean
- Verifica que `/tmp/` tenga espacio disponible
- Verifica permisos: `ls -ld /tmp/`
- Revisa mensajes de error en el script

### No puedo detener los procesos
- Usa la opción 7 del menú
- Si el script se cerró inesperadamente:
  ```bash
  # Encontrar y matar procesos manualmente
  ps aux | grep -E "worker|memhog" | grep -v grep | awk '{print $2}' | xargs kill 2>/dev/null
  ```

### fail2ban no funciona
- Verifica que SSH esté corriendo: `sudo systemctl status ssh`
- Verifica configuración: `sudo fail2ban-client -t`
- Revisa logs: `sudo tail -f /var/log/fail2ban.log`

## Ejemplos de Uso

### Ejemplo 1: Práctica Rápida de CPU
```bash
# Terminal 1
./scripts/generar-actividad-monitoreo.sh
# Opción 1

# Terminal 2
top
# Presionar 'P' para ordenar por CPU
```

### Ejemplo 2: Práctica de Permisos
```bash
# Terminal 1
./scripts/generar-actividad-seguridad.sh
# Opción 1

# Terminal 2
cd /tmp/seguridad-practica/permisos-practica
ls -lR
# Practicar chmod en los archivos
```

### Ejemplo 3: Monitoreo Completo
```bash
# Terminal 1
./scripts/generar-actividad-monitoreo.sh
# Opción 4 (actividad mixta)

# Terminal 2
# Ejecutar comandos de monitoreo
htop
free -h
df -h /
ps aux --sort=-%cpu | head -10
```

## Siguientes Pasos

1. **Completar todas las actividades:**
   - Seguir `actividades-monitoreo-recursos.md` completo
   - Seguir `actividades-seguridad-sistema.md` completo

2. **Practicar en contenedores Docker:**
   - Los scripts funcionan dentro de contenedores
   - Útil para ambientes aislados

3. **Crear tus propios scripts:**
   - Modificar los scripts existentes
   - Crear nuevas situaciones de práctica
   - Compartir con otros estudiantes

4. **Integrar con herramientas reales:**
   - Configurar monitoreo con Prometheus/Grafana
   - Implementar fail2ban en servidores reales
   - Configurar alertas automatizadas

## Recursos Adicionales

- **Documentación oficial:**
  - Manual de `htop`: `man htop`
  - Manual de `ps`: `man ps`
  - Manual de `chmod`: `man chmod`
  - Manual de `fail2ban`: `man fail2ban-client`

- **Ayuda en línea:**
  ```bash
  # Comandos con --help
   htop --help
   ps --help
   chmod --help
   ```

## Contacto y Soporte

Si encuentras problemas o tienes sugerencias:
1. Revisa la sección de "Solución de Problemas"
2. Consulta las guías teóricas (`guia-*.md`)
3. Verifica los logs del sistema
4. Ejecuta los scripts con más detalle (agregar `set -x` al inicio)

---

¡Buena práctica! 🚀

