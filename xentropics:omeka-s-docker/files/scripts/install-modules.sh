#!/bin/bash
MODULE_COUNT=$(jq -r '.modules | length' /opt/imageboot/profile.json)
echo "install-modules.sh : installing $MODULE_COUNT modules."

echo "install-modules.sh : logging in"
echo "$USER"
ls -la /var/www/html
OMEKA_MAIL=$(jq -r '.install_form."user[email]"' /opt/imageboot/profile.json)
OMEKA_PASS=$(jq -r '.install_form."user[password-confirm][password]"' /opt/imageboot/profile.json)
CSRF_TOKEN=$(curl -s -c "cookie.jar" -L http://localhost:80/login | tidy -quiet -asxml | xmlstarlet sel -t -v '//_:input[@name="loginform_csrf"]/@value')
OK=$(curl -i -L -s -c "cookie.jar" -b "cookie.jar" -H "X_CSRF-Token:${CSRF_TOKEN}" -X POST -F "loginform_csrf=${CSRF_TOKEN}" -F "email=${OMEKA_MAIL}" -F "password=${OMEKA_PASS}" http://localhost:80/login | grep "^Location: /admin")

echo $OK
if [[ "$OK" == "Location: /admin"* ]]
then
    echo "install-modules.sh : success!"    
else
    echo "install-modules.sh : login error"
    exit 1
fi

for (( i=0; i<$MODULE_COUNT; i++ ))
    do

        echo "install-modules.sh : reading module information"
        MODULE_NAME=$(eval "jq -r '.modules[${i}]'.name /opt/imageboot/profile.json")
        MODULE_VERSION=$(eval "jq -r '.modules[${i}]'.version /opt/imageboot/profile.json")
        MODULE_URL_TEMPLATE=$(eval "jq -r '.modules[${i}]'.zipUrl /opt/imageboot/profile.json")
        MODULE_URL=${MODULE_URL_TEMPLATE//'${version}'/"$MODULE_VERSION"}
        MODULE_ENABLE=$(eval "jq -r '.modules[${i}]'.install /opt/imageboot/profile.json")

        echo "install-modules.sh : fetching $MODULE_NAME"
        curl -s -L -o /tmp/$MODULE_NAME.zip $MODULE_URL
    
        echo "install-modules.sh : unzipping $MODULE_NAME.zip"
        unzip -d /tmp/ /tmp/$MODULE_NAME.zip && mv /tmp/$MODULE_NAME /var/www/html/modules/$MODULE_NAME && rm -rf /tmp/$MODULE_NAME*

        MODULE_PAGE=$(curl -s -b "cookie.jar" -c "cookie.jar" -L http://localhost:80/admin/module | tidy -quiet -asxml) 
        CSRF_TOKEN=$(echo $MODULE_PAGE | xmlstarlet sel -t -v "//_:form[contains(@action,'install?id=$MODULE_NAME')]/_:input[@name='csrf']/@value")
        ACTION=$(echo $MODULE_PAGE | xmlstarlet sel -t -v "//_:form[contains(@action,'install?id=$MODULE_NAME')]/@action")
        echo $CSRF_TOKEN
        echo $ACTION
        curl -L -s -b "cookie.jar" -c "cookie.jar" -X POST -H "X_CSRF-Token:${CSRF_TOKEN}" -F "csrf=${CSRF_TOKEN}" -F "id=" http://localhost:80${ACTION} | tidy -quiet -asxml | xmlstarlet sel -t -v "//_:ul[@class='messages']"
        
    done
