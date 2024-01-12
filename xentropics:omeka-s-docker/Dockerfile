ARG php_version=8.2
ARG os_version=bookworm
ARG omeka_version=4.0.4

FROM php:$php_version-apache-$os_version

ENV install_arkdeps=no
ENV berkeleydb_lib=libdb5.3++-dev
ENV skip_modules=yes

LABEL maintainer="Jeroen Seeverens <j.seeverens@xentropics.nl>"
LABEL description="Omeka S base image"
LABEL version=0.5.0

# build deps and utils
RUN apt-get update && \
    apt-get -y install --no-install-recommends \
    git-core \
    unzip \
    mc \
    jq \
    tidy \
    xmlstarlet \
    mariadb-client

# deps
RUN apt-get -y install --no-install-recommends \
    imagemagick
COPY profiles/template/etc/imagemagick-policy.xml /etc/ImageMagick/policy.xml

# php deps and config
RUN docker-php-ext-install -j$(nproc) pdo_mysql mysqli
COPY profiles/template/etc/php.ini /usr/local/etc/php/

# download Omeka
ARG omeka_version
RUN rm -rf /var/www/html/*
ADD https://github.com/omeka/omeka-s/releases/download/v${omeka_version}/omeka-s-${omeka_version}.zip /tmp/omeka-s.zip
RUN unzip -d /tmp/ /tmp/omeka-s.zip && mv /tmp/omeka-s/* /var/www/html/ && rm -rf /tmp/omeka-s*
RUN chmod -R +w /var/www/html/files
VOLUME [ "/var/www/html/files" ]


# apache config
ADD https://raw.githubusercontent.com/omeka/omeka-s/develop/.htaccess.dist /var/www/html/.htaccess
RUN a2enmod rewrite
COPY profiles/template/etc/apache-config.conf /etc/apache2/sites-enabled/000-default.conf
RUN chown -R www-data:www-data /var/www/html/

# server init config
COPY scripts/entrypoint.sh /opt/imageboot/entrypoint.sh
COPY scripts/bootstrap.sh /opt/imageboot/bootstrap.sh
COPY scripts/install-modules.sh /opt/imageboot/install-modules.sh
COPY scripts/install-ark-deps.sh /opt/imageboot/install-ark-deps.sh
RUN chmod 755 /opt/imageboot/*.sh

# run
VOLUME [ "/var/log" ]
EXPOSE 80
ENTRYPOINT [ "/opt/imageboot/entrypoint.sh" ]
