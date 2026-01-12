# Guía de Seguridad y Configuración del Sistema en Linux (Ubuntu)

## Objetivo

Aprender sobre permisos en Linux, configurar SSH keys, configurar swap y proteger el sistema con fail2ban.

## Herramientas Necesarias

Antes de comenzar, instala las siguientes herramientas:

```bash
# Actualizar repositorios
apt-get update

# Instalar herramientas básicas
apt-get install -y openssh-server openssh-client fail2ban

# Verificar instalación
which ssh
which ssh-keygen
which fail2ban-client
```

## 1. Permisos en Linux (Teoría y Práctica)

### Conceptos Básicos

En Linux, cada archivo y directorio tiene 3 tipos de permisos para 3 tipos de usuarios:

**Tipos de permisos:**
| Símbolo | Nombre | Valor | Descripción |
|---------|--------|-------|-------------|
| `r` | Read (lectura) | 4 | Leer contenido del archivo / listar directorio |
| `w` | Write (escritura) | 2 | Modificar archivo / crear/eliminar en directorio |
| `x` | Execute (ejecución) | 1 | Ejecutar archivo / entrar al directorio |

**Tipos de usuarios:**
| Símbolo | Usuario | Descripción |
|---------|---------|-------------|
| `u` | User (propietario) | El dueño del archivo |
| `g` | Group (grupo) | Los miembros del grupo |
| `o` | Others (otros) | Todos los demás usuarios |
| `a` | All (todos) | Propietario + grupo + otros |

### Ver Permisos Actuales

```bash
# Ver permisos de un archivo
ls -l archivo.txt

# Ver permisos de un directorio
ls -ld /tmp/carpeta

# Ver permisos de todos los archivos en un directorio
ls -la /ruta/directorio

# Ver permisos con información detallada
stat archivo.txt
```

**Interpretar permisos:**
```
-rw-r--r--  1 root root  0 Jan 5 12:00 archivo.txt
│└─┬─┘└─┬─┘ │ │    │    │
│ │ │   │ │ │ │    │    └── Tamaño
│ │ │   │ │ │ │    └─────── Grupo
│ │ │   │ │ │ └──────────── Propietario
│ │ │   │ │ └────────────── Número de enlaces
│ │ │   │ └──────────────── Otros: r-- (solo lectura)
│ │ │   └────────────────── Grupo: r-- (solo lectura)
│ │ └────────────────────── Propietario: rw- (lectura y escritura)
│ └──────────────────────── Tipo: - (archivo regular), d (directorio)
```

**Tipos de archivos:**
- `-` → archivo regular
- `d` → directorio
- `l` → enlace simbólico
- `c` → dispositivo de caracteres
- `b` → dispositivo de bloques

### Cambiar Permisos con chmod

#### Método 1: Notación Octal (Numérica)

```bash
# Sintaxis: chmod [permisos_octales] archivo

# Permisos comunes:
chmod 644 archivo.txt   # rw-r--r-- (lectura para todos, escritura solo propietario)
chmod 755 script.sh     # rwxr-xr-x (ejecutable por todos, escritura solo propietario)
chmod 700 privado.txt   # rwx------ (solo propietario tiene todos los permisos)
chmod 777 publico.txt   # rwxrwxrwx (todos pueden hacer todo - ⚠️ NO RECOMENDADO)
chmod 600 secreto.txt   # rw------- (solo propietario lee/escribe)
chmod 444 soloLectura   # r--r--r-- (solo lectura para todos)
chmod 750 ejecutable.sh # rwxr-x--- (propietario todo, grupo leer/ejecutar, otros nada)
```

**Cálculo de permisos octales:**
```
r = 4, w = 2, x = 1

Ejemplos:
rwx = 4+2+1 = 7
rw- = 4+2+0 = 6
r-x = 4+0+1 = 5
r-- = 4+0+0 = 4
--- = 0+0+0 = 0

644 = rw-r--r-- = 6(propietario) + 4(grupo) + 4(otros)
755 = rwxr-xr-x = 7(propietario) + 5(grupo) + 5(otros)
750 = rwxr-x--- = 7(propietario) + 5(grupo) + 0(otros)
```

#### Método 2: Notación Simbólica

