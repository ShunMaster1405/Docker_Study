# Guía Práctica: Gestión de Usuarios en Linux

## Herramientas Necesarias

Antes de comenzar, instala las siguientes herramientas:

```bash
# Actualizar repositorios
apt-get update

# Instalar Nano (editor de texto)
apt-get install -y nano

# Instalar herramientas de monitoreo de procesos
apt-get install -y htop procps

# Verificar instalación
which nano
which htop
ps --version
```

## Configurar SSH en el Contenedor Docker (Opcional)

Si quieres probar conexiones SSH remotas dentro del contenedor:

### Paso 1: Instalar SSH Server

```bash
# Instalar openssh-server
apt-get install -y openssh-server

# Crear directorio necesario
mkdir -p /var/run/sshd

# Verificar instalación
which sshd
```

### Paso 2: Configurar SSH

```bash
# Establecer contraseña para root (necesaria para SSH)
passwd root
# Ingresa una contraseña (ejemplo: root123)

# Configurar SSH para permitir root (temporalmente)
nano /etc/ssh/sshd_config
```

**⚠️ IMPORTANTE: Descomentar o agregar líneas**

Dentro de nano, busca estas líneas (presiona `Ctrl+W` para buscar):

**Buscar y descomentar:**
```
#PermitRootLogin yes
```
**Cambiar a (quitar el #):**
```
PermitRootLogin yes
```

**Buscar y descomentar:**
```
#PasswordAuthentication yes
```
**Cambiar a (quitar el #):**
```
PasswordAuthentication yes
```

**Si no las encuentras o están muy comentadas**, agrega estas líneas al final del archivo (sin #):
```
PermitRootLogin yes
PasswordAuthentication yes
PubkeyAuthentication yes
```

**Guardar y salir:**
- Guardar: `Ctrl+O`, `Enter`
- Salir: `Ctrl+X`

**Verificar configuración:**
```bash
# Ver qué configuración está activa (sin comentarios)
grep -E "^PermitRootLogin|^PasswordAuthentication" /etc/ssh/sshd_config | grep -v "^#"

# Debe mostrar:
# PermitRootLogin yes
# PasswordAuthentication yes
```

### Paso 3: Modificar docker-compose.yml

**Desde el host** (fuera del contenedor), edita tu `docker-compose.yml`:

```yaml
services:
  linux-server:
    image: ubuntu:24.04
    container_name: ubuntu-playground
    tty: true
    ports:
      - "8080:80"
      - "2222:22"  # Agregar esta línea para SSH
    volumes:
      - ./misarchivos:/root/workspace
    restart: unless-stopped
```

**Reiniciar el contenedor:**
```bash
# Desde el host (fuera del contenedor)
docker-compose down
docker-compose up -d
```

### Paso 4: Iniciar SSH dentro del contenedor

```bash
# Dentro del contenedor
# Iniciar SSH server
/usr/sbin/sshd

# Verificar que está corriendo
ps aux | grep sshd

# Ver puerto escuchando
netstat -tlnp | grep :22
# O si netstat no está:
ss -tlnp | grep :22
```

### Paso 5: Conectarse por SSH desde el host

**Desde tu máquina (host), abre otra terminal:**

```bash
# Conectarse por SSH al contenedor
ssh root@localhost -p 2222

# Ingresa la contraseña que configuraste
# Ahora estás conectado por SSH!
```

### ⚠️ Solución de problemas: "Permission denied"

Si obtienes el error **"Permission denied, please try again"** al intentar conectarte:

#### Problema 1: Líneas comentadas en sshd_config

**Síntoma:** Las líneas `PermitRootLogin` y `PasswordAuthentication` están comentadas (con `#`)

**Solución:**
```bash
# Verificar qué está activo
grep -E "^PermitRootLogin|^PasswordAuthentication" /etc/ssh/sshd_config | grep -v "^#"

# Si no muestra nada o muestra líneas con #, necesitas descomentarlas
nano /etc/ssh/sshd_config

# Buscar (Ctrl+W) y cambiar:
# #PermitRootLogin yes  →  PermitRootLogin yes
# #PasswordAuthentication yes  →  PasswordAuthentication yes

# O agregar al final del archivo (sin #):
PermitRootLogin yes
PasswordAuthentication yes

# Guardar (Ctrl+O, Enter) y salir (Ctrl+X)

# Reiniciar SSH
pkill sshd
/usr/sbin/sshd

# Verificar
grep -E "^PermitRootLogin|^PasswordAuthentication" /etc/ssh/sshd_config | grep -v "^#"
```

#### Problema 2: Contraseña incorrecta

**Solución:**
```bash
# Verificar que root tiene contraseña
passwd -S root

# Cambiar contraseña si es necesario
passwd root
# Ingresa una contraseña simple para probar (ejemplo: root123)
```

#### Problema 3: SSH no reiniciado después de cambios

**Solución:**
```bash
# Detener SSH
pkill sshd

# Iniciar SSH nuevamente
/usr/sbin/sshd

# Verificar que está corriendo
ps aux | grep sshd

# Verificar puerto
ss -tlnp | grep :22
```

#### Problema 4: Verificar configuración activa

```bash
# Ver configuración que SSH está usando realmente
sshd -T | grep -E "permitrootlogin|passwordauthentication"

# Debe mostrar:
# permitrootlogin yes
# passwordauthentication yes
```

#### Verificación completa antes de conectar

```bash
# 1. Verificar que SSH está corriendo
ps aux | grep sshd | grep -v grep

# 2. Verificar puerto
ss -tlnp | grep :22

# 3. Verificar configuración
grep -E "^PermitRootLogin|^PasswordAuthentication" /etc/ssh/sshd_config | grep -v "^#"

# 4. Verificar contraseña de root
passwd -S root

# 5. Probar conexión desde el host
ssh root@localhost -p 2222
```

### Paso 6: Verificar conexión SSH

```bash
# Dentro del contenedor, ver quién está conectado
who
w

# Ver conexiones SSH activas
netstat -tn | grep :22
# O
ss -tn | grep :22
```

### Paso 7: Probar bloqueo SSH de root

```bash
# Editar configuración SSH
nano /etc/ssh/sshd_config

# Cambiar:
# PermitRootLogin no

# Reiniciar SSH
pkill sshd
/usr/sbin/sshd

# Desde el host, intentar conectarse (debe fallar):
ssh root@localhost -p 2222
# Debe dar: "Permission denied"
```

### Comandos útiles para SSH

```bash
# Ver configuración SSH activa
sshd -T | grep permitroot

# Ver configuración del archivo (sin comentarios)
grep -E "^PermitRootLogin|^PasswordAuthentication" /etc/ssh/sshd_config | grep -v "^#"

# Ver intentos de conexión SSH
tail -f /var/log/auth.log

# Ver procesos SSH
ps aux | grep sshd

# Verificar que SSH está escuchando
ss -tlnp | grep :22

# Detener SSH
pkill sshd

# Iniciar SSH
/usr/sbin/sshd

# Iniciar SSH en primer plano (debug)
/usr/sbin/sshd -D
```

### ⚠️ Problema común: "Permission denied" al conectar

**Causa más frecuente:** Las líneas en `/etc/ssh/sshd_config` están comentadas (con `#`)

**Solución rápida:**
```bash
# Verificar qué está activo
grep -E "^PermitRootLogin|^PasswordAuthentication" /etc/ssh/sshd_config | grep -v "^#"

# Si no muestra nada, las líneas están comentadas
# Editar y descomentar o agregar al final:
nano /etc/ssh/sshd_config
# Agregar estas líneas SIN # al final:
PermitRootLogin yes
PasswordAuthentication yes

# Reiniciar SSH
pkill sshd && /usr/sbin/sshd

# Verificar
grep -E "^PermitRootLogin|^PasswordAuthentication" /etc/ssh/sshd_config | grep -v "^#"
```

## 1. Crear Usuarios en Linux

### Crear usuario con directorio home
```bash
useradd -m -s /bin/bash nombre_usuario
```

### Establecer contraseña
```bash
passwd nombre_usuario
```

### Verificar que se creó correctamente
```bash
# Ver información del usuario
id nombre_usuario

# Ver todos los usuarios
cat /etc/passwd | tail -10

# Ver grupos del usuario
groups nombre_usuario
```

### Eliminar usuario
```bash
# Eliminar usuario y su directorio home
userdel -r nombre_usuario
```

## 2. Otorgar Permisos Sudo

### Método 1: Agregar al grupo sudo (recomendado)
```bash
usermod -aG sudo nombre_usuario
```

### Método 2: Crear archivo de configuración
```bash
echo "nombre_usuario ALL=(ALL:ALL) ALL" > /etc/sudoers.d/nombre_usuario
chmod 0440 /etc/sudoers.d/nombre_usuario
```

### Verificar permisos sudo
```bash
# Ver si el usuario está en el grupo sudo
groups nombre_usuario | grep -q sudo && echo "Tiene permisos sudo" || echo "No tiene permisos sudo"

# Ver todos los usuarios con sudo
getent group sudo | cut -d: -f4
```

### Remover permisos sudo
```bash
# Remover del grupo sudo
gpasswd -d nombre_usuario sudo

# Eliminar archivo de configuración
rm -f /etc/sudoers.d/nombre_usuario

# Verificar
groups nombre_usuario
```

## 3. Deshabilitar Login Root

### ⚠️ Importante: Tipos de login

Existen diferentes formas de acceder como root:

| Método | Descripción | Cómo bloquearlo |
|--------|-------------|-----------------|
| **SSH** (remoto) | Conexión por red: `ssh root@servidor` | `PermitRootLogin no` en SSH |
| **Login local** | Consola física: `login root` | `usermod -s /usr/sbin/nologin` |
| **su / su -** | Cambiar a root: `su -` | `usermod -s /usr/sbin/nologin` |
| **docker exec** | Acceso directo al contenedor | No se puede bloquear (es acceso directo) |

### Método 1: Deshabilitar shell de root (bloquea login local y su)

**Este método bloquea:**
- ✅ Login local (`login root`)
- ✅ Cambiar a root (`su -`, `su - root`)
- ❌ NO bloquea SSH (necesitas configurar SSH aparte)
- ❌ NO bloquea `docker exec` (acceso directo)

```bash
# Deshabilitar shell de root
usermod -s /usr/sbin/nologin root

# Verificar
getent passwd root | cut -d: -f7
# Debe mostrar: /usr/sbin/nologin

# Probar (debe fallar)
su -
# Error: "This account is currently not available"
```

### Método 2: Bloquear cuenta de root

**Este método bloquea:**
- ✅ Login con contraseña (local y SSH)
- ❌ NO bloquea `su -` si ya eres otro usuario con permisos

```bash
# Bloquear cuenta
passwd -l root

# Verificar estado
passwd -S root
# Debe mostrar "L" (locked)
```

### Método 3: Deshabilitar SSH de root (solo bloquea acceso remoto)

**⚠️ IMPORTANTE**: Este método **SOLO bloquea SSH**, no el login local.

**Este método bloquea:**
- ✅ SSH remoto (`ssh root@servidor`)
- ❌ NO bloquea login local (`login root`)
- ❌ NO bloquea `su -`
- ❌ NO bloquea `docker exec`

**Editar configuración SSH con Nano:**
```bash
# Editar archivo de configuración
nano /etc/ssh/sshd_config
```

**Dentro de nano:**
- Buscar la línea: `PermitRootLogin` (presiona `Ctrl+W`, escribe "PermitRootLogin")
- Cambiar o agregar: `PermitRootLogin no`
- Guardar: `Ctrl+O`, `Enter`
- Salir: `Ctrl+X`

**Reiniciar SSH (si está instalado):**
```bash
# Si systemd no funciona (contenedores)
pkill sshd
/usr/sbin/sshd

# Verificar configuración
grep PermitRootLogin /etc/ssh/sshd_config

# Probar (desde otra máquina, debe fallar)
ssh root@direccion_ip
```

### Método 4: Combinación (más seguro)

Para bloquear todos los accesos excepto `docker exec`:

```bash
# 1. Deshabilitar shell (bloquea login local y su)
usermod -s /usr/sbin/nologin root

# 2. Bloquear cuenta (bloquea contraseña)
passwd -l root

# 3. Si tienes SSH: deshabilitar SSH de root
# Editar /etc/ssh/sshd_config → PermitRootLogin no
# pkill sshd && /usr/sbin/sshd

# Verificar todo
getent passwd root | cut -d: -f7  # Debe mostrar nologin
passwd -S root                     # Debe mostrar L
grep PermitRootLogin /etc/ssh/sshd_config  # Debe mostrar no
```

### Tabla resumen

| Quieres bloquear | Comando necesario |
|------------------|-------------------|
| Login local (`login root`) | `usermod -s /usr/sbin/nologin root` |
| Cambiar a root (`su -`) | `usermod -s /usr/sbin/nologin root` |
| SSH remoto (`ssh root@...`) | `PermitRootLogin no` en `/etc/ssh/sshd_config` |
| Todo (excepto docker exec) | Combinar los 3 métodos |

### Habilitar root nuevamente
```bash
# Restaurar shell
usermod -s /bin/bash root

# Desbloquear cuenta
passwd -u root

# Verificar
getent passwd root | cut -d: -f7
passwd -S root
```

## 4. Monitorear Procesos por Usuario

### Ver procesos de un usuario específico
```bash
# Con ps
ps -u nombre_usuario

# Ver todos los procesos con detalles
ps aux | grep nombre_usuario

# Ver procesos con formato personalizado
ps -U nombre_usuario -o pid,user,%cpu,%mem,command
```

### Usar htop (interfaz interactiva)
```bash
# Abrir htop
htop

# Filtrar por usuario dentro de htop:
# - Presiona F4
# - Escribe el nombre del usuario
# - Enter

# Salir de htop: F10 o q
```

### Ver información detallada de procesos
```bash
# Ver número de procesos de un usuario
ps -u nombre_usuario | wc -l

# Ver procesos con uso de CPU
ps -u nombre_usuario -o pid,user,%cpu,command --sort=-%cpu

# Ver procesos con uso de memoria
ps -u nombre_usuario -o pid,user,%mem,command --sort=-%mem
```

### Matar procesos específicos

#### Opción 1: Matar proceso por PID
```bash
# Ver procesos y sus PIDs
ps -u nombre_usuario

# Matar proceso específico por PID
kill PID

# Ejemplo: matar proceso con PID 1234
kill 1234

# Forzar eliminación (si no responde)
kill -9 PID
```

#### Opción 2: Matar proceso por nombre
```bash
# Matar un proceso específico por nombre
killall nombre_proceso

# Ejemplo: matar todos los procesos "sleep"
killall sleep

# Forzar eliminación
killall -9 nombre_proceso
```

#### Opción 3: Matar proceso con pkill (más flexible)
```bash
# Matar proceso por nombre exacto
pkill nombre_proceso

# Matar proceso por nombre parcial
pkill -f "parte_del_nombre"

# Matar proceso específico de un usuario
pkill -u nombre_usuario nombre_proceso

# Ejemplo: matar solo "sleep 100" del usuario1
pkill -u usuario1 -f "sleep 100"

# Forzar eliminación
pkill -9 -u nombre_usuario nombre_proceso
```

#### Opción 4: Matar proceso en htop (interfaz interactiva)

**Método 1: Seleccionar y matar**
```bash
# Abrir htop
htop

# Pasos dentro de htop:
# 1. Usa las flechas ↑↓ para seleccionar el proceso
# 2. Presiona F9 (o tecla "k")
# 3. Selecciona la señal (15=SIGTERM, 9=SIGKILL)
# 4. Presiona Enter para confirmar
```

**Método 2: Filtrar y matar**
```bash
# Abrir htop
htop

# Pasos:
# 1. Presiona F4 para filtrar
# 2. Escribe el nombre del proceso o usuario
# 3. Selecciona el proceso con flechas
# 4. Presiona F9 para matar
# 5. Selecciona señal y confirma
```

**Método 3: Buscar y matar**
```bash
# Abrir htop
htop

# Pasos:
# 1. Presiona "/" para buscar
# 2. Escribe el nombre del proceso
# 3. Presiona F3 para encontrar siguiente
# 4. Presiona F9 para matar el proceso seleccionado
```

### Diferencias entre señales

```bash
# SIGTERM (15) - Terminación normal (permite limpieza)
kill -15 PID
kill PID  # (por defecto usa SIGTERM)

# SIGKILL (9) - Terminación forzada (no permite limpieza)
kill -9 PID
kill -KILL PID

# SIGINT (2) - Interrupción (como Ctrl+C)
kill -2 PID
kill -INT PID

# SIGHUP (1) - Recargar configuración
kill -1 PID
kill -HUP PID
```

### Ejemplos prácticos

```bash
# Ver procesos de usuario1
ps -u usuario1

# Salida ejemplo:
# PID   TTY      TIME CMD
# 1234  pts/0    00:00:00 sleep
# 1235  pts/0    00:00:00 sleep
# 1236  pts/0    00:00:00 bash

# Matar solo el proceso con PID 1234
kill 1234

# Verificar que se mató
ps -u usuario1

# Matar todos los procesos "sleep" del usuario1
pkill -u usuario1 sleep

# Matar proceso específico por patrón
pkill -u usuario1 -f "sleep 200"

# Ver procesos antes de matar
ps -u usuario1 -o pid,user,command
# Anotar el PID del proceso que quieres matar
# Matar ese proceso específico
kill 1235
```

### Matar todos los procesos de un usuario
```bash
# Matar todos los procesos de un usuario
pkill -u nombre_usuario

# Forzar eliminación de todos los procesos
pkill -9 -u nombre_usuario

# Ver procesos antes de matar
ps -u nombre_usuario
```

### Verificar que el proceso se mató
```bash
# Ver si el proceso aún existe
ps -p PID

# Ver procesos del usuario
ps -u nombre_usuario

# Ver procesos por nombre
pgrep -a nombre_proceso
```

## 5. Permisos de Archivos y Directorios

### Conceptos básicos

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

### Ver permisos actuales

```bash
# Ver permisos de un archivo
ls -l archivo.txt
# Ejemplo de salida: -rw-r--r-- 1 root root 0 Jan 5 12:00 archivo.txt

# Ver permisos de un directorio
ls -ld /tmp/carpeta
# Ejemplo: drwxr-xr-x 2 root root 4096 Jan 5 12:00 /tmp/carpeta

# Ver permisos de todos los archivos en un directorio
ls -la /ruta/directorio
```

**Interpretar permisos:**
```
-rw-r--r--
│├──┼──┼──
│ │  │  └── Otros: r-- (solo lectura)
│ │  └───── Grupo: r-- (solo lectura)
│ └──────── Propietario: rw- (lectura y escritura)
└────────── Tipo: - (archivo regular), d (directorio)
```

### Cambiar permisos con chmod

#### Método 1: Notación octal (numérica)

```bash
# Sintaxis: chmod [permisos_octales] archivo

# Permisos comunes:
chmod 644 archivo.txt   # rw-r--r-- (lectura para todos, escritura solo propietario)
chmod 755 script.sh     # rwxr-xr-x (ejecutable por todos, escritura solo propietario)
chmod 700 privado.txt   # rwx------ (solo propietario tiene todos los permisos)
chmod 777 publico.txt   # rwxrwxrwx (todos pueden hacer todo - NO RECOMENDADO)
chmod 600 secreto.txt   # rw------- (solo propietario lee/escribe)
chmod 444 soloLectura   # r--r--r-- (solo lectura para todos)
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
```

#### Método 2: Notación simbólica

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

# Múltiples cambios
chmod u+x,g-w,o-rwx archivo.txt
```

#### Aplicar permisos recursivamente

```bash
# Cambiar permisos de un directorio y TODO su contenido
chmod -R 755 /ruta/directorio

# Cambiar permisos solo de archivos (no directorios)
find /ruta -type f -exec chmod 644 {} \;

# Cambiar permisos solo de directorios
find /ruta -type d -exec chmod 755 {} \;
```

### Cambiar propietario con chown

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
```

### Cambiar solo grupo con chgrp

```bash
# Cambiar grupo de un archivo
chgrp grupo archivo.txt

# Cambiar grupo recursivamente
chgrp -R grupo /ruta/directorio

# Ejemplos
chgrp desarrolladores codigo.py
chgrp -R usuarios /home/compartido
```

### Permisos predeterminados con umask

```bash
# Ver umask actual
umask

# Establecer umask
umask 022   # Archivos nuevos: 644, Directorios: 755
umask 077   # Archivos nuevos: 600, Directorios: 700

# Cálculo: permisos = 777 - umask (directorios), 666 - umask (archivos)
# umask 022 → archivos: 666-022=644, directorios: 777-022=755
```

### Permisos especiales (avanzado)

```bash
# SUID (4): Ejecutar como propietario
chmod u+s archivo
chmod 4755 archivo  # rwsr-xr-x

# SGID (2): Ejecutar como grupo / heredar grupo en directorio
chmod g+s directorio
chmod 2755 directorio  # rwxr-sr-x

# Sticky bit (1): Solo propietario puede eliminar en directorio
chmod +t directorio
chmod 1777 directorio  # rwxrwxrwt (común en /tmp)

# Ver permisos especiales
ls -l archivo
# s en lugar de x = SUID/SGID
# t en lugar de x = Sticky bit
```

### Tabla de permisos comunes

| Octal | Simbólico | Uso típico |
|-------|-----------|------------|
| `644` | `-rw-r--r--` | Archivos de texto, configuración |
| `755` | `-rwxr-xr-x` | Scripts, ejecutables, directorios |
| `700` | `-rwx------` | Archivos privados del usuario |
| `600` | `-rw-------` | Archivos sensibles (claves SSH) |
| `777` | `-rwxrwxrwx` | ⚠️ Evitar - muy inseguro |
| `444` | `-r--r--r--` | Archivos de solo lectura |
| `555` | `-r-xr-xr-x` | Ejecutables de solo lectura |
| `1777` | `drwxrwxrwt` | Directorios compartidos (/tmp) |

### Ejemplos prácticos

```bash
# ============================================
# Crear archivo y verificar permisos
# ============================================
touch archivo-prueba.txt
ls -l archivo-prueba.txt

# Dar permisos de ejecución al propietario
chmod u+x archivo-prueba.txt
ls -l archivo-prueba.txt

# ============================================
# Crear archivo que solo el propietario pueda leer
# ============================================
echo "información secreta" > secreto.txt
chmod 600 secreto.txt
ls -l secreto.txt

# Verificar que otros usuarios no pueden leer
su - usuario1 -c "cat /root/secreto.txt"  # Debe fallar

# ============================================
# Crear directorio compartido
# ============================================
mkdir /tmp/compartido
chmod 777 /tmp/compartido
ls -ld /tmp/compartido

# Crear archivo dentro
touch /tmp/compartido/archivo.txt
chmod 666 /tmp/compartido/archivo.txt

# ============================================
# Cambiar propietario de archivo
# ============================================
touch archivo-usuario1.txt
chown usuario1:usuario1 archivo-usuario1.txt
ls -l archivo-usuario1.txt

# ============================================
# Permisos para que un usuario específico pueda acceder
# ============================================
# Crear archivo de root
echo "datos importantes" > /root/workspace/datos.txt
ls -l /root/workspace/datos.txt

# Dar permisos de lectura a otros
chmod o+r /root/workspace/datos.txt

# O cambiar propietario
chown usuario1 /root/workspace/datos.txt
```

### Verificar acceso de un usuario

```bash
# Ver permisos de un archivo
ls -l archivo.txt

# Ver propietario y grupo
stat archivo.txt

# Probar acceso como otro usuario
su - nombre_usuario -c "cat archivo.txt"
su - nombre_usuario -c "echo 'test' >> archivo.txt"

# Ver grupos de un usuario
groups nombre_usuario
id nombre_usuario
```

## Comandos Útiles Adicionales

### Ver quién está conectado
```bash
who
w
```

### Ver usuario actual
```bash
whoami
id
```

### Cambiar de usuario
```bash
su - nombre_usuario
```

### Ver todos los usuarios del sistema
```bash
cat /etc/passwd
cut -d: -f1 /etc/passwd
```

### Navegar directorios
```bash
# Ir a directorio raíz
cd /

# Ir a directorio /etc
cd /etc

# Ver dónde estás
pwd

# Volver al directorio anterior
cd -
```

---

## Actividad Práctica

### Objetivo
Aplicar los comandos aprendidos en un contenedor Docker con Ubuntu 24.04.

### Lo que aprenderás en esta actividad:
1. ✅ Crear usuarios con directorio home
2. ✅ Otorgar y verificar permisos sudo
3. ✅ **Deshabilitar TODOS los login de root** (SSH + local + su)
4. ✅ Monitorear procesos por usuario
5. ✅ **Matar procesos específicos** (por PID, nombre, y con htop)
6. ✅ **Gestionar permisos de archivos** (chmod, chown, rwx)
7. ✅ **Configurar y usar SSH en el contenedor** (opcional)
8. ✅ **Probar bloqueo SSH remoto** (opcional)
9. ✅ Verificar y auditar el sistema
10. ✅ Revertir todos los cambios

### Requisitos previos
- Docker instalado
- Archivo `docker-compose.yml` configurado
- Aproximadamente 30-45 minutos para completar la actividad

### Paso 1: Iniciar el contenedor

Desde el directorio del proyecto:

```bash
# Iniciar el contenedor
docker-compose up -d

# Verificar que está corriendo
docker ps

# Acceder al contenedor
docker exec -it ubuntu-playground bash
```

### Paso 2: Instalar herramientas necesarias

Dentro del contenedor:

```bash
# Actualizar repositorios
apt-get update

# Instalar herramientas básicas
apt-get install -y nano htop procps

# Verificar instalación
which nano
which htop
```

### Paso 2b: Instalar SSH (Opcional - para probar login remoto)

Si quieres probar conexiones SSH:

```bash
# Instalar SSH server
apt-get install -y openssh-server

# Crear directorio necesario
mkdir -p /var/run/sshd

# Configurar contraseña para root
passwd root
# Ingresa: root123 (o la que prefieras)

# Configurar SSH para permitir root temporalmente
nano /etc/ssh/sshd_config

# IMPORTANTE: Buscar (Ctrl+W) estas líneas y DESCOMENTARLAS (quitar el #):
# #PermitRootLogin yes  →  PermitRootLogin yes
# #PasswordAuthentication yes  →  PasswordAuthentication yes

# Si no las encuentras, agregar al final del archivo (sin #):
PermitRootLogin yes
PasswordAuthentication yes

# Guardar: Ctrl+O, Enter
# Salir: Ctrl+X

# Verificar configuración
grep -E "^PermitRootLogin|^PasswordAuthentication" /etc/ssh/sshd_config | grep -v "^#"
# Debe mostrar las líneas sin #

# Iniciar SSH
/usr/sbin/sshd

# Verificar que SSH está corriendo
ps aux | grep sshd
# Debe mostrar: sshd: /usr/sbin/sshd [listener]

# Verificar puerto
ss -tlnp | grep :22
echo "✓ SSH instalado y corriendo"
```

**Nota importante**: Si instalaste SSH, necesitas exponer el puerto 22 en `docker-compose.yml`:

```bash
# Salir del contenedor temporalmente
exit

# Desde el host, editar docker-compose.yml
# Agregar bajo ports:
#   - "2222:22"

# Reiniciar contenedor
docker-compose down
docker-compose up -d

# Volver a entrar
docker exec -it ubuntu-playground bash

# Iniciar SSH nuevamente
/usr/sbin/sshd
```

**Probar SSH desde otra terminal del host:**
```bash
# Abrir nueva terminal en el host
ssh root@localhost -p 2222
# Ingresa la contraseña: root123
```

### Paso 3: Crear usuarios

```bash
# Crear usuario1 con directorio home
useradd -m -s /bin/bash usuario1

# Establecer contraseña
passwd usuario1
# Ingresa: pass123

# Crear usuario2
useradd -m -s /bin/bash usuario2

# Establecer contraseña
passwd usuario2
# Ingresa: pass456

# Verificar que se crearon
cat /etc/passwd | tail -5
id usuario1
id usuario2
```

### Paso 4: Otorgar permisos sudo

```bash
# Otorgar permisos sudo a usuario1
usermod -aG sudo usuario1

# Verificar permisos
groups usuario1

# Ver si tiene sudo
groups usuario1 | grep -q sudo && echo "Tiene sudo" || echo "No tiene sudo"

# Ver todos los usuarios con sudo
getent group sudo
```

### Paso 5: Deshabilitar TODOS los login de root (SSH y local)

```bash
# ============================================
# PARTE 1: Verificar estado actual
# ============================================
echo "=== Estado actual de root ==="
getent passwd root | cut -d: -f7
passwd -S root

# ============================================
# PARTE 2: Deshabilitar login local y su
# ============================================
echo ""
echo "=== Deshabilitando login local ==="

# Deshabilitar shell de root (bloquea login local y su -)
usermod -s /usr/sbin/nologin root

# Verificar cambio
getent passwd root | cut -d: -f7
# Debe mostrar: /usr/sbin/nologin

# ============================================
# PARTE 3: Bloquear cuenta con contraseña
# ============================================
echo ""
echo "=== Bloqueando cuenta ==="

# Bloquear cuenta de root (bloquea contraseña)
passwd -l root

# Verificar
passwd -S root
# Debe mostrar "L" (locked)

# ============================================
# PARTE 4: Deshabilitar SSH (si está instalado)
# ============================================
echo ""
echo "=== Configurando SSH (si existe) ==="

# Verificar si SSH está instalado
if [ -f /etc/ssh/sshd_config ]; then
    echo "SSH encontrado, configurando..."
    
    # Crear backup del archivo
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup
    
    # Agregar o modificar PermitRootLogin
    if grep -q "^PermitRootLogin" /etc/ssh/sshd_config; then
        sed -i 's/^PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
    else
        echo "PermitRootLogin no" >> /etc/ssh/sshd_config
    fi
    
    # Verificar configuración
    grep PermitRootLogin /etc/ssh/sshd_config
    
    # Reiniciar SSH (si está corriendo)
    pkill sshd 2>/dev/null
    /usr/sbin/sshd 2>/dev/null &
    
    echo "SSH configurado: PermitRootLogin no"
else
    echo "SSH no está instalado (normal en contenedores)"
fi

# ============================================
# PARTE 5: Verificar que todo está bloqueado
# ============================================
echo ""
echo "=== Verificación final ==="
echo "Shell de root: $(getent passwd root | cut -d: -f7)"
echo "Estado de cuenta: $(passwd -S root | awk '{print $2}')"

if [ -f /etc/ssh/sshd_config ]; then
    echo "SSH PermitRootLogin: $(grep PermitRootLogin /etc/ssh/sshd_config | grep -v "^#")"
fi

# ============================================
# PARTE 6: Probar que no funciona
# ============================================
echo ""
echo "=== Probando bloqueos ==="

# Intentar cambiar a root (debe fallar)
echo "Probando 'su -' (debe fallar):"
su - 2>&1 | head -1 || echo "✓ Login local bloqueado correctamente"

# Nota: docker exec sigue funcionando porque es acceso directo
echo ""
echo "Nota: 'docker exec' sigue funcionando porque es acceso directo al contenedor"

# ============================================
# PARTE 7: Probar bloqueo SSH (si instalaste SSH)
# ============================================
if command -v sshd &> /dev/null; then
    echo ""
    echo "=== PROBANDO BLOQUEO SSH ==="
    echo ""
    echo "SSH está instalado. Ahora prueba desde OTRA TERMINAL del host:"
    echo ""
    echo "  ssh root@localhost -p 2222"
    echo ""
    echo "Debería fallar con: 'Permission denied' o 'This account is currently not available'"
    echo ""
    read -p "Presiona Enter cuando hayas probado..."
else
    echo ""
    echo "SSH no está instalado (normal en contenedores básicos)"
fi
```

### Paso 6: Monitorear y matar procesos específicos

```bash
# ============================================
# PARTE 1: Crear procesos para monitorear
# ============================================
echo "=== Creando procesos de prueba ==="

# Ver procesos actuales de usuario1
ps -u usuario1

# Cambiar a usuario1 y ejecutar algunos procesos
su - usuario1
# Ingresa contraseña: pass123

# Ejecutar diferentes procesos en background
sleep 100 &
sleep 200 &
sleep 300 &
sleep 400 &

# Guardar los PIDs
echo "Procesos creados. Anotando PIDs..."
ps -u usuario1 -o pid,command

# Salir del usuario
exit

# ============================================
# PARTE 2: Ver y analizar procesos
# ============================================
echo ""
echo "=== Analizando procesos de usuario1 ==="

# Ver todos los procesos de usuario1
ps -u usuario1

# Ver con formato detallado
ps -u usuario1 -o pid,user,%cpu,%mem,command

# Ejemplo de salida:
#   PID USER     %CPU %MEM COMMAND
#  1234 usuario1  0.0  0.0 sleep 100
#  1235 usuario1  0.0  0.0 sleep 200
#  1236 usuario1  0.0  0.0 sleep 300
#  1237 usuario1  0.0  0.0 sleep 400

# Contar número de procesos
echo "Número total de procesos de usuario1:"
ps -u usuario1 | wc -l

# ============================================
# PARTE 3: Matar UN proceso específico por PID
# ============================================
echo ""
echo "=== Matando proceso específico por PID ==="

# Ver los PIDs actuales
ps -u usuario1 -o pid,command

# ANOTAR el primer PID (ejemplo: 1234)
# Matar ese proceso específico
# Reemplaza 1234 con el PID real que viste
echo "Matando proceso con PID 1234 (ajusta según tu caso):"
# kill 1234

# IMPORTANTE: Usa el PID real que viste arriba
# Para este ejemplo, vamos a matar el primer proceso sleep
PRIMER_PID=$(ps -u usuario1 -o pid,command | grep "sleep 100" | awk '{print $1}')
echo "PID a matar: $PRIMER_PID"
kill $PRIMER_PID

# Verificar que se mató SOLO ese proceso
echo "Procesos restantes:"
ps -u usuario1 -o pid,command
# Deben quedar 3 procesos (sleep 200, 300, 400)

# ============================================
# PARTE 4: Matar proceso específico por nombre/patrón
# ============================================
echo ""
echo "=== Matando proceso específico por patrón ==="

# Ver procesos actuales
ps -u usuario1 -o pid,command

# Matar SOLO el proceso "sleep 200"
pkill -u usuario1 -f "sleep 200"

# Verificar que se mató solo ese
echo "Procesos restantes después de matar 'sleep 200':"
ps -u usuario1 -o pid,command
# Deben quedar 2 procesos (sleep 300, 400)

# ============================================
# PARTE 5: Usar htop para matar proceso específico
# ============================================
echo ""
echo "=== Usando htop para matar procesos ==="
echo "Instrucciones para htop:"
echo "1. Ejecuta: htop"
echo "2. Presiona F4 y escribe: usuario1"
echo "3. Usa flechas ↑↓ para seleccionar 'sleep 300'"
echo "4. Presiona F9 (kill)"
echo "5. Selecciona señal 15 (SIGTERM)"
echo "6. Presiona Enter para confirmar"
echo "7. Presiona F10 para salir"
echo ""
read -p "Presiona Enter para abrir htop..."

# Abrir htop
htop

# Después de salir de htop, verificar
echo ""
echo "Verificando procesos después de htop:"
ps -u usuario1 -o pid,command
# Debe quedar 1 proceso (sleep 400) si mataste sleep 300

# ============================================
# PARTE 6: Comparar procesos entre usuarios
# ============================================
echo ""
echo "=== Comparando procesos entre usuarios ==="

# Ver número de procesos por usuario
echo "Procesos de usuario1: $(ps -u usuario1 | wc -l)"
echo "Procesos de usuario2: $(ps -u usuario2 | wc -l)"

# Ver todos los procesos de ambos usuarios
echo ""
echo "=== usuario1 ==="
ps -u usuario1 -o pid,user,%cpu,%mem,command

echo ""
echo "=== usuario2 ==="
ps -u usuario2 -o pid,user,%cpu,%mem,command

# ============================================
# PARTE 7: Matar procesos restantes
# ============================================
echo ""
echo "=== Limpiando procesos restantes ==="

# Ver procesos antes de matar
echo "Procesos de usuario1 antes de limpiar:"
ps -u usuario1 -o pid,command

# Matar TODOS los procesos restantes de usuario1
pkill -u usuario1

# Verificar que se mataron todos
echo "Procesos de usuario1 después de limpiar:"
ps -u usuario1 || echo "✓ No hay procesos de usuario1"

# ============================================
# PARTE 8: Resumen de comandos usados
# ============================================
echo ""
echo "=== RESUMEN DE COMANDOS ==="
echo "✓ ps -u usuario        → Ver procesos de un usuario"
echo "✓ kill PID             → Matar proceso por PID"
echo "✓ pkill -f 'patrón'    → Matar proceso por patrón"
echo "✓ htop                 → Ver y matar interactivamente"
echo "✓ pkill -u usuario     → Matar todos los procesos de un usuario"
```

### Paso 7: Gestionar permisos de archivos

```bash
# ============================================
# PARTE 1: Ver permisos actuales
# ============================================
echo "=== Verificando permisos actuales ==="

# Ir al directorio de trabajo
cd /root/workspace

# Crear archivos de prueba
touch archivo-root.txt
echo "Este archivo es de root" > archivo-root.txt

# Ver permisos
ls -l archivo-root.txt
# Salida: -rw-r--r-- 1 root root ... archivo-root.txt

# Explicación:
# -rw-r--r-- = archivo regular, root puede leer/escribir, otros solo leer
echo ""
echo "Permisos actuales:"
echo "  Propietario (root): rw- (lectura y escritura)"
echo "  Grupo (root): r-- (solo lectura)"
echo "  Otros: r-- (solo lectura)"

# ============================================
# PARTE 2: Probar acceso con diferentes usuarios
# ============================================
echo ""
echo "=== Probando acceso de usuario1 ==="

# usuario1 puede LEER el archivo (tiene r para otros)
su - usuario1 -c "cat /root/workspace/archivo-root.txt"
echo "✓ usuario1 puede leer el archivo"

# usuario1 NO puede ESCRIBIR (no tiene w para otros)
su - usuario1 -c "echo 'modificado' >> /root/workspace/archivo-root.txt" 2>&1 || echo "✗ usuario1 NO puede escribir (esperado)"

# ============================================
# PARTE 3: Quitar permisos de lectura a otros
# ============================================
echo ""
echo "=== Quitando permisos de lectura a otros ==="

# Quitar permisos de lectura para otros
chmod o-r archivo-root.txt
ls -l archivo-root.txt
# Ahora: -rw-r----- (otros no tienen permisos)

# Probar que usuario1 ya NO puede leer
su - usuario1 -c "cat /root/workspace/archivo-root.txt" 2>&1 || echo "✗ usuario1 ya NO puede leer (correcto!)"

# ============================================
# PARTE 4: Cambiar propietario del archivo
# ============================================
echo ""
echo "=== Cambiando propietario a usuario1 ==="

# Crear archivo nuevo
touch archivo-usuario1.txt
echo "Archivo para usuario1" > archivo-usuario1.txt

# Cambiar propietario
chown usuario1:usuario1 archivo-usuario1.txt
ls -l archivo-usuario1.txt
# Ahora: -rw-r--r-- 1 usuario1 usuario1 ...

# usuario1 ahora puede modificar SU archivo
su - usuario1 -c "echo 'agregado por usuario1' >> /root/workspace/archivo-usuario1.txt"
su - usuario1 -c "cat /root/workspace/archivo-usuario1.txt"
echo "✓ usuario1 puede escribir en su propio archivo"

# ============================================
# PARTE 5: Crear archivo privado
# ============================================
echo ""
echo "=== Creando archivo privado ==="

# Crear archivo con información sensible
echo "contraseña_secreta=abc123" > secreto.txt

# Dar permisos 600 (solo propietario lee/escribe)
chmod 600 secreto.txt
ls -l secreto.txt
# -rw------- (solo root puede acceder)

# Verificar que otros usuarios no pueden leer
su - usuario1 -c "cat /root/workspace/secreto.txt" 2>&1 || echo "✗ usuario1 NO puede leer el secreto (correcto!)"

# ============================================
# PARTE 6: Crear directorio compartido
# ============================================
echo ""
echo "=== Creando directorio compartido ==="

# Crear directorio en /tmp (accesible por todos)
mkdir -p /tmp/compartido
chmod 777 /tmp/compartido
ls -ld /tmp/compartido
# drwxrwxrwx (todos pueden todo)

# Crear archivo dentro como root
echo "archivo de root en compartido" > /tmp/compartido/archivo-root.txt
chmod 666 /tmp/compartido/archivo-root.txt
ls -l /tmp/compartido/

# usuario1 puede crear archivos en el directorio compartido
su - usuario1 -c "echo 'archivo de usuario1' > /tmp/compartido/archivo-usuario1.txt"
ls -l /tmp/compartido/

# usuario1 puede modificar el archivo de root (tiene permisos 666)
su - usuario1 -c "echo 'modificado por usuario1' >> /tmp/compartido/archivo-root.txt"
cat /tmp/compartido/archivo-root.txt
echo "✓ usuario1 puede modificar archivos en directorio compartido"

# ============================================
# PARTE 7: Permisos para scripts ejecutables
# ============================================
echo ""
echo "=== Creando script ejecutable ==="

# Crear script simple
cat > /root/workspace/mi-script.sh << 'EOF'
#!/bin/bash
echo "Hola desde el script!"
echo "Usuario actual: $(whoami)"
echo "Fecha: $(date)"
EOF

# Ver permisos iniciales
ls -l mi-script.sh
# -rw-r--r-- (no es ejecutable)

# Intentar ejecutar (debe fallar)
./mi-script.sh 2>&1 || echo "✗ No se puede ejecutar (falta permiso x)"

# Agregar permiso de ejecución
chmod u+x mi-script.sh
ls -l mi-script.sh
# -rwxr--r-- (ahora tiene x para propietario)

# Ahora sí se puede ejecutar
./mi-script.sh
echo "✓ Script ejecutado correctamente"

# Dar permiso de ejecución a todos
chmod a+x mi-script.sh
ls -l mi-script.sh
# -rwxr-xr-x

# usuario1 también puede ejecutarlo
su - usuario1 -c "/root/workspace/mi-script.sh"
echo "✓ usuario1 también puede ejecutar el script"

# ============================================
# PARTE 8: Permisos con notación octal
# ============================================
echo ""
echo "=== Usando notación octal ==="

# Crear archivos de prueba
touch octal-644.txt octal-755.txt octal-700.txt

# Aplicar diferentes permisos
chmod 644 octal-644.txt   # rw-r--r--
chmod 755 octal-755.txt   # rwxr-xr-x
chmod 700 octal-700.txt   # rwx------

# Ver resultados
ls -l octal-*.txt
echo ""
echo "644 = rw-r--r-- (lectura para todos, escritura solo propietario)"
echo "755 = rwxr-xr-x (ejecutable por todos)"
echo "700 = rwx------ (solo propietario)"

# ============================================
# PARTE 9: Verificar acceso según permisos
# ============================================
echo ""
echo "=== Tabla de verificación de acceso ==="
echo ""
echo "| Archivo        | Permisos   | usuario1 lee | usuario1 escribe |"
echo "|----------------|------------|--------------|------------------|"

# Probar octal-644 (otros tienen r)
u1_lee_644=$(su - usuario1 -c "cat /root/workspace/octal-644.txt" 2>/dev/null && echo "✓ Sí" || echo "✗ No")
u1_escribe_644=$(su - usuario1 -c "echo 'x' >> /root/workspace/octal-644.txt" 2>/dev/null && echo "✓ Sí" || echo "✗ No")
echo "| octal-644.txt  | rw-r--r--  | $u1_lee_644          | $u1_escribe_644              |"

# Probar octal-755 (otros tienen r-x)
u1_lee_755=$(su - usuario1 -c "cat /root/workspace/octal-755.txt" 2>/dev/null && echo "✓ Sí" || echo "✗ No")
u1_escribe_755=$(su - usuario1 -c "echo 'x' >> /root/workspace/octal-755.txt" 2>/dev/null && echo "✓ Sí" || echo "✗ No")
echo "| octal-755.txt  | rwxr-xr-x  | $u1_lee_755          | $u1_escribe_755              |"

# Probar octal-700 (otros no tienen nada)
u1_lee_700=$(su - usuario1 -c "cat /root/workspace/octal-700.txt" 2>/dev/null && echo "✓ Sí" || echo "✗ No")
u1_escribe_700=$(su - usuario1 -c "echo 'x' >> /root/workspace/octal-700.txt" 2>/dev/null && echo "✓ Sí" || echo "✗ No")
echo "| octal-700.txt  | rwx------  | $u1_lee_700          | $u1_escribe_700              |"

# ============================================
# PARTE 10: Limpiar archivos de prueba
# ============================================
echo ""
echo "=== Limpiando archivos de prueba ==="

# Eliminar archivos creados
rm -f /root/workspace/archivo-root.txt
rm -f /root/workspace/archivo-usuario1.txt
rm -f /root/workspace/secreto.txt
rm -f /root/workspace/mi-script.sh
rm -f /root/workspace/octal-*.txt
rm -rf /tmp/compartido

echo "✓ Archivos de prueba eliminados"

# ============================================
# PARTE 11: Resumen de comandos usados
# ============================================
echo ""
echo "=== RESUMEN DE COMANDOS DE PERMISOS ==="
echo "✓ ls -l archivo       → Ver permisos"
echo "✓ chmod 644 archivo   → Permisos con notación octal"
echo "✓ chmod u+x archivo   → Agregar permiso de ejecución"
echo "✓ chmod o-r archivo   → Quitar permiso de lectura a otros"
echo "✓ chown user:group    → Cambiar propietario"
echo "✓ su - user -c 'cmd'  → Probar como otro usuario"
```

### Paso 8: Verificación final completa (incluye permisos)

```bash
# ============================================
# VERIFICACIÓN 1: Usuarios creados
# ============================================
echo "=== VERIFICACIÓN DE USUARIOS ==="
echo ""
echo "Usuarios creados en esta sesión:"
cat /etc/passwd | grep -E "usuario1|usuario2"

echo ""
echo "Información detallada:"
id usuario1
id usuario2

# ============================================
# VERIFICACIÓN 2: Permisos sudo
# ============================================
echo ""
echo "=== VERIFICACIÓN DE PERMISOS SUDO ==="
echo ""
echo "Grupos de usuario1:"
groups usuario1
echo "¿Tiene sudo?: $(groups usuario1 | grep -q sudo && echo 'SÍ ✓' || echo 'NO ✗')"

echo ""
echo "Grupos de usuario2:"
groups usuario2
echo "¿Tiene sudo?: $(groups usuario2 | grep -q sudo && echo 'SÍ ✓' || echo 'NO ✗')"

echo ""
echo "Todos los usuarios con sudo:"
getent group sudo | cut -d: -f4

# ============================================
# VERIFICACIÓN 3: Estado de root (TODOS los bloqueos)
# ============================================
echo ""
echo "=== VERIFICACIÓN DE BLOQUEO DE ROOT ==="
echo ""
echo "1. Shell de root:"
getent passwd root | cut -d: -f7
echo "   Estado: $([ "$(getent passwd root | cut -d: -f7)" = "/usr/sbin/nologin" ] && echo '✓ Bloqueado' || echo '✗ NO bloqueado')"

echo ""
echo "2. Estado de cuenta:"
passwd -S root
echo "   Estado: $(passwd -S root | grep -q "L" && echo '✓ Bloqueada' || echo '✗ NO bloqueada')"

echo ""
echo "3. Configuración SSH:"
if [ -f /etc/ssh/sshd_config ]; then
    grep PermitRootLogin /etc/ssh/sshd_config | grep -v "^#"
    echo "   Estado: $(grep -q "PermitRootLogin no" /etc/ssh/sshd_config && echo '✓ SSH bloqueado' || echo '✗ SSH NO bloqueado')"
else
    echo "   SSH no instalado (normal en contenedores)"
fi

# ============================================
# VERIFICACIÓN 4: Probar bloqueos de root
# ============================================
echo ""
echo "=== PROBANDO BLOQUEOS ==="
echo ""
echo "Intentando 'su -' (debe fallar):"
su - 2>&1 | head -1 || echo "✓ Login local bloqueado correctamente"

# ============================================
# VERIFICACIÓN 5: Usuarios por tipo de shell
# ============================================
echo ""
echo "=== USUARIOS POR TIPO DE SHELL ==="
echo ""
echo "Usuarios con shell de login (bash/sh/zsh):"
grep -E '/bin/(bash|sh|zsh)' /etc/passwd | cut -d: -f1

echo ""
echo "Usuarios con nologin (deshabilitados):"
grep nologin /etc/passwd | cut -d: -f1

# ============================================
# VERIFICACIÓN 6: Procesos activos
# ============================================
echo ""
echo "=== PROCESOS ACTIVOS ==="
echo ""
echo "Procesos de usuario1:"
ps -u usuario1 2>/dev/null || echo "Sin procesos activos"

echo ""
echo "Procesos de usuario2:"
ps -u usuario2 2>/dev/null || echo "Sin procesos activos"

# ============================================
# RESUMEN FINAL
# ============================================
echo ""
echo "============================================"
echo "           RESUMEN DE ACTIVIDAD"
echo "============================================"
echo ""
echo "✓ Usuarios creados: usuario1, usuario2"
echo "✓ Permisos sudo: usuario1 tiene sudo"
echo "✓ Login root bloqueado:"
echo "  - Shell: nologin ✓"
echo "  - Cuenta: bloqueada ✓"
echo "  - SSH: configurado (si existe) ✓"
echo "✓ Procesos monitoreados y gestionados"
echo ""
echo "Actividad completada exitosamente!"
```

### Paso 8: Revertir TODOS los cambios (opcional)

```bash
# ============================================
# PASO 1: Habilitar root completamente
# ============================================
echo "=== Habilitando root nuevamente ==="

# Restaurar shell de root
usermod -s /bin/bash root
echo "Shell restaurado: $(getent passwd root | cut -d: -f7)"

# Desbloquear cuenta de root
passwd -u root
echo "Cuenta desbloqueada: $(passwd -S root)"

# Restaurar SSH (si existe)
if [ -f /etc/ssh/sshd_config.backup ]; then
    echo "Restaurando configuración SSH original..."
    cp /etc/ssh/sshd_config.backup /etc/ssh/sshd_config
    echo "SSH restaurado"
    
    # Reiniciar SSH
    pkill sshd 2>/dev/null
    /usr/sbin/sshd 2>/dev/null &
elif [ -f /etc/ssh/sshd_config ]; then
    echo "Configurando SSH para permitir root..."
    sed -i 's/^PermitRootLogin no/PermitRootLogin yes/' /etc/ssh/sshd_config
    echo "SSH configurado: $(grep PermitRootLogin /etc/ssh/sshd_config | grep -v "^#")"
    
    # Reiniciar SSH
    pkill sshd 2>/dev/null
    /usr/sbin/sshd 2>/dev/null &
else
    echo "SSH no está instalado"
fi

# Verificar que root está habilitado
echo ""
echo "Verificación de root:"
echo "Shell: $(getent passwd root | cut -d: -f7)"
echo "Estado: $(passwd -S root)"

# Probar que funciona
echo ""
echo "Probando 'su -' (ahora debe funcionar, pero te pedirá contraseña):"
# su -  # Descomenta si quieres probar

# ============================================
# PASO 2: Remover permisos sudo
# ============================================
echo ""
echo "=== Removiendo permisos sudo ==="

# Remover permisos sudo de usuario1
gpasswd -d usuario1 sudo

# Verificar
echo "Grupos de usuario1: $(groups usuario1)"
echo "¿Tiene sudo?: $(groups usuario1 | grep -q sudo && echo 'SÍ' || echo 'NO ✓')"

# ============================================
# PASO 3: Eliminar usuarios creados
# ============================================
echo ""
echo "=== Eliminando usuarios creados ==="

# Matar procesos antes de eliminar usuarios
pkill -u usuario1 2>/dev/null
pkill -u usuario2 2>/dev/null

# Eliminar usuarios con sus directorios home
userdel -r usuario1 2>/dev/null && echo "✓ usuario1 eliminado" || echo "✗ Error eliminando usuario1"
userdel -r usuario2 2>/dev/null && echo "✓ usuario2 eliminado" || echo "✗ Error eliminando usuario2"

# Verificar que se eliminaron
echo ""
echo "Verificando eliminación:"
cat /etc/passwd | grep -E "usuario1|usuario2" && echo "✗ Usuarios aún existen" || echo "✓ Usuarios eliminados correctamente"

# ============================================
# PASO 4: Limpiar archivos de configuración
# ============================================
echo ""
echo "=== Limpiando archivos de configuración ==="

# Eliminar archivos sudoers si existen
rm -f /etc/sudoers.d/usuario1 2>/dev/null && echo "✓ Archivo sudoers eliminado"
rm -f /etc/sudoers.d/usuario2 2>/dev/null

# Eliminar backup de SSH si existe
rm -f /etc/ssh/sshd_config.backup 2>/dev/null && echo "✓ Backup SSH eliminado"

# ============================================
# VERIFICACIÓN FINAL
# ============================================
echo ""
echo "============================================"
echo "        VERIFICACIÓN DE REVERSIÓN"
echo "============================================"
echo ""
echo "Estado de root:"
echo "  Shell: $(getent passwd root | cut -d: -f7)"
echo "  Cuenta: $(passwd -S root | awk '{print $2}')"
if [ -f /etc/ssh/sshd_config ]; then
    echo "  SSH: $(grep PermitRootLogin /etc/ssh/sshd_config | grep -v "^#" | head -1)"
fi

echo ""
echo "Usuarios:"
cat /etc/passwd | grep -E "usuario1|usuario2" || echo "  ✓ Todos los usuarios de prueba eliminados"

echo ""
echo "✓ Reversión completada - Sistema restaurado al estado inicial"
```

### Paso 9: Salir del contenedor

```bash
# Salir del contenedor
exit

# Detener el contenedor (desde el host)
docker-compose down
```

---

## Ejercicios Adicionales

### Ejercicio 1: Crear un usuario con permisos limitados
1. Crear un usuario `operador` con directorio home
2. Otorgar permisos sudo solo para comandos específicos:
   - Solo puede ejecutar `systemctl restart *`
3. Verificar que funciona
4. Probar ejecutar otros comandos (debe fallar)

**Solución:**
```bash
# Crear usuario
useradd -m -s /bin/bash operador
passwd operador

# Crear archivo de configuración sudo
echo "operador ALL=(ALL) /usr/bin/systemctl restart *" > /etc/sudoers.d/operador
chmod 0440 /etc/sudoers.d/operador

# Verificar
cat /etc/sudoers.d/operador
```

### Ejercicio 2: Monitorear recursos
1. Crear 3 usuarios: `dev1`, `dev2`, `dev3`
2. Ejecutar procesos en cada usuario
3. Comparar uso de recursos entre usuarios
4. Identificar cuál usuario consume más recursos

**Solución:**
```bash
# Crear usuarios
for user in dev1 dev2 dev3; do
  useradd -m -s /bin/bash $user
  passwd $user
done

# Ver procesos por usuario
for user in dev1 dev2 dev3; do
  echo "=== $user ==="
  ps -u $user -o pid,user,%cpu,%mem,command
done
```

### Ejercicio 3: Gestión de permisos
1. Crear un directorio `/tmp/proyecto` con permisos 770
2. Agregar usuario `dev1` al grupo `root`
3. Crear archivos con diferentes permisos y probar acceso
4. Crear un script ejecutable que solo pueda ejecutar su propietario

**Solución:**
```bash
# Crear directorio con permisos 770 (propietario y grupo tienen todo)
mkdir /tmp/proyecto
chmod 770 /tmp/proyecto
ls -ld /tmp/proyecto

# Agregar dev1 al grupo root
usermod -aG root dev1

# Crear archivos con diferentes permisos
touch /tmp/proyecto/publico.txt
touch /tmp/proyecto/privado.txt
touch /tmp/proyecto/grupo.txt

chmod 644 /tmp/proyecto/publico.txt   # Todos leen
chmod 600 /tmp/proyecto/privado.txt   # Solo propietario
chmod 660 /tmp/proyecto/grupo.txt     # Propietario y grupo

# Verificar
ls -l /tmp/proyecto/

# Crear script solo ejecutable por propietario
cat > /tmp/proyecto/admin.sh << 'EOF'
#!/bin/bash
echo "Script de administración"
EOF
chmod 700 /tmp/proyecto/admin.sh
ls -l /tmp/proyecto/admin.sh
```

### Ejercicio 4: Auditoría de usuarios
1. Listar todos los usuarios del sistema
2. Identificar usuarios con permisos sudo
3. Identificar usuarios con shell deshabilitado
4. Generar un reporte

**Solución:**
```bash
echo "=== REPORTE DE USUARIOS ==="
echo ""
echo "Total de usuarios:"
getent passwd | wc -l
echo ""
echo "Usuarios con sudo:"
getent group sudo | cut -d: -f4
echo ""
echo "Usuarios con shell deshabilitado:"
grep nologin /etc/passwd | cut -d: -f1
echo ""
echo "Usuarios con shell de login:"
grep -E '/bin/(bash|sh|zsh)' /etc/passwd | cut -d: -f1
```

### Ejercicio 5: Control de acceso a archivos
1. Crear un archivo `reporte.txt` que solo root pueda leer y escribir
2. Crear un archivo `publico.txt` que todos puedan leer pero solo root escribir
3. Crear un directorio `/tmp/equipo` donde solo el grupo `sudo` pueda escribir
4. Verificar que los permisos funcionan con diferentes usuarios

**Solución:**
```bash
# Archivo solo para root (600)
echo "Datos confidenciales" > /root/reporte.txt
chmod 600 /root/reporte.txt
ls -l /root/reporte.txt

# Archivo público de lectura (644)
echo "Información pública" > /tmp/publico.txt
chmod 644 /tmp/publico.txt
ls -l /tmp/publico.txt

# Directorio para grupo sudo (770)
mkdir /tmp/equipo
chown root:sudo /tmp/equipo
chmod 770 /tmp/equipo
ls -ld /tmp/equipo

# Verificar con usuario1 (asumiendo que tiene sudo)
su - usuario1 -c "ls -la /tmp/equipo"
su - usuario1 -c "touch /tmp/equipo/mi-archivo.txt"  # Debe funcionar si tiene sudo
ls -l /tmp/equipo/
```

---

## Notas Importantes

- **En contenedores Docker**: 
  - `systemctl` no funciona por defecto (no hay systemd)
  - SSH generalmente no está instalado por defecto
  - `docker exec` es acceso directo, no se puede bloquear
  - Para usar SSH: instala `openssh-server` y expón el puerto 22 en `docker-compose.yml`
  - Para reiniciar SSH en contenedores: `pkill sshd && /usr/sbin/sshd`
  
- **SSH en contenedores**:
  - Puerto recomendado: `2222:22` (host:contenedor)
  - Conexión desde host: `ssh root@localhost -p 2222`
  - Requiere contraseña de root: `passwd root`
  - Útil para probar bloqueos remotos de root
  
- **Diferencia entre login local y SSH**:
  - `PermitRootLogin no` solo bloquea SSH (acceso remoto)
  - Para bloquear login local usa `usermod -s /usr/sbin/nologin root`
  - Para bloquear todo: combina ambos métodos
  
- **Acceso a contenedores**: 
  - `docker exec`: Acceso directo (no usa SSH)
  - SSH: Acceso remoto (requiere instalación y configuración)
  
- **Permisos root**: Todos estos comandos requieren privilegios de root
- **Contraseñas**: En producción, usa contraseñas seguras
- **Backup**: Siempre ten un usuario con sudo antes de deshabilitar root
- **Verificación**: Verifica cada cambio antes de aplicar el siguiente

- **Permisos de archivos**:
  - `chmod` cambia permisos (lectura/escritura/ejecución)
  - `chown` cambia propietario y grupo
  - Los permisos se leen de izquierda a derecha: propietario, grupo, otros
  - Usa `ls -l` para ver permisos, `ls -ld` para directorios
  - Permisos comunes: 644 (archivos), 755 (directorios/scripts), 600 (privado)

## Referencias Rápidas

### Atajos de Nano
- `Ctrl+O`: Guardar
- `Ctrl+X`: Salir
- `Ctrl+W`: Buscar
- `Ctrl+K`: Cortar línea
- `Ctrl+U`: Pegar

### Atajos de htop
- `F4`: Filtrar por texto
- `F5`: Vista de árbol
- `F9`: Matar proceso
- `F10` o `q`: Salir
- `/`: Buscar

### Comandos esenciales
```bash
whoami          # Usuario actual
pwd             # Directorio actual
cd /            # Ir a raíz
ls -la          # Listar archivos
cat archivo     # Ver contenido
grep texto      # Buscar texto
```

### SSH en contenedores Docker
```bash
# Instalar SSH
apt-get install -y openssh-server
mkdir -p /var/run/sshd

# Iniciar SSH
/usr/sbin/sshd

# Conectarse desde host (puerto 2222)
ssh root@localhost -p 2222

# Ver configuración SSH
grep PermitRootLogin /etc/ssh/sshd_config

# Reiniciar SSH
pkill sshd && /usr/sbin/sshd

# Ver conexiones SSH
who
w
```

**Nota**: Requiere exponer puerto en `docker-compose.yml`:
```yaml
ports:
  - "2222:22"
```

### Matar procesos
```bash
kill PID              # Matar por PID (señal SIGTERM)
kill -9 PID           # Forzar (señal SIGKILL)
killall nombre        # Matar por nombre
pkill nombre          # Matar por patrón
pkill -u usuario      # Matar todos de un usuario
ps -u usuario         # Ver procesos de usuario
ps -p PID             # Verificar si PID existe
```

### Señales comunes de kill
- **15 (SIGTERM)**: Terminación normal, permite limpieza (por defecto)
- **9 (SIGKILL)**: Terminación forzada, no permite limpieza
- **2 (SIGINT)**: Interrupción (como Ctrl+C)
- **1 (SIGHUP)**: Recargar configuración

### Permisos de archivos (chmod)
```bash
# Ver permisos
ls -l archivo.txt

# Notación octal
chmod 644 archivo.txt   # rw-r--r-- (lectura para todos)
chmod 755 archivo.txt   # rwxr-xr-x (ejecutable por todos)
chmod 700 archivo.txt   # rwx------ (solo propietario)
chmod 600 archivo.txt   # rw------- (privado)

# Notación simbólica
chmod u+x archivo.txt   # Agregar ejecución a propietario
chmod o-r archivo.txt   # Quitar lectura a otros
chmod a+r archivo.txt   # Agregar lectura a todos
chmod g+w archivo.txt   # Agregar escritura al grupo

# Recursivo
chmod -R 755 directorio/
```

### Cambiar propietario (chown)
```bash
# Cambiar propietario
chown usuario archivo.txt

# Cambiar propietario y grupo
chown usuario:grupo archivo.txt

# Recursivo
chown -R usuario:grupo directorio/
```

### Tabla de permisos octales
| Octal | Permisos | Descripción |
|-------|----------|-------------|
| 7 | rwx | Lectura + Escritura + Ejecución |
| 6 | rw- | Lectura + Escritura |
| 5 | r-x | Lectura + Ejecución |
| 4 | r-- | Solo lectura |
| 0 | --- | Sin permisos |

**Ejemplos comunes:**
- `644` = rw-r--r-- (archivos normales)
- `755` = rwxr-xr-x (directorios/scripts)
- `600` = rw------- (archivos privados)
- `700` = rwx------ (directorios privados)


