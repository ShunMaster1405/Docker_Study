# Actividades Prácticas: Monitoreo de Recursos en Linux

## Objetivo

Practicar los comandos de monitoreo usando el script generador de actividad para crear situaciones reales de uso de recursos.

## Prerequisitos

```bash
# Instalar herramientas necesarias
sudo apt-get update
sudo apt-get install -y htop procps sysstat

# Dar permisos de ejecución al script
chmod +x scripts/generar-actividad-monitoreo.sh
```

## Actividad 1: Monitoreo de CPU

### Objetivo
Identificar procesos que consumen CPU usando `top`, `htop` y `ps`.

### Pasos

1. **Ejecutar el script generador de actividad:**
   ```bash
   ./scripts/generar-actividad-monitoreo.sh
   ```

2. **Seleccionar opción 1** (Generar procesos que consumen CPU)

3. **En otra terminal**, usar los siguientes comandos:

   ```bash
   # Ver procesos ordenados por CPU
   ps aux --sort=-%cpu | head -10
   
   # Abrir top y ordenar por CPU (presiona 'P')
   top
   
   # Usar htop (más visual)
   htop
   
   # Ver solo procesos con alto uso de CPU (>30%)
   ps aux | awk '$3 > 30 {print $2, $3, $11}'
   ```

4. **Ejercicios:**
   - Identifica los 3 procesos con mayor uso de CPU
   - Anota los PIDs de los procesos generados
   - Usa `top` para ordenar por CPU (tecla `P`)
   - En `htop`, usa `F6` para cambiar el orden de clasificación

5. **Verificar load average:**
   ```bash
   # Ver load average
   uptime
   
   # Ver número de CPUs
   nproc
   
   # Comparar load average con número de CPUs
   echo "CPUs: $(nproc)"
   echo "Load: $(uptime | awk -F'load average:' '{print $2}')"
   ```

## Actividad 2: Monitoreo de RAM

### Objetivo
Monitorear el uso de memoria RAM y identificar procesos que más memoria consumen.

### Pasos

1. **Ejecutar el script:**
   ```bash
   ./scripts/generar-actividad-monitoreo.sh
   ```

2. **Seleccionar opción 2** (Generar procesos que consumen RAM)

3. **Monitorear RAM:**

   ```bash
   # Ver uso de RAM
   free -h
   
   # Monitorear cada 2 segundos
   watch -n 2 free -h
   
   # Ver porcentaje de RAM usado
   free | awk '/Mem:/ {printf "RAM: %.1f%% usado (%.1f%% disponible)\n", ($3/$2)*100, ($7/$2)*100}'
   
   # Ver procesos que más RAM usan
   ps aux --sort=-%mem | head -10
   
   # Ver procesos ordenados por memoria residente (RSS)
   ps aux --sort=-rss | head -10
   ```

4. **Ejercicios:**
   - Anota la cantidad de RAM total, usada y disponible
   - Identifica los procesos generados en la lista
   - Calcula el porcentaje de RAM usado
   - Verifica la memoria disponible (más confiable que "free")

5. **En htop:**
   - Presiona `F6` y selecciona `PERCENT_MEM`
   - Observa la barra de memoria en la parte superior
   - Identifica procesos en verde (memoria usada) y azul (buffers)

## Actividad 3: Monitoreo de Disco

### Objetivo
Identificar el uso de espacio en disco y encontrar archivos/directorios que más espacio ocupan.

### Pasos

1. **Ejecutar el script:**
   ```bash
   ./scripts/generar-actividad-monitoreo.sh
   ```

2. **Seleccionar opción 3** (Crear archivos grandes en disco)

3. **Monitorear espacio en disco:**

   ```bash
   # Ver espacio disponible
   df -h
   
   # Ver espacio del filesystem raíz
   df -h /
   
   # Ver espacio en /tmp (donde se crean los archivos)
   df -h /tmp
   
   # Ver tamaño de los archivos creados
   du -sh /tmp/monitoreo-practica/archivos_grandes/*
   
   # Ver los 10 directorios más grandes desde /tmp
   du -h /tmp/monitoreo-practica | sort -hr | head -10
   
   # Buscar archivos grandes (>10MB)
   find /tmp/monitoreo-practica -type f -size +10M -exec ls -lh {} \;
   ```

4. **Ejercicios:**
   - Anota el espacio total, usado y disponible antes y después
   - Calcula cuánto espacio ocupan los archivos generados
   - Identifica el archivo más grande
   - Verifica el porcentaje de uso del disco

5. **Crear alerta de disco:**
   ```bash
   # Script de alerta básico
   THRESHOLD=80
   USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
   if [ "$USAGE" -gt "$THRESHOLD" ]; then
       echo "ALERTA: Disco al ${USAGE}%"
   else
       echo "OK: Disco al ${USAGE}%"
   fi
   ```

