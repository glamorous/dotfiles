#!/bin/bash

cd ~/dotfiles

#install composer
echo 'install composer'
echo '----------------'
curl -sS https://getcomposer.org/installer | php
echo 'move composer to /usr/local/bin/composer'
mv -f composer.phar /usr/local/bin/composer

#install prestissimo (parallel plugin)
echo 'install prestissimo (parallel plugin)'
echo '------------'
composer global require hirak/prestissimo

#install envoy
echo 'install laravel envoy'
echo '---------------------'
composer global require "laravel/envoy=~1.0"

#install php-cs-fixer
echo 'install php-cs-fixer'
echo '--------------------'
composer global require fabpot/php-cs-fixer

#install homebrew and some packages
source .brew