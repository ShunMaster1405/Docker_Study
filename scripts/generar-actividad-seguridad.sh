#!/bin/bash
# Script para generar actividad de seguridad en el sistema
# Este script crea situaciones para practicar permisos, fail2ban, etc.

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Directorio de trabajo
WORK_DIR="/tmp/seguridad-practica"

# Crear directorio de trabajo
mkdir -p "$WORK_DIR"

echo -e "${GREEN}=== Generador de Actividad para Práctica de Seguridad ===${NC}\n"

# Función para crear estructura de archivos con permisos diversos
crear_estructura_permisos() {
    echo -e "${BLUE}Creando estructura de archivos para practicar permisos...${NC}"
    
    mkdir -p "$WORK_DIR/permisos-practica"/{publico,privado,grupo,ejecutables,scripts}
    
    # Archivos públicos (644)
    echo "Contenido público" > "$WORK_DIR/permisos-practica/publico/lectura.txt"
    chmod 644 "$WORK_DIR/permisos-practica/publico/lectura.txt"
    
    # Archivos privados (600)
    echo "Información confidencial" > "$WORK_DIR/permisos-practica/privado/secreto.txt"
    chmod 600 "$WORK_DIR/permisos-practica/privado/secreto.txt"
    
    # Archivos de grupo (640, 750)
    echo "Documento del grupo" > "$WORK_DIR/permisos-practica/grupo/doc_grupo.txt"
    chmod 640 "$WORK_DIR/permisos-practica/grupo/doc_grupo.txt"
    chmod 750 "$WORK_DIR/permisos-practica/grupo"
    
    # Scripts ejecutables (755, 744)
    cat > "$WORK_DIR/permisos-practica/ejecutables/script1.sh" << 'EOF'
#!/bin/bash
echo "Script ejecutable 1"
whoami
date
EOF
    chmod 755 "$WORK_DIR/permisos-practica/ejecutables/script1.sh"
    
    cat > "$WORK_DIR/permisos-practica/ejecutables/script2.sh" << 'EOF'
#!/bin/bash
echo "Script ejecutable 2 (permisos restrictivos)"
EOF
    chmod 744 "$WORK_DIR/permisos-practica/ejecutables/script2.sh"
    
    # Script sin permisos de ejecución
    cat > "$WORK_DIR/permisos-practica/scripts/script_sin_permiso.sh" << 'EOF'
#!/bin/bash
echo "Este script necesita permisos de ejecución"
EOF
    chmod 644 "$WORK_DIR/permisos-practica/scripts/script_sin_permiso.sh"
    
    # Directorio con sticky bit (simular /tmp)
    mkdir -p "$WORK_DIR/permisos-practica/tmp_compartido"
    chmod 1777 "$WORK_DIR/permisos-practica/tmp_compartido"
    
    # Archivo con SUID (ejemplo educativo)
    cat > "$WORK_DIR/permisos-practica/ejecutables/test_suid.sh" << 'EOF'
#!/bin/bash
echo "Script con SUID (ejemplo)"
EOF
    chmod 4755 "$WORK_DIR/permisos-practica/ejecutables/test_suid.sh"
    
    echo -e "${GREEN}✓ Estructura creada en: $WORK_DIR/permisos-practica${NC}"
    echo -e "${YELLOW}Ejercicio: Explora los permisos con 'ls -l' y practica con chmod/chown${NC}\n"
}

# Función para crear archivos para practicar chown
crear_estructura_chown() {
    echo -e "${BLUE}Creando estructura para practicar chown...${NC}"
    
    mkdir -p "$WORK_DIR/chown-practica"/{usuario1,usuario2,compartido}
    
    # Crear archivos con diferentes propietarios
    touch "$WORK_DIR/chown-practica/usuario1/archivo1.txt"
    touch "$WORK_DIR/chown-practica/usuario2/archivo2.txt"
    touch "$WORK_DIR/chown-practica/compartido/archivo_compartido.txt"
    
    echo -e "${GREEN}✓ Estructura creada en: $WORK_DIR/chown-practica${NC}"
    echo -e "${YELLOW}Ejercicio: Practica cambiando propietarios y grupos con chown${NC}\n"
}

