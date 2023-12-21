#!/bin/bash
echo "install-ark-deps.sh : installing ark deps"

if [[ "$install_arkdeps" == "yes" ]]
then
    echo "install-ark-deps.sh : installing ark deps"
else
    echo "install-ark-deps.sh : skipping ark deps"
    exit 0
fi
apt-get update && apt-get install -y $berkeleydb_lib
ln -s /usr/include /opt/include
ln -s /usr/lib/aarch64-linux-gnu/ /opt/lib
docker-php-ext-configure dba --with-db4=/opt
docker-php-ext-install dba
docker-php-ext-install bcmath