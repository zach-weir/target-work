import json

site_names = ["t3863","t3865","t3866","t3871","t3872","t3876","t3880","t3881","t3892","t3895","t3897","t3899","t9156","t9275","t9478","t9479","t0553","t9407"]

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
    "justification": "new vm for win2012 to 2016 migration"
}

for site_name in site_names:
    data = template.copy()
    data["datacenter"] = site_name
    
    filename = f"/Users/Z008L2N/Developer/VM_JSON/{site_name}.json"
    with open(filename, "w") as json_file:
        json.dump(data, json_file, indent=4)

    print(f"JSON file '{filename}' created.")
