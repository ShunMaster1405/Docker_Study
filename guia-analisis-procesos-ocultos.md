# Guía de Análisis de Procesos Ocultos y Anomalías

## Objetivo

Aprender a identificar procesos que intentan ocultarse, hacerse pasar por servicios legítimos o que se ejecutan desde archivos eliminados en el sistema.

## Herramientas Necesarias

Para este módulo, necesitaremos herramientas de análisis de procesos y archivos abiertos. Instálalas en tu contenedor:

```bash
apt-get update
apt-get install -y lsof procps net-tools htop strace
```

## 1. El Sistema de Archivos `/proc`

En Linux, `/proc` no es un directorio real en el disco, es una interfaz al kernel. Cada proceso tiene un directorio numérico allí (su PID).

- `/proc/[PID]/cmdline`: El comando exacto que inició el proceso.
- `/proc/[PID]/exe`: Enlace simbólico al ejecutable real.
- `/proc/[PID]/fd`: Directorio con los descriptores de archivo abiertos por el proceso.

## 2. Técnicas de Detección

### A. Ejecutables Eliminados (Fileless execution basic)

Un ataque común es ejecutar un binario y luego borrarlo del disco para no dejar rastro. El proceso sigue corriendo en memoria.

**Cómo detectarlo:**
Verificar enlaces rotos en la carpeta `/proc`:

```bash
ls -l /proc/*/exe 2>/dev/null | grep '(deleted)'
```
O usando `lsof`:
```bash
lsof | grep deleted
```

### B. Masquerading (Suplantación de nombre)

Malware a menudo se nombra como `sshd`, `nginx`, o `[kworker]` para pasar desapercibido en `top`.

**Cómo detectarlo:**
Comparar el nombre del proceso con su ruta real.
Si ves un proceso llamado `sshd` pero su ejecutable está en `/tmp/sshd` o `/home/usuario/hack`, es malicioso. El `sshd` real vive en `/usr/sbin/sshd`.

Comando útil:
```bash
ps aux | grep sshd
ls -l /proc/[PID_SOSPECHOSO]/exe
```

### C. Puertos Extraños

Revisar conexiones de red que no coinciden con servicios conocidos.

```bash
# Ver puertos escuchando y qué proceso los tiene
ss -tulpn
# O
netstat -tulpn
```

## 3. Práctica

Usa el script `generar-actividad-procesos.sh` para crear un escenario de infección simulada.

1. Ejecuta el generador: `./scripts/generar-actividad-procesos.sh`
2. **Misión 1**: Encuentra el PID del proceso que está corriendo desde un archivo eliminado.
3. **Misión 2**: Encuentra el proceso que se hace llamar "syslogd" pero es falso.
4. **Misión 3**: Identifica qué puerto extraño se abrió y qué proceso lo controla.

---
**Comandos de Investigación Rápida:**

```bash
# Listar todos los PIDs y sus ejecutables
for pid in $(ps -ef | awk '{print $2}'); do ls -l /proc/$pid/exe 2>/dev/null; done

# Ver actividad de un proceso específico
strace -p [PID]
```
