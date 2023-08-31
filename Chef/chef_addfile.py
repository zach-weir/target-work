import paramiko

# SSH connection parameters
hostname = 'remote_server'
port = 22
username = 'your_ssh_username'
password = 'your_ssh_password'

# Local path to the Chef script file
local_script_path = 'path/to/your/chef_script.rb'

# Remote path to the cookbook directory
remote_cookbook_dir = '/path/to/remote/cookbook/files/default/'

def upload_chef_script():
    try:
        # Connect to the remote server
        ssh_client = paramiko.SSHClient()
        ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh_client.connect(hostname, port, username, password)

        # Create an SFTP client for file transfer
        sftp = ssh_client.open_sftp()

        # Transfer the Chef script file
        remote_script_path = remote_cookbook_dir + 'chef_script.rb'
        sftp.put(local_script_path, remote_script_path)

        print(f'Chef script uploaded to {remote_script_path}')

    except Exception as e:
        print(f'Error uploading Chef script: {e}')

    finally:
        sftp.close()
        ssh_client.close()

if __name__ == '__main__':
    upload_chef_script()
