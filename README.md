# apache2-deployer
Easier website deployment with user based folders for Apache 2

# Functionalities
* Creates a user with its home folder in any desired location
* Creates web folder inside user's folder
* Applies proper rules on web folder
* Makes apache2 part of user's group
* Creates the virtualhosts automatically!
* Enables the website
* Reloads when necessary

# Usage

Note: This script needs elevated privileges (root or sudo)  
Should work with most Debian based distros with Apache2 installed


#### Get the script
````bash
wget https://raw.githubusercontent.com/UltimateByte/apache2-deployer/master/apache2-deployer.sh
````
#### Edit settings part if needed
````bash
nano apache2-deployer.sh
````
#### Make it executable
````bash
chmod +x apache2-deployer.sh
````
#### Run it with proper arguments (don't worry about the "www", the script will add it into the virtualhosts)
````bash
./apache2-deployer.sh username domain.com
````
#### Enjoy!




### Demo

````
root@terageek:~# ./apache2-deployer.sh terageek www.terageek.org
Checking config...

[OK] Config test passed!

########################################################
########## Apache 2 website deployment script ##########
########################################################

Welcome!

Please, take a moment to review your settings:

User: terageek will be created
Web directory: /websites/terageek/public_html will be created
Permissions will be fixed in /websites/terageek/public_html
Umask will be set to umask 007 for terageek if possible
Vhost: /etc/apache2/sites-available/terageek.org.conf will be created and enabled

Continue? [Y/n]y
Let's go!

#################### User Creation #####################

Creating terageek...
[OK] User created!

[PASSWORD] Please, input a password for terageek
Enter new UNIX password:
Retype new UNIX password:
passwd: password updated successfully
[OK] Password set!

##################### Fixing Umask ####################

Fixing user umask (default permissions on files)
[OK] Umask umask 007 set!

################## Directory Creation ##################

Creating the web directory...
mkdir: created directory ‘/websites/terageek/public_html’
[OK] Directory created!

Applying correct ownership & permissions to the website folder...
[OK] Ownership & permissions set!

Adding terageek group to www-data...
[OK] Added user group to www-data!

Restarting apache2 to enable group modifications...
[OK] apache2 restarted!

################# VirtualHosts Creation ################

Generating Virtual Host...
[OK] Virtual Host generated!

################### Enabling Website ###################

Enabling config for terageek.org...
Enabling site terageek.org.
To activate the new configuration, you need to run:
  service apache2 reload
[OK] Config enabled

Reloading apache2 to apply config...
[OK] apache2 reloaded


########################################################
###################### Job Done  #######################
########################################################

Info! Time to add your website into /websites/terageek/public_html
Info! Time to make terageek.org point to this machine

###################### Credits  ########################
UltimateByte: Main development
BassSpleen: Idea and initial script
[OK] We wish you the best!
````

### Demo on an existing user

````
root@terageek:~# ./apache2-deployer.sh terageek www.terageek.org
Checking config...

[OK] Config test passed!

########################################################
########## Apache 2 website deployment script ##########
########################################################

Welcome!

Please, take a moment to review your settings:

User: terageek exists and will not be created
Web directory: /websites/terageek/public_html will be created if it doesn't exist
Permissions will be fixed in /websites/terageek/public_html
Umask will be set to umask 007 for terageek if possible

Continue? [Y/n]y
Let's go!

##################### Fixing Umask ####################

Info! It appears that umask 007 is already set for terageek

################## Directory Creation ##################

Creating the web directory...
Info! /websites/terageek/public_html already exists

Applying correct ownership & permissions to the website folder...
[OK] Ownership & permissions set!

Adding terageek group to www-data...
[OK] Added user group to www-data!

Restarting apache2 to enable group modifications...
[OK] apache2 restarted!

################# VirtualHosts Creation ################

VirtualHost already exists!
It won't be touched.


########################################################
###################### Job Done  #######################
########################################################

Info! Time to add your website into /websites/terageek/public_html
Info! Time to make terageek.org point to this machine

###################### Credits  ########################
UltimateByte: Main development
BassSpleen: Idea and initial script
[OK] We wish you the best!
````
