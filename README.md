# ☁️ LocalCloud Gaming: Infraestructura Distribuida de Servidores de Juego

![Project Banner](https://img.shields.io/badge/Status-Completed-success)
![Docker](https://img.shields.io/badge/Docker-24.0.5-blue?logo=docker)
![Ubuntu](https://img.shields.io/badge/Ubuntu-Server_24.04-orange?logo=ubuntu)
![Grafana](https://img.shields.io/badge/Grafana-Monitoring-F46800?logo=grafana)
![Security](https://img.shields.io/badge/SSL-SelfSigned-red)

## 📖 Descripción del Proyecto

**LocalCloud Gaming** es una implementación académica de una infraestructura de TI distribuida diseñada para alojar servicios de videojuegos de alta disponibilidad. El proyecto simula un entorno de producción real utilizando **virtualización, contenedores (Docker), automatización con Bash y monitoreo centralizado**.

Este proyecto fue desarrollado como requisito final para la materia de **SIS313** en la **Universidad San Francisco Xavier**.

### 🎯 Objetivos y Requisitos Cumplidos
- ✅ **Alta Disponibilidad:** Servicios desplegados mediante Docker Compose.
- ✅ **Redundancia de Datos:** Implementación de **RAID 1 (Espejo)** para almacenamiento de backups.
- ✅ **Seguridad Perimetral:** Proxy Inverso con **SSL/TLS** y Firewalls (UFW) configurados.
- ✅ **Infraestructura de Red:** Servidor **DNS Local** (Pi-hole) para resolución de nombres.
- ✅ **Observabilidad:** Dashboard de monitoreo en tiempo real (CPU, RAM, Disco, Red).
- ✅ **Automatización:** Scripts de backup automático y menú de gestión en consola.
- ✅ **Simulacro de Incidentes:** Pruebas de estrés y recuperación ante desastres.

---

## 🗺️ Topología de Red

La infraestructura se divide en 5 nodos virtualizados interconectados en una red local (`192.168.0.0/24`).

| Nodo | IP Estática | Rol | Servicios Principales |
| :--- | :--- | :--- | :--- |
| **VM 1** | `192.168.0.201` | **Storage / RAID** | RAID 1 (mdadm), SSH Server, Node Exporter |
| **VM 2** | `192.168.0.202` | **Compute (Juegos)** | Docker, Luanti, Minecraft (PaperMC), Scripts |
| **VM 3** | `192.168.0.203` | **Monitor / Gateway** | Grafana, Prometheus, Nginx (SSL) |
| **VM 4** | `192.168.0.204` | **Admin / Attacker** | Herramientas de ataque (hping3), Cliente SSH |
| **VM 5** | `192.168.0.205` | **Infra DNS** | Pi-hole (Docker) |

![Diagrama de Topología](docs/topologia_red.png)
*Imagen del diagrama*

---

## 🛠️ Implementación Técnica

### 1. Nodo de Cómputo (Servidores de Juego)
Este nodo es el corazón del procesamiento. Ejecuta los juegos en contenedores aislados para maximizar la estabilidad.
* **Luanti (Minetest):** Puerto `30000/udp`.
* **Minecraft (PaperMC):** Optimizado para bajo consumo de RAM (`1.5GB`) en puerto `25565/tcp`.
* **Gestión:** Se desarrolló un **Panel de Control en Bash** (`menu_servidor.sh`) que permite:
    * Iniciar/Detener contenedores.
    * Ver logs en tiempo real.
    * Ejecutar backups manuales.

### 2. Automatización de Backups
Se implementó una estrategia de respaldo **3-2-1**:
1.  **Script Bash:** Detiene el contenedor momentáneamente (consistencia), comprime la data (`tar.gz`) y reactiva el servicio.
2.  **Transferencia Segura:** Envío automático vía `SCP` (con llaves SSH) al Nodo de Storage.
3.  **Cron:** Ejecución programada diariamente a las 03:00 AM.
4.  **Retención:** Limpieza automática de archivos locales mayores a 14 días.

### 3. Almacenamiento Seguro (RAID)
El Nodo 1 cuenta con dos discos virtuales (`/dev/sdb`, `/dev/sdc`) configurados en **RAID 1 (Software)** mediante `mdadm`.
* **Punto de montaje:** `/var/backups/clientes_juegos`
* Esto garantiza que si un disco falla, los backups de los mundos persisten.

### 4. Monitoreo y DNS
* **DNS Local:** Se utiliza **Pi-hole** para mapear el dominio `dashboard.juego.lan` a la IP del Monitor.
* **Dashboard:** Grafana visualiza métricas recolectadas por Prometheus desde los agentes `node-exporter` instalados en todos los nodos.
* **Seguridad SSL:** Acceso HTTPS forzado mediante **Nginx Proxy Manager** con certificados autofirmados.

![Dashboard Grafana](docs/dashboard_grafana.png)
*Captura Grafana*

---

## 🚀 Despliegue e Instalación

### Prerrequisitos
* VirtualBox configurado en modo "Adaptador Puente" o "Red Solo-Anfitrión".
* 5 VMs con Ubuntu Server 24.04 LTS.

### Estructura del Repositorio
```text
/
├── nodo-compute/       # Archivos para VM 2
│   ├── docker-compose.yml
│   └── scripts/
├── nodo-monitor/       # Archivos para VM 3
│   ├── prometheus.yml
│   ├── nginx.conf
│   └── docker-compose.yml
├── nodo-dns/           # Configuración Pi-hole VM 5
└── nodo-storage/       # Scripts de configuración RAID VM 1
````

### Instrucciones Rápidas

1.  Clonar el repositorio en cada VM según su rol.
2.  Configurar IPs estáticas con **Netplan**.
3.  Instalar Docker y Docker Compose.
4.  Ejecutar `docker compose up -d` en las carpetas correspondientes.
5.  Configurar las llaves SSH entre el Nodo Compute y el Nodo Storage.

-----

## 🛡️ Simulación de Incidente de Seguridad

Como parte de la validación del proyecto, se diseñó un escenario de ataque:

1.  **Vector:** Ataque de Denegación de Servicio (DoS) UDP Flood usando `hping3` desde el Nodo Admin.
2.  **Objetivo:** Saturar el CPU del Nodo Compute (Juegos).
3.  **Detección:** El Dashboard de Grafana alerta sobre el uso de CPU \> 90%.
4.  **Recuperación:** Restauración del servicio mediante backup desde el RAID.

-----

*Proyecto universitario - 2025*

```
```