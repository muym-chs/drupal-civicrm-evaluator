# from https://www.drupal.org/docs/8/system-requirements/drupal-8-php-requirements
FROM php:7.4-apache

# install the PHP extensions we need
RUN set -eux; \
	\
	if command -v a2enmod; then \
		a2enmod rewrite; \
	fi; \
	\
	savedAptMark="$(apt-mark showmanual)"; \
	\
	apt-get update; \
	apt-get install -y --no-install-recommends \
		libfreetype6-dev \
		libjpeg-dev \
		libpng-dev \
		libpq-dev \
		libzip-dev \
		wget \
	; \
	\
	docker-php-ext-configure gd \
		--with-freetype \
		--with-jpeg=/usr \
	; \
	\
	docker-php-ext-install -j "$(nproc)" \
		gd \
		opcache \
		pdo_mysql \
		pdo_pgsql \
		zip \
	; \
	\
# reset apt-mark's "manual" list so that "purge --auto-remove" will remove all build dependencies
	apt-mark auto '.*' > /dev/null; \
	apt-mark manual $savedAptMark; \
	ldd "$(php -r 'echo ini_get("extension_dir");')"/*.so \
		| awk '/=>/ { print $3 }' \
		| sort -u \
		| xargs -r dpkg-query -S \
		| cut -d: -f1 \
		| sort -u \
		| xargs -rt apt-mark manual; \
	\
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	rm -rf /var/lib/apt/lists/*

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=60'; \
		echo 'opcache.fast_shutdown=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini

RUN apt-get update \
  && apt-get install -y mariadb-client sudo vim git zip unzip netcat \
  && apt-get purge -y
COPY ./admin/drush.phar /usr/local/bin/drush
COPY ./admin/wait-for-it.sh /usr/local/bin/wait-for-it.sh
COPY ./admin/admin.sh /usr/local/bin/admin.sh
RUN chmod ugo+x /usr/local/bin/drush && chmod ugo+x /usr/local/bin/*.sh 
# provide a non-root user to own drupal code
RUN useradd -u 1978 -g www-data -ms /bin/bash drupal
COPY ./admin/admin.conf /etc/apache2/conf-available
RUN a2enconf admin
# CMD["apache2-foreground"]
# Run the same initialization script that vhttp does, and then the admin one.
CMD /usr/local/bin/admin.sh && apache2-foreground

# https://www.drupal.org/node/3060/release
#ENV DRUPAL_VERSION 7.73
#ENV DRUPAL_MD5 1db5b6bbacbfd735849221a0a9fb982e

#RUN set -eux; \
#	curl -fSL "https://ftp.drupal.org/files/projects/drupal-${DRUPAL_VERSION}.tar.gz" -o drupal.tar.gz; \
#	echo "${DRUPAL_MD5} *drupal.tar.gz" | md5sum -c -; \
#	tar -xz --strip-components=1 -f drupal.tar.gz; \
#	rm drupal.tar.gz; \
#	chown -R www-data:www-data sites modules themes

# download CiviCRM, specified version defaulting to STABLE
#ARG CIVICRM_VERSION=STABLE
#ARG CIVICRM_BRANCH=latest
#RUN set -eux; \
#        cd sites/all/modules/; \
#        curl -fSL "https://download.civicrm.org/${CIVICRM_BRANCH}/civicrm-${CIVICRM_VERSION}-drupal.tar.gz" -o civicrm-drupal.tar.gz; \
#	tar -xzf civicrm-drupal.tar.gz; \
#	rm civicrm-drupal.tar.gz; \
#	chown -R www-data:www-data civicrm