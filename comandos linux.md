# Guía Básica para Crear Usuarios en Linux

## Conceptos Básicos

### ¿Qué es el Directorio Home?

El **directorio home** es la carpeta personal de un usuario en Linux. Es su espacio privado donde puede guardar archivos, configuraciones y datos personales.

#### Características principales:

1. **Ubicación típica**: `/home/nombre_usuario`
   - Ejemplo: `/home/juan`, `/home/maria`, `/home/ubuntu`

2. **Propósito**:
   - Almacenar archivos personales (documentos, imágenes, videos, etc.)
   - Guardar configuraciones de aplicaciones (archivos ocultos que empiezan con `.`)
   - Contener archivos de trabajo del usuario
   - Servir como directorio de trabajo por defecto al iniciar sesión

3. **Permisos**:
   - El usuario es dueño de su directorio home
   - Solo él (y root) puede acceder por defecto
   - Otros usuarios no pueden ver sus archivos sin permisos explícitos

#### Ejemplo práctico:

```bash
# Usuario "juan" tiene directorio home en:
/home/juan

# Dentro puede tener:
/home/juan/Documentos
/home/juan/Imágenes
/home/juan/.bashrc      # archivo de configuración (oculto)
/home/juan/.ssh/        # configuración SSH (oculto)
/home/juan/archivo.txt
```

#### ¿Qué pasa si un usuario NO tiene directorio home?

- ❌ No puede guardar archivos personales fácilmente
- ❌ Las aplicaciones no saben dónde guardar configuraciones
- ❌ No tiene un lugar "por defecto" para trabajar
- ❌ Al iniciar sesión, no tiene un directorio de trabajo inicial
- ❌ Muchas aplicaciones pueden fallar o comportarse de forma inesperada

#### Comandos relacionados:

```bash
# Ver el directorio home de un usuario
getent passwd nombre_usuario | cut -d: -f6

# Ver el directorio home del usuario actual
echo $HOME

# Ir al directorio home
cd ~
# o simplemente
cd
```

#### En resumen:

El directorio home es como el **escritorio o la carpeta personal** del usuario: su espacio privado en el sistema donde puede guardar sus cosas de forma segura y organizada. **Siempre es recomendable crear usuarios con directorio home** usando la opción `-m` en el comando `useradd`.

### ¿Qué es el Shell?

El **Shell** es el **intérprete de comandos**: el programa que lee y ejecuta los comandos que escribes en la terminal.

#### Analogía simple:

- **Terminal** = La ventana donde escribes
- **Shell** = El programa que interpreta y ejecuta lo que escribes

#### Funciones principales:

1. **Interpreta comandos**: Cuando escribes `ls`, el shell busca el programa `ls` y lo ejecuta
2. **Gestiona variables de entorno**: Maneja `$HOME`, `$PATH`, etc.
3. **Ejecuta scripts**: Puede ejecutar archivos con múltiples comandos
4. **Proporciona funcionalidades**: Autocompletado, historial, alias, etc.

#### Tipos de Shell comunes:

**1. `/bin/bash` (Bash - Bourne Again Shell)**
- El más usado en Linux
- Recomendado para usuarios normales
- Permite iniciar sesión interactiva

**2. `/bin/sh` (Shell básico)**
- Shell simple y ligero
- Compatible con scripts estándar

**3. `/usr/sbin/nologin` o `/bin/false`**
- ⚠️ **NO es un shell real**
- Impide que el usuario inicie sesión
- Usado para usuarios del sistema o cuentas deshabilitadas

**4. Otros shells:**
- `/bin/zsh` (Z Shell) - Más moderno y con más características
- `/bin/fish` (Friendly Interactive Shell) - Interfaz amigable
- `/bin/tcsh` (C Shell) - Menos común

#### Ejemplo práctico:

```bash
# Usuario con shell bash (puede iniciar sesión)
usuario1:x:1001:1001:Usuario 1:/home/usuario1:/bin/bash
#                                                      ^^^^^^^^^
#                                                      Este es el shell

# Usuario del sistema (NO puede iniciar sesión)
daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
#                                              ^^^^^^^^^^^^^^^^
#                                              Shell que impide login
```

#### ¿Qué pasa si un usuario tiene `/usr/sbin/nologin`?

- ❌ No puede iniciar sesión en el sistema
- ❌ No puede usar SSH
- ❌ No puede abrir una terminal interactiva
- ✅ Útil para usuarios del sistema o cuentas deshabilitadas

