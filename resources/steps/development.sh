#!/usr/bin/env bash


# Go to the end of the file (main-function) to see the specific steps!


###############################################
# Check script
###############################################
current_script=`basename "${BASH_SOURCE[0]}"`
starting_script=`basename "$0"`

if [ "$starting_script" == $current_script ]; then
    exit 1
fi;

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../utils.sh"


###############################################
# PHP
###############################################
install_php_extensions() {
    PREFIX="PHP Extensions:"

    execute \
        "printf \"\n\" | pecl install mcrypt-1.0.1" \
        "$PREFIX mcrypt"

    execute \
        "printf \"\n\" | pecl install apcu" \
        "$PREFIX APC"

    execute \
        "pecl install imagick" \
        "$PREFIX Imagick"

    execute \
        "pecl install xdebug" \
        "$PREFIX Xdebug"
}

install_global_composer_packages() {
    execute \
        "composer global require laravel/valet" \
        "Composer (global): Laravel Valet"

    execute \
        "composer global require laravel/envoy" \
        "Composer (global): Laravel Envoy"
}

install_valet() {
    execute \
        "valet install" \
        "Valet: install"

    execute \
        "valet trust" \
        "Valet: trust"
}
###############################################
# MySQL
###############################################
mysql_set_password() {
    MYSQL_PASSWORD="root"
    ask_for_input "What should the root password for MySQL be? (default: $MYSQL_PASSWORD)"
    [ -n "$REPLY" ] && MYSQL_PASSWORD=$REPLY

    mysql -u root -e "ALTER USER root@localhost IDENTIFIED WITH mysql_native_password BY '$MYSQL_PASSWORD'; FLUSH PRIVILEGES;"

}
mysql_configure() {
    cat "$MAIN_DIR/resources/configs/my.cnf" > /usr/local/etc/my.cnf
}
###############################################
# Main for Development script
###############################################
main() {
    install_php_extensions
    install_global_composer_packages
    install_valet
    mysql_set_password
    mysql_configure
}

main $1
