import socket
from utilities import ping_host

def get_printer_model(printer_ip):
    string_to_send = "! U1 getvar \"usb.device.product_string\"\r\n"
    MESSAGE = string_to_send.encode('utf-8')

    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.connect((printer_ip, TCP_PORT))
        s.send(MESSAGE)
        data = s.recv(BUFFER_SIZE)
        data = str(data, 'utf-8').lower()
        s.close()
    except:
        pass

    if "zq620" in data:
        printer_model = "ZQ620"
    elif "qln320" in data:
        printer_model = "QLN320"
    elif "zt410" in data:
        printer_model = "ZT410"
    elif "zt411" in data:
        printer_model = "ZT411"
    else:
        printer_model = "UNKNOWN"

    print(f"Printer model - {printer_model}")


SERVER_PORT = 9100
BUFFER_SIZE = 1024
TCP_PORT = SERVER_PORT

printer_hostname = input("Enter printer hostname -> ")
printer_hostname = printer_hostname.strip()
printer_ip = socket.gethostbyname(printer_hostname)
ping_response = ping_host(printer_hostname)

if ping_response == 1:
    print(f"{printer_hostname} is offline!")
else:
    get_printer_model(printer_ip)
