#!/bin/sh
# 2022-2044 by Jeroen Seeverens, Xentropics (CC BY)

# exit on error so container will terminate
set -e

# try max 10 times to connect to mysql, wait 10 sec between attempts
echo "bootstrap.sh : waiting for database to come up"
TRY=0
until [ $TRY -eq 10 ] || mysql -u $DB_USER -p$DB_PASS -h $DB_HOST -P $DB_PORT $DB_NAME -N -e "SELECT 42 AS \`The answer to the ultimate question of life, the universe and everything\`;"; do
    echo "bootstrap.sh : attempt ${TRY}"
    sleep 10
    TRY=$((TRY + 1))
done
# will fail if server not up by now
mysql -u $DB_USER -p$DB_PASS -h $DB_HOST -P $DB_PORT $DB_NAME -N -e "SELECT NULL AS \`The ultimate question of life, the universe and everything\`;"
echo "bootstrap.sh : database up!"

# write Omeka database settings to config file
echo "bootstrap.sh : writing db-settings to Omeka database.ini"
echo "user = $DB_USER" >/var/www/html/config/database.ini
echo "password = $DB_PASS" >>/var/www/html/config/database.ini
echo "host = $DB_HOST" >>/var/www/html/config/database.ini
echo "port = $DB_PORT" >>/var/www/html/config/database.ini
echo "dbname = $DB_NAME" >>/var/www/html/config/database.ini

echo "bootstrap.sh : starting apache"
service apache2 start

# Check if we need to fill in the post install form
echo "bootstrap.sh : heurtistically checking if we already have an initialized database schema"
# post install form if user table doesn't exist (that's what we ASUME when there's an error)
# @TODO: deal with possible schema migrations
if ! mysql -u $DB_USER -p$DB_PASS -h $DB_HOST -P $DB_PORT $DB_NAME -N -e "SELECT role FROM user LIMIT 1;"; then
    echo "bootstrap.sh : database schema not initialized, so posting data to install form"
    echo "bootstrap.sh : posting data to install form"
    #FORM_DATA=$(jq -r '[.install_form | keys_unsorted[] as $k | ($k|@uri)+"="+(.[$k]|@uri)] | join("&")' /opt/imageboot/profile.json)
    JSON_DATA=$(jq --arg pwd "$OMEKA_GLOBAL_ADMIN_PWD" '.install_form |= with_entries(if .value == "<OMEKA_PASS>" then .value = $pwd else . end)' /opt/imageboot/profile.json)
    FORM_DATA=$(echo "$JSON_DATA" | jq -r '[.install_form | keys_unsorted[] as $k | ($k|@uri)+"="+(.[$k]|@uri)] | join("&")')
    echo "JSON_DATA: $JSON_DATA"
    echo "FORM_DATA: $FORM_DATA"
    curl -X POST http://127.0.0.1:8888/install \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -d "${FORM_DATA}"
fi

# install modules if requested
if [[ "$skip_modules" == "no" ]]; then
    echo "bootstrap.sh : running install-modules.sh"
    source /opt/imageboot/install-modules.sh
    echo "bootstrap.sh : running install-ark-deps.sh"
    source /opt/imageboot/install-ark-deps.sh

fi

# stop apache and return to entrypoint.sh
echo "bootstrap.sh : done, so stopping apache"
service apache2 stop