#### Comandos relacionados:

```bash
# Ver el shell de un usuario
getent passwd nombre_usuario | cut -d: -f7

# Ver el shell del usuario actual
echo $SHELL

# Cambiar el shell de un usuario
usermod -s /bin/bash nombre_usuario

# Ver qué shells están disponibles
cat /etc/shells
```

#### En resumen:

El Shell es el **intérprete de comandos** que te permite interactuar con el sistema. Si un usuario tiene `/bin/bash` o `/bin/sh`, puede iniciar sesión y usar la terminal. Si tiene `/usr/sbin/nologin`, **no puede iniciar sesión** (útil para usuarios del sistema).

### ¿Qué es SSH?

**SSH** (Secure Shell) es un **protocolo de red** que permite conectarse de forma segura a un servidor o computadora remota a través de una red (internet o red local).

#### Analogía simple:

- **SSH** = Como una "llave segura" para entrar a otra computadora desde lejos
- Es como hacer login en otra máquina, pero de forma remota y cifrada

#### Funciones principales:

1. **Conexión remota segura**: Te conectas a otro servidor desde tu computadora
2. **Cifrado de datos**: Toda la comunicación está encriptada (segura)
3. **Autenticación**: Puedes usar contraseña o claves SSH para identificarte
4. **Ejecución remota**: Puedes ejecutar comandos en el servidor remoto
5. **Transferencia de archivos**: Puedes copiar archivos de forma segura (con SCP o SFTP)

#### Componentes de SSH:

**1. Cliente SSH** (`openssh-client`)
- El programa que usas para conectarte
- Comando: `ssh`
- Debe estar instalado en tu computadora local

**2. Servidor SSH** (`openssh-server`)
- El programa que recibe las conexiones
- Debe estar instalado y corriendo en el servidor remoto
- Escucha en el puerto 22 por defecto

#### Ejemplo práctico:

```bash
# Conectarte a un servidor remoto
ssh usuario@192.168.1.100

# O con nombre de dominio
ssh usuario@servidor.com

# El servidor te pedirá contraseña o usará tu clave SSH
```

#### ¿Cuándo usar SSH?

- ✅ Conectarte a servidores remotos (VPS, servidores en la nube)
- ✅ Administrar servidores Linux desde tu computadora
- ✅ Ejecutar comandos en máquinas remotas
- ✅ Transferir archivos de forma segura
- ✅ Túneles seguros para otros servicios

#### ¿Cuándo NO usar SSH?

- ❌ En contenedores Docker (generalmente no está instalado)
- ❌ Para cambiar de usuario en la misma máquina (usa `su` en su lugar)
- ❌ En sistemas locales sin red (usa `login` o `su`)

#### Instalación:

```bash
# Instalar cliente SSH (para conectarte a otros servidores)
apt-get install -y openssh-client

# Instalar servidor SSH (para que otros se conecten a ti)
apt-get install -y openssh-server
```

#### Seguridad:

- SSH cifra toda la comunicación
- Puedes usar claves SSH en lugar de contraseñas (más seguro)
- Por defecto usa el puerto 22, pero puedes cambiarlo
- Es el método estándar y seguro para administración remota

#### En resumen:

SSH es el **protocolo estándar** para conectarse de forma segura a servidores remotos. Te permite trabajar en otra computadora como si estuvieras sentado frente a ella, pero a través de internet. **Nota**: En contenedores Docker, SSH generalmente no está instalado por defecto, usa `su` para cambiar de usuario en su lugar.

### Otros Conceptos Importantes

- **UID (User ID)**: Identificador numérico único del usuario. Root siempre tiene UID 0. Los usuarios normales generalmente tienen UID >= 1000.
- **GID (Group ID)**: Identificador numérico del grupo principal del usuario. Cada usuario pertenece a al menos un grupo.
- **Usuario del sistema**: Usuarios con UID < 1000, generalmente usados por servicios y aplicaciones, no para login humano. Ejemplos: `daemon`, `www-data`, `nobody`.

## Comandos Principales

### 1. Crear un usuario básico
```bash
useradd nombre_usuario
```

### 2. Crear usuario con directorio home
```bash
useradd -m nombre_usuario
```

### 3. Crear usuario con directorio home y shell específico
```bash
useradd -m -s /bin/bash nombre_usuario
```

