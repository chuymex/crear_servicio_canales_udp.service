# canales_udp

Este proyecto contiene scripts y configuraciones para la gestión y supervisión de canales UDP utilizando FFmpeg, integrando el arranque automático mediante un servicio systemd en servidores Linux.

## Características

- **Automatización:** Crea, habilita y arranca automáticamente un servicio systemd para supervisar los canales UDP.
- **Supervisión:** El servicio reinicia el proceso en caso de fallo y garantiza que no queden procesos FFmpeg huérfanos al reiniciar.
- **Gestión de logs:** El servicio guarda la salida estándar y de error en archivos de log configurables.
- **Eliminación de servicios previos:** El script de instalación detecta y elimina servicios antiguos relacionados antes de crear uno nuevo, personalizable mediante palabras clave.

## Archivos principales

- `canales_udp.sh`: Script principal que gestiona los canales UDP.
- `crear_servicio_canales_udp.sh`: Script para instalar y configurar el servicio systemd. 
- `README.md`: Este archivo.

## Instalación y uso

1. **Editar palabras clave de búsqueda (opcional):**
   En la parte superior de `crear_servicio_canales_udp.sh` puedes personalizar las palabras clave para detectar y eliminar servicios previos.

2. **Ejecutar el script de instalación:**
   ```bash
   sudo bash crear_servicio_canales_udp.sh
   ```

3. **Comandos útiles para el servicio:**
   - Ver estado:  
     ```bash
     sudo systemctl status canales_udp
     ```
   - Detener el servicio:  
     ```bash
     sudo systemctl stop canales_udp
     ```
   - Reiniciar el servicio (esto mata todos los procesos ffmpeg antes de reiniciar):  
     ```bash
     sudo systemctl restart canales_udp
     ```
   - Deshabilitar autoarranque:  
     ```bash
     sudo systemctl disable canales_udp
     ```
   - Eliminar el servicio:  
     ```bash
     sudo rm /etc/systemd/system/canales_udp.service && sudo systemctl daemon-reload
     ```

4. **Logs del servicio:**
   - Salida estándar: `/home/udp_push/logs/canales_udp_stdout.log`
   - Salida de error: `/home/udp_push/logs/canales_udp_stderr.log`

## Personalización

- Puedes modificar el usuario que ejecuta el servicio, la ruta de los logs y las palabras clave de búsqueda en el script `crear_servicio_canales_udp.sh`.
- El script principal (`canales_udp.sh`) debe contener la lógica de tus canales UDP y debe tener permisos de ejecución.

## Requisitos

- Linux con systemd (Debian, Ubuntu, CentOS, etc.)
- FFmpeg instalado.
- Permisos sudo para instalar y gestionar servicios.

## Licencia

Este proyecto está bajo la Licencia MIT.

---

**Contacto:**  
Autor: [chuymex](https://github.com/chuymex)
