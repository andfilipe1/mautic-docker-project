#!/bin/bash

mautic-backup

echo "Starting upgrade..."

echo "Backup /var/www/html to /var/www/backup ..."
cp -rf /var/www/html /var/www/backup

echo "remove oldest upgrade.php file"
rm -f /var/www/html/upgrade.php

echo "Get the latest upgrade.php file"
cd /var/www/html
wget https://raw.githubusercontent.com/mautic/mautic/staging/upgrade.php

echo "Running upgrade.php"
php upgrade.php

mautic-database

echo "Mautic Upgrade Complete"
