#!/bin/bash

echo "Runing Symphony migrations ..."

echo "doctrine:migration:status ..."
php /var/www/html/app/console doctrine:migration:status

echo "doctrine:migration:migrate --no-interaction ..."
php /var/www/html/app/console doctrine:migration:migrate --no-interaction

echo "doctrine:schema:update --dump-sql ..."
php /var/www/html/app/console doctrine:schema:update --dump-sql

echo "doctrine:schema:update --force ..."
php /var/www/html/app/console doctrine:schema:update --force

mautic-cache
