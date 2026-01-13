# Actividades Prácticas: Seguridad y Configuración del Sistema en Linux

## Objetivo

Practicar los comandos de seguridad usando el script generador de actividad para crear situaciones reales de configuración y seguridad.

## Prerequisitos

```bash
# Instalar herramientas necesarias
sudo apt-get update
sudo apt-get install -y openssh-server openssh-client fail2ban

# Dar permisos de ejecución al script
chmod +x scripts/generar-actividad-seguridad.sh
```

## Actividad 1: Permisos de Archivos y Directorios (chmod)

### Objetivo
Practicar el cambio de permisos usando notación octal y simbólica.

### Pasos

1. **Ejecutar el script generador:**
   ```bash
   ./scripts/generar-actividad-seguridad.sh
   ```

2. **Seleccionar opción 1** (Crear estructura de archivos para practicar permisos)

3. **Explorar la estructura creada:**
   ```bash
   # Ver estructura
   ls -la /tmp/seguridad-practica/permisos-practica/
   
   # Ver permisos de cada subdirectorio
   ls -ld /tmp/seguridad-practica/permisos-practica/*
   
   # Ver permisos detallados de archivos
   ls -lR /tmp/seguridad-practica/permisos-practica/
   ```

4. **Ejercicios con notación octal:**
   ```bash
   cd /tmp/seguridad-practica/permisos-practica
   
   # Cambiar permisos a 755 (rwxr-xr-x)
   chmod 755 publico/lectura.txt
   ls -l publico/lectura.txt
   
   # Cambiar permisos a 600 (rw-------)
   chmod 600 privado/secreto.txt
   ls -l privado/secreto.txt
   
   # Cambiar permisos a 644 (rw-r--r--)
   chmod 644 grupo/doc_grupo.txt
   ls -l grupo/doc_grupo.txt
   
   # Cambiar permisos a 777 (⚠️ solo para práctica)
   chmod 777 ejecutables/script1.sh
   ls -l ejecutables/script1.sh
   chmod 755 ejecutables/script1.sh  # Restaurar
   ```

5. **Ejercicios con notación simbólica:**
   ```bash
   # Agregar ejecución al propietario
   chmod u+x scripts/script_sin_permiso.sh
   ls -l scripts/script_sin_permiso.sh
   
   # Agregar lectura al grupo
   chmod g+r privado/secreto.txt
   ls -l privado/secreto.txt
   
   # Quitar escritura a otros
   chmod o-w publico/lectura.txt
   ls -l publico/lectura.txt
   
   # Establecer permisos exactos
   chmod u=rwx,g=rx,o=r ejecutables/script2.sh
   ls -l ejecutables/script2.sh
   
   # Quitar todos los permisos a otros
   chmod o= publico/lectura.txt
   ls -l publico/lectura.txt
   ```

6. **Ejercicios recursivos:**
   ```bash
   # Crear directorio de prueba
   mkdir -p /tmp/test_permisos/{dir1,dir2}
   touch /tmp/test_permisos/{file1.txt,file2.txt}
   
   # Cambiar permisos recursivamente
   chmod -R 755 /tmp/test_permisos
   ls -lR /tmp/test_permisos/
   
   # Cambiar solo archivos a 644
   find /tmp/test_permisos -type f -exec chmod 644 {} \;
   ls -lR /tmp/test_permisos/
   
   # Cambiar solo directorios a 755
   find /tmp/test_permisos -type d -exec chmod 755 {} \;
   ls -ld /tmp/test_permisos/*
   ```

7. **Verificar permisos especiales:**
   ```bash
   # Ver sticky bit en tmp_compartido
   ls -ld permisos-practica/tmp_compartido
   # Debe mostrar 't' en los permisos de otros: drwxrwxrwt
   
   # Ver SUID en test_suid.sh
   ls -l permisos-practica/ejecutables/test_suid.sh
   # Debe mostrar 's' en los permisos del propietario: -rwsr-xr-x
   ```

