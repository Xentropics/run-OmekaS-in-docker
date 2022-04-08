#!/bin/sh
# 2022 by Jeroen Seeverens, Xentropics (CC BY)

# exit on error so docker image will terminate
set -e

DB_USER=$(jq -r '.database.user' /var/www/html/profile.json)
DB_PASS=$(jq -r '.database.password' /var/www/html/profile.json)
DB_HOST=$(jq -r '.database.host' /var/www/html/profile.json)
DB_PORT=$(jq -r '.database.port' /var/www/html/profile.json)
DB_NAME=$(jq -r '.database.dbname' /var/www/html/profile.json)

# try max 10 times to connect to mysql, wait 10 sec between atempts 
TRY=0
until [ $TRY -eq 10 ] || mysql -u $DB_USER -p$DB_PASS -h $DB_HOST -P $DB_PORT $DB_NAME -N -e "SELECT 42 AS THEANSWER;"; 
do
    sleep 10
    TRY=$((TRY+1)) 
done

# write Omeka database settings to config file 
echo "user = $DB_USER" > /var/www/html/config/database.ini
echo "password = $DB_PASS" >> /var/www/html/config/database.ini
echo "host = $DB_HOST" >> /var/www/html/config/database.ini
echo "port = $DB_PORT" >> /var/www/html/config/database.ini
echo "dbname = $DB_NAME" >> /var/www/html/config/database.ini
chown -R www-data:www-data /var/www/html/config/database.ini

# just to be sure, someone might have altered the volume
chown -R www-data:www-data /var/www/html/files

# post install form if user table doesn't exist (that's what we ASUME when there's an error)
if ! mysql -u $DB_USER -p$DB_PASS -h $DB_HOST -P $DB_PORT $DB_NAME -N -e "SELECT role FROM user LIMIT 1;"; then
service apache2 start
FORM_DATA=$(jq -r '[.install_form | keys_unsorted[] as $k | ($k|@uri)+"="+(.[$k]|@uri)] | join("&")' /var/www/html/profile.json)
curl -X POST http://localhost/install \
   -H "Content-Type: application/x-www-form-urlencoded" \
   -d "${FORM_DATA}"
service apache2 stop
fi

# remove sensitive config from env (of course still in config files) 
DB_USER=
DB_PASS=
DB_HOST=
DB_PORT=
DB_NAME=

# run apache in the foreground: crash will be detected by docker host
apache2-foreground