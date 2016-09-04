# apache2-deployer
Easier website deployment with user based folders for Apache 2

# Usage

As root : 

````bash
wget https://raw.githubusercontent.com/UltimateByte/apache2-deployer/master/apache2-deployer.sh
chmod +x apache2-deployer.sh
./apache2-deployer.sh username domain.com
````

Enjoy



### Demo

````bash
root@terageek:~# ./apache2-deployer.sh terageek www.terageek.org
Checking config...

[OK] Config test passed!

########################################################
########## Apache 2 website deployment script ##########
########################################################

Welcome!

Here are your settings:
Domain: terageek.org
Username: terageek
Target directory: /websites/terageek/public_html

Continue? [Y/n]y
Let's go!

#################### User Creation ####################

Creating terageek...
[OK] User created!

[PASSWORD] Please, input a password for terageek
Enter new UNIX password:
Retype new UNIX password:
passwd: password updated successfully
[OK] Password set!

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

################# VirtualHosts Creation #################

Generating config file...
[OK] Config file generated!

################## Enabling Website ##################

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

Time to add your website into /websites/terageek/public_html
Time to make terageek.org point to this machine

###################### Credits  ########################
 -Idea and base: BassSpleen
 -Code overhaul: UltimateByte (terageek.org & gameservermanagers.com)
[OK] We wish you the best!
````