## Actividad 2: Cambio de Propietario y Grupo (chown, chgrp)

### Objetivo
Practicar el cambio de propietarios y grupos de archivos y directorios.

### Pasos

1. **Ejecutar el script:**
   ```bash
   ./scripts/generar-actividad-seguridad.sh
   ```

2. **Seleccionar opción 2** (Crear estructura para practicar chown)

3. **Ver información actual:**
   ```bash
   cd /tmp/seguridad-practica/chown-practica
   
   # Ver propietarios actuales
   ls -l usuario1/
   ls -l usuario2/
   ls -l compartido/
   
   # Ver tu usuario y grupo actual
   whoami
   id
   ```

4. **Ejercicios con chown:**
   ```bash
   # Crear archivos de prueba
   touch archivo_prueba1.txt archivo_prueba2.txt
   
   # Cambiar propietario (requiere sudo si cambias a otro usuario)
   sudo chown root archivo_prueba1.txt
   ls -l archivo_prueba1.txt
   
   # Cambiar de vuelta a tu usuario
   sudo chown $USER archivo_prueba1.txt
   ls -l archivo_prueba1.txt
   
   # Cambiar propietario y grupo
   sudo chown $USER:$USER archivo_prueba2.txt
   ls -l archivo_prueba2.txt
   
   # Cambiar solo el grupo (si tienes varios grupos)
   sudo chown :$USER archivo_prueba2.txt
   ls -l archivo_prueba2.txt
   
   # Cambiar recursivamente
   sudo chown -R $USER:$USER usuario1/
   ls -lR usuario1/
   ```

5. **Ejercicios con chgrp:**
   ```bash
   # Ver grupos disponibles
   groups
   
   # Cambiar grupo de un archivo
   sudo chgrp $USER archivo_prueba1.txt
   ls -l archivo_prueba1.txt
   
   # Cambiar grupo recursivamente
   sudo chgrp -R $USER compartido/
   ls -lR compartido/
   ```

6. **Ejercicio práctico:**
   ```bash
   # Crear estructura de proyecto web
   mkdir -p /tmp/proyecto_web/{html,cgi-bin,logs}
   touch /tmp/proyecto_web/html/index.html
   touch /tmp/proyecto_web/cgi-bin/script.cgi
   touch /tmp/proyecto_web/logs/access.log
   
   # Simular configuración de servidor web (www-data es común en Ubuntu)
   # Nota: Esto puede no funcionar si www-data no existe
   sudo chown -R www-data:www-data /tmp/proyecto_web/html/ 2>/dev/null || echo "www-data no existe, usando $USER"
   sudo chown -R www-data:www-data /tmp/proyecto_web/cgi-bin/ 2>/dev/null || sudo chown -R $USER:$USER /tmp/proyecto_web/cgi-bin/
   
   # Ver resultado
   ls -lR /tmp/proyecto_web/
   ```

## Actividad 3: Configuración de SSH Keys

### Objetivo
Generar, configurar y usar claves SSH para autenticación.

### Pasos

1. **Ejecutar el script:**
   ```bash
   ./scripts/generar-actividad-seguridad.sh
   ```

2. **Seleccionar opción 4** (Crear estructura para practicar SSH keys)

3. **Generar clave SSH de prueba:**
   ```bash
   # Opción 1: Usar el script generado
   /tmp/seguridad-practica/ssh-keys-practica/generar_clave_prueba.sh
   
   # Opción 2: Manualmente
   ssh-keygen -t ed25519 -f ~/.ssh/test_key -N "" -C "test-key-$(date +%Y%m%d)"
   ```

4. **Explorar las claves generadas:**
   ```bash
   # Ver todas las claves
   ls -la ~/.ssh/
   
   # Ver clave pública
   cat ~/.ssh/test_key.pub
   
   # Ver información de la clave privada (sin mostrar contenido completo)
   ssh-keygen -y -f ~/.ssh/test_key
   
   # Verificar permisos (deben ser 600 para privada, 644 para pública)
   ls -l ~/.ssh/test_key*
   ```

