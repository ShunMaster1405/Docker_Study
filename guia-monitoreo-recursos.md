# Guía de Monitoreo de Recursos en Linux (Ubuntu)

## Objetivo

Aprender a revisar y monitorear el uso de disco, RAM, procesos y configurar alertas básicas en un entorno Linux (Ubuntu), especialmente útil en contenedores Docker.

## Herramientas Necesarias

Antes de comenzar, instala las siguientes herramientas:

```bash
# Actualizar repositorios
apt-get update

# Instalar herramientas de monitoreo
apt-get install -y htop procps sysstat

# Verificar instalación
which htop
which ps
free --version
df --version
```

## 1. Revisión de Espacio en Disco

### df – Espacio en disco por filesystem

El comando `df` muestra el espacio disponible y usado en los sistemas de archivos montados.

```bash
# Ver espacio en formato legible (human-readable)
df -h

# Ver espacio sin formato legible
df

# Ver espacio de un filesystem específico
df -h /

# Ver espacio de /var
df -h /var

# Ver solo el sistema de archivos raíz
df -h / | tail -1
```

**Qué hace:**
- Muestra el espacio total, usado y disponible de cada filesystem montado
- `-h` = human readable (muestra en GB, MB, KB)
- `-T` = muestra el tipo de filesystem (ext4, xfs, etc.)

**Qué mirar:**
- `% Use` → si supera 80% es una alerta crítica
- `Available` → espacio realmente disponible
- `Mounted on` → dónde está montado cada filesystem
- Montajes críticos: `/`, `/var`, `/tmp`, `/home`

**Ejemplo de salida:**
```
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda1        20G  8.5G   10G  46% /
tmpfs           2.0G     0  2.0G   0% /dev/shm
```

**En Docker:**
- Normalmente verás overlay o aufs como filesystem
- El disco físico depende del host, pero el consumo dentro del contenedor sí importa
- Usa `docker system df` desde el host para ver uso de imágenes y contenedores

**Comando útil para alertas:**
```bash
# Ver solo filesystems con más del 80% de uso
df -h | awk 'NR>1 && $5+0 > 80 {print "ALERTA: " $6 " al " $5}'
```

### du – Espacio ocupado por directorios

El comando `du` muestra el espacio usado por archivos y directorios.

```bash
# Ver tamaño de cada elemento en el directorio actual
du -sh *

# Ver tamaño de un directorio específico
du -sh /var

# Ver tamaño con detalle de subdirectorios
du -h /var

# Ver solo el total
du -sh /var

# Ver los 10 directorios más grandes
du -h / | sort -hr | head -n 10
```

**Qué hace:**
- Muestra cuánto espacio ocupa cada carpeta y archivo
- `-s` = summary (solo muestra el total)
- `-h` = human readable (GB, MB, KB)
- `-d` = profundidad máxima (ej: `-d 1` para solo un nivel)

**Para buscar los directorios que más espacio ocupan:**
```bash
# Top 10 directorios más grandes desde la raíz
du -h / | sort -hr | head -n 10

# Top 10 directorios más grandes en /var
du -h /var | sort -hr | head -n 10

# Buscar archivos grandes (>100MB)
find / -type f -size +100M -exec ls -lh {} \; 2>/dev/null | awk '{print $5, $9}' | sort -hr
```

**⚠️ Nota:** 
- `du` puede tardar mucho tiempo en contenedores grandes o sistemas con muchos archivos
- Usa `-d` para limitar la profundidad y ahorrar tiempo
- Ejemplo: `du -h -d 2 /var` solo mostrará 2 niveles de profundidad

**Ejemplo práctico:**
```bash
# Ver qué está ocupando espacio en /var/log
du -sh /var/log/* | sort -hr | head -10

# Limpiar logs antiguos (cuidado, solo si es necesario)
# journalctl --vacuum-time=7d  # Eliminar logs de más de 7 días
```

### Ejercicios Prácticos

```bash
# 1. Ver espacio disponible en el sistema
df -h

# 2. Identificar el directorio que más espacio ocupa
du -sh /* 2>/dev/null | sort -hr | head -5

# 3. Encontrar archivos grandes en /tmp
find /tmp -type f -size +50M -exec ls -lh {} \; 2>/dev/null

# 4. Crear un script de alerta de disco
cat > /tmp/check_disk.sh << 'EOF'
#!/bin/bash
THRESHOLD=80
USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ "$USAGE" -gt "$THRESHOLD" ]; then
    echo "ALERTA: Disco al ${USAGE}%"
    exit 1
else
    echo "OK: Disco al ${USAGE}%"
    exit 0
fi
EOF
chmod +x /tmp/check_disk.sh
/tmp/check_disk.sh
```