```bash
# Sintaxis: chmod [quien][operador][permisos] archivo
# Quien: u (user), g (group), o (others), a (all)
# Operador: + (agregar), - (quitar), = (establecer)
# Permisos: r, w, x

# Agregar permisos
chmod u+x script.sh       # Agregar ejecución al propietario
chmod g+w archivo.txt     # Agregar escritura al grupo
chmod o+r archivo.txt     # Agregar lectura a otros
chmod a+x script.sh       # Agregar ejecución a todos
chmod u+rwx archivo.txt   # Agregar rwx al propietario

# Quitar permisos
chmod o-w archivo.txt     # Quitar escritura a otros
chmod g-wx archivo.txt    # Quitar escritura y ejecución al grupo
chmod a-x archivo.txt     # Quitar ejecución a todos

# Establecer permisos exactos
chmod u=rwx,g=rx,o=r archivo.txt  # rwxr-xr--
chmod u=rw,go=r archivo.txt       # rw-r--r--
chmod a=r archivo.txt             # r--r--r--
chmod u=rwx,g=,o= archivo.txt     # rwx------ (equivalente a 700)

# Múltiples cambios
chmod u+x,g-w,o-rwx archivo.txt
```

#### Aplicar Permisos Recursivamente

```bash
# Cambiar permisos de un directorio y TODO su contenido
chmod -R 755 /ruta/directorio

# Cambiar permisos solo de archivos (no directorios)
find /ruta -type f -exec chmod 644 {} \;

# Cambiar permisos solo de directorios
find /ruta -type d -exec chmod 755 {} \;

# Alternativa con find más eficiente
find /ruta -type f -print0 | xargs -0 chmod 644
find /ruta -type d -print0 | xargs -0 chmod 755
```

### Cambiar Propietario con chown

```bash
# Cambiar propietario de un archivo
chown usuario archivo.txt

# Cambiar propietario y grupo
chown usuario:grupo archivo.txt

# Cambiar solo el grupo
chown :grupo archivo.txt

# Cambiar propietario recursivamente
chown -R usuario:grupo /ruta/directorio

# Ejemplos prácticos
chown usuario1 documento.txt
chown usuario1:desarrolladores proyecto/
chown -R www-data:www-data /var/www/html
chown -R usuario1:usuario1 /home/usuario1
```

### Cambiar Solo Grupo con chgrp

```bash
# Cambiar grupo de un archivo
chgrp grupo archivo.txt

# Cambiar grupo recursivamente
chgrp -R grupo /ruta/directorio

# Ejemplos
chgrp desarrolladores codigo.py
chgrp -R usuarios /home/compartido
```

### Permisos Predeterminados con umask

```bash
# Ver umask actual
umask

# Establecer umask
umask 022   # Archivos nuevos: 644, Directorios: 755
umask 077   # Archivos nuevos: 600, Directorios: 700
umask 002   # Archivos nuevos: 664, Directorios: 775

# Cálculo: permisos = 777 - umask (directorios), 666 - umask (archivos)
# umask 022 → archivos: 666-022=644, directorios: 777-022=755
# umask 077 → archivos: 666-077=600, directorios: 777-077=700
```

### Permisos Especiales (Avanzado)

```bash
# SUID (4): Ejecutar como propietario
chmod u+s archivo
chmod 4755 archivo  # rwsr-xr-x (s en lugar de x para propietario)

# SGID (2): Ejecutar como grupo / heredar grupo en directorio
chmod g+s directorio
chmod 2755 directorio  # rwxr-sr-x (s en lugar de x para grupo)

# Sticky bit (1): Solo propietario puede eliminar en directorio
chmod +t directorio
chmod 1777 directorio  # rwxrwxrwt (t en lugar de x para otros, común en /tmp)

# Ver permisos especiales
ls -l archivo
# s en lugar de x = SUID/SGID
# t en lugar de x = Sticky bit

# Ejemplo práctico: /tmp normalmente tiene sticky bit
ls -ld /tmp
# Salida: drwxrwxrwt (t indica sticky bit)
```

### Tabla de Permisos Comunes

| Octal | Simbólico | Uso típico |
|-------|-----------|------------|
| `644` | `-rw-r--r--` | Archivos de texto, configuración |
| `755` | `-rwxr-xr-x` | Scripts, ejecutables, directorios |
| `700` | `-rwx------` | Archivos privados del usuario |
| `600` | `-rw-------` | Archivos sensibles (claves SSH) |
| `777` | `-rwxrwxrwx` | ⚠️ Evitar - muy inseguro |
| `444` | `-r--r--r--` | Archivos de solo lectura |
| `555` | `-r-xr-xr-x` | Ejecutables de solo lectura |
| `750` | `-rwxr-x---` | Scripts para grupo específico |
| `1777` | `drwxrwxrwt` | Directorios compartidos (/tmp) |

