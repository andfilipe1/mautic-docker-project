#!/bin/bash
sudo -u www-data php /var/www/html/app/console mautic:emails:send > /var/log/cron.pipe 2>&1