## 2. Monitoreo de RAM

### free

El comando `free` muestra información sobre el uso de memoria RAM y swap.

```bash
# Ver memoria en formato legible
free -h

# Ver memoria en KB (por defecto)
free

# Ver memoria en MB
free -m

# Ver memoria en GB
free -g

# Actualizar cada 2 segundos
watch -n 2 free -h
```

**Qué mirar:**
- `total` → RAM total instalada
- `used` → RAM realmente usada por procesos
- `free` → RAM libre (puede ser engañosa)
- `available` → RAM disponible para nuevos procesos (esta es la importante)
- `shared` → Memoria compartida
- `buff/cache` → Memoria usada para buffers y caché
- `Swap` → Espacio de intercambio (en Docker suele ser 0 o muy bajo)

**Interpretación:**
- `available` es más confiable que `free` porque Linux usa RAM libre para caché
- Si `available` es bajo, el sistema puede empezar a usar swap
- En Docker, el swap suele estar limitado o deshabilitado

**Ejemplo de salida:**
```
              total        used        free      shared  buff/cache   available
Mem:           2.0G        1.2G        150M         50M        650M        700M
Swap:            0B          0B          0B
```

**Script para verificar RAM:**
```bash
# Ver porcentaje de RAM usado
free | awk '/Mem:/ {printf "RAM: %.1f%% usado\n", ($3/$2)*100}'

# Ver RAM disponible
free -h | awk '/Mem:/ {print "RAM disponible:", $7}'
```

### top

El comando `top` muestra procesos en tiempo real con información de CPU y memoria.

```bash
# Abrir top
top

# Ver procesos de un usuario específico
top -u nombre_usuario

# Actualizar cada 5 segundos
top -d 5
```

**Qué mirar:**
- `%MEM` → porcentaje de RAM usado por cada proceso
- `%CPU` → porcentaje de CPU usado por cada proceso
- `VIRT` → memoria virtual
- `RES` → memoria residente (RAM física usada)
- `SHR` → memoria compartida
- `load average` → carga promedio del sistema (1 min, 5 min, 15 min)

**Teclas útiles dentro de top:**
- `M` → ordenar por uso de memoria (%MEM)
- `P` → ordenar por uso de CPU (%CPU)
- `T` → ordenar por tiempo de CPU
- `k` → matar un proceso (pedirá PID y señal)
- `r` → cambiar prioridad (renice) de un proceso
- `f` → seleccionar campos a mostrar
- `u` → filtrar por usuario
- `q` → salir

**Señales para matar procesos (cuando presionas `k` en top):**

Las **señales** son mensajes que Linux envía a los procesos. Cuando presionas `k` en `top`, te mostrará un menú con números. Las señales más comunes son:

| Número | Nombre | Descripción | Cuándo usar |
|--------|--------|-------------|-------------|
| **15** | SIGTERM | Terminación normal (permite limpieza) | ✅ **Recomendado** - Intenta cerrar el proceso de forma ordenada |
| **9** | SIGKILL | Terminación forzada (no permite limpieza) | ⚠️ Solo si SIGTERM no funciona - Mata el proceso inmediatamente |
| **2** | SIGINT | Interrupción (como presionar Ctrl+C) | Para procesos interactivos |
| **1** | SIGHUP | Recargar configuración | Para recargar configuración de servicios |

**Cómo usar en top:**
1. Presiona `k`
2. Te pedirá el PID (número del proceso)
3. Te mostrará un menú con señales o te pedirá el número de señal
4. Ingresa `15` para SIGTERM (recomendado) o `9` para SIGKILL (forzado)
5. Presiona Enter

**Ejemplo en línea de comandos:**
```bash
# Terminación normal (recomendado)
kill -15 PID
kill PID  # (por defecto usa 15/SIGTERM)

# Terminación forzada (solo si es necesario)
kill -9 PID
kill -KILL PID

# Ver todas las señales disponibles
kill -l
```

**Recomendación:** Siempre intenta primero con la señal **15 (SIGTERM)**, y solo usa **9 (SIGKILL)** si el proceso no responde. SIGTERM permite que el proceso guarde datos y se cierre correctamente, mientras que SIGKILL lo mata inmediatamente sin permitir limpieza.

