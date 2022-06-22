# Run Omeka-S on Docker

Spin up an Omeka-S instance in no-time, including selected plugins.

Version 0.2.0. Work in progress... use at your own risk, not recommended for production use. Doesn't follow any standards or best practices at the moment, just a proof of concept that might grow up one day.

Created by Jeroen Seeverens @xentropics
Inspired by [https://github.com/klokantech/omeka-s-docker]

## What am I looking at?

A bunch of scripts and config files that

- install and run (fingers crossed) Omeka S in a docker container,
- use MariaDB as a backend (+phpAdmin),
- initialize Omeka during the first run,
- install modules during the first run,
- optionally purge all images, but keep the data, etc.

## How to use this?

1. Copy xentropics:omeka-s-docker/files/etc/profile_template.json to xentropics:omeka-s-docker/files/etc/default_profile.json
2. Edit xentropics:omeka-s-docker/files/etc/default_profile.json to match your preferences (or set some passwords at least)
3. Edit docker-compose.yml to match the credentials you made up in xentropics:omeka-s-docker/files/etc/default_profile.json
4. Optional: edit the arguments at the top of the Dockerfile
5. Run build_run.sh and sit back and relax (first install Docker btw...)

## What are these files for?

Not exactly up to documentation standards, but will have to do for now.

### In xentropics:omeka-s-docker/files/etc

- apache-config.conf : apache config, no SSL right now, but we could add that later, not intended for production use

- imagemagick-policy.xml : not sure why we need this, but apparantly we do

- php.ini : php-settings mainly because it allows big files to be uploaded

- profile_template.json : user settings template. In the future should be possible to define multiple profiles for your very own Omeka-S farm

### In xentropics:omeka-s-docker/files/scripts

- bootstrap.sh : will run when the container is booted the first time. Installs and initialized everything. Skips database init if there is already an initialized schema, so you can bring your own data to a fresh instance with different settings (might break of course if the settings deviate to much)

- entrypoint.sh : entrypoint referenced in Dockerfile. Checks if this is the first run. If so, runs bootstrap.sh. If not, starts apache in the foreground right away

- install-modules.sh : invoked from bootstrap.sh, installs modules: work in progess, no post-install config possible so far

### In xentropics:omeka-s-docker

- docker-compose.yml : defines an ensemble of containers running Omeka, MariaDB and phpadmin as well as network connections and volumes for persistence

- Dockerfile : defines the omeka-s-image, based on the official php+apache image

- build_run.sh : builds the omeka image, removes the old dangling containers and runs the compose file

- reset_all.sh : shutdown and delete everything

- reset_keep_data_and_images.sh : shutdown and keep the data and the images (no rebuild needed)

- reset_keep_data.sh : shutdown and keep the data (you need to rebuild the image after this)
