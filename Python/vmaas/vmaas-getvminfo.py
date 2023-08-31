import requests
import json
import urllib3
import keyring
import time
import csv
from colorama import Fore, Back, Style

# list of site names
site_list = [
    "t0551", "t0554", "t0555", "t0556", "t0557", "t0558", "t0559", "t0560", "t0578", "t0579", "t0580", "t0587", "t0588", "t0589", "t0590", "t0593", "t0594", "t0600",
    "t3032", "t3801", "t3802", "t3803", "t3804", "t3806", "t3808", "t3810", "t3811", "t3840", "t3841", "t3842", "t3844", "t3856", "t3857", "t3858", "t3859", "t3861",
    "t3862", "t3863", "t3865", "t3866", "t3871", "t3872", "t3876", "t3880", "t3881", "t3892", "t3895", "t3897", "t3899", "t9156", "t9275", "t9478", "t9479", "t0553",
    "t9407"
]

type = "voc"

urllib3.disable_warnings()

directory = "/Users/Z008L2N/Developer"
username = "z008l2n"
password = keyring.get_password("system", "z008l2n")

csv_file = f'{directory}/script_results/{type}_vm_info.csv'

print(Back.LIGHTYELLOW_EX + Fore.WHITE + "########## STARTING VM INFO CHECK ##########" + Style.RESET_ALL)
            
with open(csv_file, 'a', newline='') as file:
    writer = csv.writer(file)
    writer.writerow(['name', 'disks', 'os', 'owner', 'vmaas_group', 'ip_addr'])

    for site in site_list:
        try:
            url = f"https://vmaasapi.prod.target.com/vm/info?name={site}{type}01p"
            headers = {
                "Content-Type": "application/json"
            }

            name = f"{site}{type}01p"

            # send request
            response = requests.get(url, headers=headers, auth=(username, password), verify=False)
            response_data = response.json()

            if "message" in response_data[0] and "name" not in response_data[0]:
                print(Fore.RED + f"{site.upper()} -- Site not found" + Style.RESET_ALL)
                disks = "not found"
                os = "not found"
                owner = "not found"
                vm_group = "not found"
                ip_addr = "not found"
            elif "name" in response_data[0]:
                print(Fore.GREEN + f"{site.upper()} -- Obtained VM info" + Style.RESET_ALL)
                disks = len(response_data[0]['hardware']['disks'])
                vmaas_owner = response_data[0]['vmaas_owner']
                owner = vmaas_owner.split('@')[0]

                if "2012" in response_data[0]['guest_os']:
                    os = "2012"
                elif "2016" in response_data[0]['guest_os']:
                    os = "2016"

                vm_group = response_data[0]['vmaas_group']
                ip_addr = response_data[0]['hardware']['ipaddresses'][0]
        except:
            print(Back.RED + Fore.WHITE + f"{site.upper()} -- Error getting VM info -- SKIPPING" + Style.RESET_ALL)
            disks = "error"
            os = "error"
            owner = "error"
            vm_group = "error"
            ip_addr = "error"
        
        writer.writerow([name, disks, os, owner, vm_group, ip_addr])

print(Back.LIGHTGREEN_EX + Fore.WHITE + "########## INFO CHECK COMPLETE ##########" + Style.RESET_ALL)