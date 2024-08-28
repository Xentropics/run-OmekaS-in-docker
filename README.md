# Run Omeka-S on Docker

This repository contains scripts and configuration files to quickly set up an Omeka-S instance on Docker. Omeka-S is a popular open-source web publishing platform for sharing digital collections and creating media-rich online exhibits. Running Omeka-S on Docker allows for easy setup, scalability, and distribution.

**Version:** 0.6.8

**Disclaimer:** Use at your own risk.

**Creator:** [Jeroen Seeverens](https://github.com/xentropics)

**Inspiration:** [https://github.com/klokantech/omeka-s-docker]

## Contents of this Repository

This repository contains scripts and configuration files that:

- build a docker image for Omeka S
- use Mysql 8 as a backend, and PHP 8.2 
- optionally add Apache Solr in the mix
- install ARK depedencies if needed
- initialize Omeka during the first run, setting up basic configurations and install selected modules.
- add custom PHP scripts to the container

More detailed instructions on how to use these scripts and configuration files will be provided below.

## How to use this?

### Prerequisites

- You need a working Docker installation on your system. If you don't have Docker installed, you can download it from [https://www.docker.com/get-started]. However, securely installing and configuring Docker for production is beyond the scope of this document. NOTE: the image has been tested on K8s as well, but as of of now this repo does not contain the K8s deployment files.

- The image has been built assuming that the container will be accessed via a reverse proxy (e.g. Nginx or Apache). The container exposes port 8888 (i.e. a non-root compatible port), but it is recommended to use a reverse proxy to handle SSL termination and other security features, as well as ARK resolving functionality.

- The compose project runs smoothly on a 4GB/1 core VPS, but if you plan to add Solr or run a large collection, you might want to consider a larger VPS (e.g. 6-8 GB RAM and 2-4 cores). Scaling out is also an option, but not covered in this document.

### Step 1: Clone this repository

Clone this repository to your server.

### Step 2: Build the Docker image

- Navigate to the directory where you cloned this repository.
- Optionally edit any files in the `profiles/template/etc`  directory to customize the image. However, most of these files will be overlayed with bind mounts in the docker-compose file during runtime. It is possible, though, to run the image without using bind mounts, in that case you should make sure to adjust the files in the `profiles/template/etc`  directory to that scenario.
- Also, edit the ARGs in the Dockerfile to set the desired versions of the OS (Debian), PHP and Omeka if needed. Only the default values have been tested.

- Now run the following command to build the Docker image:

``` bash
bin/build.sh
```

### Step 3: Create a profile

- Copy the `profiles/template`  directory to a new directory, e.g. `profiles/myprofile` . Optionally, you can create a profile directory elsewhere on your system, but make sure to adjust the `profiles_dir`  variable in the `includes/defaults.sh`  file accordingly. Before every run or build the contents of that directory will be copied to `profiles` .

- Adjust your newly created profile to your liking. Things you should or probably want to look into:

* Add or remove anything you need or don't need from `docker-compose.yml`  in your profile dir. In the template profile this file contains everything needed to run Solr. So, if you don't need that, remove everything from the copy in your profile. This file should exist, but may be empty. It's content will be merged with that of the root level docker-compose.yml.

* Edit `.env` in your profile dir to set the environment variables to the desired values. The template file contains the defaults, but you have to fill in passwords (use single quotes to prevent variable expansion). If you run more than one instance make sure every instance gets it's own port. `OMEKA_INSTALL_ARKDEPS`  should be set to `yes`  if you use Daniel Berthereau's `Omeka-S-module-Ark` . 

* Edit `profile.json`. First, fill in all the install-form fields. `<OMEKA_PASS>` is a placeholder that will be replaced by the value of the `OMEKA_GLOBAL_ADMIN_PWD` variable, which is set in `.env`. So, no need to put secrets inside `profile.json`. Als provide DB-settings (except the password) and a list of modules you want to be installed. See the template profile for an example. 

### Step 4: Run!

To run a container use the following command:

```bash
bin/run.sh -c [profile] -m
```

Substitute [profile] with the name of your profile, which is the name of the folder you created in step 3. No paths, just the name.

This will:

- submit the post install form on first boot
- install the selected modules from `profile.json`, if the `-m` flag is set. You can update modules by changing `profiles.json` deleting the container and recreating it.
-  start everything needed to run your instance

Beware: if you upgrade Omeka, a database upgrade may be needed (for example when you upgrade from 4.0 to 4.1). Omeka will go into maintenance mode. Manual confirmation is needed before you (or the script trying to install modules) can proceed, as the login form will not be shown.



