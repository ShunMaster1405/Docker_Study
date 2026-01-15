#!/bin/bash

# Script para generar "Actividad Maliciosa Simulada" para análisis forense básico
# NO ES MALWARE REAL. Son procesos inofensivos (sleep, netcat) disfrazados.

WORK_DIR="/tmp/malware_sim"
mkdir -p "$WORK_DIR"

echo "=== Generando escenario de Procesos Ocultos ==="

# 1. Simulación de ejecutable eliminado (Fileless)
# Creamos un script, lo ejecutamos y lo borramos inmediatamente.
cat << 'EOF' > "$WORK_DIR/malware_deleted.sh"
#!/bin/bash
# Este script simula un proceso huérfano de archivo
while true; do
    sleep 5
    # Hacemos algo trivial para no gastar cpu
    date > /dev/null
done
EOF

chmod +x "$WORK_DIR/malware_deleted.sh"
echo "[+] Iniciando proceso con ejecutable eliminado..."
"$WORK_DIR/malware_deleted.sh" &
PID_DEL=$!
sleep 1
rm "$WORK_DIR/malware_deleted.sh"
echo "    -> Proceso iniciado con PID: $PID_DEL (Archivo eliminado)"


# 2. Simulación de Masquerading (Nombre falso)
# Copiamos sleep a un nombre que parece del sistema y lo corremos
FAKE_NAME="kworker-maintainer"
cp /bin/sleep "$WORK_DIR/$FAKE_NAME"
echo "[+] Iniciando proceso con nombre falso de sistema..."
"$WORK_DIR/$FAKE_NAME" 3600 &
PID_FAKE=$!
echo "    -> Proceso falso '$FAKE_NAME' iniciado con PID: $PID_FAKE"


# 3. Simulación de Puerto Extraño (Backdoor listener)
# Usamos netcat si está disponible, o bash tcp, o python
PORT=6666
echo "[+] Abriendo puerto sospechoso $PORT..."

# Intentamos usar python que suele venir en ubuntu, o nc
if command -v python3 &> /dev/null; then
    nohup python3 -m http.server $PORT > /dev/null 2>&1 &
    PID_PORT=$!
    echo "    -> Listener Python iniciado en puerto $PORT con PID: $PID_PORT"
else
    # Fallback a sleep simulando servicio
    echo "    (Python no encontrado, simulando proceso network-manager falso)"
    cp /bin/sleep "$WORK_DIR/net-svc"
    "$WORK_DIR/net-svc" 3600 &
    PID_PORT=$!
fi

echo ""
echo "=== Escenario Listo ==="
echo "Tu misión es encontrar estos 3 procesos usando comandos como:"
echo "  1. ps aux | grep ..."
echo "  2. ls -l /proc/*/exe | grep deleted"
echo "  3. netstat -tulpn o ss -tulpn" 
echo ""
echo "Para limpiar todo después, ejecuta: kill $PID_DEL $PID_FAKE $PID_PORT"