# Función para simular intentos de login fallidos (para fail2ban)
simular_intentos_fallidos() {
    echo -e "${BLUE}Simulando intentos de login fallidos para fail2ban...${NC}"
    echo -e "${YELLOW}NOTA: Esto requiere permisos sudo y que SSH esté configurado${NC}"
    
    read -p "¿Continuar con la simulación? (s/n): " respuesta
    if [ "$respuesta" != "s" ] && [ "$respuesta" != "S" ]; then
        echo -e "${YELLOW}Simulación cancelada${NC}"
        return
    fi
    
    # Verificar si estamos en el servidor SSH
    if ! systemctl is-active --quiet ssh 2>/dev/null && ! systemctl is-active --quiet sshd 2>/dev/null; then
        echo -e "${RED}SSH no parece estar activo. Esta función es para servidores SSH reales.${NC}"
        echo -e "${YELLOW}Para practicar fail2ban, puedes:${NC}"
        echo "  1. Configurar fail2ban en un servidor real"
        echo "  2. Ver los logs en /var/log/auth.log"
        echo "  3. Probar desde otra máquina con intentos de conexión fallidos"
        return
    fi
    
    echo -e "${GREEN}Generando script de prueba...${NC}"
    
    # Crear script que puede ejecutarse manualmente
    cat > "$WORK_DIR/simular_ssh_fail.sh" << 'EOFSCRIPT'
#!/bin/bash
# Script para simular intentos de login SSH fallidos
# ADVERTENCIA: Usar solo en entornos de prueba

USUARIO="testuser"
INTENTOS=10

echo "Simulando $INTENTOS intentos de login fallidos para usuario: $USUARIO"
echo "Esto debería activar fail2ban si está configurado correctamente"
echo ""
echo "NOTA: En producción, ejecuta esto desde OTRA máquina o verás tu propia IP bloqueada"
echo ""

for i in $(seq 1 $INTENTOS); do
    echo "Intento $i/$INTENTOS..."
    ssh -o ConnectTimeout=2 -o StrictHostKeyChecking=no ${USUARIO}@localhost "exit" 2>&1 | grep -i "permission denied\|connection refused\|connection timed out" > /dev/null
    sleep 0.5
done

echo ""
echo "Simulación completada. Revisa:"
echo "  - /var/log/auth.log"
echo "  - sudo fail2ban-client status sshd"
EOFSCRIPT
    
    chmod +x "$WORK_DIR/simular_ssh_fail.sh"
    
    echo -e "${GREEN}✓ Script creado en: $WORK_DIR/simular_ssh_fail.sh${NC}"
    echo -e "${YELLOW}ADVERTENCIA: Este script puede hacer que tu IP sea bloqueada por fail2ban${NC}"
    echo -e "${YELLOW}Recomendación: Ejecutar desde otra máquina o en un entorno de prueba aislado${NC}\n"
}

# Función para crear scripts de prueba de swap
crear_scripts_swap() {
    echo -e "${BLUE}Creando scripts para practicar con swap...${NC}"
    
    # Script para monitorear swap
    cat > "$WORK_DIR/monitor_swap.sh" << 'EOF'
#!/bin/bash
# Script para monitorear uso de swap

echo "=== Estado de Swap ==="
echo ""
echo "Información básica:"
free -h | grep -i swap
echo ""
echo "Swap activo:"
swapon --show
echo ""
echo "Uso detallado:"
cat /proc/swaps
echo ""
echo "Swappiness:"
cat /proc/sys/vm/swappiness
EOF
    chmod +x "$WORK_DIR/monitor_swap.sh"
    
    # Script para crear swap de prueba
    cat > "$WORK_DIR/crear_swap_prueba.sh" << 'EOF'
#!/bin/bash
# Script para crear swap de prueba (1GB)
# ADVERTENCIA: Requiere permisos sudo

SWAP_FILE="/tmp/swap_prueba"
SIZE_GB=1

echo "Creando archivo de swap de ${SIZE_GB}GB..."
sudo fallocate -l ${SIZE_GB}G "$SWAP_FILE" 2>/dev/null || sudo dd if=/dev/zero of="$SWAP_FILE" bs=1M count=$((SIZE_GB * 1024)) 2>/dev/null

echo "Estableciendo permisos..."
sudo chmod 600 "$SWAP_FILE"

echo "Formateando como swap..."
sudo mkswap "$SWAP_FILE"

echo "Activando swap..."
sudo swapon "$SWAP_FILE"

echo "✓ Swap creado y activado: $SWAP_FILE"
echo "Para desactivar: sudo swapoff $SWAP_FILE && sudo rm $SWAP_FILE"
EOF
    chmod +x "$WORK_DIR/crear_swap_prueba.sh"
    
    echo -e "${GREEN}✓ Scripts creados:${NC}"
    echo "  - $WORK_DIR/monitor_swap.sh"
    echo "  - $WORK_DIR/crear_swap_prueba.sh"
    echo ""
}