**Load Average:**
- Ideal: menor que el número de CPUs
- Atención: igual al número de CPUs
- Crítico: mayor que el número de CPUs
- Ver número de CPUs: `nproc` o `lscpu | grep "^CPU(s)"`

### htop (interfaz mejorada)

`htop` es una versión mejorada de `top` con interfaz más amigable.

**Instalar:**
```bash
apt-get update
apt-get install -y htop
```

**Usar:**
```bash
htop
```

**Ventajas sobre top:**
- Interfaz visual más clara
- Colores y barras de progreso
- Árbol de procesos (F5)
- Filtrado fácil (F4)
- Búsqueda (F3)
- Scroll horizontal y vertical
- Facilidad para matar procesos (F9)

**Atajos de teclado en htop:**
- `F1` → ayuda
- `F2` → configuración
- `F3` → buscar proceso
- `F4` → filtrar por texto
- `F5` → vista de árbol
- `F6` → ordenar por columna
- `F7` → disminuir prioridad (nice)
- `F8` → aumentar prioridad (nice)
- `F9` → matar proceso
- `F10` o `q` → salir
- `↑↓` → navegar procesos
- `Space` → marcar proceso

**Ejercicios prácticos:**
```bash
# 1. Ver uso de RAM actual
free -h

# 2. Monitorear RAM en tiempo real
watch -n 1 free -h

# 3. Ver procesos que más RAM consumen
ps aux --sort=-%mem | head -10

# 4. Ver procesos que más CPU consumen
ps aux --sort=-%cpu | head -10

# 5. Usar htop para explorar procesos
htop
```

## 3. Análisis de Procesos

### ps

El comando `ps` muestra información sobre procesos en ejecución.

```bash
# Ver todos los procesos (formato estándar)
ps aux

# Ver procesos del usuario actual
ps ux

# Ver procesos en formato árbol
ps auxf

# Ver procesos de un usuario específico
ps -u nombre_usuario

# Ver procesos con formato personalizado
ps aux -o pid,user,%cpu,%mem,command

# Ver procesos ordenados por memoria
ps aux --sort=-%mem | head -10

# Ver procesos ordenados por CPU
ps aux --sort=-%cpu | head -10
```

**Columnas clave en `ps aux`:**
- `USER` → usuario que ejecuta el proceso
- `PID` → ID del proceso
- `%CPU` → porcentaje de CPU usado
- `%MEM` → porcentaje de memoria usada
- `VSZ` → memoria virtual (KB)
- `RSS` → memoria residente (KB)
- `TTY` → terminal asociado
- `STAT` → estado del proceso (R=running, S=sleeping, Z=zombie, etc.)
- `START` → hora de inicio
- `TIME` → tiempo de CPU acumulado
- `COMMAND` → comando completo

**Buscar procesos específicos:**
```bash
# Buscar proceso por nombre
ps aux | grep nginx

# Buscar proceso por PID
ps -p 1234

# Buscar procesos de un programa
ps aux | grep -i python

# Ver procesos sin el propio grep
ps aux | grep -i python | grep -v grep
```

**Comandos útiles:**
```bash
# Ver número de procesos de un usuario
ps -u nombre_usuario | wc -l

# Ver procesos con uso de CPU
ps aux --sort=-%cpu -o pid,user,%cpu,command | head -10

# Ver procesos con uso de memoria
ps aux --sort=-%mem -o pid,user,%mem,command | head -10

# Ver procesos en ejecución (estado R)
ps aux | awk '$8 ~ /R/ {print}'
```

### pstree – Árbol de procesos

El comando `pstree` muestra los procesos en forma de árbol mostrando las relaciones padre-hijo.

```bash
# Ver árbol de procesos
pstree

# Ver árbol con PIDs
pstree -p

# Ver árbol con información de usuario
pstree -u

# Ver árbol de un proceso específico
pstree -p 1234

# Ver árbol de un usuario
pstree -u nombre_usuario

# Ver árbol completo (todo)
pstree -a
```

**Qué muestra:**
- Relación padre → hijo entre procesos
- Muy útil para entender:
  - Workers y procesos hijos
  - Procesos zombies
  - Forks y procesos duplicados
  - Estructura de servicios

**En Docker:**
- El proceso root suele ser PID 1
- Puedes ver todos los procesos del contenedor con `pstree -p`

**Ejemplo de salida:**
```
systemd(1)─┬─sshd(1234)───sshd(5678)───bash(5679)
           ├─nginx(2345)─┬─nginx(2346)
           │             └─nginx(2347)
           └─docker(3456)
```

### Otros comandos útiles para procesos

