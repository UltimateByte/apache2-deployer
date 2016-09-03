#!/bin/bash
# Author: BassSpleen
# Contributor: UltimateByte
# Addsite script
 
# Variables
apache_home_dir=public_html
apache_sites=/etc/apache2/sites-available
 
# Checking if a username and a domain was given, if not displaying the correct usage and stop the script.
if [ -z "$1" ] && [ -z "$2" ]; then
    echo "Please specify a username and a domain for the website"
    echo "Example : ./scriptname username domain.com"
else
# Adding a new user, prompting for the password then create the website folder in the user's home
   useradd -m "$1"
   passwd "$1"
   cd /home/"$1"
   mkdir "$apache_home_dir"
# Applying ownership/permissions to the website folder.
   chown -R "$1":"$1" "$apache_home_dir"
   chmod -R 770 "$apache_home_dir"
   chmod -R g+s "$apache_home_dir"
   setfacl -d -R -m u::rwx "$apache_home_dir"
   setfacl -d -R -m g::rwx "$apache_home_dir"
   usermod -a -G "$1" www-data
# Create the Virtual Host config file and enable the site in apache
   cd "$apache_sites"
   touch "$2".conf
   echo "<VirtualHost *:80>" >> "$2".conf
   echo "  # Addresses" >> "$2".conf
   echo "  ServerName $2" >> "$2".conf
   echo "  ServerAlias www.$2" >> "$2".conf
   echo "  ServerAdmin admin@localhost" >> "$2".conf
   echo "" >> "$2".conf
   echo "  # Directory and rules" >> "$2".conf
   echo "  DocumentRoot /home/$1/$apache_home_dir" >> "$2".conf
   echo "  <Directory /home/$1/$apache_home_dir>" >> "$2".conf
   echo "    Options Indexes FollowSymLinks MultiViews" >> "$2".conf
   echo "    AllowOverride All" >> "$2".conf
   echo "    Require all granted" >> "$2".conf
   echo "  </Directory>" >> "$2".conf
   echo "" >> "$2".conf
   echo "  # Logging" >> "$2".conf
   echo "  # LogLevel settings : debug, info, notice, warn, error, crit, alert" >> "$2".conf
   echo "  LogLevel warn" >> "$2".conf
   echo "  ErrorLog \${APACHE_LOG_DIR}/$2-error.log" >> "$2".conf
   echo "  CustomLog \${APACHE_LOG_DIR}/$2-access.log combined" >> "$2".conf
   echo "</VirtualHost>" >> "$2".conf
   a2ensite "$2".conf
# Reloading apache to activate the new website
   service apache2 reload
fi