### 4. Crear usuario con comentario/descripción
```bash
useradd -m -c "Descripción del usuario" nombre_usuario
```

### 5. Crear usuario con UID específico
```bash
useradd -m -u 1001 nombre_usuario
```

### 6. Crear usuario y asignar a grupo específico
```bash
useradd -m -g nombre_grupo nombre_usuario
```

### 7. Crear usuario con grupos adicionales
```bash
useradd -m -G grupo1,grupo2 nombre_usuario
```

## Establecer Contraseña

### Asignar contraseña a un usuario
```bash
passwd nombre_usuario
```

## Modificar Usuarios Existentes

### Cambiar el shell del usuario
```bash
usermod -s /bin/bash nombre_usuario
```

### Agregar usuario a grupos adicionales
```bash
usermod -aG grupo1,grupo2 nombre_usuario
```

### Cambiar el directorio home
```bash
usermod -d /nuevo/home nombre_usuario
```

### Cambiar el UID del usuario
```bash
usermod -u 1002 nombre_usuario
```

## Eliminar Usuarios

### Eliminar usuario (sin eliminar home)
```bash
userdel nombre_usuario
```

### Eliminar usuario y su directorio home
```bash
userdel -r nombre_usuario
```

## Verificar Usuarios

### Ver información de un usuario
```bash
id nombre_usuario
```

### Ver todos los usuarios del sistema
```bash
cat /etc/passwd
```

### Ver grupos de un usuario
```bash
groups nombre_usuario
```

## Buscar y Listar Usuarios

### Buscar un usuario específico
```bash
grep nombre_usuario /etc/passwd
```

### Listar todos los usuarios del sistema
```bash
cut -d: -f1 /etc/passwd
```

### Listar usuarios con UID >= 1000 (usuarios normales)
```bash
awk -F: '$3 >= 1000 {print $1}' /etc/passwd
```

### Listar usuarios con shell de login
```bash
grep -E '/bin/(bash|sh|zsh)' /etc/passwd | cut -d: -f1
```

### Contar número de usuarios
```bash
wc -l /etc/passwd
```

### Buscar usuarios por grupo
```bash
grep nombre_grupo /etc/group
```

## Información Detallada de Usuarios

### Ver información completa de un usuario
```bash
getent passwd nombre_usuario
```

### Ver UID, GID y grupos de un usuario
```bash
id nombre_usuario
```

### Ver información detallada (formato extendido)
```bash
id -a nombre_usuario
```

### Ver solo el UID
```bash
id -u nombre_usuario
```

### Ver solo el GID principal
```bash
id -g nombre_usuario
```

### Ver todos los grupos del usuario
```bash
id -Gn nombre_usuario
```

### Ver GIDs de todos los grupos
```bash
id -G nombre_usuario
```

### Ver directorio home del usuario
```bash
getent passwd nombre_usuario | cut -d: -f6
```

### Ver shell del usuario
```bash
getent passwd nombre_usuario | cut -d: -f7
```

## Sesiones y Usuarios Conectados

### Ver quién está conectado actualmente
```bash
who
```

### Ver usuarios conectados (formato extendido)
```bash
w
```

### Ver solo los nombres de usuarios conectados
```bash
who | cut -d' ' -f1 | sort -u
```

### Ver último login de un usuario
```bash
lastlog -u nombre_usuario
```

### Ver todos los últimos logins
```bash
lastlog
```

### Ver historial de logins de un usuario
```bash
last nombre_usuario
```

### Ver usuarios que han iniciado sesión recientemente
```bash
last -n 10
```

### Ver usuario actual
```bash
whoami
```

### Ver UID del usuario actual
```bash
id -u
```

### Ver información completa del usuario actual
```bash
id
```

## Iniciar Sesión

### Iniciar sesión localmente (desde consola)
```bash
login nombre_usuario
```

### Iniciar sesión con SSH (remoto)
```bash
ssh nombre_usuario@direccion_ip
```

### Iniciar sesión con SSH usando puerto específico
```bash
ssh -p 2222 nombre_usuario@direccion_ip
```

### Iniciar sesión con SSH usando clave privada
```bash
ssh -i /ruta/a/clave_privada nombre_usuario@direccion_ip
```

### Iniciar sesión con SSH y ejecutar comando directamente
```bash
ssh nombre_usuario@direccion_ip 'comando'
```