```bash
# Ver procesos en tiempo real (similar a top pero solo una ejecución)
ps aux --sort=-%cpu | head -10

# Contar procesos por usuario
ps aux | awk '{print $1}' | sort | uniq -c | sort -rn

# Ver procesos zombies
ps aux | awk '$8 ~ /Z/ {print}'

# Ver procesos que llevan más tiempo ejecutándose
ps aux --sort=-etime | head -10

# Ver procesos que más memoria virtual usan
ps aux --sort=-vsz | head -10

# Ver información detallada de un proceso
ps -fp 1234

# Ver procesos hijos de un proceso
pstree -p 1234
```

## 4. Configuración de Alertas

**⚠️ Importante:** En contenedores Docker NO se suele usar systemd, cron o servicios complejos. Se usan scripts + logs + monitoreo externo (Prometheus, Datadog, CloudWatch, etc.).

### Alerta por uso de disco

**Comando rápido:**
```bash
# Ver filesystems con más del 80% de uso
df -h | awk 'NR>1 && $5+0 > 80 {print "ALERTA: " $6 " al " $5}'
```

**Script básico:**
```bash
#!/bin/bash
# check_disk.sh

THRESHOLD=80
USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')

if [ "$USAGE" -gt "$THRESHOLD" ]; then
    echo "ALERTA: Disco al ${USAGE}% (umbral: ${THRESHOLD}%)"
    exit 1
else
    echo "OK: Disco al ${USAGE}%"
    exit 0
fi
```

**Script avanzado:**
```bash
#!/bin/bash
# check_disk_advanced.sh

THRESHOLD=80
LOG_FILE="/var/log/disk_alerts.log"

# Verificar todos los filesystems
df -h | awk 'NR>1 {gsub(/%/, "", $5); if ($5 > '$THRESHOLD') print $6 " está al " $5 "%"}' | while read alert; do
    echo "$(date '+%Y-%m-%d %H:%M:%S') - ALERTA DISCO: $alert" >> "$LOG_FILE"
    echo "ALERTA: $alert"
done
```

### Alerta por uso de RAM

**Comando rápido:**
```bash
# Verificar si RAM está por encima del 80%
free | awk '/Mem:/ {if (($3/$2)*100 > 80) print "ALERTA RAM ALTA: " ($3/$2)*100 "%"}'
```

**Script básico:**
```bash
#!/bin/bash
# check_ram.sh

THRESHOLD=80
RAM_USAGE=$(free | awk '/Mem:/ {printf "%.0f", ($3/$2)*100}')

if [ "$RAM_USAGE" -gt "$THRESHOLD" ]; then
    echo "ALERTA: RAM al ${RAM_USAGE}% (umbral: ${THRESHOLD}%)"
    exit 1
else
    echo "OK: RAM al ${RAM_USAGE}%"
    exit 0
fi
```

**Script avanzado:**
```bash
#!/bin/bash
# check_ram_advanced.sh

THRESHOLD=80
LOG_FILE="/var/log/ram_alerts.log"

RAM_TOTAL=$(free | awk '/Mem:/ {print $2}')
RAM_USED=$(free | awk '/Mem:/ {print $3}')
RAM_AVAILABLE=$(free | awk '/Mem:/ {print $7}')
RAM_PERCENT=$(free | awk '/Mem:/ {printf "%.1f", ($3/$2)*100}')

if (( $(echo "$RAM_PERCENT > $THRESHOLD" | bc -l) )); then
    MESSAGE="$(date '+%Y-%m-%d %H:%M:%S') - ALERTA RAM: ${RAM_PERCENT}% usado (Total: ${RAM_TOTAL}KB, Disponible: ${RAM_AVAILABLE}KB)"
    echo "$MESSAGE" >> "$LOG_FILE"
    echo "$MESSAGE"
    
    # Opcional: ver top 5 procesos que más RAM usan
    echo "Top 5 procesos que más RAM usan:"
    ps aux --sort=-%mem | head -6 | tail -5
fi
```

### Alerta por procesos zombies

```bash
#!/bin/bash
# check_zombies.sh

ZOMBIES=$(ps aux | awk '$8 ~ /Z/ {count++} END {print count+0}')

if [ "$ZOMBIES" -gt 0 ]; then
    echo "ALERTA: Se encontraron $ZOMBIES procesos zombie"
    ps aux | awk '$8 ~ /Z/ {print}'
    exit 1
else
    echo "OK: No hay procesos zombie"
    exit 0
fi
```

