#!/bin/bash

# --- COLORES Y ESTILOS ---
VERDE='\033[0;32m'
ROJO='\033[0;31m'
AZUL='\033[0;34m'
AMARILLO='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# --- CONFIGURACIÓN ---
# IMPORTANTE: Verifica que esta carpeta sea la correcta
DOCKER_DIR="/home/sebastian/game-server" 
SCRIPT_LUANTI="/home/sebastian/scripts/backup_luanti.sh"
SCRIPT_MC="/home/sebastian/scripts/backup_minecraft.sh"

# --- FUNCIONES AUXILIARES ---

wait_key() {
    echo ""
    read -n 1 -s -r -p "Presiona cualquier tecla para volver al menú..."
}

gestion_docker() {
    ACCION=$1
    SERVICIO=$2

    echo -e "\n${CYAN}Ejecutando: $ACCION en ${SERVICIO:-TODOS}...${NC}"
    cd "$DOCKER_DIR" || { echo "Error: No se encuentra el directorio $DOCKER_DIR"; wait_key; return; }

    case $ACCION in
        "up")
            docker compose up -d $SERVICIO
            ;;
        "down")
            docker compose down # 'down' baja todo, no acepta nombre de servicio individual usualmente para borrar redes
            ;;
        "stop")
            docker compose stop $SERVICIO
            ;;
        "restart")
            docker compose restart $SERVICIO
            ;;
        "logs")
            docker compose logs -f --tail=50 $SERVICIO
            # No ponemos wait_key aquí para salir rápido con Ctrl+C
            return 
            ;;
    esac
    
    if [ $? -eq 0 ]; then
        echo -e "${VERDE}✔ Operación completada.${NC}"
    else
        echo -e "${ROJO}✘ Hubo un error.${NC}"
    fi
    wait_key
}

mostrar_menu() {
    clear
    echo -e "${AZUL}==============================================${NC}"
    echo -e "${AZUL}   🎮  PANEL DE CONTROL - LOCALCLOUD GAMING   ${NC}"
    echo -e "${AZUL}==============================================${NC}"
    
    echo -e "${AMARILLO}--- 🌍 GESTIÓN GLOBAL ---${NC}"
    echo "1. 🟢 Encender TODO (Luanti + Minecraft + Monitor)"
    echo "2. 🔴 Apagar TODO"
    echo "3. 📊 Ver Estado General (docker ps)"
    echo "4. 📈 Ver Métricas (URL Node Exporter)"

    echo -e "\n${AMARILLO}--- 🟦 LUANTI (Minetest) ---${NC}"
    echo "10. Ver Logs Luanti"
    echo "11. Reiniciar Luanti"
    echo "12. 💾 Backup Manual Luanti"

    echo -e "\n${AMARILLO}--- 🟩 MINECRAFT ---${NC}"
    echo "20. Ver Logs Minecraft"
    echo "21. Reiniciar Minecraft"
    echo "22. 💾 Backup Manual Minecraft"

    echo -e "\n0. Salir"
    echo -e "${AZUL}==============================================${NC}"
}

# --- BUCLE PRINCIPAL ---

while true; do
    mostrar_menu
    read -p "Selecciona una opción: " OPCION

    case $OPCION in
        # GLOBAL
        1) gestion_docker "up" "" ;;
        2) gestion_docker "stop" "" ;; # Usamos stop en vez de down para no borrar la red
        3) 
            echo -e "\n${CYAN}Listando contenedores activos:${NC}"
            cd "$DOCKER_DIR" && docker compose ps
            wait_key 
            ;;
        4)
            IP=$(hostname -I | awk '{print $1}')
            echo -e "\n${VERDE}Métricas disponibles en:${NC} http://$IP:9100/metrics"
            wait_key
            ;;

        # LUANTI
        10) gestion_docker "logs" "luanti" ;;
        11) gestion_docker "restart" "luanti" ;;
        12) 
            echo -e "\n${VERDE}Iniciando script de backup para Luanti...${NC}"
            bash "$SCRIPT_LUANTI"
            wait_key 
            ;;

        # MINECRAFT
        20) gestion_docker "logs" "minecraft" ;;
        21) gestion_docker "restart" "minecraft" ;;
        22) 
            echo -e "\n${VERDE}Iniciando script de backup para Minecraft...${NC}"
            bash "$SCRIPT_MC"
            wait_key 
            ;;

        # SALIDA
        0) 
            echo "Saliendo... ¡Hasta luego!"
            exit 0 
            ;;
        *) 
            echo -e "\n${ROJO}Opción inválida, intenta de nuevo.${NC}"
            sleep 1
            ;;
    esac
done