### Verificar si puedes conectarte por SSH (sin iniciar sesión)
```bash
ssh -o ConnectTimeout=5 nombre_usuario@direccion_ip echo "Conexión exitosa"
```

### Iniciar sesión como root por SSH
```bash
ssh root@direccion_ip
```

### Instalar SSH (requiere permisos de root)

**Importante**: SSH se instala a nivel del sistema, no por usuario. Todos los usuarios pueden usarlo una vez instalado.

Si obtienes el error "Permission denied" al intentar instalar:

**Opción 1: Cambiar a root primero**
```bash
# Cambiar a root (necesitarás la contraseña de root)
su -

# O si ya eres root, simplemente ejecuta:
apt-get update && apt-get install -y openssh-client
```

**Opción 2: Si estás como usuario normal y no tienes sudo**
```bash
# Cambiar a root
su -

# Luego instalar
apt-get update && apt-get install -y openssh-client
```

**Opción 3: Instalar desde root directamente**
```bash
# Si ya estás como root (prompt muestra "root@")
apt-get update && apt-get install -y openssh-client
```

**Nota**: El error "Permission denied" significa que el usuario actual no tiene permisos de administrador. Necesitas ser `root` para instalar paquetes en el sistema.

### Iniciar sesión interactiva desde script
```bash
login -f nombre_usuario
```

### Ver intentos de login fallidos
```bash
lastb
```

### Ver intentos de login fallidos de un usuario específico
```bash
lastb nombre_usuario
```

### Ver historial de logins exitosos
```bash
last
```

### Ver último login de todos los usuarios
```bash
lastlog
```

### Ver último login de un usuario específico
```bash
lastlog -u nombre_usuario
```

## Cambiar de Usuario

### Cambiar a otro usuario (requiere contraseña)
```bash
su nombre_usuario
```

### Cambiar a otro usuario y cargar entorno completo
```bash
su - nombre_usuario
```

### Cambiar a root
```bash
su -
```

### Ejecutar comando como otro usuario (si no eres root, usa: sudo -u)
```bash
runuser -l nombre_usuario -c 'comando'
```

### Ejecutar comando como otro usuario (alternativa)
```bash
su - nombre_usuario -c 'comando'
```

## Bloquear y Desbloquear Usuarios

### Bloquear cuenta de usuario
```bash
usermod -L nombre_usuario
```

### Desbloquear cuenta de usuario
```bash
usermod -U nombre_usuario
```

### Verificar si una cuenta está bloqueada
```bash
passwd -S nombre_usuario
```

### Expirar contraseña (forzar cambio en próximo login)
```bash
passwd -e nombre_usuario
```

### Deshabilitar cuenta (sin eliminar)
```bash
usermod -s /usr/sbin/nologin nombre_usuario
```

### Habilitar cuenta nuevamente
```bash
usermod -s /bin/bash nombre_usuario
```

## Gestión de Grupos

### Crear un nuevo grupo
```bash
groupadd nombre_grupo
```

### Crear grupo con GID específico
```bash
groupadd -g 1001 nombre_grupo
```

### Crear grupo del sistema (GID < 1000)
```bash
groupadd -r nombre_grupo
```

### Eliminar un grupo
```bash
groupdel nombre_grupo
```

### Modificar un grupo existente
```bash
groupmod nombre_grupo
```

### Cambiar el GID de un grupo
```bash
groupmod -g 1002 nombre_grupo
```

### Cambiar el nombre de un grupo
```bash
groupmod -n nuevo_nombre nombre_grupo_viejo
```

### Ver todos los grupos del sistema
```bash
cat /etc/group
```

### Ver todos los grupos (solo nombres)
```bash
cut -d: -f1 /etc/group
```

### Ver información de un grupo específico
```bash
getent group nombre_grupo
```

### Ver GID de un grupo
```bash
getent group nombre_grupo | cut -d: -f3
```

### Ver miembros de un grupo
```bash
getent group nombre_grupo | cut -d: -f4
```

### Ver solo los nombres de los miembros de un grupo
```bash
getent group nombre_grupo | cut -d: -f4 | tr ',' '\n'
```

### Buscar grupos por GID
```bash
getent group | grep ":1001:"
```

### Contar número de grupos
```bash
getent group | wc -l
```

### Ver grupos del usuario actual
```bash
groups
```

### Ver grupos de un usuario específico
```bash
groups nombre_usuario
```

