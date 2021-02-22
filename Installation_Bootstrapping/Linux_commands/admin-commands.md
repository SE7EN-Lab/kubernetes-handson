 
 ```
 # To identify the os details of Linux
	# Ubuntu, Debian, CentOS, RedHat
			hostnamectl
			cat /etc/os-release

 # List all installed packages on Linux
	# Ubuntu, Debian
			apt list
	# CentOS, RedHat, Fedora
			rpm -qa
			yum list installed 

 # Install a specific version of package on Linux
	# Ubuntu, Debian
			apt-get update && apt-get install <package-name>=<version>
	# CentOS, RedHat, Fedora
			yum update && yum install <package-name>-<version>

 # Hold auto update of package
	# Ubuntu, Debian
			apt-mark hold <pacakage-name>
			apt-mark showhold
	
 # Un-hold auto update of package
	# Ubuntu, Debian
			apt-mark unhold <pacakage-name>
			apt-mark showhold
	# CentOS, RedHat, Fedora
			yum --exclude <pacakage-name> update 
			
 # System level Firewall commands
	# Ubuntu, Debian
		UFW - Ubuntu ships with a firewall configuration tool called UFW (Uncomplicated Firewall). UFW is a user-friendly front-end for managing iptables firewall rules and its main goal is to make managing firewall rules easier.
			ufw status
			ufw disable
			ufw reset
			ufw enable
	
	# RedHat, CentOS
		Firewalld - firewalld is a zone-based firewall. Zone-based firewalls are network security systems that monitor traffic and take actions based on a set of defined rules applied against incoming/outgoing packets. More info https://www.redhat.com/sysadmin/beginners-guide-firewalld
		#Disable, Enable firewall
			systemctl stop firewalld
			systemctl disable firewalld
			firewall-cmd --state
			
			systemctl restart firewalld
			systemctl enable firewalld
			firewall-cmd --state
			
		# List all zones
			firewall-cmd --get-zones
		# List all services associated with a given zone
			firewall-cmd --zone=<zone-name> --list-all
		# Allow & Deny by Service
			firewall-cmd --permanent --zone=<zonename> --add-service=<service-name>
			firewall-cmd --permanent --zone=<zonename> --remove-service=<service-name>
			firewall-cmd --reload 
			firewall-cmd --zone=<zonename> --list-services
		
		# Allow & Deny by Port
			firewall-cmd --permanent --zone=<zonename> --add-port=<port-no>/<protocol-name> 
			firewall-cmd --permanent --zone=<zonename> --remove-port=<prot-no>/<protocol-name>
			firewall-cmd --reload
			firewall-cmd --zone=<zonename> --list-ports
		
 # Networking commands			
	# List IP address on Linux
		ip addr
	
	# List network interfaces on Linux
		ip link show
		
	# List all open ports on Linux
		netstat -lntu
	
	# List listening programs running on port
		netstat -ap | grep <program-name>
		
	# Scan for open ports on (remote) host
		nc -z -v <host-ip> <port-no>
	
	# Start a tcp connection to a specific host and port
		nc <host-ip> <port-no>
	
	# nslookup command
 
 # Bash commands
	# List the history of comands executed on bash
		history
		
	# Reverse search commands executed on bash
		<CTRL>+ R
	# Re-execute last command line
		!!
	# View return code of the last executed cmmanline
		echo $?
	
 # Auto completion for bash
	# Verify auto-completetion is enabled on bash
			type init_completion
	
	# Enable kubectl auto-completion
			echo 'source <(kubectl completion bash)' >>~/.bashrc
			source ~/.bash_profile
			
 # configure vim editor for yaml editing. Edit/Create  ~/.vimrc file with below content
		set nu
		syntax enable
		filetype on
		autocmd FileType yaml,yml setlocal ts=2 sts=2 sw=2 expandtab indentkeys-=0# indentkeys-=<:>

 # Systemctl commands
	# Start, Stop, Re-start, Reload systemd services
		systemctl start <systemd-unit-name>
		systemctl stop <systemd-unit-name>
		systemctl restart <systemd-unit-name>
		systemctl reload <systemd-unit-name>
		
	# Enable, Disable systemd services
		systemctl enable <systemd-unit-name>
		systemctl disable <systemd-unit-name>
		
	# Status checking systemd services
		systemctl status <systemd-unit-name>
		systemctl is-active <systemd-unit-name>
		systemctl is-enabled <systemd-unit-name>
		systemctl is-failed <systemd-unit-name>
		
	# System state overview
		systemctl list-units
		systemctl list-units --all --state=inactive
		systemctl list-units --type=service
		systemctl list-unit-files
		
	# Systemd unit management
		systemctl cat <systemd-unit-name>
		systemctl list-dependencies <systemd-unit-name>
		systemctl show <systemd-unit-name>
		systemctl edit <systemd-unit-name>
		
	# Reload systemd process
		systemctl daemon-reload
	
	# Shutdown, Restart Server
		systemctl halt
		systemctl poweroff
		systemctl reboot
		
 # Log management commands
 # Journalctl is a utility for querying and displaying logs from journald, systemd’s logging service. Since journald stores log data in a binary format instead of a plaintext format, journalctl is the standard way of reading log messages processed by journald.
		# Query logs by boot messages
				journalctl --list-boots
				journalctl -b <offset-value>
				
		# Query logs by time ranges
				journalctl --since "1 hour ago"
				journalctl --since ''2 days ago"
				journalctl --since "YYYY-MM-DD HH:MM:SS" --until "YYYY-MM-DD HH:MM:SS"
				
		# Query logs by systemd unit
				journalctl -u <systemd-unit-name> --since "YYYY-MM-DD HH:MM:SS" --until "YYYY-MM-DD HH:MM:SS"
				journalctl -u <systemd-unit-name> -r -n <number-of-most-recent-entries> --since "<time range>"
		
		# Tail system logs on console
				journalctl -f 
				journalctl -u <systemd-unit-name> -f
		
		# Output formats
				journalctl -o [json-pretty | verbose | cat]
		
		# Query logs by user id
				journalctl _UID=<user-id>
		
		# Query logs by process-id
				journalctl _PID=<process-id>
				
		# Query all errors for services since last reboot
				journalctl -p 3 -xb
				
# User management commands
		# Create a user group on linux
				groupadd <group-name>
				
		# Add user to a specific group with home dir on Linux
				useradd  -m -g <group-name> <user-name>
				id <user-name>
				
		# Set password for the user n Linux
				passwd <user-name>
		
		# View the expiry details of user account on Linux
				chage -l <user-name>
		
# Process management commands

 ```
 ## vim cheat sheet
![alt text](images/vim_cheatsheet.png)