### Ejercicios Prácticos

```bash
# 1. Crear archivo y verificar permisos
touch archivo-prueba.txt
ls -l archivo-prueba.txt

# 2. Dar permisos de ejecución al propietario
chmod u+x archivo-prueba.txt
ls -l archivo-prueba.txt

# 3. Crear archivo privado (solo propietario)
echo "información secreta" > secreto.txt
chmod 600 secreto.txt
ls -l secreto.txt

# 4. Crear script ejecutable
cat > mi-script.sh << 'EOF'
#!/bin/bash
echo "Hola desde el script!"
whoami
EOF
chmod +x mi-script.sh
./mi-script.sh

# 5. Crear directorio compartido con permisos específicos
mkdir /tmp/compartido
chmod 775 /tmp/compartido
ls -ld /tmp/compartido

# 6. Cambiar propietario de archivo
chown usuario1:usuario1 secreto.txt
ls -l secreto.txt

# 7. Aplicar permisos recursivamente
mkdir -p /tmp/proyecto/{src,docs}
chmod -R 755 /tmp/proyecto
find /tmp/proyecto -type f -exec chmod 644 {} \;
find /tmp/proyecto -type d -exec ls -ld {} \;
```

## 2. Configurar SSH Keys

### ¿Qué son las SSH Keys?

Las SSH Keys son un par de claves criptográficas (pública y privada) que permiten autenticarse en servidores remotos sin usar contraseñas. Es más seguro que usar contraseñas.

**Ventajas:**
- Más seguro que contraseñas
- No necesitas escribir contraseña cada vez
- Requerido por muchos servicios (GitHub, GitLab, etc.)
- Puedes deshabilitar autenticación por contraseña después

### Generar Par de Claves SSH

```bash
# Generar par de claves SSH (tipo RSA, 4096 bits)
ssh-keygen -t rsa -b 4096

# Generar con email en comentario
ssh-keygen -t rsa -b 4096 -C "tu_email@ejemplo.com"

# Generar sin preguntas (para scripts)
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""

# Generar con Ed25519 (más moderno y seguro)
ssh-keygen -t ed25519 -C "tu_email@ejemplo.com"

# Especificar nombre de archivo personalizado
ssh-keygen -t rsa -b 4096 -f ~/.ssh/mi_servidor
```

**Proceso interactivo:**
1. Te pedirá dónde guardar la clave (presiona Enter para `~/.ssh/id_rsa`)
2. Te pedirá una passphrase (puedes dejarla vacía o poner una contraseña)
3. Se crearán dos archivos:
   - `~/.ssh/id_rsa` → clave privada (¡nunca compartas esta!)
   - `~/.ssh/id_rsa.pub` → clave pública (esta es la que compartes)

### Ver Claves SSH Existentes

```bash
# Ver todas las claves públicas
ls -la ~/.ssh/*.pub

# Ver contenido de clave pública
cat ~/.ssh/id_rsa.pub

# Ver información de clave pública
ssh-keygen -y -f ~/.ssh/id_rsa

# Listar todas las claves (públicas y privadas)
ls -la ~/.ssh/
```

### Copiar Clave Pública al Servidor Remoto

#### Método 1: ssh-copy-id (Recomendado)

```bash
# Copiar clave al servidor (pedirá contraseña)
ssh-copy-id usuario@servidor.com

# Copiar clave a puerto específico
ssh-copy-id -p 2222 usuario@servidor.com

# Copiar clave específica
ssh-copy-id -i ~/.ssh/mi_clave.pub usuario@servidor.com

# Desde Windows (si tienes Git Bash o WSL)
ssh-copy-id usuario@servidor.com
```

#### Método 2: Manual (si ssh-copy-id no está disponible)

```bash
# 1. Ver tu clave pública
cat ~/.ssh/id_rsa.pub

# 2. Copiar el contenido completo

# 3. Conectarte al servidor
ssh usuario@servidor.com

# 4. En el servidor, crear directorio .ssh si no existe
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# 5. Agregar clave pública al archivo authorized_keys
echo "tu_clave_publica_aqui" >> ~/.ssh/authorized_keys

# 6. Establecer permisos correctos
chmod 600 ~/.ssh/authorized_keys

# 7. Verificar
cat ~/.ssh/authorized_keys
```

#### Método 3: Usando cat y pipe (una línea)