5. **Configurar archivo SSH config:**
   ```bash
   # Crear/editar configuración SSH
   nano ~/.ssh/config
   ```
   
   Agregar contenido de ejemplo:
   ```
   # Servidor de prueba local
   Host test-local
       HostName localhost
       User $USER
       IdentityFile ~/.ssh/test_key
       ServerAliveInterval 60
   
   # Servidor de ejemplo
   Host ejemplo
       HostName ejemplo.com
       User usuario
       Port 22
       IdentityFile ~/.ssh/test_key
   ```
   
   ```bash
   # Establecer permisos correctos
   chmod 600 ~/.ssh/config
   ```

6. **Practicar copiar clave pública:**
   ```bash
   # Ver tu clave pública
   cat ~/.ssh/test_key.pub
   
   # Si tienes acceso a otro servidor, copiar la clave:
   # ssh-copy-id -i ~/.ssh/test_key.pub usuario@servidor
   
   # O manualmente (en el servidor remoto):
   # mkdir -p ~/.ssh
   # chmod 700 ~/.ssh
   # echo "tu_clave_publica_aqui" >> ~/.ssh/authorized_keys
   # chmod 600 ~/.ssh/authorized_keys
   ```

7. **Limpiar clave de prueba (al finalizar):**
   ```bash
   # Eliminar clave de prueba
   rm ~/.ssh/test_key ~/.ssh/test_key.pub
   ```

## Actividad 4: Configuración y Monitoreo de Swap

### Objetivo
Configurar, monitorear y gestionar memoria swap.

### Pasos

1. **Ejecutar el script:**
   ```bash
   ./scripts/generar-actividad-seguridad.sh
   ```

2. **Seleccionar opción 3** (Crear scripts para practicar con swap)

3. **Ver estado actual de swap:**
   ```bash
   # Usar el script generado
   /tmp/seguridad-practica/monitor_swap.sh
   
   # O manualmente:
   free -h
   swapon --show
   cat /proc/swaps
   cat /proc/sys/vm/swappiness
   ```

4. **Crear swap de prueba (requiere sudo):**
   ```bash
   # Opción 1: Usar el script generado
   /tmp/seguridad-practica/crear_swap_prueba.sh
   
   # Opción 2: Manualmente
   # Crear archivo de 1GB
   sudo fallocate -l 1G /tmp/swap_prueba
   
   # Establecer permisos
   sudo chmod 600 /tmp/swap_prueba
   
   # Formatear como swap
   sudo mkswap /tmp/swap_prueba
   
   # Activar swap
   sudo swapon /tmp/swap_prueba
   
   # Verificar
   swapon --show
   free -h
   ```

5. **Ajustar swappiness:**
   ```bash
   # Ver valor actual
   cat /proc/sys/vm/swappiness
   
   # Cambiar temporalmente (solo para esta sesión)
   sudo sysctl vm.swappiness=10
   
   # Verificar cambio
   cat /proc/sys/vm/swappiness
   
   # Nota: Para hacer permanente, editar /etc/sysctl.conf
   # echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf
   # sudo sysctl -p
   ```

6. **Monitorear uso de swap:**
   ```bash
   # Monitorear cada 2 segundos
   watch -n 2 'free -h | grep -i swap'
   
   # Ver procesos que usan swap
   # (requiere script adicional, no disponible por defecto)
   ```

7. **Desactivar y eliminar swap de prueba:**
   ```bash
   # Desactivar swap
   sudo swapoff /tmp/swap_prueba
   
   # Eliminar archivo
   sudo rm /tmp/swap_prueba
   
   # Verificar
   swapon --show
   free -h
   ```

## Actividad 5: Configuración de fail2ban

### Objetivo
Configurar fail2ban para proteger el servidor de intentos de acceso no autorizados.

