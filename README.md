# ☁️ LocalCloud Gaming: Infraestructura Distribuida de Servidores de Juego

> **Proyecto Final SIS313:** Infraestructura, Plataformas Tecnológicas y Redes  
> **Universidad San Francisco Xavier de Chuquisaca**  
> **Semestre:** 2/2025  
> **Docente:** Ing. Marcelo Quispe Ortega

![Project Banner](https://img.shields.io/badge/Status-Completed-success)
![Docker](https://img.shields.io/badge/Docker-24.0.5-blue?logo=docker)
![Ubuntu](https://img.shields.io/badge/Ubuntu-Server_24.04-orange?logo=ubuntu)
![Grafana](https://img.shields.io/badge/Grafana-Monitoring-F46800?logo=grafana)
![Security](https://img.shields.io/badge/SSL-SelfSigned-red)

## 👥 Equipo de Proyecto (Grupo G-21)

| Nombre Completo | Rol en el Proyecto | Contacto (GitHub) |
| :--- | :--- | :--- |
| **Huanca Coronado Oscar Santiago** | Arquitecto de Infraestructura y Redes | [@UsuarioGitHub](https://github.com/) |
| **Mollinedo Siles Renzo Sebastian** | Ingeniero de Automatización (DevOps) | [@UsuarioGitHub](https://github.com/) |
| **Quispe Zarate Franky** | Admin. de Servidores y Almacenamiento | [@QZFfranky011223](https://github.com/) |
| **Vargas Alarcón Brayan Mario** | Especialista en Seguridad y Monitoreo | [@UsuarioGitHub](https://github.com/) |

---

## 📖 Descripción del Proyecto

**LocalCloud Gaming** es una implementación académica de una infraestructura de TI distribuida diseñada para alojar servicios de videojuegos de alta disponibilidad. El proyecto simula un entorno de producción real utilizando **virtualización, contenedores (Docker), automatización con Bash y monitoreo centralizado**.

Este proyecto fue desarrollado para resolver problemáticas de disponibilidad (T2) y seguridad (T5) en entornos de juegos on-premise.

### 🎯 Objetivos y Requisitos Cumplidos
- ✅ **Alta Disponibilidad:** Servicios desplegados mediante Docker Compose con reinicio automático.
- ✅ **Redundancia de Datos:** Implementación de **RAID 1 (Espejo)** para almacenamiento seguro de backups.
- ✅ **Seguridad Perimetral:** Proxy Inverso con **SSL/TLS** y Firewalls (UFW) configurados.
- ✅ **Infraestructura de Red:** Servidor **DNS Local** (Pi-hole) para resolución de nombres interna.
- ✅ **Observabilidad:** Dashboard de monitoreo en tiempo real (CPU, RAM, Disco, Red).
- ✅ **Automatización:** Scripts de backup automático y menú de gestión en consola.
- ✅ **Simulacro de Incidentes:** Pruebas de estrés y recuperación ante desastres (Disaster Recovery).

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
*(Asegúrate de subir la imagen a la carpeta docs/)*

---

## 🛠️ Implementación Técnica

### 1. Nodo de Cómputo (Servidores de Juego)
Este nodo es el corazón del procesamiento. Ejecuta los juegos en contenedores aislados para maximizar la estabilidad y facilitar la escalabilidad.
* **Luanti (Minetest):** Puerto `30000/udp`.
* **Minecraft (PaperMC):** Optimizado para bajo consumo de RAM (`1.5GB`) en puerto `25565/tcp`.
* **Gestión:** Se desarrolló un **Panel de Control en Bash** (`menu_servidor.sh`) que permite:
    * Iniciar/Detener contenedores.
    * Ver logs en tiempo real.
    * Ejecutar backups manuales.

### 2. Automatización de Backups (Estrategia 3-2-1)
1.  **Script Bash:** Detiene el contenedor momentáneamente (para consistencia), comprime la data (`tar.gz`) y reactiva el servicio.
2.  **Transferencia Segura:** Envío automático vía `SCP` (con llaves SSH) al Nodo de Storage.
3.  **Cron:** Ejecución programada diariamente a las 03:00 AM.
4.  **Retención:** Limpieza automática de archivos locales mayores a 14 días.

### 3. Almacenamiento Seguro (RAID)
El Nodo 1 cuenta con dos discos virtuales (`/dev/sdb`, `/dev/sdc`) configurados en **RAID 1 (Software)** mediante `mdadm`.
* **Punto de montaje:** `/var/backups/clientes_juegos`
* **Beneficio:** Garantiza que si un disco falla, los backups de los mundos persisten en el disco espejo.

### 4. Monitoreo y DNS
* **DNS Local:** Se utiliza **Pi-hole** para mapear el dominio `dashboard.juego.lan` a la IP del Monitor.
* **Dashboard:** Grafana visualiza métricas recolectadas por Prometheus desde los agentes `node-exporter` instalados en todos los nodos.
* **Seguridad SSL:** Acceso HTTPS forzado mediante **Nginx Proxy Manager** con certificados autofirmados.

![Dashboard Grafana](docs/dashboard_grafana.png)
*(Asegúrate de subir la imagen a la carpeta docs/)*

---

## 🚀 Despliegue e Instalación

### Prerrequisitos
* VirtualBox/VMware configurado en modo "Adaptador Puente".
* 5 VMs con Ubuntu Server 24.04 LTS.

### Estructura del Repositorio
```text
/
├── docs/               # Documentación y Diagramas
├── nodo-compute/       # Archivos para VM 2 (Juegos)
│   ├── docker-compose.yml
│   └── scripts/
├── nodo-monitor/       # Archivos para VM 3 (Prometheus/Grafana)
│   ├── prometheus.yml
│   ├── nginx.conf
│   └── docker-compose.yml
├── nodo-dns/           # Configuración Pi-hole VM 5
└── nodo-storage/       # Scripts de configuración RAID VM 1