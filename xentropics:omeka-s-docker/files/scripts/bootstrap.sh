#!/bin/sh
# 2022 by Jeroen Seeverens, Xentropics (CC BY)

# exit on error so docker image will terminate
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
# will fail if server not uo by now
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
chown -R www-data:www-data /var/www/html/config/database.ini

echo "bootstrap.sh : kind of checking if we already have an initialized database schema"
# post install form if user table doesn't exist (that's what we ASUME when there's an error)
if ! mysql -u $DB_USER -p$DB_PASS -h $DB_HOST -P $DB_PORT $DB_NAME -N -e "SELECT role FROM user LIMIT 1;"; then
    echo "bootstrap.sh : nope, starting apache"
    service apache2 start
        echo "bootstrap.sh : posting to install form"
        FORM_DATA=$(jq -r '[.install_form | keys_unsorted[] as $k | ($k|@uri)+"="+(.[$k]|@uri)] | join("&")' /opt/imageboot/profile.json)
        curl -X POST http://localhost/install \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -d "${FORM_DATA}"
    echo "bootstrap.sh : done, I hope, so stopping apache"
    service apache2 stop
fi

# remove sensitive config from env (of course still in config files) 
DB_USER=
DB_PASS=
DB_HOST=
DB_PORT=
DB_NAME=
