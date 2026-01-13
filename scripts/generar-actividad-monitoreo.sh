#!/bin/bash
# Script para generar actividad de monitoreo en el sistema
# Este script crea procesos que consumen CPU, RAM, disco, etc.
# Útil para practicar comandos de monitoreo

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Directorio de trabajo
WORK_DIR="/tmp/monitoreo-practica"
PID_FILE="$WORK_DIR/procesos.pid"

# Función para limpiar procesos al salir
cleanup() {
    echo -e "\n${YELLOW}Limpiando procesos generados...${NC}"
    if [ -f "$PID_FILE" ]; then
        while read pid; do
            if ps -p $pid > /dev/null 2>&1; then
                kill $pid 2>/dev/null
            fi
        done < "$PID_FILE"
        rm -f "$PID_FILE"
    fi
    
    # Limpiar archivos grandes creados
    rm -rf "$WORK_DIR/archivos_grandes"
    
    echo -e "${GREEN}Limpieza completada${NC}"
    exit 0
}

# Capturar Ctrl+C
trap cleanup SIGINT SIGTERM

# Crear directorio de trabajo
mkdir -p "$WORK_DIR"
mkdir -p "$WORK_DIR/archivos_grandes"
rm -f "$PID_FILE"

echo -e "${GREEN}=== Generador de Actividad para Práctica de Monitoreo ===${NC}\n"

# Función para crear proceso que consume CPU
crear_proceso_cpu() {
    local nombre=$1
    local uso=$2
    local tiempo=$3
    
    (
        end_time=$(($(date +%s) + $tiempo))
        while [ $(date +%s) -lt $end_time ]; do
            # Calcular ciclos según el uso deseado
            # Uso de CPU aproximado basado en tiempo activo vs sleep
            timeout 0.1 bash -c "while true; do : ; done" 2>/dev/null || true
            # Sleep proporcional al uso (mayor uso = menos sleep)
            # Simplificado: si uso > 50, sleep corto; si uso < 50, sleep largo
            if [ $uso -gt 50 ]; then
                sleep 0.1
            else
                sleep 0.3
            fi
        done
    ) > /dev/null 2>&1 &
    
    echo $! >> "$PID_FILE"
    echo -e "${GREEN}✓${NC} Proceso CPU '$nombre' iniciado (PID: $!, uso aproximado: ${uso}%, duración: ${tiempo}s)"
}

# Función para crear proceso que consume RAM
crear_proceso_ram() {
    local nombre=$1
    local mb=$2
    local tiempo=$3
    
    (
        # Crear variable que consume memoria
        # Usar dd para crear archivo en memoria (más confiable)
        data=$(dd if=/dev/zero bs=1M count=$mb 2>/dev/null | base64 2>/dev/null || head -c $(($mb * 1024 * 1024)) < /dev/zero 2>/dev/null)
        sleep $tiempo
        unset data
    ) > /dev/null 2>&1 &
    
    echo $! >> "$PID_FILE"
    echo -e "${GREEN}✓${NC} Proceso RAM '$nombre' iniciado (PID: $!, memoria: ${mb}MB, duración: ${tiempo}s)"
}

# Función para crear archivos grandes
crear_archivos_grandes() {
    local cantidad=$1
    local tamano_mb=$2
    
    echo -e "${YELLOW}Creando $cantidad archivos de ${tamano_mb}MB cada uno...${NC}"
    for i in $(seq 1 $cantidad); do
        dd if=/dev/zero of="$WORK_DIR/archivos_grandes/archivo_${i}.dat" bs=1M count=$tamano_mb 2>/dev/null
        echo -e "${GREEN}✓${NC} Creado: archivo_${i}.dat (${tamano_mb}MB)"
    done
}

# Función para crear procesos zombie (para práctica avanzada)
crear_proceso_zombie() {
    (
        # Crear un proceso hijo que termina pero no es waitado
        (sleep 1; exit 0) &
        sleep 10
    ) > /dev/null 2>&1 &
    
    echo $! >> "$PID_FILE"
    echo -e "${GREEN}✓${NC} Proceso que puede generar zombie iniciado (PID: $!)"
}

