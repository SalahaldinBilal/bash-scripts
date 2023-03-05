#!/bin/bash
NORMAL=$(tput sgr0)
LIME_YELLOW=$(tput setaf 190)
LOG_FILE=./install_$(date +'%m_%d_%Y').log

exec > >(tee -a $LOG_FILE)

if [[ $(id -u) > 0 ]]; then
    echo "Please run script with root privliges (root user or 'sudo')"
    exit 0
fi

get_apache_version () {
    OLD_IFS=$IFS
    IFS=$'\n'
    TEMP_OUTPUT=($(apache2 -v | awk -F': |\\(|/' '{for(i=1;i<=NF;i++){print $i}}'))
    IFS=$OLD_IFS
    echo ${TEMP_OUTPUT[2]}
}

get_apache_main_version () {
    TEMP_OUTPUT=($(get_apache_version | awk -F'.' '{for(i=1;i<=NF;i++){print $i}}'))
    echo ${TEMP_OUTPUT[0]}
}

if [[ $(which apache2) && $(get_apache_main_version) -eq 2 ]]; then
    echo "Apache is already installed, version: ${LIME_YELLOW}$(get_apache_version)${NORMAL}"
else
    echo "Installing apache 2"
    apt-get install -y apache2
fi

echo "Removing old app"
rm -rf ./SimpleApacheApp
rm -rf /var/www/SimpleApp

echo "Cloning Repostiory"
git clone https://github.com/mkassaf/SimpleApacheApp
echo "Cloned Repsotiory"

echo "Moving app"
mv ./SimpleApacheApp/App /var/www/SimpleApp
echo "Moving config"
mv ./SimpleApacheApp/simpleApp.conf /etc/apache2/sites-available/simpleApp.conf

echo "Disabling default config"
a2dissite 000-default.conf
echo "Enabling app config"
a2ensite simpleApp
echo "Reloading apache"
systemctl reload apache2

SITE_CONTENT=$(curl http://localhost)

if [[ $SITE_CONTENT == *"GreenHost - Web Hosting HTML Template"* ]]; then
    echo "Changes done sucessfully"
else
    echo "Some error happened, site didn't change"
fi