### Pasos

1. **Instalar fail2ban (si no está instalado):**
   ```bash
   sudo apt-get update
   sudo apt-get install -y fail2ban
   ```

2. **Verificar instalación:**
   ```bash
   fail2ban-client --version
   sudo systemctl status fail2ban
   ```

3. **Configurar fail2ban:**
   ```bash
   # Crear archivo de configuración local
   sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
   
   # Editar configuración
   sudo nano /etc/fail2ban/jail.local
   ```
   
   Configuración básica recomendada:
   ```
   [DEFAULT]
   ignoreip = 127.0.0.1/8 ::1
   bantime = 600
   findtime = 600
   maxretry = 5
   
   [sshd]
   enabled = true
   port = ssh
   logpath = /var/log/auth.log
   maxretry = 3
   bantime = 3600
   findtime = 600
   ```

4. **Reiniciar fail2ban:**
   ```bash
   # Verificar configuración
   sudo fail2ban-client -t
   
   # Reiniciar servicio
   sudo systemctl restart fail2ban
   sudo systemctl enable fail2ban
   
   # Verificar estado
   sudo systemctl status fail2ban
   ```

5. **Comandos útiles de fail2ban:**
   ```bash
   # Ver estado general
   sudo fail2ban-client status
   
   # Ver estado del jail SSH
   sudo fail2ban-client status sshd
   
   # Ver logs
   sudo tail -f /var/log/fail2ban.log
   
   # Ver intentos fallidos recientes
   sudo grep "Failed password" /var/log/auth.log | tail -20
   ```

6. **Simular intentos fallidos (CUIDADO - solo en entorno de prueba):**
   ```bash
   # Ejecutar el script generador
   ./scripts/generar-actividad-seguridad.sh
   # Seleccionar opción 5
   
   # ADVERTENCIA: Esto puede hacer que tu IP sea bloqueada
   # Solo ejecutar en entornos de prueba aislados
   # O desde otra máquina
   ```

7. **Gestionar IPs baneadas:**
   ```bash
   # Ver IPs baneadas
   sudo fail2ban-client status sshd
   
   # Banear IP manualmente (ejemplo)
   # sudo fail2ban-client set sshd banip 192.168.1.100
   
   # Desbanear IP
   # sudo fail2ban-client set sshd unbanip 192.168.1.100
   
   # Recargar configuración
   sudo fail2ban-client reload
   ```

## Actividad 6: Ejercicio Integrado - Configurar Servidor Seguro

### Objetivo
Aplicar todos los conceptos aprendidos en un ejercicio integrado.

### Pasos

1. **Crear estructura de proyecto:**
   ```bash
   # Crear estructura
   mkdir -p /tmp/servidor_seguro/{web,scripts,logs,private}
   
   # Crear archivos de ejemplo
   echo "<html>Página web</html>" > /tmp/servidor_seguro/web/index.html
   echo "#!/bin/bash\necho 'Script privado'" > /tmp/servidor_seguro/scripts/backup.sh
   touch /tmp/servidor_seguro/logs/access.log
   echo "información confidencial" > /tmp/servidor_seguro/private/secreto.txt
   ```

2. **Configurar permisos adecuados:**
   ```bash
   cd /tmp/servidor_seguro
   
   # Web: lectura para todos, escritura solo propietario
   chmod 644 web/index.html
   chmod 755 web
   
   # Scripts: ejecutable solo por propietario
   chmod 700 scripts/backup.sh
   chmod 700 scripts
   
   # Logs: escritura para propietario y grupo
   chmod 664 logs/access.log
   chmod 775 logs
   
   # Private: solo propietario
   chmod 600 private/secreto.txt
   chmod 700 private
   
   # Verificar
   ls -lR /tmp/servidor_seguro/
   ```

