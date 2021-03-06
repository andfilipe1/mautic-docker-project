#!/bin/bash

set -e

rm -rf /var/www/html/app/cache

# ==============================================================================
# ATUALIZA AS EXTENSÕES E BIBLIOTECAS DE TERCEIROS
# ==============================================================================

rm -rf /var/www/html/whitelabel
cp -rf /var/www/whitelabel /var/www/html
cp -rf /var/www/tester/tester.php /var/www/html/tester.php
chown -R www-data:www-data /var/www/html

# ==============================================================================
# CONSISTÊNCIA DAS VARIAVEIS DE CONEXÃO
# ==============================================================================

if [ -n "$MYSQL_PORT_3306_TCP" ]; then
        if [ -z "$MAUTIC_DB_HOST" ]; then
                export MAUTIC_DB_HOST='mysql'
                if [ "$MAUTIC_DB_USER" = 'root' ] && [ -z "$MAUTIC_DB_PASSWORD" ]; then
                        export MAUTIC_DB_PASSWORD="$MYSQL_ENV_MYSQL_ROOT_PASSWORD"
                fi
        else
                echo >&2 "warning: both MAUTIC_DB_HOST and MYSQL_PORT_3306_TCP found"
                echo >&2 "  Connecting to MAUTIC_DB_HOST ($MAUTIC_DB_HOST)"
        fi
fi

if [ -z "$MAUTIC_DB_HOST" ]; then
    echo >&2 "error: missing MAUTIC_DB_HOST and MYSQL_PORT_3306_TCP environment variables"
    exit 1
fi

if [ -z "$MAUTIC_DB_PASSWORD" ]; then
    echo >&2 "error: missing required MAUTIC_DB_PASSWORD environment variable"
    exit 1
fi

# ==============================================================================
# CONSISTÊNCIA DAS VARIAVEIS DE LOTE
# ==============================================================================

# Usa um valor de lote padrão caso nenhum seja especificado
if [ -z "$MAUTIC_CRON_SEGMENTS_BATCH" ]; then
    export MAUTIC_CRON_SEGMENTS_BATCH=150
fi

# Usa um valor de lote padrão caso nenhum seja especificado
if [ -z "$MAUTIC_CRON_REBUILD_BATCH" ]; then
    export MAUTIC_CRON_REBUILD_BATCH=50
fi

# Usa um valor de lote padrão caso nenhum seja especificado
if [ -z "$MAUTIC_CRON_TRIGGER_BATCH" ]; then
    export MAUTIC_CRON_TRIGGER_BATCH=50
fi

# Usa um valor padrão caso nenhum seja especificado
if [ -z "$MAUTIC_CRON_IMPORT" ]; then
    export MAUTIC_CRON_IMPORT="0,15,30,45 * * * *"
fi

# ==============================================================================
# CONFIGURAÇÃO DAS CRONS
# ==============================================================================

# CRON mautic:segments:update
if [ -n "$MAUTIC_CRON_SEGMENTS_UPDATE" ]; then
    echo >&2 "CRON: mautic:segments:update @ $MAUTIC_CRON_SEGMENTS_UPDATE"
    echo "$MAUTIC_CRON_SEGMENTS_UPDATE   www-data   php /var/www/html/app/console mautic:segments:update --batch-limit=$MAUTIC_CRON_SEGMENTS_BATCH > /var/log/cron.pipe 2>&1" >> /etc/cron.d/mautic
fi

# CRON mautic:import
if [ -n "$MAUTIC_CRON_IMPORT" ]; then
    echo >&2 "CRON: mautic:import"
    echo "$MAUTIC_CRON_IMPORT   www-data   php /var/www/html/app/console mautic:import > /var/log/cron.pipe 2>&1" >> /etc/cron.d/mautic
fi

# CRON mautic:campaigns:rebuild
if [ -n "$MAUTIC_CRON_CAMPAIGN_REBUILD" ]; then
    echo >&2 "CRON: mautic:campaigns:rebuild"
    echo "$MAUTIC_CRON_CAMPAIGN_REBUILD   www-data   php /var/www/html/app/console mautic:campaigns:rebuild --batch-limit=$MAUTIC_CRON_REBUILD_BATCH > /var/log/cron.pipe 2>&1" >> /etc/cron.d/mautic
fi

# CRON mautic:campaigns:trigger
if [ -n "$MAUTIC_CRON_CAMPAIGN_TRIGGER" ]; then
    echo >&2 "CRON: mautic:campaigns:trigger"
    echo "$MAUTIC_CRON_CAMPAIGN_TRIGGER   www-data   php /var/www/html/app/console mautic:campaigns:trigger --batch-limit=$MAUTIC_CRON_TRIGGER_BATCH > /var/log/cron.pipe 2>&1" >> /etc/cron.d/mautic
fi

