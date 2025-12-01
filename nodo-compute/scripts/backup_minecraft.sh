#!/bin/bash

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="/home/sebastian/backups-locales"
DATA_DIR="/home/sebastian/minecraft-data"
CONTAINER_NAME="minecraft"
BACKUP_NAME="minecraft_backup_$TIMESTAMP.tar.gz"
RETENTION_DAYS=14

# --- Configuración Remota (Nodo Storage) ---
REMOTE_USER="sebastian"
REMOTE_IP="192.168.0.201"
REMOTE_DIR="/var/backups/clientes_juegos/"

echo "=== Iniciando backup de MINECRAFT ($TIMESTAMP) ==="

# Verificar directorio de datos
if [ ! -d "$DATA_DIR" ]; then
    echo "ERROR: No existe el directorio de datos: $DATA_DIR"
    exit 1
fi

# Crear directorio de backups local
mkdir -p "$BACKUP_DIR"

# Detener contenedor
echo "Deteniendo contenedor '$CONTAINER_NAME'..."
docker stop "$CONTAINER_NAME" >/dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "ADVERTENCIA: No se pudo detener el contenedor (¿ya estaba detenido?)."
fi

# Crear backup
echo "Comprimiendo datos desde $DATA_DIR..."
tar -czf "$BACKUP_DIR/$BACKUP_NAME" -C "$DATA_DIR" .

if [ $? -ne 0 ]; then
    echo "ERROR: Falló la creación del archivo comprimido."
    echo "Intentando reiniciar el contenedor..."
    docker start "$CONTAINER_NAME" >/dev/null 2>&1
    exit 1
fi

echo "Backup creado: $BACKUP_DIR/$BACKUP_NAME"

# Reiniciar contenedor
echo "Iniciando contenedor '$CONTAINER_NAME'..."
docker start "$CONTAINER_NAME" >/dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "ERROR: No se pudo iniciar el contenedor nuevamente."
    exit 1
fi

# Eliminar backups antiguos locales
echo "Eliminando backups locales con más de $RETENTION_DAYS días..."
find "$BACKUP_DIR" -name "minecraft_backup_*.tar.gz" -mtime +$RETENTION_DAYS -type f -delete
echo "Limpieza de backups antiguos completada."


# Envío al nodo Storage
echo "--- Enviando backup al RAID ($REMOTE_IP) ---"

# Usamos -o ConnectTimeout=10 para que no se quede colgado si el Storage está apagado
scp -o ConnectTimeout=10 "$BACKUP_DIR/$BACKUP_NAME" $REMOTE_USER@$REMOTE_IP:$REMOTE_DIR

if [ $? -eq 0 ]; then
    echo "✅ Backup enviado correctamente al Storage RAID."
else
    echo "⚠️ ADVERTENCIA: Falló el envío al RAID."
    echo "   El backup LOCAL está seguro, pero no se copió al remoto."
    echo "   Verifica que la VM 192.168.0.201 esté encendida y tengas llaves SSH."
fi

# FIN
echo "=== Backup finalizado ==="
exit 0