```bash
# Copiar clave pública directamente
cat ~/.ssh/id_rsa.pub | ssh usuario@servidor.com "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
```

### Conectarse con Clave SSH

```bash
# Conectar usando clave por defecto (~/.ssh/id_rsa)
ssh usuario@servidor.com

# Conectar usando clave específica
ssh -i ~/.ssh/mi_clave usuario@servidor.com

# Conectar a puerto específico
ssh -p 2222 -i ~/.ssh/id_rsa usuario@servidor.com

# Conectar con modo verbose (para debugging)
ssh -v usuario@servidor.com
ssh -vv usuario@servidor.com  # más verbose
ssh -vvv usuario@servidor.com # máximo verbose
```

### Configurar SSH Client (Config File)

Crear archivo `~/.ssh/config` para simplificar conexiones:

```bash
# Crear/editar archivo de configuración
nano ~/.ssh/config
```

**Contenido del archivo:**
```
# Servidor de producción
Host produccion
    HostName servidor.com
    User usuario
    Port 22
    IdentityFile ~/.ssh/id_rsa
    ServerAliveInterval 60

# Servidor de desarrollo
Host desarrollo
    HostName dev.servidor.com
    User devuser
    Port 2222
    IdentityFile ~/.ssh/dev_key

# Servidor con proxy
Host servidor-detras-proxy
    HostName servidor-interno.com
    User admin
    ProxyJump usuario@proxy.com
    IdentityFile ~/.ssh/id_rsa
```

**Usar configuración:**
```bash
# Ahora puedes conectarte simplemente con:
ssh produccion
ssh desarrollo
```

**Permisos del archivo config:**
```bash
chmod 600 ~/.ssh/config
```

### Configurar Servidor SSH (sshd_config)

**⚠️ Importante:** Los cambios en `/etc/ssh/sshd_config` requieren reiniciar el servicio SSH.

```bash
# Editar configuración SSH del servidor
sudo nano /etc/ssh/sshd_config
```

**Configuraciones recomendadas:**
```
# Permitir autenticación por clave pública
PubkeyAuthentication yes

# Opcional: Deshabilitar autenticación por contraseña (solo después de configurar keys)
# PasswordAuthentication no

# Permitir solo ciertos usuarios (opcional)
# AllowUsers usuario1 usuario2

# Denegar acceso a root (recomendado)
PermitRootLogin no

# Usar protocolo 2 (más seguro)
Protocol 2

# Deshabilitar login vacío
PermitEmptyPasswords no
```

**Aplicar cambios:**
```bash
# Verificar configuración (solo muestra errores)
sudo sshd -t

# Reiniciar servicio SSH
sudo systemctl restart sshd
# O en contenedores:
sudo pkill sshd && sudo /usr/sbin/sshd

# Verificar que SSH está corriendo
sudo systemctl status sshd
# O:
ps aux | grep sshd
```

### Gestionar Múltiples Claves SSH

```bash
# Listar todas las claves
ls -la ~/.ssh/

# Agregar clave al agente SSH
ssh-add ~/.ssh/mi_clave

# Ver claves agregadas al agente
ssh-add -l

# Eliminar clave del agente
ssh-add -d ~/.ssh/mi_clave

# Eliminar todas las claves del agente
ssh-add -D

# Iniciar agente SSH (si no está corriendo)
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa
```

### Eliminar Clave SSH del Servidor

```bash
# Conectarse al servidor
ssh usuario@servidor.com

# Editar archivo authorized_keys
nano ~/.ssh/authorized_keys

# Eliminar la línea que contiene tu clave pública
# Guardar y salir (Ctrl+O, Enter, Ctrl+X)

# Verificar
cat ~/.ssh/authorized_keys
```

### Ejercicios Prácticos

```bash
# 1. Generar nueva clave SSH
ssh-keygen -t ed25519 -C "mi_email@ejemplo.com"

# 2. Ver clave pública
cat ~/.ssh/id_ed25519.pub

# 3. Copiar clave a servidor local (si tienes acceso)
ssh-copy-id usuario@localhost

# 4. Probar conexión sin contraseña
ssh usuario@localhost

# 5. Configurar múltiples claves para diferentes servidores
# Editar ~/.ssh/config
```

## 3. Configurar Swap

### ¿Qué es Swap?

Swap es un espacio en disco que se usa como memoria RAM virtual cuando la RAM física se agota. Aunque más lento que RAM, evita que el sistema se quede sin memoria.

### Verificar Swap Actual

