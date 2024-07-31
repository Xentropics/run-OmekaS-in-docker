#!/bin/sh
# 2022 by Jeroen Seeverens, Xentropics (CC BY)

# exit on error so container will terminate
set -e

echo "bootstrap.sh : reading db-settings"
DB_USER=$(jq -r '.database.user' /opt/imageboot/profile.json)
DB_PASS=$(jq -r '.database.password' /opt/imageboot/profile.json)
DB_HOST=$(jq -r '.database.host' /opt/imageboot/profile.json)
DB_PORT=$(jq -r '.database.port' /opt/imageboot/profile.json)
DB_NAME=$(jq -r '.database.dbname' /opt/imageboot/profile.json)

# try max 10 times to connect to mysql, wait 10 sec between attempts, will 
echo "bootstrap.sh : waiting for database to come up"
TRY=0
until [ $TRY -eq 10 ] || mysql -u $DB_USER -p$DB_PASS -h $DB_HOST -P $DB_PORT $DB_NAME -N -e "SELECT 42 AS \`The answer to the ultimate question of life, the universe and everything\`;"; 
do
    echo "bootstrap.sh : attempt ${TRY}"
    sleep 10
    TRY=$((TRY+1)) 
done
# will fail if server not up by now
mysql -u $DB_USER -p$DB_PASS -h $DB_HOST -P $DB_PORT $DB_NAME -N -e "SELECT NULL AS \`The ultimate question of life, the universe and everything\`;"; 
echo "bootstrap.sh : database up!"

echo "bootstrap.sh : writing db-settings to Omeka database.ini"
# write Omeka database settings to config file 
echo "user = $DB_USER" > /var/www/html/config/database.ini
echo "password = $DB_PASS" >> /var/www/html/config/database.ini
echo "host = $DB_HOST" >> /var/www/html/config/database.ini
echo "port = $DB_PORT" >> /var/www/html/config/database.ini 
echo "dbname = $DB_NAME" >> /var/www/html/config/database.ini

echo "bootstrap.sh : setting permissions for www-data"
# just to be sure, someone might have altered the volume
# chown -R www-data:www-data /var/www/html/
# chmod -R 755 /var/www/html/files
# nvm, we're running as root, so we can do this, should change this to www-data in the future

echo "bootstrap.sh : kind of checking if we already have an initialized database schema"
# post install form if user table doesn't exist (that's what we ASUME when there's an error)
if ! mysql -u $DB_USER -p$DB_PASS -h $DB_HOST -P $DB_PORT $DB_NAME -N -e "SELECT role FROM user LIMIT 1;"; then
    echo "bootstrap.sh : nope, starting apache"
    service apache2 start
        echo "bootstrap.sh : posting data to install form"
        FORM_DATA=$(jq -r '[.install_form | keys_unsorted[] as $k | ($k|@uri)+"="+(.[$k]|@uri)] | join("&")' /opt/imageboot/profile.json)
        curl -X POST http://127.0.0.1:8888/install \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -d "${FORM_DATA}"

    # install berkely db and noid. Script will check if this has been requested itself
    echo "bootstrap.sh : running install-ark-deps.sh"
    source /opt/imageboot/install-ark-deps.sh
    
    # install modules if requested
    if [[ "$skip_modules" == "no" ]]
    then
        echo "bootstrap.sh : running install-modules.sh"
        source /opt/imageboot/install-modules.sh
    fi
    echo "bootstrap.sh : done, I hope, so stopping apache"
    service apache2 stop
else
    # update modules if requested
    if [[ "$skip_modules" == "no" ]]
    then
        echo "bootstrap.sh : yep, so starting apache to install modules"
        service apache2 start
        echo "bootstrap.sh : running install-modules.sh"
        source /opt/imageboot/install-modules.sh
        echo "bootstrap.sh : running install-ark-deps.sh"
        source /opt/imageboot/install-ark-deps.sh
        echo "bootstrap.sh : done, I hope, so stopping apache"
        service apache2 stop
    fi  
fi

