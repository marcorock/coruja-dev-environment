FROM php:8.3-apache

ARG USERNAME=developer
ARG USER_UID=1000
ARG USER_GID=1000

RUN apt-get update \
    && apt-get install -y \
        git \
        unzip \
        curl \
        locales \
        zsh \
        fzf \
        ripgrep \
        bat \
        fd-find \
        zsh-autosuggestions \
        zsh-syntax-highlighting \
        libicu-dev \
        libzip-dev \
    && echo "pt_BR.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen \
    && docker-php-ext-install \
        pdo \
        pdo_mysql \
        intl \
        zip \
    && pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && a2enmod rewrite vhost_alias \
    && groupadd --gid "${USER_GID}" "${USERNAME}" \
    && useradd \
        --uid "${USER_UID}" \
        --gid "${USER_GID}" \
        --create-home \
        --shell /bin/zsh \
        "${USERNAME}" \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

COPY docker/apache/000-default.conf /etc/apache2/sites-available/000-default.conf
COPY docker/php/php.ini /usr/local/etc/php/conf.d/development.ini
COPY docker/php/xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini
COPY docker/zsh/.zshrc /home/developer/.zshrc

RUN chown developer:developer /home/developer/.zshrc \
    && mkdir -p /home/developer/.composer \
    && chown -R developer:developer /home/developer

ENV SHELL=/bin/zsh
ENV LANG=pt_BR.UTF-8
ENV LC_ALL=pt_BR.UTF-8
ENV COMPOSER_HOME=/home/developer/.composer

WORKDIR /var/www/projects

CMD ["apache2-foreground"]