```bash
# Ver información de swap
free -h

# Ver solo swap
swapon --show

# Ver información detallada
cat /proc/swaps

# Ver uso de swap en tiempo real
watch -n 1 free -h
```

### Crear Archivo de Swap

#### Paso 1: Crear archivo de swap

```bash
# Crear archivo de 2GB (ajustar según necesidad)
sudo fallocate -l 2G /swapfile

# O si fallocate no está disponible:
sudo dd if=/dev/zero of=/swapfile bs=1M count=2048

# Verificar que se creó
ls -lh /swapfile
```

#### Paso 2: Establecer permisos correctos

```bash
# Solo root debe poder leer/escribir
sudo chmod 600 /swapfile

# Verificar permisos
ls -l /swapfile
# Debe mostrar: -rw------- (600)
```

#### Paso 3: Formatear como swap

```bash
# Formatear archivo como swap
sudo mkswap /swapfile

# Deberías ver algo como:
# Setting up swapspace version 1, size = 2 GiB (2147479552 bytes)
```

#### Paso 4: Activar swap

```bash
# Activar swap
sudo swapon /swapfile

# Verificar que está activo
swapon --show
free -h
```

#### Paso 5: Hacer permanente (agregar a /etc/fstab)

```bash
# Hacer backup del fstab
sudo cp /etc/fstab /etc/fstab.backup

# Agregar entrada al fstab
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

# Verificar que se agregó correctamente
cat /etc/fstab
```

### Ajustar Swappiness

Swappiness controla qué tan agresivamente el sistema usa swap (0-100).

```bash
# Ver swappiness actual (por defecto suele ser 60)
cat /proc/sys/vm/swappiness

# Cambiar swappiness temporalmente
sudo sysctl vm.swappiness=10

# Cambiar swappiness permanentemente
echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf

# Aplicar cambios
sudo sysctl -p

# Verificar
cat /proc/sys/vm/swappiness
```

**Recomendaciones:**
- `0` → Solo usa swap cuando RAM está completamente llena
- `10` → Recomendado para servidores (menos swap, más RAM)
- `60` → Valor por defecto (balanceado)
- `100` → Usa swap agresivamente

### Eliminar Swap

```bash
# 1. Desactivar swap
sudo swapoff /swapfile

# 2. Eliminar entrada de /etc/fstab
sudo nano /etc/fstab
# Eliminar la línea: /swapfile none swap sw 0 0

# 3. Eliminar archivo
sudo rm /swapfile

# 4. Verificar
free -h
swapon --show
```

### Redimensionar Swap

```bash
# 1. Desactivar swap actual
sudo swapoff /swapfile

# 2. Eliminar archivo antiguo
sudo rm /swapfile

# 3. Crear nuevo archivo con tamaño diferente (ej: 4GB)
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile

# 4. Activar nuevo swap
sudo swapon /swapfile

# 5. Verificar
free -h
```

### Ejercicios Prácticos

```bash
# 1. Verificar estado actual de swap
free -h
swapon --show

# 2. Crear swap de 1GB
sudo fallocate -l 1G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# 3. Verificar que funciona
free -h

# 4. Hacer permanente
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

# 5. Ajustar swappiness a 10
echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

## 4. Instalar y Configurar fail2ban

### ¿Qué es fail2ban?

fail2ban es una herramienta que protege servidores de ataques de fuerza bruta monitoreando logs y bloqueando IPs que muestran comportamientos maliciosos.

### Instalar fail2ban

```bash
# Actualizar repositorios
sudo apt-get update

# Instalar fail2ban
sudo apt-get install -y fail2ban

# Instalar también sendmail o postfix si quieres recibir emails (opcional)
sudo apt-get install -y mailutils
# O solo postfix:
sudo apt-get install -y postfix

# Verificar instalación
fail2ban-client --version
which fail2ban-client
```

### Configuración Básica

fail2ban viene con configuración por defecto, pero es mejor crear un archivo de configuración local:

```bash
# Crear archivo de configuración local (no sobrescribe actualizaciones)
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

# Editar configuración
sudo nano /etc/fail2ban/jail.local
```

**Configuración básica recomendada:**
```
[DEFAULT]
# Dirección IP que no será baneada (tu IP)
ignoreip = 127.0.0.1/8 ::1

# Tiempo de baneo en segundos (10 minutos)
bantime = 600

# Ventana de tiempo para contar intentos fallidos
findtime = 600

# Número máximo de intentos antes del baneo
maxretry = 5

