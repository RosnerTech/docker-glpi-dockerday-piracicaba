# Escolhendo a Imagem do Debian
FROM debian:12.5-slim

LABEL org.opencontainers.image.authors="rosner@rosnertech.com.br"

# Não fazer perguntas durante a instalação
ENV DEBIAN_FRONTEND=noninteractive

RUN apt update \
    && apt install --yes --no-install-recommends \
       ca-certificates \
       apt-transport-https \
       lsb-release \
       wget \
       curl \
       gnupg \
    && curl -sSLo /usr/share/keyrings/deb.sury.org-php.gpg https://packages.sury.org/php/apt.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/deb.sury.org-php.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list \
    && apt update \
    && apt install --yes --no-install-recommends \
       apache2 \
       php8.2 \
       php8.2-mysql \
       php8.2-ldap \
       php8.2-xmlrpc \
       php8.2-imap \
       php8.2-curl \
       php8.2-gd \
       php8.2-mbstring \
       php8.2-xml \
       php-cas \
       php8.2-intl \
       php8.2-zip \
       php8.2-bz2 \
       php8.2-redis \
       cron \
       jq \
       libldap-common \
       libsasl2-2 \
       libsasl2-modules \
       libsasl2-modules-db \
       nano \
       vim \
       net-tools \
       iputils-ping \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/* /usr/share/man/*

# Configurando o Apache para ouvir na porta 8888
RUN sed -i 's/Listen 80/Listen 8888/' /etc/apache2/ports.conf \
    && sed -i 's/:80/:8888/' /etc/apache2/sites-available/000-default.conf

# Instalando GLPI
RUN mkdir -p /var/www/html/glpi \
    && cd /tmp \
    && wget https://github.com/glpi-project/glpi/releases/download/10.0.15/glpi-10.0.15.tgz \
    && tar -xvzf glpi-10.0.15.tgz \
    && cp -r glpi/* /var/www/html/glpi \
    && rm -rf /tmp/glpi-10.0.15.tgz /tmp/glpi

# Copiando os plugins baixados anteriormente
COPY glpiinventory /var/www/html/glpi/plugins/glpiinventory
COPY behaviors /var/www/html/glpi/plugins/behaviors

# Alterando as permissões das pastas
RUN chown www-data:www-data /var/www/html/* -Rf \
    && chmod 775 /var/www/html/* -Rf 

# Adiciona o agendamento cron
RUN echo "* * * * * /usr/bin/php8.2 /var/www/html/glpi/front/cron.php" >> /etc/crontab

# Configuração de segurança para sessões
RUN sed -i 's/session.cookie_httponly =/session.cookie_httponly = on/' /etc/php/8.2/apache2/php.ini 

# Expondo a porta 8888
EXPOSE 8888

# Mantendo o Container em execução
CMD ["apache2ctl", "-D", "FOREGROUND"]
