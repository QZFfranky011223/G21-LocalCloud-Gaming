# ☁️ LocalCloud Gaming: Infraestructura Distribuida de Servidores de Juego
# UNIVERSIDAD MAYOR, REAL Y PONTIFICIA DE SAN FRANCISCO XAVIER DE CHUQUISACA
## FACULTAD DE TECNOLOGÍA

![USFX Logo](https://img.shields.io/badge/USFX-Sistemas-red?style=for-the-badge) 
![Status](https://img.shields.io/badge/Estado-Finalizado-success?style=for-the-badge)
![Docker](https://img.shields.io/badge/Docker-Enabled-blue?style=for-the-badge&logo=docker)

---

# 🚀 Proyecto Final SIS313: LocalCloud Gaming (Infraestructura Distribuida)

**Asignatura:** SIS313: Infraestructura, Plataformas Tecnológicas y Redes  
**Semestre:** 2/2025  
**Docente:** Ing. Marcelo Quispe Ortega  

---

## 👥 Miembros del Equipo (Grupo G-21)

| Nombre Completo | Rol en el Proyecto | Contacto (GitHub) |
| :--- | :--- | :--- |
| **Huanca Coronado Oscar Santiago** | Arquitecto de Infraestructura y Redes | [@ssantiagoxx](https://github.com/ssantiagoxx) |
| **Mollinedo Siles Renzo Sebastian** | Ingeniero de Automatización (DevOps) | [@SoKierkegaard](https://github.com/SoKierkegaard) |
| **Quispe Zarate Franky** | Administrador de Servidores y Almacenamiento | [@QZFfranky011223](https://github.com/QZFfranky011223) |
| **Vargas Alarcón Brayan Mario** | Especialista en Seguridad y Monitoreo | [@TheBranx](https://github.com/) |

---

## 🎯 I. Objetivo del Proyecto

**Objetivo:** Diseñar e implementar una infraestructura de TI distribuida y virtualizada para alojar servicios de videojuegos (Luanti y Minecraft) en contenedores, garantizando la redundancia de datos mediante RAID 1, seguridad perimetral y monitoreo centralizado en tiempo real.

## 💡 II. Justificación e Importancia

**Justificación:**  
Este proyecto es relevante porque simula un entorno de producción real donde la continuidad del servicio es crítica. Resuelve problemas de **Pérdida de Datos (T2)** mediante la implementación de RAID 1 y estrategias de backup automatizado (Regla 3-2-1). Además, aborda la **Gestión de Redes (T3)** mediante un servidor DNS local (Pi-hole) y mejora la **Seguridad (T5)** mediante segmentación y proxies inversos, alejándose de las configuraciones monolíticas vulnerables a fallos únicos.

## 🛠️ III. Tecnologías y Conceptos Implementados

### 3.1. Tecnologías Clave
*   **Docker & Docker Compose:** Orquestación de contenedores para los servicios de juego (PaperMC, Luanti) y monitoreo, asegurando aislamiento y fácil despliegue.
*   **mdadm (Linux RAID):** Herramienta para la gestión de RAID por software, utilizada para crear un arreglo RAID 1 (Espejo) en el nodo de almacenamiento.
*   **Prometheus & Grafana:** Sistema de recolección de métricas y visualización. Prometheus extrae datos de los *node-exporters* y Grafana los presenta en dashboards (CPU, RAM, Red).
*   **Bash Scripting & Cron:** Automatización de tareas de mantenimiento, menús de gestión (`menu_servidor.sh`) y copias de seguridad automáticas vía SCP.
*   **Pi-hole:** Servidor DNS local para la resolución de nombres de dominio internos (ej. `dashboard.juego.lan`) y bloqueo de tráfico no deseado.
*   **Nginx Proxy Manager:** Gestión de Proxy Inverso para forzar conexiones SSL/TLS seguras hacia los paneles de administración.

### 3.2. Conceptos de la Asignatura Puestos en Práctica (T1 - T6)
- ✅ **Alta Disponibilidad (T2) y Tolerancia a Fallos:** Implementación de RAID 1 en el nodo de Storage y recuperación de servicios mediante backups externos.
- ✅ **Seguridad y Hardening (T5):** Uso de Firewalls (UFW), llaves SSH para transferencias sin contraseña y simulación de ataques DoS con `hping3`.
- ✅ **Automatización y Gestión (T6):** Scripts de Bash para la gestión de contenedores y automatización de backups con retención de 14 días.
- ✅ **Balanceo de Carga/Proxy (T3/T4):** Implementación de Nginx como punto de entrada seguro (HTTPS).
- ✅ **Monitoreo (T4/T1):** Despliegue de agentes Node Exporter en 5 nodos y centralización de alertas en VM-Monitor.
- ✅ **Networking Avanzado (T3):** Configuración de DNS interno, IPs estáticas y enrutamiento en red local.

## 🌐 IV. Diseño de la Infraestructura y Topología

### 4.1. Diseño Esquemático
La infraestructura opera en la red `192.168.0.0/24` con 5 nodos especializados.

| VM/Host | Rol | IP Estática | Servicios Principales | SO |
| :--- | :--- | :--- | :--- | :--- |
| **VM 1** | Storage / RAID | `192.168.0.201` | RAID 1 (mdadm), SSH Server | Ubuntu 24.04 |
| **VM 2** | Compute (Juegos) | `192.168.0.202` | Docker (Luanti, Minecraft), Scripts | Ubuntu 24.04 |
| **VM 3** | Monitor / Gateway | `192.168.0.203` | Grafana, Prometheus, Nginx | Ubuntu 24.04 |
| **VM 4** | Admin / Attacker | `192.168.0.204` | hping3, Cliente SSH | Ubuntu 24.04 |
| **VM 5** | Infra DNS | `192.168.0.205` | Pi-hole (Docker) | Ubuntu 24.04 |

### 4.2. Estrategia Adoptada
*   **Estrategia de Separación de Roles:** Se decidió desacoplar el cómputo (VM 2) del almacenamiento (VM 1). Esto permite que, si el servidor de juegos se satura o corrompe, los respaldos permanezcan seguros e intactos en un nodo físico/lógico distinto protegido por RAID.
*   **Estrategia de Seguridad 3-2-1:** Los backups se generan localmente, se comprimen y se envían a un almacenamiento remoto (VM Storage), garantizando que existan al menos dos copias de los datos en diferentes medios.

## 📋 V. Guía de Implementación y Puesta en Marcha

### 5.1. Pre-requisitos
*   Hypervisor (VirtualBox/VMware) configurado en modo "Adaptador Puente".
*   5 Máquinas Virtuales con Ubuntu Server 24.04 LTS instalado.
*   Acceso a internet en las VMs para la instalación inicial de paquetes.

### 5.2. Despliegue

**1. Configuración de Red (Netplan):**
Editar `/etc/netplan/00-installer-config.yaml` en cada VM para asignar las IPs estáticas (201 a 205) y establecer el DNS server a `192.168.0.205` (VM 5).

**2. Despliegue de Servicios (Docker):**
En VM 2 (Compute) y VM 3 (Monitor), clonar el repositorio y ejecutar:
```
sudo mdadm --create --verbose /dev/md0 --level=1 --raid-devices=2 /dev/sdb /dev/sdc
sudo mkfs.ext4 /dev/md0
sudo mount /dev/md0 /var/backups/clientes_juegos
```
### 5.3. Ficheros de Configuración Clave
*   `/nodo-compute/docker-compose.yml`: Define los servicios de Minecraft (PaperMC) y Luanti, limitando recursos (RAM/CPU).
*   `/nodo-compute/scripts/menu_servidor.sh`: Script interactivo para administración y backups manuales.
*   `/nodo-monitor/prometheus.yml`: Configuración de scraping para recolectar métricas de las IPs 192.168.0.201 a 205.
*   `/etc/crontab` (en VM 2): Programación de la tarea de respaldo a las 03:00 AM.

## ⚠️ VI. Pruebas y Validación

| Prueba Realizada | Resultado Esperado | Resultado Obtenido |
| :--- | :--- | :--- |
| **Simulación de Ataque DoS** (hping3 desde VM 4) | El uso de CPU en VM 2 debe subir drásticamente y Grafana debe registrar el pico. | **[OK]** Grafana mostró uso de CPU > 90% y alerta visual. |
| **Validación de Backup Automático** | El archivo `.tar.gz` debe aparecer en la carpeta RAID de la VM 1 sin intervención manual. | **[OK]** Archivo recibido correctamente vía SCP. |
| **Resolución DNS Interna** | Ping a `dashboard.juego.lan` debe resolver a `192.168.0.203`. | **[OK]** Pi-hole resolvió el dominio correctamente. |
| **Acceso Seguro Web** | Acceso al panel de control vía HTTP debe redirigir o bloquearse, permitiendo solo HTTPS. | **[OK]** Nginx Proxy Manager gestionó el certificado SSL. |

## 📚 VII. Conclusiones y Lecciones Aprendidas

El proyecto **LocalCloud Gaming** demostró la viabilidad de utilizar tecnologías de contenedores y virtualización para crear servicios robustos de entretenimiento.

*   **Logros:** Se logró una integración exitosa entre servicios dispares (Juegos, DNS, Monitoreo) utilizando una red interna estática. La implementación de RAID 1 y la automatización de backups aseguran la integridad de los datos de los usuarios, un activo crítico en servidores de juegos.
*   **Desafíos Superados:** La configuración de la comunicación segura entre nodos (SSH Keys) y la correcta configuración de los targets en Prometheus requirieron un ajuste fino de los firewalls (UFW) para permitir el tráfico en puertos específicos (9100, 3000, 22).
*   **Lección Aprendida:** La observabilidad no es opcional. Durante las pruebas de estrés, sin Grafana hubiera sido difícil identificar qué recurso (CPU vs RAM) estaba siendo el cuello de botella.

---
© 2025 Facultad de Tecnología - USFX