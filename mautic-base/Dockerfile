# INFO: mautic/mautic:apache is based on debian:jessie
FROM mautic/mautic:apache

RUN apt-get update && apt-get install --no-install-recommends -y \
    build-essential  \
    software-properties-common \
    htop \
    tcl8.5 \
    nano \
    git \
    libmagickwand-dev \
    imagemagick \
    libpng-dev \
    zlib1g-dev \
    libzip-dev \
    wget \
    groff \
    libmemcached-dev \
    zlib1g-dev \
    libz-dev \
    libpq-dev \
    libjpeg-dev \
    libpng12-dev \
    libfreetype6-dev \
    mysql-client \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install bcmath exif intl mbstring xml gd soap opcache \
    && docker-php-ext-configure bcmath \
    && docker-php-ext-configure gd \
          --enable-gd-native-ttf \
          --with-jpeg-dir=/usr/lib \
          --with-freetype-dir=/usr/include/freetype2 \
    && docker-php-ext-install gd \
    && pecl install imagick -y \
    && docker-php-ext-enable imagick

RUN { \
      echo 'opcache.memory_consumption=256M'; \
      echo 'opcache.interned_strings_buffer=8'; \
      echo 'opcache.max_accelerated_files=8000'; \
      echo 'opcache.revalidate_freq=2'; \
      echo 'opcache.fast_shutdown=1'; \
      echo 'opcache.enable_cli=1'; \
      echo 'memory_limit=256M'; \
      echo 'file_uploads = On'; \
      echo 'upload_max_filesize=128M'; \
      echo 'post_max_size=128M'; \
      echo 'max_execution_time=300'; \
    } > /usr/local/etc/php/conf.d/eou.ini

RUN { \
      echo  'AddDefaultCharset utf-8'; \
      echo  '<filesMatch ".(ico|pdf|flv|jpg|jpeg|png|gif|js|css|swf)$">'; \
      echo  '  Header set Cache-Control "max-age=8400600, public"'; \
      echo  '</filesMatch>'; \
      echo  '<IfModule mod_expires.c>'; \
      echo  '  ExpiresActive On'; \
      echo  '  ExpiresByType image/jpg "access 1 year"'; \
      echo  '  ExpiresByType image/jpeg "access 1 year"'; \
      echo  '  ExpiresByType image/gif "access 1 year"'; \
      echo  '  ExpiresByType image/png "access 1 year"'; \
      echo  '  ExpiresByType text/css "access 1 month"'; \
      echo  '  ExpiresByType application/pdf "access 1 month"'; \
      echo  '  ExpiresByType application/javascript "access 1 month"'; \
      echo  '  ExpiresByType application/x-javascript "access 1 month"'; \
      echo  '  ExpiresByType application/x-shockwave-flash "access 1 month"'; \
      echo  '  ExpiresByType image/x-icon "access 1 year"'; \
      echo  '  ExpiresDefault "access 1 month"'; \
      echo  '</IfModule>'; \
    } > /etc/apache2/conf-available/eou.conf

RUN a2enmod headers rewrite expires \
    && a2enconf eou
