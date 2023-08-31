import requests
import json
import urllib3
import keyring
from colorama import Fore, Back, Style

urllib3.disable_warnings()

url = f"https://vmaasapi.prod.target.com/vm/request"
headers = {
    "Content-Type": "application/json"
}
username = "z008l2n"
password = keyring.get_password("system", "z008l2n")

template = {
    "datacenter": "",
    "number_of_vms": "1",
    "vm_size": "medium",
    "operating_system": "windows2016",
    "environment": "prod",
    "ad_group": "app-msa-mobilityservercoidpwv",
    "vm_group": "tts-mobility-mpls",
    "identifier": "MOB",
    "maintenance_time": "0100",
    "maintenance_day": "1",
    "maintenance_week": "3",
    "blossom_id": "CI02722557",
    "business_group": "target technology services",
    "pvt_safe_name": "COID-WIN-SRV-CFD-Mobility",
    "justification": "MOB server for new DC"
}

site = int(input("Enter site name (####) -> "))
site_format = f"t{site:04d}"

try:
    if 1 <= site <= 9999:
        template["datacenter"] = site_format
        request_data = json.dumps(template)

        print(Fore.YELLOW + f"Submitting VM request..." + Style.RESET_ALL)
        response = requests.post(url, headers=headers, data=request_data, auth=(username, password), verify=False)
        request_error = json.loads(response.text)
            
        if "error" in request_error:
            print(Back.LIGHTRED_EX + Fore.WHITE + f"ERROR - VM request unsuccessful" + Style.RESET_ALL)
            print(Fore.RED + f"Error: {request_error['error']}" + Style.RESET_ALL)
        else:
            print(Back.LIGHTGREEN_EX + Fore.WHITE + f"VM request successful" + Style.RESET_ALL)
            print(Fore.GREEN + f"Request URL: {response.text}" + Style.RESET_ALL)
    else:
        print("ERROR - Incorrect DC number") 
except ValueError:
    print("ERROR - Invalid entry")