## Actividad 4: Monitoreo Completo (Actividad Mixta)

### Objetivo
Practicar monitoreo completo del sistema con CPU, RAM y disco simultáneamente.

### Pasos

1. **Ejecutar el script:**
   ```bash
   ./scripts/generar-actividad-monitoreo.sh
   ```

2. **Seleccionar opción 4** (Generar actividad mixta)

3. **Monitoreo completo:**

   ```bash
   # Resumen rápido
   echo "=== CPU ==="
   ps aux --sort=-%cpu | head -5
   
   echo -e "\n=== RAM ==="
   free -h
   
   echo -e "\n=== DISCO ==="
   df -h /
   
   # Usar htop para monitoreo visual completo
   htop
   ```

4. **Crear script de monitoreo:**

   ```bash
   # Crear script de monitoreo completo
   cat > /tmp/monitor_completo.sh << 'EOF'
   #!/bin/bash
   
   echo "=== RESUMEN DE RECURSOS ==="
   echo ""
   
   echo "CPU - Top 5 procesos:"
   ps aux --sort=-%cpu | head -6 | tail -5 | awk '{printf "  PID: %-6s CPU: %5s%% %s\n", $2, $3, $11}'
   
   echo ""
   echo "RAM:"
   free -h | grep Mem | awk '{printf "  Total: %s  Usado: %s  Disponible: %s\n", $2, $3, $7}'
   
   echo ""
   echo "DISCO:"
   df -h / | tail -1 | awk '{printf "  Total: %s  Usado: %s  Disponible: %s  Uso: %s\n", $2, $3, $4, $5}'
   
   echo ""
   echo "Load Average:"
   uptime | awk -F'load average:' '{print "  " $2}'
   EOF
   
   chmod +x /tmp/monitor_completo.sh
   /tmp/monitor_completo.sh
   ```

5. **Ejercicios:**
   - Ejecuta el script de monitoreo cada 10 segundos
   - Identifica qué recursos están más utilizados
   - Verifica si el load average es mayor al número de CPUs
   - Crea alertas para cada recurso

## Actividad 5: Análisis de Procesos con ps y pstree

### Objetivo
Entender la jerarquía de procesos y relaciones padre-hijo.

### Pasos

1. **Ejecutar procesos del script** (cualquier opción)

2. **Analizar procesos:**

   ```bash
   # Ver todos los procesos
   ps aux
   
   # Ver procesos en formato árbol
   ps auxf
   
   # Ver árbol de procesos con PIDs
   pstree -p
   
   # Ver árbol con información de usuario
   pstree -u
   
   # Ver árbol completo con argumentos
   pstree -a
   ```

3. **Identificar procesos específicos:**

   ```bash
   # Buscar procesos generados por el script
   ps aux | grep -E "monitoreo|worker|memhog"
   
   # Ver procesos de un usuario específico
   ps -u $USER
   
   # Contar procesos por usuario
   ps aux | awk '{print $1}' | sort | uniq -c | sort -rn
   ```

4. **Ejercicios:**
   - Identifica el proceso padre de los procesos generados
   - Crea un árbol visual de los procesos
   - Identifica procesos zombie (si los hay)
   - Anota los PIDs principales

## Actividad 6: Procesos Zombie (Avanzado)

### Objetivo
Identificar y entender procesos zombie.

### Pasos

1. **Ejecutar el script:**
   ```bash
   ./scripts/generar-actividad-monitoreo.sh
   ```

2. **Seleccionar opción 5** (Generar proceso zombie)

3. **Identificar zombies:**

   ```bash
   # Ver procesos zombie
   ps aux | awk '$8 ~ /Z/ {print}'
   
   # Contar zombies
   ps aux | awk '$8 ~ /Z/ {count++} END {print count+0 " procesos zombie"}'
   
   # Ver árbol de procesos (los zombies aparecen como <defunct>)
   pstree -p
   ```

4. **Ejercicios:**
   - Identifica si hay procesos zombie
   - Anota el PID del proceso zombie y su proceso padre
   - Investiga por qué se creó el zombie
   - Documenta cómo se resolvería el problema

## Actividad 7: Crear Scripts de Alertas

### Objetivo
Crear scripts de monitoreo y alertas automatizadas.

### Pasos

1. **Script de alerta de disco:**

   ```bash
   cat > /tmp/alerta_disco.sh << 'EOF'
   #!/bin/bash
   THRESHOLD=80
   LOG_FILE="/tmp/alertas_disco.log"
   
   DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
   
   if [ "$DISK_USAGE" -gt "$THRESHOLD" ]; then
       echo "$(date '+%Y-%m-%d %H:%M:%S') - ALERTA: Disco al ${DISK_USAGE}%" | tee -a "$LOG_FILE"
       exit 1
   else
       echo "$(date '+%Y-%m-%d %H:%M:%S') - OK: Disco al ${DISK_USAGE}%"
       exit 0
   fi
   EOF
   
   chmod +x /tmp/alerta_disco.sh
   /tmp/alerta_disco.sh
   ```