# Menú interactivo
mostrar_menu() {
    echo -e "\n${YELLOW}=== Menú de Actividad ===${NC}"
    echo "1. Generar procesos que consumen CPU (3 procesos, uso moderado)"
    echo "2. Generar procesos que consumen RAM (2 procesos, 100MB cada uno)"
    echo "3. Crear archivos grandes en disco (5 archivos de 50MB)"
    echo "4. Generar actividad mixta (CPU + RAM + Disco)"
    echo "5. Generar proceso zombie (para práctica avanzada)"
    echo "6. Ver procesos generados actualmente"
    echo "7. Detener todos los procesos generados"
    echo "8. Salir y limpiar"
    echo -e "${NC}"
}

# Ver procesos generados
ver_procesos() {
    if [ ! -f "$PID_FILE" ] || [ ! -s "$PID_FILE" ]; then
        echo -e "${YELLOW}No hay procesos activos${NC}"
        return
    fi
    
    echo -e "\n${GREEN}Procesos activos:${NC}"
    echo "PID    %CPU  %MEM  COMMAND"
    echo "----------------------------------------"
    while read pid; do
        if ps -p $pid > /dev/null 2>&1; then
            ps -p $pid -o pid=,%cpu=,%mem=,comm= --no-headers
        fi
    done < "$PID_FILE"
    echo ""
}

# Detener procesos
detener_procesos() {
    if [ ! -f "$PID_FILE" ]; then
        echo -e "${YELLOW}No hay procesos para detener${NC}"
        return
    fi
    
    echo -e "${YELLOW}Deteniendo procesos...${NC}"
    while read pid; do
        if ps -p $pid > /dev/null 2>&1; then
            kill $pid 2>/dev/null
            echo -e "${GREEN}✓${NC} Proceso $pid detenido"
        fi
    done < "$PID_FILE"
    rm -f "$PID_FILE"
    echo -e "${GREEN}Todos los procesos han sido detenidos${NC}"
}

# Limpiar archivos grandes
limpiar_archivos() {
    echo -e "${YELLOW}Limpiando archivos grandes...${NC}"
    rm -rf "$WORK_DIR/archivos_grandes"
    mkdir -p "$WORK_DIR/archivos_grandes"
    echo -e "${GREEN}Archivos limpiados${NC}"
}

# Actividad mixta
actividad_mixta() {
    echo -e "${GREEN}Generando actividad mixta...${NC}"
    
    # CPU
    crear_proceso_cpu "worker1" 30 60
    crear_proceso_cpu "worker2" 50 60
    crear_proceso_cpu "worker3" 20 60
    
    # RAM
    crear_proceso_ram "memhog1" 100 60
    crear_proceso_ram "memhog2" 150 60
    
    # Disco
    crear_archivos_grandes 3 30
    
    echo -e "\n${GREEN}✓ Actividad mixta iniciada${NC}"
}

# Bucle principal
while true; do
    mostrar_menu
    read -p "Selecciona una opción (1-8): " opcion
    
    case $opcion in
        1)
            echo -e "\n${GREEN}Generando procesos CPU...${NC}"
            crear_proceso_cpu "cpu_intensivo1" 40 120
            crear_proceso_cpu "cpu_intensivo2" 60 120
            crear_proceso_cpu "cpu_intensivo3" 30 120
            ;;
        2)
            echo -e "\n${GREEN}Generando procesos RAM...${NC}"
            crear_proceso_ram "memoria1" 100 120
            crear_proceso_ram "memoria2" 150 120
            ;;
        3)
            echo -e "\n${GREEN}Creando archivos grandes...${NC}"
            crear_archivos_grandes 5 50
            ;;
        4)
            actividad_mixta
            ;;
        5)
            echo -e "\n${YELLOW}Generando proceso zombie...${NC}"
            crear_proceso_zombie
            echo -e "${YELLOW}Nota: Verifica con 'ps aux | grep Z' después de unos segundos${NC}"
            ;;
        6)
            ver_procesos
            ;;
        7)
            detener_procesos
            limpiar_archivos
            ;;
        8)
            cleanup
            ;;
        *)
            echo -e "${RED}Opción inválida${NC}"
            ;;
    esac
    
    echo -e "\n${YELLOW}Presiona Enter para continuar...${NC}"
    read
done

