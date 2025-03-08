import curses
import subprocess

def draw_menu(stdscr, selected_row_idx, options, title):
    stdscr.clear()
    h, w = stdscr.getmaxyx()

    stdscr.addstr(1, w // 2 - len(title) // 2, title, curses.A_BOLD)

    for idx, option in enumerate(options):
        x = w // 2 - len(option) // 2
        y = h // 2 - len(options) // 2 + idx + 2

        if idx == selected_row_idx:
            stdscr.attron(curses.A_REVERSE)
            stdscr.addstr(y, x, option)
            stdscr.attroff(curses.A_REVERSE)
        else:
            stdscr.addstr(y, x, option)

    stdscr.refresh()
def show_message(stdscr, message, ascii_art=None):
    """Muestra un mensaje y opcionalmente arte ASCII en la pantalla con colores."""
    stdscr.clear()
    h, w = stdscr.getmaxyx()

    # Inicializar colores
    curses.start_color()
    curses.init_pair(1, curses.COLOR_RED, curses.COLOR_BLACK)  # Texto verde, fondo negro
    curses.init_pair(2, curses.COLOR_CYAN, curses.COLOR_BLACK)   # Texto cyan, fondo negro

    # Mostrar el arte ASCII si está proporcionado
    if ascii_art:
        art_lines = ascii_art.splitlines()
        art_y = h // 2 - len(art_lines) // 2 - 1
        for idx, line in enumerate(art_lines):
            x = w // 2 - len(line) // 2
            stdscr.addstr(art_y + idx, x, line, curses.color_pair(1))  # Aplicar color verde

    # Mostrar el mensaje debajo del arte ASCII
    msg_y = h // 2 + 1 if ascii_art else h // 2
    stdscr.addstr(msg_y, w // 2 - len(message) // 2, message, curses.color_pair(2))  # Aplicar color cyan
    stdscr.refresh()

    # Esperar a que el usuario presione Enter (tecla 10 o 13)
    while True:
        key = stdscr.getch()
        if key in [10, 13]:  # Enter
            break

    
def get_network_devices():

    try:
        result = subprocess.run(["ip", "link", "show"], capture_output=True, text=True, check=True)
        devices = []
        for line in result.stdout.splitlines():
            if "state" in line:
                device = line.split(":")[1].strip()
                devices.append(device)
        return devices
    except subprocess.CalledProcessError:
        return []

def ping_device(stdscr, device):
    show_message(stdscr, f"Haciendo ping con {device}...")
    try:
        subprocess.run(["ping", "-c", "3", "-I", device, "archlinux.org"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)
        show_message(stdscr, f"Ping exitoso con {device}.")
    except subprocess.CalledProcessError:
        show_message(stdscr, f"Error al hacer ping con {device}.")

def connect_wifi(stdscr):
    """Conecta a una red Wi-Fi usando `iwctl`."""
    show_message(stdscr, "Conectando a Wi-Fi con iwctl...")
    try:
        subprocess.run(["iwctl", "station", "wlan0", "scan"], check=True)
        subprocess.run(["iwctl", "station", "wlan0", "get-networks"], check=True)
        show_message(stdscr, "Ingresa el nombre de la red Wi-Fi:")
        curses.echo()  
        network_name = stdscr.getstr().decode("utf-8")
        curses.noecho() 
        subprocess.run(["iwctl", "station", "wlan0", "connect", network_name], check=True)
        show_message(stdscr, f"Conectado a {network_name}.")
    except subprocess.CalledProcessError:
        show_message(stdscr, "Error al conectar a Wi-Fi.")

def configure_network(stdscr):
    devices = get_network_devices()
    if not devices:
        show_message(stdscr, "No se encontraron dispositivos de red.")
        return

    selected_row_idx = 0
    while True:
        draw_menu(stdscr, selected_row_idx, devices, "Selecciona un dispositivo de red:")
        key = stdscr.getch()

        if key == curses.KEY_UP and selected_row_idx > 0:
            selected_row_idx -= 1
        elif key == curses.KEY_DOWN and selected_row_idx < len(devices) - 1:
            selected_row_idx += 1
        elif key == curses.KEY_ENTER or key in [10, 13]:
            selected_device = devices[selected_row_idx]
            if selected_device == "wlan0":
                connect_wifi(stdscr)
            else:
                ping_device(stdscr, selected_device)
            break
        elif key == ord("q"):  # Presionar 'q' para salir
            break

def partition_disk(stdscr):
    show_message(stdscr, "Particionando disco... (Simulación)")
    # Aquí podrías agregar lógica real para particionar el disco

def install_system(stdscr):
    show_message(stdscr, "Instalando sistema... (Simulación)")
    # Aquí podrías agregar lógica real para instalar el sistema

def main_menu(stdscr):
    curses.curs_set(0)
    stdscr.keypad(True)
    options = ["Configurar red", "Particionar disco", "Instalar sistema", "Salir"]
    selected_row_idx = 0

    while True:
        draw_menu(stdscr, selected_row_idx, options, "Menú principal")
        key = stdscr.getch()

        if key == curses.KEY_UP and selected_row_idx > 0:
            selected_row_idx -= 1
        elif key == curses.KEY_DOWN and selected_row_idx < len(options) - 1:
            selected_row_idx += 1
        elif key == curses.KEY_ENTER or key in [10, 13]:
            if selected_row_idx == 0:
                configure_network(stdscr)
            elif selected_row_idx == 1:
                partition_disk(stdscr)
            elif selected_row_idx == 2:
                install_system(stdscr)
            elif selected_row_idx == 3:
                break

def main(stdscr):
    curses.curs_set(0)
    stdscr.keypad(True)   
    ascii_art = r"""
██╗  ██╗ ██████╗ ██╗  ██╗ █████╗ ████████╗███████╗███████╗███╗   ██╗
██║ ██╔╝██╔═══██╗██║ ██╔╝██╔══██╗╚══██╔══╝╚══███╔╝██╔════╝████╗  ██║
█████╔╝ ██║   ██║█████╔╝ ███████║   ██║     ███╔╝ █████╗  ██╔██╗ ██║
██╔═██╗ ██║   ██║██╔═██╗ ██╔══██║   ██║    ███╔╝  ██╔══╝  ██║╚██╗██║
██║  ██╗╚██████╔╝██║  ██╗██║  ██║   ██║   ███████╗███████╗██║ ╚████║
╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   ╚══════╝╚══════╝╚═╝  ╚═══╝
    """

    message = "¡Bienvenido al instalador de Arch Linux!"
    show_message(stdscr, message, ascii_art)
    main_menu(stdscr)
    show_message(stdscr, "Instalación completada. ¡Gracias!")

# Iniciar la aplicación
curses.wrapper(main)
