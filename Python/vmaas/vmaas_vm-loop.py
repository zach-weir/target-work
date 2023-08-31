import requests
import time
import json
import urllib3

# List of site names
#site_names = ["t0551","t0554"]
#site_names = ["t0555","t0556","t0557","t0558"]
site_names = ["t0559","t0560","t0578","t0579","t0580","t0587"]
#site_names = ["t0588","t0589","t0590","t0593","t0594","t0600"]
#site_names = ["t3032","t3801","t3802","t3803","t3804","t3806","t3808"]
#site_names = ["t3810","t3811","t3840","t3841","t3842","t3844","t3856"]
#site_names = ["t3857","t3858","t3859","t3861","t3862","t3863","t3865"]
#site_names = ["t3866","t3871","t3872","t3876","t3880","t3881","t3892"]
#site_names = ["t3895","t3897","t3899","t9156","t9275","t9478","t9479","t0553","t9407"]

urllib3.disable_warnings()

directory = "/Users/Z008L2N/Developer"
username = "z008l2n"
password = config.get('password')

# URL and headers
url = "https://vmaasapi.prod.target.com/vm/request"
headers = {
    "Content-Type": "application/json"
}

with open(f'{directory}/config.json') as config_file:
    config = json.load(config_file)

# Iterate through sites
for site_name in site_names:
    try:
        # Read JSON data from file
        json_filename = f"{directory}/VM_JSON/{site_name}.json"
        print(f"Opening {json_filename}...")
        data = open(json_filename, 'rb').read()

        # Send POST request
        response = requests.post(url, headers=headers, data=data, auth=(username, password), verify=False)

        # Print response
        print(f"Site: {site_name} -- Status Code: {response.status_code}")
        print(f"Request URL: {response.text}\n")
    except:
        print(f"{site_name}.json file not found, skipping")

    time.sleep(3)
