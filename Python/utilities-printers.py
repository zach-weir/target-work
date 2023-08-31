import os
import subprocess

def ping_host(host):
    if operating_system == "nt":
        ping = subprocess.call(['ping', '-n', '1', host], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    else:
        ping = subprocess.call(['ping', '-c', '1', host], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    return ping

# get OS name
operating_system = os.name