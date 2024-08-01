#!/bin/bash
MODULE_COUNT=$(jq -r '.modules | length' /opt/imageboot/profile.json)
echo "install-modules.sh : installing $MODULE_COUNT modules."

echo "install-modules.sh : logging in"
echo "$USER"
ls -la /var/www/html
OMEKA_MAIL=$(jq -r '.install_form."user[email]"' /opt/imageboot/profile.json)
OMEKA_PASS=${OMEKA_GLOBAL_ADMIN_PWD}
set +e
CSRF_TOKEN=$(curl -s -c "cookie.jar" -L http://127.0.0.1:8888/login | tidy -quiet -asxml | xmlstarlet sel -t -v '//_:input[@name="loginform_csrf"]/@value')
echo "Token: $CSRF_TOKEN"
OK=$(curl -i -L -s -c "cookie.jar" -b "cookie.jar" -H "X_CSRF-Token:${CSRF_TOKEN}" -X POST -F "loginform_csrf=${CSRF_TOKEN}" -F "email=${OMEKA_MAIL}" -F "password=${OMEKA_PASS}" http://127.0.0.1:8888/login | grep "^Location: /admin")

echo $OK
if [[ "$OK" == "Location: /admin"* ]]
then
    echo "install-modules.sh : success!"    
else
    echo "install-modules.sh : login error"
    sleep 60
    exit 1
fi

rm -rf /tmp/omeka
for (( i=0; i<$MODULE_COUNT; i++ ))
    do     
        echo "install-modules.sh : reading module information"
        MODULE_INSTALL=$(eval "jq -r '.modules[${i}]'.install /opt/imageboot/profile.json")

        if $MODULE_INSTALL
        then
                MODULE_VERSION=$(eval "jq -r '.modules[${i}]'.version /opt/imageboot/profile.json")
                MODULE_NAME_TEMPLATE=$(eval "jq -r '.modules[${i}]'.name /opt/imageboot/profile.json")
                MODULE_NAME=${MODULE_NAME_TEMPLATE//'${version}'/"$MODULE_VERSION"}
                MODULE_URL_TEMPLATE=$(eval "jq -r '.modules[${i}]'.zipUrl /opt/imageboot/profile.json")
                MODULE_URL=${MODULE_URL_TEMPLATE//'${version}'/"$MODULE_VERSION"}
                MODULE_ENABLE=$(eval "jq -r '.modules[${i}]'.install /opt/imageboot/profile.json")

                echo "install-modules.sh : fetching $MODULE_NAME"
                curl -s -L -o /tmp/$MODULE_NAME.zip $MODULE_URL
    
                echo "install-modules.sh : unzipping $MODULE_NAME.zip"
                echo "install-modules.sh : removing old module"
                rm -rf /var/www/html/modules/$MODULE_NAME
                echo "install-modules.sh : installing $MODULE_NAME"
                unzip -d /tmp/omeka/ /tmp/$MODULE_NAME.zip && mv /tmp/omeka/**/ /var/www/html/modules/$MODULE_NAME && rm -rf /tmp/$MODULE_NAME* && rm -rf /tmp/omeka
                PREACTIVATECOUNT=$(eval "jq -r '.modules[${i}].preActivate | length' /opt/imageboot/profile.json")
                for (( j=0; j<$PREACTIVATECOUNT; j++ ))
                do
                    echo "install-modules.sh : running pre-activate script #${j+1}"
                    PREACTIVATECMD=$(eval "jq -r '.modules[${i}].preActivate[${j}]' /opt/imageboot/profile.json")
                    eval "$PREACTIVATECMD"
                done
                echo "install-modules.sh : enabling $MODULE_NAME"
                MODULE_PAGE=$(curl -s -b "cookie.jar" -c "cookie.jar" -L http://127.0.0.1:8888/admin/module | tidy -quiet -asxml) 
                CSRF_TOKEN=$(echo $MODULE_PAGE | xmlstarlet sel -t -v "//_:form[contains(@action,'install?id=$MODULE_NAME')]/_:input[@name='csrf']/@value") || true
                UPDATE_TOKEN=$(echo $MODULE_PAGE | xmlstarlet sel -t -v "//_:form[contains(@action,'upgrade?id=$MODULE_NAME')]/_:input[@name='csrf']/@value") || true 
                : ${CSRF_TOKEN:=$UPDATE_TOKEN}
                ACTION=$(echo $MODULE_PAGE | xmlstarlet sel -t -v "//_:form[contains(@action,'install?id=$MODULE_NAME')]/@action") || true
                UPDATE_ACTION=$(echo $MODULE_PAGE | xmlstarlet sel -t -v "//_:form[contains(@action,'upgrade?id=$MODULE_NAME')]/@action") || true
                : ${ACTION:=$UPDATE_ACTION}
                if [ ! -z "$CSRF_TOKEN" ] 
                then
                    echo "install-modules.sh : found token, enabling $MODULE_NAME"
                    curl -L -s -b "cookie.jar" -c "cookie.jar" -X POST -H "X_CSRF-Token:${CSRF_TOKEN}" -F "csrf=${CSRF_TOKEN}" -F "id=" http://127.0.0.1:8888${ACTION} | tidy -quiet -asxml | xmlstarlet sel -t -v "//_:ul[@class='messages']"
                else
                    echo "install-modules.sh : error: no token found, skipping activation of $MODULE_NAME"
                fi
                POSTINSTALLCOUNT=$(eval "jq -r '.modules[${i}].postInstall | length' /opt/imageboot/profile.json")
                for (( j=0; j<$POSTINSTALLCOUNT; j++ ))
                do
                    echo "install-modules.sh : running postInstall script #${j+1}"
                    POSTINSTALLCMD=$(eval "jq -r '.modules[${i}].postInstall[${j}]' /opt/imageboot/profile.json")
                    eval "$POSTINSTALLCMD"
                done
        fi
    done
set -e