# CRON mautic:emails:send
if [ -n "$MAUTIC_CRON_EMAILS_SEND" ]; then
    echo >&2 "CRON: mautic:emails:send"
    echo "$MAUTIC_CRON_EMAILS_SEND   www-data   php /var/www/html/app/console mautic:emails:send > /var/log/cron.pipe 2>&1" >> /etc/cron.d/mautic
fi

# CRON mautic:email:fetch
if [ -n "$MAUTIC_CRON_EMAIL_FETCH" ]; then
    echo >&2 "CRON: mautic:mautic:email:fetch"
    echo "$MAUTIC_CRON_EMAIL_FETCH   www-data   php /var/www/html/app/console mautic:email:fetch > /var/log/cron.pipe 2>&1" >> /etc/cron.d/mautic
fi

# CRON mautic:social:monitoring
if [ -n "$MAUTIC_CRON_SOCIAL_MONITORING" ]; then
    echo >&2 "CRON: mautic:social:monitoring"
    echo "$MAUTIC_CRON_SOCIAL_MONITORING   www-data   php /var/www/html/app/console mautic:social:monitoring > /var/log/cron.pipe 2>&1" >> /etc/cron.d/mautic
fi

# CRON mautic:messages:send
if [ -n "$MAUTIC_CRON_MESSAGES_SEND" ]; then
    echo >&2 "CRON: mautic:messages:send"
    echo "$MAUTIC_CRON_MESSAGES_SEND   www-data   php /var/www/html/app/console mautic:messages:send > /var/log/cron.pipe 2>&1" >> /etc/cron.d/mautic
fi

# CRON mautic:webhooks:process
if [ -n "$MAUTIC_CRON_WEBHOOKS_PROCESSS" ]; then
    echo >&2 "CRON: mautic:webhooks:process"
    echo "$MAUTIC_CRON_WEBHOOKS_PROCESSS   www-data   php /var/www/html/app/console mautic:webhooks:process > /var/log/cron.pipe 2>&1" >> /etc/cron.d/mautic
fi

# CRON mautic:broadcasts:send
if [ -n "$MAUTIC_CRON_BROADCASTS_SEND" ]; then
    echo >&2 "CRON: mautic:broadcasts:send"
    echo "$MAUTIC_CRON_BROADCASTS_SEND   www-data   php /var/www/html/app/console mautic:broadcasts:send > /var/log/cron.pipe 2>&1" >> /etc/cron.d/mautic
fi

# CRON mautic:maintenance:cleanup
if [ -n "$MAUTIC_CRON_MAINTENANCE" ]; then
    echo >&2 "CRON: mautic:maintenance:cleanup"
    echo "$MAUTIC_CRON_MAINTENANCE   www-data   php /var/www/html/app/console mautic:maintenance:cleanup > /var/log/cron.pipe 2>&1" >> /etc/cron.d/mautic
fi

# CRON mautic:iplookup:download
  echo >&2 "CRON: mautic:iplookup:download"
  echo "$MAUTIC_CRON_IPLOOKUP   www-data   php /var/www/html/app/console mautic:iplookup:download > /var/log/cron.pipe 2>&1" >> /etc/cron.d/mautic

# CRON mautic:reports:scheduler
if [ -n "$MAUTIC_CRON_REPORTS_SCHEDULER" ]; then
    echo >&2 "CRON: mautic:reports:scheduler"
    echo "$MAUTIC_CRON_REPORTS_SCHEDULER   www-data   php /var/www/html/app/console mautic:reports:scheduler > /var/log/cron.pipe 2>&1" >> /etc/cron.d/mautic
fi

#ENABLES HUBSPOT CRON
if [ -n "$MAUTIC_CRON_HUBSPOT" ]; then
        echo >&2 "CRON: Activating Hubspot"
        echo "10,40 * * * *     www-data   php /var/www/html/app/console mautic:integration:fetchleads --integration=Hubspot > /var/log/cron.pipe 2>&1" >> /etc/cron.d/mautic
        echo "15,45 * * * *     www-data   php /var/www/html/app/console mautic:integration:pushactivity --integration=Hubspot > /var/log/cron.pipe 2>&1" >> /etc/cron.d/mautic
fi

#ENABLES SALESFORCE CRON
if [ -n "$MAUTIC_CRON_SALESFORCE" ]; then
        echo >&2 "CRON: Activating Salesforce"
        echo "10,40 * * * *     www-data   php /var/www/html/app/console mautic:integration:fetchleads --integration=Salesforce > /var/log/cron.pipe 2>&1" >> /etc/cron.d/mautic
        echo "12,42 * * * *     www-data   php /var/www/html/app/console mautic:integration:pushactivity --integration=Salesforce > /var/log/cron.pipe 2>&1" >> /etc/cron.d/mautic
        echo "14,44 * * * *     www-data   php /var/www/html/app/console mautic:integration:pushleadactivity --integration=Salesforce > /var/log/cron.pipe 2>&1" >> /etc/cron.d/mautic
        echo "16,46 * * * *     www-data   php /var/www/html/app/console mautic:integration:synccontacts --integration=Salesforce > /var/log/cron.pipe 2>&1" >> /etc/cron.d/mautic
