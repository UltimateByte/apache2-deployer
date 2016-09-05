#!/bin/bash
# Apache2 website deployment
# Authors: UltimateByte, BassSpleen
# Website: https://www.terageek.org
# Description: Creates required files and folders to deploy an apache2 website in one command
# Version: 0.2
 
### SETTINGS ##
# The parent folder for your user's home directory (usually /home)
homedir="/home"
# The name of you website's folder (usually public_html or www)
webdir="public_html"

#############
## Program ##
#############

# Misc Variables
selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"
apache_sites="/etc/apache2/sites-available"
apacheprocess="www-data"
defumask="#umask 022"
umask="umask 007"

# Check that the user inputted two arguments
if [ -z "$1" ] || [ -z "$2" ]; then
	echo "Info! Please, specify a username and a domain for the website"
	echo "Example: ./${selfname} username domain.com"
	exit 1
elif [ -n "$3" ]; then
	echo "[ERROR] Too many arguments!"
	sleep 1
	echo "Info! Please specify a username and a domain for the website"
	echo "Example: ./${selfname} username domain.com"
	exit 1
else
	# Use a variable name that makes sense
	username="${1}"
	# Strip www. from user input since we're adding it as an alias
	domain="${2#www.}"
fi

# Check that the script is launched with elevated privileges
fn_check_root(){
	if [ "$(id -u)" != "0" ]; then
		echo "[ERROR] This script must be run with elevated privileges"
		exit 1
	fi
}

 # Checking script config
fn_check_vars(){
	echo "Checking config..."
	sleep 1
	# Checking that the home directory exists
	if [ -d "${homedir}" ]; then
		check_homedir=0
	else
		check_homedir=1
		echo "[ERROR] Could not find ${homedir}"
		echo "Please, set a valid homedir value"
		sleep 2
	fi
	# Checking that the variable directory has been set
	if [ -n "${webdir}" ]; then
		check_webdir=0
	else
		check_webdir=1
		echo "[ERROR] No webdir set"
		echo "Please, set a valid webdir"
	sleep 2
	fi
 
	# Checking that Apache2 websites-available folder exists
	if [ -d "${apache_sites}" ]; then
		check_apachedir=0
	else
		check_apachedir=1
		echo "[ERROR] Could not find ${apache_sites}"
		echo "Please, install apache2"
		sleep 2
	fi
 
	# Check summ up
	if [ "${check_homedir}" == "1" ] || [ "${check_webdir}" == "1" ] || [ "${check_apachedir}" == "1" ]; then
		echo "Info! Errors found, exiting..."
		sleep 1
		exit 1
	else
		echo ""
		echo "[OK] Config test passed!"
		sleep 1
		echo ""
		# Setting directories
		userdir="${homedir}/${username}"
		targetdir="${userdir}/${webdir}"
	fi
}

# Checks if the user exists and sets the test variable
fn_check_user_exists(){
	if [ -z "$(grep -q "${username}" /etc/passwd)" ]; then
		userexists="0"
	else
		userexists="1"
		if [ ! -d "${targetdir}" ]; then
			echo "[ERROR] no target directory to fix"
			echo "This script needs ${targetdir} to exist"
			echo "Maybe edit the script variables accordingly"
		fi
	fi
}

fn_welcome_prompt(){
	echo "########################################################"
	echo "########## Apache 2 website deployment script ##########"
	echo "########################################################"
	sleep 1
	echo ""
	echo "Welcome!"
	echo ""
	if [ "${userexists}" == "0" ]; then
		echo "${username} and Virtual Hosts will be created"
		echo ""
	elif [ "${userexists}" == "1" ]; then
		echo "${username} exists"
		echo "Virtual Hosts will be created if it does not exist"
		echo "Permissions will be fixed"
		echo "HTML directory will be created if needed"
		echo ""
	else
		echo "[ERROR] Could not determine if ${username} exists"
		echo "Please, open a Github issue"
		exit 1
	fi
	echo "Here are your settings:"
	echo "Domain: ${domain}"
	echo "Username: ${username}"
	echo "Target directory: ${targetdir}"
	echo ""
	while true; do
		read -e -i "y" -p "Continue? [Y/n]" yn
		case $yn in
		[Yy]* ) echo "Let's go!"; sleep 1; break;;
		[Nn]* ) echo "Maybe next time!"; return;;
		* ) echo "Please answer yes or no.";;
	esac
	done
}