# Acción a tomar (banear IP)
action = %(action_)s

# Email para notificaciones (opcional)
destemail = admin@tudominio.com
sendername = Fail2Ban
mta = sendmail
```

### Configurar Protección SSH

```bash
# Editar jail.local
sudo nano /etc/fail2ban/jail.local
```

**Agregar o modificar sección [sshd]:**
```
[sshd]
enabled = true
port = ssh
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600
findtime = 600
```

**Aplicar configuración:**
```bash
# Reiniciar fail2ban
sudo systemctl restart fail2ban

# Verificar estado
sudo systemctl status fail2ban

# Verificar que está funcionando
sudo fail2ban-client status
```

### Comandos Útiles de fail2ban

```bash
# Ver estado general
sudo fail2ban-client status

# Ver estado de un jail específico
sudo fail2ban-client status sshd

# Ver IPs baneadas en un jail
sudo fail2ban-client status sshd

# Banear una IP manualmente
sudo fail2ban-client set sshd banip 192.168.1.100

# Desbanear una IP
sudo fail2ban-client set sshd unbanip 192.168.1.100

# Ver logs de fail2ban
sudo tail -f /var/log/fail2ban.log

# Recargar configuración sin reiniciar
sudo fail2ban-client reload

# Ver todas las acciones disponibles
sudo fail2ban-client get sshd actions
```

### Configurar Otros Servicios

#### Proteger Apache/Nginx

```bash
sudo nano /etc/fail2ban/jail.local
```

**Agregar:**
```
[apache-auth]
enabled = true
port = http,https
logpath = /var/log/apache2/*error.log

[nginx-http-auth]
enabled = true
port = http,https
logpath = /var/log/nginx/error.log
```

#### Proteger MySQL/MariaDB

```
[mysqld-auth]
enabled = true
port = 3306
logpath = /var/log/mysql/error.log
```

### Verificar y Monitorear

```bash
# Ver logs en tiempo real
sudo tail -f /var/log/fail2ban.log

# Ver intentos fallidos de SSH
sudo grep "Failed password" /var/log/auth.log | tail -20

# Ver IPs baneadas actualmente
sudo fail2ban-client status sshd | grep "Banned IP"

# Ver estadísticas
sudo fail2ban-client status sshd
```

### Desinstalar fail2ban

```bash
# Detener servicio
sudo systemctl stop fail2ban

# Desinstalar
sudo apt-get remove --purge fail2ban

# Eliminar configuración (opcional)
sudo rm -rf /etc/fail2ban/
```

### Ejercicios Prácticos

```bash
# 1. Instalar fail2ban
sudo apt-get update
sudo apt-get install -y fail2ban

# 2. Crear configuración local
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

# 3. Configurar protección SSH básica
sudo nano /etc/fail2ban/jail.local
# Asegurarse de que [sshd] tenga enabled = true

# 4. Reiniciar servicio
sudo systemctl restart fail2ban
sudo systemctl enable fail2ban

# 5. Verificar estado
sudo fail2ban-client status
sudo fail2ban-client status sshd

# 6. Monitorear logs
sudo tail -f /var/log/fail2ban.log
```

## Resumen de Comandos Esenciales

### Permisos
```bash
ls -l archivo              # Ver permisos
chmod 755 archivo          # Cambiar permisos (octal)
chmod u+x archivo          # Cambiar permisos (simbólico)
chown user:group archivo   # Cambiar propietario
chgrp grupo archivo        # Cambiar grupo
umask                      # Ver umask actual
```

### SSH Keys
```bash
ssh-keygen -t rsa -b 4096           # Generar clave
ssh-copy-id usuario@servidor        # Copiar clave al servidor
ssh -i ~/.ssh/clave usuario@servidor  # Conectar con clave específica
cat ~/.ssh/id_rsa.pub               # Ver clave pública
```

### Swap
```bash
free -h                    # Ver memoria y swap
swapon --show              # Ver swap activo
sudo swapon /swapfile      # Activar swap
sudo swapoff /swapfile     # Desactivar swap
cat /proc/sys/vm/swappiness  # Ver swappiness
```

### fail2ban
```bash
sudo fail2ban-client status              # Ver estado
sudo fail2ban-client status sshd         # Ver jail específico
sudo fail2ban-client set sshd banip IP   # Banear IP
sudo fail2ban-client set sshd unbanip IP # Desbanear IP
sudo tail -f /var/log/fail2ban.log      # Ver logs
```