fi

#ENABLES SUGARCRM CRON
if [ -n "$MAUTIC_CRON_SUGARCRM" ]; then
        echo >&2 "CRON: Activating SugarCRM"
        echo "10,40 * * * *     www-data   php /var/www/html/app/console mautic:integration:fetchleads --fetch-all --integration=Sugarcrm > /var/log/cron.pipe 2>&1" >> /etc/cron.d/mautic
fi

#ENABLES PIPEDRIVE CRON
if [ -n "$MAUTIC_CRON_PIPEDRIVE" ]; then
        echo >&2 "CRON: Activating Pipedrive"
        echo "10,40 * * * *     www-data   php /var/www/html/app/console mautic:integration:pipedrive:fetch > /var/log/cron.pipe 2>&1" >> /etc/cron.d/mautic
        echo "15,45 * * * *     www-data   php /var/www/html/app/console mautic:integration:pipedrive:push > /var/log/cron.pipe 2>&1" >> /etc/cron.d/mautic
fi

#ENABLES ZOHO CRON
if [ -n "$MAUTIC_CRON_ZOHO" ]; then
        echo >&2 "CRON: Activating ZohoCRM"
        echo "10,40 * * * *     www-data   php /var/www/html/app/console mautic:integration:fetchleads --integration=Zoho > /var/log/cron.pipe 2>&1" >> /etc/cron.d/mautic
fi

#ENABLES DYNAMICS CRON
if [ -n "$MAUTIC_CRON_DYNAMICS" ]; then
        echo >&2 "CRON: Activating DynamicsCRM"
        echo "10,40 * * * *     www-data   php /var/www/html/app/console mautic:integration:fetchleads -i Dynamics > /var/log/cron.pipe 2>&1" >> /etc/cron.d/mautic
fi

if ! [ -e index.php -a -e app/AppKernel.php ]; then
        echo >&2 "Mautic not found in $(pwd) - copying now..."

        if [ "$(ls -A)" ]; then
                echo >&2 "WARNING: $(pwd) is not empty - press Ctrl+C now if this is an error!"
                ( set -x; ls -A; sleep 10 )
        fi

        tar cf - --one-file-system -C /usr/src/mautic . | tar xf -

        echo >&2 "Complete! Mautic has been successfully copied to $(pwd)"
fi

# Ensure the MySQL Database is created
php /makedb.php "$MAUTIC_DB_HOST" "$MAUTIC_DB_USER" "$MAUTIC_DB_PASSWORD" "$MAUTIC_DB_NAME"

echo >&2 "======================================================================"
echo >&2 " "
echo >&2 "MAUTIC CONFIGURADO COM SUCESSO!"
echo >&2 "Host Name: $MAUTIC_DB_HOST"
echo >&2 "Database Name: $MAUTIC_DB_NAME"
echo >&2 "Database Username: $MAUTIC_DB_USER"
echo >&2 "Database Password: $MAUTIC_DB_PASSWORD"
echo >&2 " "
echo >&2 "======================================================================"

# Write the database connection to the config so the installer prefills it
if ! [ -e app/config/local.php ]; then
        php /makeconfig.php
        # Make sure our web user owns the config file if it exists
        chown www-data:www-data app/config/local.php
        mkdir -p /var/www/html/app/logs
        chown www-data:www-data /var/www/html/app/logs
fi

if [[ "$MAUTIC_RUN_CRON_JOBS" == "true" ]]; then
    if [ ! -e /var/log/cron.pipe ]; then
        mkfifo /var/log/cron.pipe
        chown www-data:www-data /var/log/cron.pipe
    fi
    (tail -f /var/log/cron.pipe | while read line; do echo "[CRON] $line"; done) &
    CRONLOGPID=$!
    cron -f &
    CRONPID=$!
else
    echo >&2 "Not running cron as requested."
fi

echo >&2
echo >&2 "========================================================================"
echo >&2

"$@" &
MAINPID=$!

shut_down() {
    if [[ "$MAUTIC_RUN_CRON_JOBS" == "true" ]]; then
        kill -TERM $CRONPID || echo 'Cron not killed. Already gone.'
        kill -TERM $CRONLOGPID || echo 'Cron log not killed. Already gone.'
    fi
    kill -TERM $MAINPID || echo 'Main process not killed. Already gone.'
}
trap 'shut_down;' TERM INT

# wait until all processes end (wait returns 0 retcode)
while :; do
    if wait; then
        break
    fi
done
