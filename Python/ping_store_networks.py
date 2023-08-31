import os
import subprocess
import sys

def ping_host(host):
    if operating_system == "nt":
        ping = subprocess.call(['ping', '-n', '1', host], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    else:
        ping = subprocess.call(['ping', '-c', '1', host], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    return ping

# get OS name
operating_system = os.name

# open location file
locations = open("location_test.txt", "r")

# loop through list of locations between 0001 and 7999
for num in locations:
    num = num.strip()
    hostname = f"t{num}rtr_v29.target.com"
    ping_response = ping_host(hostname)

    if ping_response == 0:
        print(f"{hostname} is up!")
    else:
        print(f"{hostname} is down!")