### Logs como mecanismo de alerta

**Escribir a log:**
```bash
# Crear log de alertas
echo "$(date '+%Y-%m-%d %H:%M:%S') - RAM alta: 85%" >> /var/log/resource_alerts.log

# Ver últimas alertas
tail -20 /var/log/resource_alerts.log

# Monitorear log en tiempo real
tail -f /var/log/resource_alerts.log
```

**Script de monitoreo completo:**
```bash
#!/bin/bash
# monitor_resources.sh

LOG_FILE="/var/log/resource_alerts.log"
DISK_THRESHOLD=80
RAM_THRESHOLD=80

# Función para escribir log
log_alert() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Verificar disco
DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -gt "$DISK_THRESHOLD" ]; then
    log_alert "ALERTA DISCO: ${DISK_USAGE}% usado"
fi

# Verificar RAM
RAM_USAGE=$(free | awk '/Mem:/ {printf "%.0f", ($3/$2)*100}')
if [ "$RAM_USAGE" -gt "$RAM_THRESHOLD" ]; then
    log_alert "ALERTA RAM: ${RAM_USAGE}% usado"
fi

# Verificar procesos zombie
ZOMBIES=$(ps aux | awk '$8 ~ /Z/ {count++} END {print count+0}')
if [ "$ZOMBIES" -gt 0 ]; then
    log_alert "ALERTA ZOMBIES: $ZOMBIES procesos zombie encontrados"
fi
```

### Integración con monitoreo externo

**Docker logs:**
```bash
# Ver logs del contenedor
docker logs nombre_contenedor

# Seguir logs en tiempo real
docker logs -f nombre_contenedor

# Ver últimas 100 líneas
docker logs --tail 100 nombre_contenedor
```

**Herramientas de monitoreo:**
- **Prometheus** → métricas y alertas
- **Grafana** → visualización de métricas
- **Datadog** → monitoreo completo
- **CloudWatch** → monitoreo en AWS
- **ELK Stack** → Elasticsearch, Logstash, Kibana para logs

### Ejercicio Práctico: Script de Monitoreo Completo

```bash
# Crear script de monitoreo
cat > /tmp/monitor.sh << 'EOF'
#!/bin/bash

LOG_FILE="/var/log/system_monitor.log"
DISK_THRESHOLD=80
RAM_THRESHOLD=80

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Verificar disco
DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -gt "$DISK_THRESHOLD" ]; then
    log_message "⚠️  ALERTA DISCO: ${DISK_USAGE}% usado (umbral: ${DISK_THRESHOLD}%)"
fi

# Verificar RAM
RAM_USAGE=$(free | awk '/Mem:/ {printf "%.0f", ($3/$2)*100}')
RAM_AVAILABLE=$(free -h | awk '/Mem:/ {print $7}')
if [ "$RAM_USAGE" -gt "$RAM_THRESHOLD" ]; then
    log_message "⚠️  ALERTA RAM: ${RAM_USAGE}% usado, ${RAM_AVAILABLE} disponible"
fi

# Verificar procesos zombie
ZOMBIES=$(ps aux | awk '$8 ~ /Z/ {count++} END {print count+0}')
if [ "$ZOMBIES" -gt 0 ]; then
    log_message "⚠️  ALERTA ZOMBIES: $ZOMBIES procesos zombie"
fi

# Resumen
log_message "✓ Monitoreo completado - Disco: ${DISK_USAGE}%, RAM: ${RAM_USAGE}%"
EOF

chmod +x /tmp/monitor.sh

# Ejecutar
/tmp/monitor.sh

# Ver log
cat /var/log/system_monitor.log
```

## Resumen de Comandos Esenciales

### Disco
```bash
df -h                          # Ver espacio en disco
du -sh *                       # Ver tamaño de directorios
du -h / | sort -hr | head -10  # Top 10 directorios más grandes
```

### RAM
```bash
free -h                        # Ver memoria
watch -n 2 free -h             # Monitorear cada 2 segundos
ps aux --sort=-%mem | head     # Procesos que más RAM usan
```

### Procesos
```bash
ps aux                         # Ver todos los procesos
ps aux --sort=-%cpu | head     # Procesos que más CPU usan
top                            # Procesos en tiempo real
htop                           # Interfaz mejorada
pstree -p                      # Árbol de procesos
```

### Alertas
```bash
df -h | awk '$5+0 > 80 {print}'  # Disco > 80%
free | awk '/Mem:/ {if (($3/$2)*100 > 80) print}'  # RAM > 80%
```

