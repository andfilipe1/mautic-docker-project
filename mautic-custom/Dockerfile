FROM repo/mautic-base:latest

# 2018-03-26
#
# EXEMPLOS PARA A CONFIGURAÇÃO DAS CRONS =======================================
#
# ENV MAUTIC_CRON_IMPORT "*/5 * * * *"
# ENV MAUTIC_CRON_CAMPAIGN_REBUILD "5,20,35,50 * * * *"
# ENV MAUTIC_CRON_CAMPAIGN_TRIGGER "2,17,32,47 * * * *"
# ENV MAUTIC_CRON_EMAILS_SEND "0,15,30,45 * * * *"
# ENV MAUTIC_CRON_BROADCASTS_SEND "0,15,30,45 * * * *"
# ENV MAUTIC_CRON_EMAIL_FETCH "0,15,30,45 * * * *"
# ENV MAUTIC_CRON_MAINTENANCE "* 1 * * *"
#
# PADRÃO PARA AS VARIÁVEIS DE LOTE =============================================
#
# ENV MAUTIC_CRON_SEGMENTS_BATCH 150
# ENV MAUTIC_CRON_REBUILD_BATCH 50
# ENV MAUTIC_CRON_TRIGGER_BATCH 50
#
# ==============================================================================

RUN chown -R www-data:www-data /var/www/html/

RUN rm -f /etc/cron.d/mautic

COPY cron-template/mautic /etc/cron.d/

COPY cron-template/spool_cleanup /etc/cron.d/

RUN git clone https://github.com/nickian/mautic-whitelabeler.git /var/www/whitelabel

RUN git clone https://github.com/mautic/mautic-tester.git /var/www/tester

COPY mautic-upgrade.sh /usr/bin/mautic-upgrade

RUN chmod +x /usr/bin/mautic-upgrade

COPY mautic-cache.sh /usr/bin/mautic-cache

RUN chmod +x /usr/bin/mautic-cache

COPY mautic-database.sh /usr/bin/mautic-database

RUN chmod +x /usr/bin/mautic-database

COPY docker-entrypoint.sh /entrypoint.sh