3. **Configurar propietarios (simulado):**
   ```bash
   # En un entorno real, usarías usuarios específicos
   # Por ejemplo: sudo chown -R www-data:www-data web/
   # Por ahora, solo verificamos la estructura
   
   # Ver propietarios actuales
   ls -lR /tmp/servidor_seguro/
   ```

4. **Crear script de verificación de seguridad:**
   ```bash
   cat > /tmp/verificar_seguridad.sh << 'EOF'
   #!/bin/bash
   
   echo "=== VERIFICACIÓN DE PERMISOS ==="
   echo ""
   
   BASE_DIR="/tmp/servidor_seguro"
   
   echo "Permisos de archivos web:"
   ls -l $BASE_DIR/web/
   echo ""
   
   echo "Permisos de scripts:"
   ls -l $BASE_DIR/scripts/
   echo ""
   
   echo "Permisos de logs:"
   ls -l $BASE_DIR/logs/
   echo ""
   
   echo "Permisos de private:"
   ls -ld $BASE_DIR/private/
   ls -l $BASE_DIR/private/
   echo ""
   
   echo "Verificando permisos inseguros (777, 666):"
   find $BASE_DIR -perm -777 -o -perm -666 2>/dev/null
   EOF
   
   chmod +x /tmp/verificar_seguridad.sh
   /tmp/verificar_seguridad.sh
   ```

5. **Documentar configuración:**
   ```bash
   cat > /tmp/servidor_seguro/README.txt << 'EOF'
   CONFIGURACIÓN DE SEGURIDAD
   ==========================
   
   Estructura de permisos:
   - web/: 755 (directorio), 644 (archivos) - Público
   - scripts/: 700 - Solo propietario
   - logs/: 775 (directorio), 664 (archivos) - Grupo puede escribir
   - private/: 700 (directorio), 600 (archivos) - Solo propietario
   
   Recomendaciones adicionales:
   - Configurar fail2ban para proteger SSH
   - Usar claves SSH en lugar de contraseñas
   - Revisar logs regularmente
   - Mantener sistema actualizado
   EOF
   
   cat /tmp/servidor_seguro/README.txt
   ```

## Actividad 7: Limpieza Final

### Objetivo
Limpiar archivos y configuraciones de prueba.

### Pasos

1. **Limpiar estructura de seguridad:**
   ```bash
   # Opción 1: Usar el script (opción 7)
   ./scripts/generar-actividad-seguridad.sh
   # Seleccionar opción 7
   
   # Opción 2: Manualmente
   rm -rf /tmp/seguridad-practica
   rm -rf /tmp/servidor_seguro
   rm -rf /tmp/test_permisos
   rm -rf /tmp/proyecto_web
   ```

2. **Limpiar swap de prueba (si se creó):**
   ```bash
   sudo swapoff /tmp/swap_prueba 2>/dev/null
   sudo rm /tmp/swap_prueba 2>/dev/null
   ```

3. **Verificar limpieza:**
   ```bash
   # Verificar que no quedan archivos
   ls -la /tmp/ | grep -E "seguridad|permisos|servidor"
   
   # Verificar swap
   swapon --show
   ```

## Resumen de Comandos Aprendidos

```bash
# Permisos
chmod 755 archivo, chmod u+x archivo, chmod -R 644 directorio

# Propietarios
chown usuario:grupo archivo, chown -R usuario:grupo directorio
chgrp grupo archivo

# SSH Keys
ssh-keygen -t ed25519, ssh-copy-id usuario@servidor
cat ~/.ssh/id_rsa.pub

# Swap
free -h, swapon --show, sudo swapon /swapfile
sudo sysctl vm.swappiness=10

# fail2ban
sudo fail2ban-client status, sudo fail2ban-client status sshd
sudo tail -f /var/log/fail2ban.log
```

## Siguientes Pasos

- Configurar fail2ban para otros servicios (Apache, Nginx, MySQL)
- Implementar políticas de permisos más complejas
- Configurar autenticación SSH más segura
- Integrar con herramientas de auditoría de seguridad

