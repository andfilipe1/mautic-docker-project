#!/bin/bash

echo "Cleaning Cache..."
rm -rf /var/www/html/app/cache
mkdir -m 777 /var/www/html/app/cache

echo "Update permissions..."
chown -R www-data:www-data /var/www/html/
chmod +777 /var/www/html/app/cache
chmod +777 /var/www/html/app/spool/default

echo "Cache OK"
