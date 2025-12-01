#!/bin/bash

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="/home/sebastian/backups-locales"
DATA_DIR="/home/sebastian/luanti-data"
CONTAINER_NAME="luanti"
BACKUP_NAME="luanti_backup_$TIMESTAMP.tar.gz"
RETENTION_DAYS=14   # Días a conservar los backups

# --- Configuración Remota ---
REMOTE_USER="sebastian"
REMOTE_IP="192.168.0.201"
REMOTE_DIR="/var/backups/clientes_juegos/"

echo "=== Iniciando backup del servidor ==="

#   Verificar directorio de datos
if [ ! -d "$DATA_DIR" ]; then
    echo "ERROR: No existe el directorio de datos: $DATA_DIR"
    exit 1
fi

#   Crear directorio de backups
mkdir -p "$BACKUP_DIR"

#   Detener contenedor
echo "Deteniendo contenedor '$CONTAINER_NAME'..."
docker stop "$CONTAINER_NAME" >/dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "ADVERTENCIA: No se pudo detener el contenedor (¿ya estaba detenido?)."
fi

#   Crear backup
echo "Comprimiendo datos desde $DATA_DIR..."
tar -czf "$BACKUP_DIR/$BACKUP_NAME" -C "$DATA_DIR" .

if [ $? -ne 0 ]; then
    echo "ERROR: Falló la creación del archivo comprimido."
    echo "Intentando reiniciar el contenedor..."
    docker start "$CONTAINER_NAME" >/dev/null 2>&1
    exit 1
fi

echo "Backup creado: $BACKUP_DIR/$BACKUP_NAME"

#   Reiniciar contenedor (PRIORIDAD: Que el juego vuelva a funcionar)
echo "Iniciando contenedor '$CONTAINER_NAME'..."
docker start "$CONTAINER_NAME" >/dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "ERROR: No se pudo iniciar el contenedor nuevamente."
    exit 1
fi

#   Eliminar backups antiguos locales
echo "Eliminando backups locales con más de $RETENTION_DAYS días..."
find "$BACKUP_DIR" -name "luanti_backup_*.tar.gz" -mtime +$RETENTION_DAYS -type f -delete
echo "Limpieza de backups antiguos completada."


#   Envío al nodo Storage
echo "--- Enviando backup al RAID ($REMOTE_IP) ---"

scp -o ConnectTimeout=10 "$BACKUP_DIR/$BACKUP_NAME" $REMOTE_USER@$REMOTE_IP:$REMOTE_DIR

if [ $? -eq 0 ]; then
    echo "Backup enviado correctamente al Storage RAID."
else
    echo "   ADVERTENCIA: Falló el envío al RAID."
    echo "   El backup LOCAL está seguro, pero no se copió al remoto."
fi

#   FIN
echo "=== Backup finalizado ==="
exit 0