# Docker Mautic

Procedimentos para utilização das imagens do Mautic em uma instancia

## Instalando o Docker
***

```bash
#Comando para instalar o Docker:

 curl -fsSL https://get.docker.com |sh
 
#Se você quiser evitar digitar sudo sempre que você executar o comando docker, adicione o seu usuário ao grupo docker:

sudo usermod -aG docker $(whoami)

#Se você precisar adicionar um usuário com o qual você não está logado ao grupo docker, declare aquele usuário explicitamente usando:

sudo usermod -aG docker "username"

#Obs: Será necessario reiniciar a maquina para as alteraçoes terem efeito.


 sudo service docker start
```

## Login do hub.docker.com
***

Para utilizar as imagens é necessário informar o login e senha do hub.docker.com:

```bash
 docker login

 ***Se for usar o docker hub
```

## Executando o portainer.io
***

#### Importante: Execute este comando diretamente no servidor

###### Faz o pull da imagem do portainer para o host

```bash
docker pull portainer/portainer:latest
```

###### Volume usado pelo portainer para persistir os dados
```
docker volume create portainer_data
```

###### Comando para subir o portainer com o modo swarm ativo
```
docker run -d --restart always \
 --name portainer \
  -p 9000:9000 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer
```

## Executando o Proxy Reverso
***

### Importante: Execute este comando diretamente no servidor


###### Faz o pull da imagem do nginx-proxy-custom para o host
```bash
sudo docker pull andfilipe1/nginx-proxy-latest

sudo docker run -d -p 80:80 -p 443:443 \
  --name eou-nginx-proxy \
  -e ENABLE_IPV6=true \
  --restart always \
  -v /path/to/certs:/etc/nginx/certs:ro \
  -v /etc/nginx/vhost.d \
  -v /usr/share/nginx/html \
  -v /var/run/docker.sock:/tmp/docker.sock:ro \
  --label com.github.jrcs.letsencrypt_nginx_proxy_companion.nginx_proxy \
  andfilipe1/nginx-proxy-custom:latest
```

## Executando o SSL do Proxy Reverso
***

###### Importante: Execute este comando diretamente no servidor

```bash
docker pull jrcs/letsencrypt-nginx-proxy-companion:latest

docker run --name letsencrypt -d --restart always \
  -v /path/to/certs:/etc/nginx/certs:rw \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  --volumes-from eou-nginx-proxy \
  jrcs/letsencrypt-nginx-proxy-companion:latest
```

## Utilizando a imagem do Mautic
***

Atualizando a imagem do Mautic

```bash
docker pull andfilipe1/mautic-custom:latest
ou
docker pull andfilipe1/mautic-base:latest
```

## Persistência de Dados
***

Agora precisamos criar um volume para persistir os arquivos do Mautic e montar
este volume em `/var/www/html`

```bash
docker volume create nome_do_volume
```

### Variáveis de ambiente
***

#####	`-e MAUTIC_DB_HOST=`
(obrigatório) Hostname ou IP do MySQL

#####	`-e MAUTIC_DB_USER=`
(obrigatório) Usuário do Banco de Dados

##### `-e MAUTIC_DB_PASSWORD=`
(obrigatório) Senha do MySQL

#####	`-e MAUTIC_DB_NAME=`
(obrigatório) Nome do Banco de Dados

##### `-e MAUTIC_DB_TABLE_PREFIX=`
(opcional) Prefixo do Banco de Dados

#####	`-e MAUTIC_RUN_CRON_JOBS=true`
(opcional) Habilita o cron