# Función para crear estructura de SSH keys de ejemplo
crear_estructura_ssh() {
    echo -e "${BLUE}Creando estructura para practicar con SSH keys...${NC}"
    
    mkdir -p "$WORK_DIR/ssh-keys-practica"
    
    # Crear script educativo
    cat > "$WORK_DIR/ssh-keys-practica/README.txt" << 'EOF'
PRÁCTICA DE SSH KEYS
===================

Ejercicios sugeridos:

1. Generar nueva clave SSH:
   ssh-keygen -t ed25519 -f ~/.ssh/test_key -N ""

2. Ver clave pública:
   cat ~/.ssh/test_key.pub

3. Ver información de la clave:
   ssh-keygen -y -f ~/.ssh/test_key

4. Ver todas tus claves:
   ls -la ~/.ssh/*.pub

5. Crear archivo de configuración SSH:
   nano ~/.ssh/config

6. Probar conexión (si tienes servidor):
   ssh -i ~/.ssh/test_key usuario@servidor

NOTA: Las claves reales deben estar en ~/.ssh/, no en este directorio.
Este directorio es solo para documentación y scripts de práctica.
EOF
    
    # Script para generar clave de prueba
    cat > "$WORK_DIR/ssh-keys-practica/generar_clave_prueba.sh" << 'EOF'
#!/bin/bash
# Script para generar clave SSH de prueba

KEY_NAME="test_key_$(date +%s)"
KEY_PATH="$HOME/.ssh/${KEY_NAME}"

echo "Generando clave SSH de prueba: $KEY_NAME"
ssh-keygen -t ed25519 -f "$KEY_PATH" -N "" -C "test-key-$(date +%Y%m%d)"

echo ""
echo "✓ Clave generada:"
echo "  Privada: ${KEY_PATH}"
echo "  Pública:  ${KEY_PATH}.pub"
echo ""
echo "Para ver la clave pública:"
echo "  cat ${KEY_PATH}.pub"
echo ""
echo "Para eliminar después de practicar:"
echo "  rm ${KEY_PATH} ${KEY_PATH}.pub"
EOF
    chmod +x "$WORK_DIR/ssh-keys-practica/generar_clave_prueba.sh"
    
    echo -e "${GREEN}✓ Estructura creada en: $WORK_DIR/ssh-keys-practica${NC}\n"
}

# Función para limpiar todo
limpiar_todo() {
    echo -e "${YELLOW}Limpiando todos los archivos generados...${NC}"
    rm -rf "$WORK_DIR"
    echo -e "${GREEN}✓ Limpieza completada${NC}\n"
}

# Menú principal
mostrar_menu() {
    echo -e "\n${YELLOW}=== Menú de Actividad de Seguridad ===${NC}"
    echo "1. Crear estructura de archivos para practicar permisos (chmod)"
    echo "2. Crear estructura para practicar chown"
    echo "3. Crear scripts para practicar con swap"
    echo "4. Crear estructura para practicar SSH keys"
    echo "5. Crear script para simular intentos SSH fallidos (fail2ban)"
    echo "6. Ver estructura creada"
    echo "7. Limpiar todo"
    echo "8. Salir"
    echo -e "${NC}"
}

# Ver estructura creada
ver_estructura() {
    if [ ! -d "$WORK_DIR" ] || [ -z "$(ls -A $WORK_DIR 2>/dev/null)" ]; then
        echo -e "${YELLOW}No hay estructura creada${NC}"
        return
    fi
    
    echo -e "\n${GREEN}Estructura creada en: $WORK_DIR${NC}\n"
    tree -L 2 "$WORK_DIR" 2>/dev/null || find "$WORK_DIR" -maxdepth 2 -type f -o -type d | head -20
    echo ""
}

# Bucle principal
while true; do
    mostrar_menu
    read -p "Selecciona una opción (1-8): " opcion
    
    case $opcion in
        1)
            crear_estructura_permisos
            ;;
        2)
            crear_estructura_chown
            ;;
        3)
            crear_scripts_swap
            ;;
        4)
            crear_estructura_ssh
            ;;
        5)
            simular_intentos_fallidos
            ;;
        6)
            ver_estructura
            ;;
        7)
            limpiar_todo
            ;;
        8)
            echo -e "${GREEN}¡Hasta luego!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Opción inválida${NC}"
            ;;
    esac
    
    echo -e "\n${YELLOW}Presiona Enter para continuar...${NC}"
    read
done

