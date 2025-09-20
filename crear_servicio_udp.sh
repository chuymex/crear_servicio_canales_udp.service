#!/bin/bash

################################################################################
# CONFIGURACIÓN DE PALABRAS CLAVE PARA DETECTAR Y ELIMINAR SERVICIOS PREVIOS
# Modifica el arreglo SEARCH_KEYWORDS para personalizar la búsqueda de servicios.
################################################################################
SEARCH_KEYWORDS=("canales" "udp")

################################################################################
# VARIABLES PRINCIPALES DEL SCRIPT Y SERVICIO
################################################################################
SCRIPT_PATH="/home/udp_push/canales_udp.sh"   # Script principal que será ejecutado por el servicio
SERVICE_NAME="canales_udp"                    # Nombre base del servicio systemd (sin .service)
LOG_DIR="/home/udp_push/logs"                 # Carpeta donde se guardarán los logs del servicio

################################################################################
# FUNCIÓN: Elimina servicios systemd previos que contengan las palabras clave.
# Busca tanto en /etc/systemd/system como en /lib/systemd/system.
# Para cada servicio detectado:
#   - Lo detiene.
#   - Lo deshabilita.
#   - Elimina el archivo .service.
# Finalmente, recarga systemd para aplicar los cambios.
################################################################################
eliminar_servicios_existentes() {
    echo "Buscando y eliminando servicios existentes con las palabras clave: ${SEARCH_KEYWORDS[*]}"
    for dir in /etc/systemd/system /lib/systemd/system; do
        if [ -d "$dir" ]; then
            for palabra in "${SEARCH_KEYWORDS[@]}"; do
                servicios=$(ls $dir | grep ".service" | grep -i "$palabra")
                for servicio in $servicios; do
                    ruta_servicio="$dir/$servicio"
                    nombre_servicio="${servicio%.service}"
                    echo "Eliminando servicio detectado: $servicio"
                    sudo systemctl stop "$nombre_servicio" 2>/dev/null
                    sudo systemctl disable "$nombre_servicio" 2>/dev/null
                    sudo rm -f "$ruta_servicio"
                done
            done
        fi
    done
    sudo systemctl daemon-reload
}

################################################################################
# ELIMINAR SERVICIOS EXISTENTES ANTES DE CREAR EL NUEVO
################################################################################
eliminar_servicios_existentes

################################################################################
# CREACIÓN DE LA CARPETA DE LOGS (si no existe)
################################################################################
sudo mkdir -p "${LOG_DIR}"

################################################################################
# CREACIÓN DEL ARCHIVO DE SERVICIO SYSTEMD
# Incluye lógica para matar ffmpeg en cada reinicio (ExecStop).
################################################################################
cat <<EOF | sudo tee /etc/systemd/system/${SERVICE_NAME}.service > /dev/null
[Unit]
Description=Supervisor de Canales UDP con FFmpeg
After=network.target

[Service]
Type=simple
ExecStart=${SCRIPT_PATH}
ExecStop=/usr/bin/killall -9 ffmpeg
Restart=always
RestartSec=2
User=$(whoami)
WorkingDirectory=$(dirname ${SCRIPT_PATH})
StandardOutput=append:${LOG_DIR}/canales_udp_stdout.log
StandardError=append:${LOG_DIR}/canales_udp_stderr.log

[Install]
WantedBy=multi-user.target
EOF

################################################################################
# ASIGNAR PERMISOS DE EJECUCIÓN AL SCRIPT PRINCIPAL
################################################################################
sudo chmod +x "${SCRIPT_PATH}"

################################################################################
# RECARGA DE SYSTEMD PARA DETECTAR EL NUEVO SERVICIO
################################################################################
sudo systemctl daemon-reload

################################################################################
# HABILITAR EL SERVICIO PARA INICIO AUTOMÁTICO
################################################################################
sudo systemctl enable ${SERVICE_NAME}.service

################################################################################
# INICIAR EL SERVICIO POR PRIMERA VEZ
################################################################################
sudo systemctl start ${SERVICE_NAME}.service

################################################################################
# MENSAJE INFORMATIVO Y COMANDOS ÚTILES PARA EL USUARIO
################################################################################
echo "Servicio ${SERVICE_NAME}.service creado y arrancado."
echo ""
echo "Comandos útiles:"
echo "  sudo systemctl status ${SERVICE_NAME}       # Ver estado del servicio"
echo "  sudo systemctl stop ${SERVICE_NAME}         # Detener el servicio"
echo "  sudo systemctl restart ${SERVICE_NAME}      # Reiniciar el servicio (ejecutará killall -9 ffmpeg antes de reiniciar)"
echo "  sudo systemctl disable ${SERVICE_NAME}      # Deshabilitar el autoarranque del servicio"
echo "  sudo rm /etc/systemd/system/${SERVICE_NAME}.service && sudo systemctl daemon-reload  # Eliminar el servicio"
echo ""
echo "Ver los logs en:"
echo "  Stdout: ${LOG_DIR}/canales_udp_stdout.log"
echo "  Stderr: ${LOG_DIR}/canales_udp_stderr.log"

################################################################################
# FIN DEL SCRIPT
################################################################################