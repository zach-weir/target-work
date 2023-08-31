# Chef scripting

## Install Chef Infra
- Use chef-client installer provided by Chef Software:
- Open PowerShell with admin rights
- Download and Install Chef Infra running the following command
```powershell
Invoke-WebRequest -Uri https://omnitruck.chef.io/install.ps1 -UseBasicParsing | Invoke-Expression
```
(This command downloads and executes the Chef Infra installer script - will determine the appropriate version of Chef Infra based on your system)
- Verify Installation
```powershell
chef-client --version
```

## Upload script to server
- Follow **add_chef_file.py** to run script to install the file to the remote server

## Run script
Use Chef client (chef-client) to apply the desired configuration to the server:
- Preparing your cookbook and configuration, uploading it to a Chef server, and then running the Chef client on the target server to apply the configuration.

Create or Prepare Cookbook:
- Write or modify the Chef cookbook (recipes, attributes, templates, etc.) to define the desired configuration for the target server.

Upload Cookbook:
- Upload the cookbook to a Chef server. You can use the knife command-line tool to do this.

Bootstrap the Node:
- "Bootstrap" the target server by installing the Chef client and establishing the connection between the server and the Chef server. You can use knife bootstrap or other methods depending on your environment.

Run Chef Client:
- On server, run the Chef client to apply the configuration defined in your cookbook

<br><br>
(Assume you have a cookbook named my_cookbook)

Upload cookbook:
- Use *knife* cookbook upload to upload cookbook to the Chef server

```bash
knife cookbook upload my_cookbook
```

Configure client on server:
- Bootstrap the target server to install and configure the Chef client

```bash
knife bootstrap target_server_ip -x username -P password -N node_name --sudo
```
*(Replace username, password, and node_name with appropriate values)*

Run Chef client:
- SSH into the target server and run the Chef client to apply config

```bash
ssh username@target_server_ip
sudo chef-client
```