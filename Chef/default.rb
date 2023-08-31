# Enable IIS
windows_feature 'IIS-WebServerRole' do
    action :install
  end
  
  # Enable FTP
  windows_feature 'IIS-FTPServer' do
    action :install
  end
  
  # Create inbound firewall rule for ports 9090, 9091, and 9443
  windows_firewall_rule 'Inbound - 9090' do
    local_port '9090'
    protocol 'TCP'
    direction :inbound
    action :allow
  end
  
  # Create outbound firewall rule for port 9090
  windows_firewall_rule 'Outbound - 9090' do
    local_port '9090'
    protocol 'TCP'
    direction :outbound
    action :allow
  end
  