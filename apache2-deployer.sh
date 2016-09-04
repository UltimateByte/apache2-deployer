#!/bin/bash
# Authors: UltimateByte, BassSpleen
# Description: Creates required files and folders to deploy an apache2 website in one command
 
# Settings Variables
homedir="/home"
webdir="public_html"

###########
# Program #
###########

# Misc Variables
selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"
apache_sites="/etc/apache2/sites-available"

# Check that the script is launched with elevated privileges
fn_check_root(){
	if [ "$(id -u)" != "0" ]; then
		echo "This script must be run with elevated privileges"
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
		echo "Could not find ${homedir}"
		echo "Please, set a valid homedir value"
		sleep 2
	fi
 
	# Checking that the variable directory has been set
	if [ -n "${webdir}" ]; then
		check_webdir=0
	else
		check_webdir=1
		echo "No webdir set"
		echo "Please, set a valid webdir"
	sleep 2
	fi
 
	# Checking that Apache2 websites-available folder exists
	if [ -d "${apache_sites}" ]; then
		check_apachedir=0
	else
		check_apachedir=1
		echo "${apache_sites} folder not found"
		echo "Please, install Apache2"
		sleep 2
	fi
 
	# Check summ up
	if [ "${check_homedir}" == "1" ] || [ "${check_webdir}" == "1" ] || [ "${check_apachedir}" == "1" ]; then
		echo "Exiting"
		sleep 2
		exit 1
	else
		echo "Config OK!"
		# Setting directories
		userdir="${homedir}/${username}"
		targetdir="${userdir}/${webdir}"
		sleep 1
	fi
}

# Adding a user with the correct homedir
fn_add_user(){
	echo "Creating ${username}..."
	sleep 1
	useradd -m -d "${userdir}" "${username}"
	echo "Please, input a password for ${username}"
	sleep 1
	passwd "${username}"
	echo "Password set!"
	sleep 1
}

# Creating the web directory and applying permissions
fn_web_directory(){
	echo "Creating the web directory"
	sleep 1
	mkdir -pv "${targetdir}"
	echo "Applying correct ownership/permissions to the website folder..."
	sleep 1
	chown -R "${username}":"${username}" "${targetdir}"
	chmod -R 770 "${targetdir}"
	chmod -R g+s "${targetdir}"
	echo "Adding ${username} group to www-data"
	sleep 1
	usermod -a -G "${username}" www-data
}

# Create the Virtual Host config file and enable the site in apache

fn_create_vhosts(){
	touch "${apache_sites}"/"${domain}".conf
	
	echo "<VirtualHost *:80>
	# Addresses
	ServerName ${domain}
	ServerAlias www.${domain}
	ServerAdmin admin@localhost

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
</VirtualHost>"
}

fn_ensite(){
	echo "Enableing website ${domain}"
	sleep 1
	a2ensite "${domain}".conf
	echo "Restarting Apache2"
	sleep 1
	# Reloading apache to activate the new website
	service apache2 reload
}

fn_conclusion(){
	echo ""
	echo "Job done!"
	sleep 1
	echo "Time to add your website into ${targetdir}"
	echo "Time to make ${domain} point to this machine"
	sleep 1
	echo ""
	echo "Credits:"
	echo " -Idea and base: BassSpleen"
	echo " -Code rework: UltimateByte (terageek.org & gameservermanagers.com)"
	echo""
	sleep 1
	echo "We wish you the best!"
}

# Starting functions

fn_check_root

# Check that the user inputted two arguments
if [ -z "$1" ] || [ -z "$2" ]; then
	echo "Please specify a username and a domain for the website"
	echo "Example : ./${selfname} username domain.com"
	exit 1
elif [ -n "$3" ]; then
	echo "Too many arguments!"
	echo "Please specify a username and a domain for the website"
	echo "Example : ./${selfname} username domain.com"
	exit 1
else
	# Use a variable name that makes sense
	username="${1}"
	# Strip www. from user input since we're adding it as an alias
	domain="${2#www.}"
fi

fn_check_vars
fn_add_user
fn_web_directory
fn_create_vhosts
fn_ensite
fn_conclusion