2. **Script de alerta de RAM:**

   ```bash
   cat > /tmp/alerta_ram.sh << 'EOF'
   #!/bin/bash
   THRESHOLD=80
   LOG_FILE="/tmp/alertas_ram.log"
   
   RAM_USAGE=$(free | awk '/Mem:/ {printf "%.0f", ($3/$2)*100}')
   RAM_AVAILABLE=$(free -h | awk '/Mem:/ {print $7}')
   
   if [ "$RAM_USAGE" -gt "$THRESHOLD" ]; then
       MESSAGE="$(date '+%Y-%m-%d %H:%M:%S') - ALERTA: RAM al ${RAM_USAGE}% (${RAM_AVAILABLE} disponible)"
       echo "$MESSAGE" | tee -a "$LOG_FILE"
       
       echo "Top 5 procesos que más RAM usan:"
       ps aux --sort=-%mem | head -6 | tail -5
       exit 1
   else
       echo "$(date '+%Y-%m-%d %H:%M:%S') - OK: RAM al ${RAM_USAGE}%"
       exit 0
   fi
   EOF
   
   chmod +x /tmp/alerta_ram.sh
   /tmp/alerta_ram.sh
   ```

3. **Script de monitoreo completo:**

   ```bash
   cat > /tmp/monitor_sistema.sh << 'EOF'
   #!/bin/bash
   LOG_FILE="/tmp/monitor_sistema.log"
   
   log_message() {
       echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
   }
   
   # Disco
   DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
   if [ "$DISK_USAGE" -gt 80 ]; then
       log_message "⚠️  ALERTA DISCO: ${DISK_USAGE}%"
   fi
   
   # RAM
   RAM_USAGE=$(free | awk '/Mem:/ {printf "%.0f", ($3/$2)*100}')
   if [ "$RAM_USAGE" -gt 80 ]; then
       log_message "⚠️  ALERTA RAM: ${RAM_USAGE}%"
   fi
   
   # Zombies
   ZOMBIES=$(ps aux | awk '$8 ~ /Z/ {count++} END {print count+0}')
   if [ "$ZOMBIES" -gt 0 ]; then
       log_message "⚠️  ALERTA ZOMBIES: $ZOMBIES procesos"
   fi
   
   # Resumen
   log_message "✓ Monitoreo: Disco ${DISK_USAGE}%, RAM ${RAM_USAGE}%, Zombies: $ZOMBIES"
   EOF
   
   chmod +x /tmp/monitor_sistema.sh
   /tmp/monitor_sistema.sh
   
   # Ver log
   cat /tmp/monitor_sistema.log
   ```

4. **Ejercicios:**
   - Ejecuta los scripts varias veces
   - Modifica los umbrales de alerta
   - Agrega más verificaciones (CPU, load average)
   - Programa los scripts con cron (opcional)

## Actividad 8: Limpieza y Verificación Final

### Objetivo
Limpiar procesos y archivos generados y verificar el estado del sistema.

### Pasos

1. **Detener procesos generados:**
   ```bash
   # Opción 1: Usar el script (opción 7)
   ./scripts/generar-actividad-monitoreo.sh
   # Seleccionar opción 7
   
   # Opción 2: Manualmente
   ps aux | grep -E "worker|memhog" | grep -v grep | awk '{print $2}' | xargs kill 2>/dev/null
   ```

2. **Limpiar archivos grandes:**
   ```bash
   rm -rf /tmp/monitoreo-practica/archivos_grandes
   ```

3. **Verificar estado final:**
   ```bash
   # Ver recursos
   free -h
   df -h /
   
   # Ver procesos
   ps aux --sort=-%cpu | head -5
   
   # Verificar que no quedan procesos del script
   ps aux | grep -E "monitoreo|worker|memhog" | grep -v grep
   ```

## Resumen de Comandos Aprendidos

```bash
# CPU
top, htop, ps aux --sort=-%cpu

# RAM
free -h, ps aux --sort=-%mem, watch -n 2 free -h

# Disco
df -h, du -sh, du -h | sort -hr | head

# Procesos
ps aux, pstree -p, ps auxf

# Monitoreo continuo
watch -n 2 "comando", htop
```

## Siguientes Pasos

- Configurar alertas automatizadas con cron
- Integrar con herramientas de monitoreo (Prometheus, Grafana)
- Practicar en contenedores Docker
- Crear dashboards personalizados