#####	`-e MAUTIC_TRUSTED_PROXIES=0.0.0.0/0`
(obrigatório) Proxy para o Symphony. [Veja a Documentação do Proxy](http://symfony.com/doc/current/request/load_balancer_reverse_proxy.html)

#####	`-e MAUTIC_CRON_HUBSPOT=true`
(opcional) Habilita a integração com Hubspot

#####	`-e MAUTIC_CRON_SALESFORCE=true`
(opcional) Habilita a cron do Salesforce

#####	`-e MAUTIC_CRON_PIPEDRIVE=true`
(opcional) Habilita a cron do Pipedrive

#####	`-e MAUTIC_CRON_ZOHO=true`
(opcional) Habilita a cron para o Zoho CRM

#####	`-e MAUTIC_CRON_SUGARCRM=true`
(opcional) Habilita a cron do SugarCRM

#####	`-e MAUTIC_CRON_DYNAMICS=true`
(opcional) Habilita a cron para habilitar o SugarCRM

### Importante

Se não houver o banco de dados especificado em `MAUTIC_DB_NAME` no host `MAUTIC_DB_HOST` o mautic irá criar automaticamente um novo banco de dados. Caso o banco de dados já exista o Mautic irá utilizá-lo. Lembre-se do parâmetro `MAUTIC_DB_TABLE_PREFIX` caso utilize tabelas prefixadas.

## Container Frontend
***

```shell
 docker run -d --name nome_do_mautic_frontend \
   --restart always \
   -e MAUTIC_DB_HOST=123.123.123.123 \
   -e MAUTIC_DB_USER=asdf \
   -e MAUTIC_DB_PASSWORD=asdf \
   -e MAUTIC_DB_NAME=asdf \
   -e VIRTUAL_HOST=mkt.dominio.com.br \
   -e LETSENCRYPT_HOST=mkt.dominio.com.br \
   -e LETSENCRYPT_EMAIL=notificacao@eoumrm.com.br \
   -e MAUTIC_TRUSTED_PROXIES=0.0.0.0/0 \
   -e MAUTIC_CRON_IMPORT 0,15,30,45 * * * * \
   -v nome_do_volume:/var/www/html \
  andfilipe1/mautic-custom:latest
```

##### Variáveis
***

Informar estas variáveis ao criar o container em algum orquestrador visual:

ENV                 | Obrigatório | Valor               | Descrição
:-------------------|:-----------:|:--------------------|:----------------------
MAUTIC_DB_HOST      |      *      | 123.123.123.123     | Endereço do Host
MAUTIC_DB_USER      |      *      | usuário             | Usuário do MySQL
MAUTIC_DB_PASSWORD  |      *      | senha               | Senha do MySQL
MAUTIC_DB_NAME      |      *      | 123.123.123.123     | Endereço do Host
VIRTUAL_HOST        |      *      | mkt.site.com        | Endereço do Mautic
LETSENCRYPT_HOST    |             | mkt.site.com        | Endereço do Mautic com SSL
LETSENCRYPT_EMAIL   |             | lets@mkt.site.com   | E-mail de Notificações do SSL
MAUTIC_CRON_IMPORT  |             | \*/5 \* \* \* \*    | Importação de Contatos

#### Importante
***

As variáveis VIRTUAL_HOST E LETSENCRYPT_HOST controlam o acesso http ao Mautic. Caso você não queira usar o SSL, informe apenas o VIRTUAL_HOST.

O SSL é fornecido através do EFF Certbot e se renova automaticamente.

## Container para Backend (Uso Geral)
***

```shell
docker run -d --name nome_do_mautic_backend \
  --restart always \
  -e MAUTIC_DB_HOST=123.123.123.123:3306 \
  -e MAUTIC_DB_USER=asdf \
  -e MAUTIC_DB_PASSWORD=asdf \
  -e MAUTIC_DB_NAME=asdf \
  -e MAUTIC_RUN_CRON_JOBS=true \
  -e MAUTIC_CRON_SEGMENTS_BATCH=150 \
  -e MAUTIC_CRON_CAMPAIGN_REBUILD=5,20,35,50 * * * * \
  -e MAUTIC_CRON_CAMPAIGN_TRIGGER=2,17,32,47 * * * * \
  -e MAUTIC_CRON_REBUILD_BATCH=50 \
  -e MAUTIC_CRON_TRIGGER_BATCH=50 \
  -e MAUTIC_CRON_EMAILS_SEND=0,15,30,45 * * * * \
  -v nome_do_volume:/var/www/html \
  andfilipe1/mautic-custom:latest
```

## Container para Backend (Execução de Campanhas)
***

```shell
docker run -d --name nome_do_mautic_campanhas \
  --restart always \
  -e MAUTIC_DB_HOST=123.123.123.123:3306 \
  -e MAUTIC_DB_USER=asdf \
  -e MAUTIC_DB_PASSWORD=asdf \
  -e MAUTIC_DB_NAME=asdf \
  -e MAUTIC_RUN_CRON_JOBS=true \
  -e MAUTIC_CRON_CAMPAIGN_REBUILD=5,20,35,50 * * * * \
  -e MAUTIC_CRON_CAMPAIGN_TRIGGER=2,17,32,47 * * * * \
  -e MAUTIC_CRON_REBUILD_BATCH=50 \
  -e MAUTIC_CRON_TRIGGER_BATCH=50 \
  -v nome_do_volume:/var/www/html \
  andfilipe1/mautic-custom:latest
```

## Container para Backend (Envio de e-mails)
***

```shell
docker run -d --name nome_do_mautic_emails \
  --restart always \
  -e MAUTIC_DB_HOST=123.123.123.123:3306 \
  -e MAUTIC_DB_USER=asdf \
  -e MAUTIC_DB_PASSWORD=asdf \
  -e MAUTIC_DB_NAME=asdf \
  -e MAUTIC_RUN_CRON_JOBS=true \
  -e MAUTIC_CRON_EMAILS_SEND=0,15,30,45 * * * * \
  -e MAUTIC_CRON_BROADCASTS_SEND=0,15,30,45 * * * * \
  -v nome_do_volume:/var/www/html \
  andfilipe1/mautic-custom:latest
```

## Container para Backend (Atualização de Segmentos)
***

```shell
docker run -d --name nome_do_mautic_segmentos \
  --restart always \
  -e MAUTIC_DB_HOST=123.123.123.123:3306 \
  -e MAUTIC_DB_USER=asdf \
  -e MAUTIC_DB_PASSWORD=asdf \
  -e MAUTIC_DB_NAME=asdf \
  -e MAUTIC_RUN_CRON_JOBS=true \
  -e MAUTIC_CRON_SEGMENTS_BATCH=150 \
  -v nome_do_volume:/var/www/html \
  andfilipe1/mautic-custom:latest
```
