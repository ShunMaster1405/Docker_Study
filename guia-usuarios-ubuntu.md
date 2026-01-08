# Guía Completa de Gestión de Usuarios en Ubuntu/Linux

## Índice
1. [Comandos Básicos](#comandos-básicos)
2. [Conectarse Entre Usuarios](#conectarse-entre-usuarios)
3. [Docker y Contenedores](#docker-y-contenedores)
4. [Ejercicios Prácticos](#ejercicios-prácticos)

---

## Comandos Básicos para Gestionar Usuarios

### Crear un usuario
```bash
# En sistemas Ubuntu/Debian completos
sudo adduser nombre_usuario

# En contenedores Docker (método manual)
useradd -m -s /bin/bash nombre_usuario
passwd nombre_usuario
```

### Ver usuarios existentes
```bash
cat /etc/passwd

# Solo los nombres:
cut -d: -f1 /etc/passwd

# Solo usuarios "humanos" (UID >= 1000)
awk -F: '$3 >= 1000 {print $1}' /etc/passwd

# Usuarios con shell bash
grep "/bin/bash" /etc/passwd
```

### Eliminar un usuario
```bash
sudo deluser nombre_usuario

# Con su directorio home:
sudo deluser --remove-home nombre_usuario

# Método alternativo (más directo)
userdel nombre_usuario
userdel -r nombre_usuario  # Con directorio home
```

### Modificar un usuario
```bash
# Cambiar contraseña
sudo passwd nombre_usuario

# Agregar a un grupo
sudo usermod -aG grupo nombre_usuario

# Ejemplo: dar privilegios sudo
sudo usermod -aG sudo nombre_usuario

# Cambiar shell
usermod -s /bin/bash nombre_usuario

# Cambiar directorio home
usermod -d /nuevo/home nombre_usuario
```

---

## Conectarse Entre Usuarios

### 1. Cambiar de usuario (Switch User)
```bash
# Cambiar a otro usuario
su nombre_usuario

# Cambiar a root
su -
# o
sudo su

# Cambiar y cargar el entorno del usuario (recomendado)
su - nombre_usuario
```

**Diferencia entre `su` y `su -`:**
- `su usuario`: Cambia al usuario pero mantiene el entorno actual
- `su - usuario`: Cambia al usuario Y carga su entorno completo (PATH, HOME, etc.)

### 2. Ejecutar comandos como otro usuario
```bash
# Con sudo (requiere privilegios)
sudo -u nombre_usuario comando

# Ejemplos
sudo -u david ls /home/david
sudo -u www-data touch /var/www/file.txt
```

### 3. Ver información de usuarios
```bash
# Ver qué usuario eres actualmente
whoami

# Ver información completa (UID, GID, grupos)
id

# Ver grupos del usuario actual
groups

# Ver grupos de otro usuario
groups nombre_usuario
id nombre_usuario
```

### 4. Ver usuarios conectados
```bash
# Usuarios actualmente logueados
who

# Información detallada de sesiones
w

# Solo nombres de usuarios
users

# Histórico de logins
last

# Último login de cada usuario
lastlog
```

### 5. Conexión SSH entre usuarios (misma máquina)
```bash
# Primero instala SSH si no está
sudo apt update
sudo apt install openssh-server

# Conectarse localmente
ssh usuario@localhost

# Con clave privada
ssh -i ~/.ssh/id_rsa usuario@localhost
```

---

## Docker y Contenedores

### Diferencias en contenedores Docker

**Normalmente ya eres root:**
- No necesitas `sudo` (probablemente no está instalado)
- Tienes permisos completos desde el inicio

**Comandos minimalistas:**
```bash
# Usa useradd en lugar de adduser
useradd -m -s /bin/bash nombre_usuario
passwd nombre_usuario

# O instala adduser
apt update && apt install -y adduser
adduser nombre_usuario
```

**Opciones útiles de useradd:**
- `-m`: Crea el directorio home
- `-s /bin/bash`: Establece bash como shell
- `-g grupo`: Establece grupo principal
- `-G grupos`: Añade a grupos adicionales
- `-u UID`: Especifica UID personalizado

---

## Ejercicios Prácticos

### 1. 🔄 Cambiar entre usuarios

```bash
# Ver quién eres
whoami

# Cambiar al usuario que creaste
su - nombre_usuario

# Ver nuevamente quién eres
whoami

# Ver información completa
id

# Regresar a root
exit
```

---

### 2. 👥 Crear y gestionar múltiples usuarios

```bash
# Crear 3 usuarios para practicar
useradd -m -s /bin/bash alice
useradd -m -s /bin/bash bob
useradd -m -s /bin/bash charlie

# Poner contraseñas
passwd alice
passwd bob
passwd charlie

# Listar todos los usuarios del sistema
cat /etc/passwd | tail -5

# Ver solo usuarios "reales" (con home y shell)
cat /etc/passwd | grep "/home"

# Contar cuántos usuarios hay
wc -l /etc/passwd
```

---

### 3. 👨‍👩‍👧‍👦 Trabajar con grupos

```bash
# Ver grupos existentes
cat /etc/group

# Crear grupos
groupadd developers
groupadd testers
groupadd managers

# Agregar usuarios a grupos
usermod -aG developers alice
usermod -aG developers bob
usermod -aG testers charlie

# Ver grupos de un usuario
groups alice
id alice

# Crear archivo como root
echo "Archivo del proyecto" > /tmp/proyecto.txt

# Cambiar grupo del archivo
chgrp developers /tmp/proyecto.txt

# Ver permisos
ls -l /tmp/proyecto.txt

# Cambiar grupo principal de un usuario
usermod -g developers alice
```

---

### 4. 🔐 Gestionar permisos de archivos

```bash
# Crear directorio compartido
mkdir /compartido
mkdir /compartido/dev_team

# Dar propiedad al grupo
chown root:developers /compartido/dev_team

# Dar permisos de lectura/escritura al grupo
chmod 770 /compartido/dev_team

# Verificar
ls -ld /compartido/dev_team

# Probar como alice
su - alice
cd /compartido/dev_team
touch alice_file.txt    # Debería funcionar
exit

# Probar como charlie (no está en developers)
su - charlie
cd /compartido/dev_team
touch charlie_file.txt  # Debería fallar - Permission denied
exit
```

**Explicación de permisos (chmod):**
```
chmod 770 = rwxrwx---
  7 = owner: rwx (read, write, execute)
  7 = group: rwx
  0 = others: --- (sin permisos)

Otros ejemplos:
chmod 755 = rwxr-xr-x  (común para ejecutables)
chmod 644 = rw-r--r--  (común para archivos)
chmod 600 = rw-------  (archivos privados)
```

---

### 5. 📂 Permisos especiales

#### Sticky Bit
```bash
# Crear carpeta donde todos puedan escribir pero solo eliminar sus propios archivos
mkdir /uploads
chmod 1777 /uploads  # Sticky bit

# El "1" al inicio activa el sticky bit
# Común en /tmp

# Probar como alice
su - alice
touch /uploads/alice_secret.txt
exit

# Probar como bob
su - bob
touch /uploads/bob_secret.txt
ls /uploads
rm /uploads/alice_secret.txt  # Debería fallar - solo alice puede borrarlo
rm /uploads/bob_secret.txt    # Esto sí funciona
exit
```

#### SUID (Set User ID)
```bash
# El archivo se ejecuta con permisos del dueño
chmod 4755 archivo_ejecutable

# Ejemplo: /usr/bin/passwd tiene SUID
ls -l /usr/bin/passwd
# -rwsr-xr-x (la "s" indica SUID)
```

#### SGID (Set Group ID)
```bash
# Archivos creados heredan el grupo del directorio
mkdir /shared_project
chgrp developers /shared_project
chmod 2775 /shared_project

# La "s" en grupo indica SGID
ls -ld /shared_project
# drwxrwsr-x (la "s" en grupo indica SGID)
```

---

### 6. 🛡️ Simular sudo (limitado en Docker)

```bash
# Instalar sudo si quieres practicar
apt update && apt install -y sudo

# Crear grupo sudo si no existe
groupadd sudo 2>/dev/null

# Agregar alice a sudoers
usermod -aG sudo alice

# Permitir sudo sin contraseña (solo para práctica)
echo "alice ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Método más seguro: usar visudo
visudo
# Añadir: alice ALL=(ALL) ALL

# Probar como alice
su - alice
sudo whoami  # Debería decir "root"
sudo cat /etc/shadow  # Acceso a archivo restringido
exit
```

---

### 7. 🔍 Información y auditoría

```bash
# Ver último login de usuarios
lastlog

# Ver intentos de login
last

# Ver información de contraseñas
chage -l alice

# Establecer expiración de contraseña
chage -M 90 alice  # Expira cada 90 días

# Expirar contraseña (obligar cambio en próximo login)
passwd -e bob

# Bloquear un usuario
passwd -l charlie
# o
usermod -L charlie

# Desbloquear
passwd -u charlie
# o
usermod -U charlie

# Ver estado de contraseña de usuarios
passwd -S alice
passwd -S charlie

# Ver procesos por usuario
ps aux | grep ^alice
ps -u alice

# Matar procesos de un usuario
pkill -u bob
```

---

### 8. 🎯 Ejercicio completo práctico

**Escenario:** Crear un proyecto con permisos adecuados

```bash
# 1. Crear estructura de directorios
mkdir -p /proyecto/{src,docs,config,logs}

# 2. Crear usuarios del proyecto
useradd -m -s /bin/bash developer1
useradd -m -s /bin/bash developer2
useradd -m -s /bin/bash manager
useradd -m -s /bin/bash auditor

passwd developer1
passwd developer2
passwd manager
passwd auditor

# 3. Crear grupos del proyecto
groupadd proyecto_team
groupadd proyecto_managers

# 4. Agregar usuarios a grupos
usermod -aG proyecto_team developer1
usermod -aG proyecto_team developer2
usermod -aG proyecto_team manager
usermod -aG proyecto_managers manager

# 5. Configurar permisos por directorio
chown -R root:proyecto_team /proyecto

# src: todos pueden leer y escribir
chmod 770 /proyecto/src
chown root:proyecto_team /proyecto/src

# docs: solo lectura para el equipo
chmod 750 /proyecto/docs
chown root:proyecto_team /proyecto/docs

# config: solo managers
chmod 770 /proyecto/config
chown root:proyecto_managers /proyecto/config

# logs: todos pueden leer, nadie puede eliminar archivos ajenos
chmod 1775 /proyecto/logs
chown root:proyecto_team /proyecto/logs

# 6. Crear archivos de ejemplo
echo "print('Hello World')" > /proyecto/src/main.py
echo "# Documentación del Proyecto" > /proyecto/docs/README.md
echo "API_KEY=secret123" > /proyecto/config/secrets.env

# 7. Probar acceso como developer1
su - developer1
cd /proyecto/src
touch mi_codigo.py          # ✅ Funciona
cat ../docs/README.md       # ✅ Puede leer
echo "test" >> ../docs/README.md  # ❌ Sin permisos de escritura
cat ../config/secrets.env   # ❌ Sin permisos
exit

# 8. Probar acceso como manager
su - manager
cd /proyecto
cat config/secrets.env      # ✅ Funciona
echo "DEBUG=true" >> config/secrets.env  # ✅ Funciona
cd src
touch manager_note.txt      # ✅ Funciona
exit
```

---

### 9. 📋 Comandos de resumen útiles

```bash
# Ver todos los usuarios "humanos"
awk -F: '$3 >= 1000 {print $1}' /etc/passwd

# Ver cuántos usuarios hay
wc -l /etc/passwd

# Ver usuarios con shell
grep "/bin/bash" /etc/passwd

# Listar todos los grupos
cat /etc/group

# Ver miembros de un grupo
getent group developers

# Buscar usuario por UID
getent passwd 1001

# Cambiar información del usuario (nombre completo, etc)
chfn alice

# Ver información completa de usuario
finger alice  # (requiere instalar: apt install finger)

# Eliminar usuario cuando termines
userdel bob
userdel -r bob  # Con su directorio home
```

---

## 📝 Conceptos Clave

### UID y GID
- **UID** (User ID): Identificador único del usuario
  - `0`: root (superusuario)
  - `1-999`: Usuarios del sistema/servicios
  - `1000+`: Usuarios normales
  
- **GID** (Group ID): Identificador del grupo
  - Cada usuario tiene un grupo principal
  - Puede pertenecer a múltiples grupos secundarios

### Permisos (rwx)
```
r (read)    = 4
w (write)   = 2
x (execute) = 1

Ejemplos:
rwx = 7 (4+2+1)
rw- = 6 (4+2)
r-x = 5 (4+1)
r-- = 4

chmod 755 archivo
  7 (rwx) = owner
  5 (r-x) = group
  5 (r-x) = others
```

### Permisos especiales
- **Sticky Bit (1)**: Solo el propietario puede eliminar archivos
  - Ejemplo: `chmod 1777 /tmp`
  - Se ve como: `drwxrwxrwt`

- **SUID (4)**: Ejecutar con permisos del propietario
  - Ejemplo: `chmod 4755 programa`
  - Se ve como: `-rwsr-xr-x`

- **SGID (2)**: Archivos heredan grupo del directorio
  - Ejemplo: `chmod 2775 directorio`
  - Se ve como: `drwxrwsr-x`

### Archivos importantes
```bash
/etc/passwd     # Información de usuarios
/etc/shadow     # Contraseñas encriptadas (solo root)
/etc/group      # Información de grupos
/etc/gshadow    # Contraseñas de grupos (raro uso)
/etc/sudoers    # Configuración de sudo
/home/*         # Directorios personales de usuarios
```

### Diferencia entre sudo y su
- **sudo**: Ejecuta UN comando como otro usuario (por defecto root)
  - Requiere TU contraseña
  - Más seguro, queda registrado
  - Permisos configurables en `/etc/sudoers`

- **su**: Cambia completamente al otro usuario
  - Requiere la contraseña DEL OTRO usuario
  - Crea nueva sesión
  - `su -` carga el entorno completo

---

## 🚀 Tips y Buenas Prácticas

1. **Usa `su -` en lugar de `su`**: Carga el entorno completo del usuario

2. **No trabajes como root**: Crea un usuario con sudo

3. **Grupos para permisos**: Usa grupos en lugar de dar permisos individuales

4. **Principio de menor privilegio**: Da solo los permisos necesarios

5. **Documenta cambios**: Especialmente en `/etc/sudoers`

6. **Contraseñas fuertes**: Usa `passwd` para establecer buenas contraseñas

7. **Audita regularmente**: Revisa usuarios y permisos periódicamente
   ```bash
   # Ver últimos logins
   lastlog
   
   # Ver usuarios sin login reciente
   lastlog | grep "Never"
   ```

8. **Limpia usuarios obsoletos**: Elimina cuentas que ya no se usan

9. **Backup antes de cambios**: Especialmente de `/etc/passwd` y `/etc/group`

10. **Usa visudo**: Para editar `/etc/sudoers` (valida sintaxis)

---

## 🔧 Troubleshooting Común

### "Permission denied"
```bash
# Verificar permisos
ls -l archivo

# Verificar propiedad
stat archivo

# Verificar grupos del usuario
groups
id
```

### Usuario no puede hacer sudo
```bash
# Verificar si está en grupo sudo
groups usuario

# Agregar a grupo sudo
usermod -aG sudo usuario

# Verificar /etc/sudoers
visudo
```

### No se puede cambiar a usuario
```bash
# Verificar que el usuario existe
id usuario

# Verificar que tiene shell válido
grep usuario /etc/passwd

# Verificar que no está bloqueado
passwd -S usuario
```

### Olvidé la contraseña
```bash
# Como root, puedes cambiarla
passwd usuario

# O establecer sin contraseña (inseguro)
passwd -d usuario
```

---

## 📚 Comandos de Referencia Rápida

```bash
# CREAR
useradd -m -s /bin/bash usuario    # Crear usuario
groupadd grupo                      # Crear grupo
passwd usuario                      # Establecer contraseña

# MODIFICAR
usermod -aG grupo usuario          # Agregar a grupo
usermod -l nuevo viejo             # Renombrar usuario
chsh -s /bin/zsh usuario           # Cambiar shell

# ELIMINAR
userdel usuario                    # Eliminar usuario
userdel -r usuario                 # Eliminar con directorio
groupdel grupo                     # Eliminar grupo

# INFORMACIÓN
whoami                             # Usuario actual
id                                 # UID, GID, grupos
groups                             # Grupos del usuario
who                                # Usuarios conectados
lastlog                            # Últimos logins

# PERMISOS
chmod 755 archivo                  # Cambiar permisos
chown usuario:grupo archivo        # Cambiar dueño
chgrp grupo archivo                # Cambiar grupo

# CAMBIAR USUARIO
su - usuario                       # Cambiar a usuario
sudo comando                       # Ejecutar como root
sudo -u usuario comando            # Ejecutar como usuario
exit                               # Salir de sesión
```

---

**Creado:** Diciembre 2025  
**Propósito:** Guía práctica para aprender gestión de usuarios en Linux/Ubuntu