### Ver nombre del grupo primario de un usuario
```bash
id -gn nombre_usuario
```

### Ver GID del grupo primario de un usuario
```bash
id -g nombre_usuario
```

### Verificar si un usuario pertenece a un grupo
```bash
groups nombre_usuario | grep -q nombre_grupo && echo "Sí pertenece" || echo "No pertenece"
```

### Agregar usuario a un grupo
```bash
gpasswd -a nombre_usuario nombre_grupo
```

### Remover usuario de un grupo
```bash
gpasswd -d nombre_usuario nombre_grupo
```

### Establecer lista completa de miembros de un grupo
```bash
gpasswd -M usuario1,usuario2,usuario3 nombre_grupo
```

### Establecer administradores del grupo
```bash
gpasswd -A usuario1,usuario2 nombre_grupo
```

### Agregar contraseña a un grupo
```bash
gpasswd nombre_grupo
```

### Remover contraseña de un grupo
```bash
gpasswd -r nombre_grupo
```

### Cambiar grupo primario de un usuario
```bash
usermod -g nombre_grupo nombre_usuario
```

### Cambiar grupo primario y grupos secundarios
```bash
usermod -g grupo_primario -G grupo1,grupo2 nombre_usuario
```

### Agregar usuario a grupos adicionales (sin perder los actuales)
```bash
usermod -aG grupo1,grupo2 nombre_usuario
```

### Cambiar a un grupo temporalmente (nueva sesión)
```bash
newgrp nombre_grupo
```

### Ver grupos con contraseña
```bash
getent group | grep -v "::"
```

### Ver grupos vacíos (sin miembros)
```bash
getent group | awk -F: '$4 == ""'
```

### Ver grupos con miembros
```bash
getent group | awk -F: '$4 != ""'
```

### Listar usuarios de un grupo específico
```bash
getent group nombre_grupo | cut -d: -f4 | tr ',' '\n'
```

### Ver todos los grupos de un usuario con sus GIDs
```bash
id nombre_usuario
```

### Ver solo los nombres de grupos de un usuario
```bash
id -Gn nombre_usuario
```

### Ver solo los GIDs de grupos de un usuario
```bash
id -G nombre_usuario
```

## Información del Sistema

### Ver número total de usuarios
```bash
getent passwd | wc -l
```

### Ver usuarios con privilegios sudo
```bash
grep -E '^sudo|^admin' /etc/group | cut -d: -f4
```

### Ver usuarios sin contraseña
```bash
awk -F: '($2 == "") {print $1}' /etc/shadow
```

### Ver usuarios con shell nologin (deshabilitados)
```bash
grep nologin /etc/passwd | cut -d: -f1
```

### Ver tamaño del directorio home de un usuario
```bash
du -sh ~nombre_usuario
```

### Ver permisos del directorio home
```bash
ls -ld ~nombre_usuario
```

## Comandos Útiles Adicionales

### Ver variables de entorno de un usuario
```bash
runuser -l nombre_usuario -c 'env'
```

### Ver procesos de un usuario
```bash
ps -u nombre_usuario
```

### Ver procesos de todos los usuarios
```bash
ps aux
```

### Matar todos los procesos de un usuario
```bash
pkill -u nombre_usuario
```

### Ver archivos abiertos por un usuario
```bash
lsof -u nombre_usuario
```

### Ver cuota de disco de un usuario
```bash
quota -u nombre_usuario
```

## Ejemplo Completo

```bash
# Crear usuario con todas las opciones comunes
useradd -m -s /bin/bash -c "Usuario de ejemplo" -G sudo,users ejemplo

# Establecer contraseña
passwd ejemplo

# Verificar que se creó correctamente
id ejemplo
```

## Notas Importantes

- **Estos comandos requieren privilegios de root/administrador**
  - Si eres **root**: ejecuta los comandos directamente (sin `sudo`)
  - Si eres **usuario normal**: agrega `sudo` antes de cada comando administrativo
- El comando `useradd` es para sistemas basados en Debian/Ubuntu
- En algunas distribuciones, `adduser` es un script interactivo más amigable
- Siempre establece una contraseña segura después de crear el usuario
- Verifica que el usuario puede iniciar sesión antes de cerrar la sesión actual
- Para verificar si eres root: ejecuta `whoami` (debe mostrar "root") o `id -u` (debe mostrar 0)