# Adding a user with the correct homedir
fn_add_user(){
	if [ "${userexists}" == "0" ]; then
		echo ""
		echo "#################### User Creation #####################"
		echo ""
		sleep 1
		echo "Creating ${username}..."
		sleep 1
		useradd -m -d "${userdir}" "${username}"
		echo "[OK] User created!"
		echo ""
		echo "[PASSWORD] Please, input a password for ${username}"
		passwd "${username}"
		echo "[OK] Password set!"
	fi
}

fn_fix_umask(){
	echo ""
	echo "##################### Fixing Umask ####################"
	echo ""	
	sleep 2
	if [ -n "$(cat "${userdir}"/.profile | grep "${defumask}")" ]; then
		echo "[Warning] Default umask not found, no change will be applied"
	else
		echo "Fixing user umask (default permissions on files)"
		sleep 1
		sed -i "s/${defumask}/${umask}/g" "${userdir}"/.profile
		echo "[OK] ${umask} set!"
	fi
}

# Creating the web directory and applying permissions
fn_web_directory(){
	echo ""
	echo "################## Directory Creation ##################"
	echo ""
	sleep 1
	echo "Creating the web directory..."
	sleep 1
	if [ -d "${targetdir}" ]; then
		echo "Info! ${targetdir} already exists"
	else
		mkdir -pv "${targetdir}"
		echo "[OK] Directory created!"
	fi
	echo ""
	echo "Applying correct ownership & permissions to the website folder..."
	sleep 1
	chown -R "${username}":"${username}" "${targetdir}"
	chmod -R 770 "${targetdir}"
	chmod -R g+s "${targetdir}"
	echo "[OK] Ownership & permissions set!"
	echo ""
	echo "Adding ${username} group to ${apacheprocess}..."
	sleep 2
	usermod -a -G "${username}" "${apacheprocess}"
	echo "[OK] Added user group to ${apacheprocess}!"
	echo ""
	echo "Restarting apache2 to enable group modifications..."
	sleep 1
	service apache2 restart
	echo "[OK] apache2 restarted!"
}

# Create the Virtual Host config file and enable the site in apache
fn_create_vhosts(){
	echo ""
	echo "################# VirtualHosts Creation ################"
	echo ""
	sleep 2
	if [ -f "${apache_sites}/${domain}.conf" ]; then
		vhostexists="1"
		echo "VirtualHost already exists!"
		echo "It won't be touched."
	else	
		vhostexists="0"
		echo "Generating Virtual Host..."
		touch "${apache_sites}/${domain}.conf"
		sleep 1
	echo "<VirtualHost *:80>
	# Addresses
	ServerName ${domain}
	ServerAlias www.${domain}
	ServerAdmin admin@${domain}

	# Directory and rules
	DocumentRoot ${targetdir}
	<Directory ${targetdir}>
		Options Indexes FollowSymLinks MultiViews
		AllowOverride All
		Require all granted
	</Directory>

	# Logging
	# LogLevel settings : debug, info, notice, warn, error, crit, alert
	LogLevel warn
	ErrorLog \${APACHE_LOG_DIR}/${domain}-error.log
	CustomLog \${APACHE_LOG_DIR}/${domain}-access.log combined
</VirtualHost>" >> "${apache_sites}"/"${domain}".conf
		echo "[OK] Virtual Host generated!"
	fi
}

# Enable the website and restart apache
fn_ensite(){
	if [ "${vhostexists}" == "0" ]; then
		echo ""
		echo "################### Enabling Website ###################"
		echo ""
		sleep 2
		echo "Enabling config for ${domain}..."
		sleep 1
		a2ensite "${domain}".conf
		echo "[OK] Config enabled"
		echo ""
		echo "Reloading apache2 to apply config..."
		sleep 1
		# Reloading apache to activate the new website
		service apache2 reload
		echo "[OK] apache2 reloaded"
		sleep 1
	fi
}

fn_conclusion(){
	echo ""
	echo ""
	echo "########################################################"
	echo "###################### Job Done  #######################"
	echo "########################################################"
	sleep 1
	echo ""
	echo "Info! Time to add your website into ${targetdir}"
	echo "Info! Time to make ${domain} point to this machine"
	echo ""
	echo ""
	echo "###################### Credits  ########################"
	echo ""
	echo " -Initial script: BassSpleen"
	echo " -Code overhaul: UltimateByte (terageek.org & gameservermanagers.com)"
	echo "[OK] We wish you the best!"
}

# Starting functions
fn_check_root
fn_check_vars
fn_check_user_exists
fn_welcome_prompt
fn_add_user
fn_fix_umask
fn_web_directory
fn_create_vhosts
fn_ensite
fn_conclusion
