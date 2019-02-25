#!/usr/bin/env bash

execute_step() {
    show_header
    print_step $1 "$2"

    print_with_newline

    ask_for_confirmation "Are you sure you want to execute the script?"

    if answer_is_yes; then
        print_after_newline "" "print_with_newline"
        source "$MAIN_DIR/resources/steps/$3"
    else
        print_after_newline "We will skip this step like you asked…" "print_info"
    fi;

    ask_to_continue
}

main() {
    # Ensure that the following actions
    # are made relative to this file's path.

    cd "$(dirname "${BASH_SOURCE[0]}")" \
        || exit 1

    source resources/utils.sh
    source resources/utils-macos.sh

    show_header

    print_with_newline "So you want to set up your Mac? Good, \033[1mbootstrap.sh\033[0m will help you out with that."
    print_with_newline "Beware though… This will alter many of your settings…"

    ask_for_sudo

    if cmd_exists "git"; then

        # @TODO: Ask and download latests updates from repo
        print_after_newline "You should use the latest version of this repository." "print_warning"

    fi

    print_after_newline "If you're really sure you want to continue, enter “yes sir!” to continue" "ask_for_input"

    if [[ $REPLY != "yes sir!" ]]; then
        print_after_newline "No worries, I'll stop here… Ciao! 👋" "print_in_yellow"
        print_with_newline
        exit 0
    fi;

    print_after_newline "OK, you asked for it… Let's go!" "print_in_green"
    print_with_newline

    ask_to_continue

    execute_step "1" "OSX setup (computer name, Apple ID…)" "macos-setup.sh"
    execute_step "2" "Essentials (.dotfiles, brew, xcode, ssh, git…)" "essentials.sh"
    execute_step "3" "Development (Composer packages, PHP-settings…)" "development.sh"
    execute_step "4" "OSX settings (App preferences)" "macos-app-settings.sh"

    ask_for_reboot

    print_after_newline "\033[32mYay, we're all done here! 🎉\nEnjoy your configured computer! 😊\033[0m" "print_with_newline"
}

MAIN_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

main $1
exit;
