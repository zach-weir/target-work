import requests
import json
import urllib3
import keyring
import time
from colorama import Fore, Back, Style

urllib3.disable_warnings()

# list site names
site_names = ["t0551","t0554"]
#site_names = ["t0555","t0556","t0557","t0558"]
#site_names = ["t0559","t0560","t0578","t0579","t0580","t0587"]
#site_names = ["t0588","t0589","t0590","t0593","t0594","t0600"]
#site_names = ["t3032","t3801","t3802","t3803","t3804","t3806","t3808"]
#site_names = ["t3810","t3811","t3840","t3841","t3842","t3844","t3856"]
#site_names = ["t3857","t3858","t3859","t3861","t3862","t3863","t3865"]
#site_names = ["t3866","t3871","t3872","t3876","t3880","t3881","t3892"]
#site_names = ["t3895","t3897","t3899","t9156","t9275","t9478","t9479","t0553","t9407"]

# set local directory and credentials
directory = "/Users/Z008L2N/Developer/Python"
username = "z008l2n"
password = keyring.get_password("system", "z008l2n")

# set API endpoints and header
check_url = f"https://vmaasapi.prod.target.com/vm/info?name=t{site_name}mob001p"
newdisk_url = "https://vmaasapi.prod.target.com/vm/disk"
headers = {
    "Content-Type": "application/json"
}

print(Back.LIGHTYELLOW_EX + Fore.WHITE + "########## STARTING ADDITIONAL DISK REQUESTS ##########" + Style.RESET_ALL)

for site_name in site_names:
    try:
        # send request
        response = requests.get(check_url, headers=headers, auth=(username, password), verify=False)
        response_data = response.json()

        # check for additional disks
        disks = response_data[0]['hardware']['disks']
        disk_count = len(disks)

        # request additional disk
        if disk_count < 1:
            print(f"{site_name} - Requesting additional disk...")
            raw_json = {
                "vm_name": f"t{site_name}mob001p",
                "action": "add_disk",
                "disk_size": "100"
            }
            format_json = json.dumps(raw_json)

            response = requests.post(newdisk_url, headers=headers, data=format_json, auth=(username, password), verify=False)
            print

        else:
            print(f"{site_name} - Additional disk already provisioned")
            print(disks)
    except:
        print(Back.Red + Fore.WHITE + f"{site_name.upper()} -- Error provisioning additional disk -- SKIPPING  " + Style.RESET_ALL)

    time.sleep(1)

print(Back.LIGHTGREEN_EX + Fore.WHITE + "########## ADDITIONAL DISK REQUESTS COMPLETE ##########" + Style.RESET_ALL)