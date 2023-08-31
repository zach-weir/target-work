import datetime
import re
import requests
import json
import urllib3
import keyring
import time
from colorama import Fore, Back, Style

server = "uat"
aw_environment = {
    "store/dc": "https://awconsole.target.com",
    "workspace": "https://workspace.target.com",
    "uat": "https://uat-awconsole.target.com"
}
url_base = f'{aw_environment[server]}/api'
username = "z008l2n"
password = keyring.get_password("system", "z008l2n")
directory = "/Users/Z008L2N/Developer"

headers = {
    'aw-tenant-code': "12PQHIBAAAG7A6KAAEQA",
    'Content-Type': 'application/json',
    'Accept': 'application/json;version=2'
}

site_list = [
    "t0551", "t0554", "t0555", "t0556", "t0557", "t0558", "t0559", "t0560", "t0578", "t0579", "t0580", "t0587", "t0588", "t0589", "t0590", "t0593", "t0594", "t0600",
    "t3032", "t3801", "t3802", "t3803", "t3804", "t3806", "t3808", "t3810", "t3811", "t3840", "t3841", "t3842", "t3844", "t3856", "t3857", "t3858", "t3859", "t3861",
    "t3862", "t3863", "t3865", "t3866", "t3871", "t3872", "t3876", "t3880", "t3881", "t3892", "t3895", "t3897", "t3899", "t9156", "t9275", "t9478", "t9479", "t0553",
    "t9407"
]

aw_relay_servers = f'{directory}/script_results/aw-relay-servers.csv'

print(Back.LIGHTYELLOW_EX + Fore.WHITE + "########## STARTING AW RELAY SERVER LOOP ##########" + Style.RESET_ALL)
            
with open(csv_file, 'a', newline='') as file:
    writer = csv.writer(file)
    writer.writerow(['server_id', 'name', 'org_group', 'relay_hostname', 'relay_ip', 'relay_port', 'relay_user', 'device_passive', 'console_passive'])

    for relay_id in range(0,1000):
        try:
            response = requests.get(f"{url_base}/mdm/relayservers/{relay_id}", auth=(username, password), headers=headers)
            response_data = json.loads(response.text)

            server_id = relay_id
            name = response_data["General"]["Name"]
            relay_hostname = response_data["DeviceConnection"]["Hostname"]
            relay_ip_addr = response_data["ConsoleConnection"]["Hostname"]
            dev_port = response_data["DeviceConnection"]["Port"]
            dev_user = response_data["DeviceConnection"]["User"]
            dev_passive = response_data["DeviceConnection"]["PassiveMode"]
            con_port = response_data["ConsoleConnection"]["Port"]
            con_user = response_data["ConsoleConnection"]["User"]
            con_passive = response_data["ConsoleConnection"]["PassiveMode"]

            for site in site_list:
                if site.lower() in relay_hostname.lower():
                    org_group = site.strip('t')
                else:
                    continue
        except:
            print("exception")

        writer.writerow([server_id, name, org_group, relay_hostname, relay_ip_addr, dev_port, dev_user, dev_passive, con_port, con_user, con_passive])

""" 
params = {
    'serialnumber': device_id,
    'profileid': profile_id
}

data = {
    "deviceWipe": {
        "disallowProximitySetup": True,
        "preserveDataPlan": True,
        "disableActivationKey": True,
        "wipeType": "WIPE"
    }
}
"""