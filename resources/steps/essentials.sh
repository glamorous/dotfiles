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
# .dotfiles
###############################################
copy_dotfiles() {
    execute \
        "cp -R ./../dotfiles/ $HOME/" \
        "Copy the dotfiles to your home directory"
}
###############################################
# Homebrew
###############################################
brew_install() {
    if ! cmd_exists "brew"; then
        printf "\n" | /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" &> /dev/null
        #  └─ simulate the ENTER keypress
    fi

    print_result $? "Homebrew (install)"
}

brew_update() {
    execute \
        "brew update" \
        "Homebrew (update)"
}

brew_upgrade() {
    execute \
        "brew upgrade" \
        "Homebrew (upgrade)"
}

brew_permissions() {
    if [ "$(ls -ld /usr/local/Cellar/ | awk '{print $3}')" != "$(whoami)" ]; then
        print_warning "Homebrew (folder permissions) - Needs fixing"
        sudo chown -R $(whoami) /usr/local/Cellar
        sudo chown -R $(whoami) /usr/local/Homebrew
        sudo chown -R $(whoami) /usr/local/var/homebrew/locks
        sudo chown -R $(whoami) /usr/local/etc /usr/local/lib /usr/local/sbin /usr/local/share /usr/local/var /usr/local/Frameworks /usr/local/share/locale /usr/local/share/man /usr/local/opt
    fi;

    print_success "Homebrew (folder permissions)"
}

brew_doctor() {
    execute \
        "brew doctor" \
        "Homebrew (doctor)"
}

brew_execute_brewfile() {
    execute \
        "brew bundle --global" \
        "Homebrew (install software through the global .Brewfile)"
}
###############################################
# Xcode Command Line Tools
###############################################
are_xcode_command_line_tools_installed() {
    xcode-select --print-path &> /dev/null
}

install_xcode_tools() {
    # We installed XCode with brew (but we need to accept the license)
    sudo xcodebuild -license accept &> /dev/null

    xcode-select --install &> /dev/null

    # Wait until the `Xcode Command Line Tools` are installed.
    execute \
        "until are_xcode_command_line_tools_installed; do \
            sleep 5; \
         done" \
        "Xcode Command Line Tools"

    sudo xcode-select -switch "/Applications/Xcode.app/Contents/Developer" &> /dev/null

    # Enable Developer Mode
    DevToolsSecurity -enable 2>&1 > /dev/null
}
###############################################
# SSH Folder & config
###############################################
ssh_folder_and_config() {
    if ! directory_exits "$SSH_DIR"; then
        mkdir "$SSH_DIR"
        print_info ".ssh folder created"
    fi

    if ! file_exists "$SSH_DIR/config"; then
        touch $SSH_DIR/config
	    echo "Host *" >> $SSH_DIR/config
	    echo "	AddKeysToAgent yes" >> $SSH_DIR/config
	    echo "	UseKeychain yes" >> $SSH_DIR/config
	    echo "  HashKnownHosts yes" >> $SSH_DIR/config
	    echo "" >> $SSH_DIR/config
    fi

    print_success "SSH-folder and config"
}

ssh_key_create() {
    if [ "$(ls -a $SSH_DIR/*.pub 2>&1 | sort | grep "No such file or directory")" ]; then
        # Generate key with an empty passphrase without outputting the generated key
        ssh-keygen -t rsa -b 4096 -q -f "$SSH_DIR/id_rsa" -N ""

        print_success "SSH Key (created)"
    else
        print_success "SSH Key (already exists)"
    fi;
}
ssh_show_public_keys() {
    print_info "SSH Public keys"
    PUBLIC_KEYS="$SSH_DIR/*.pub"

    for file in "$(ls -a $PUBLIC_KEYS)"; do cat $file; done;
}
###############################################
# Git global e-mail and username
###############################################
git_setup() {
    # Fall back to the Apple ID as the git e-mail address if none set yet
    if [ -z "$(git config --global user.email)" ]; then
        if [ -n "$(defaults read NSGlobalDomain AppleID 2>&1 | grep -E "( does not exist)$")" ]; then
            EMAIL_ADDRESS=""
        else
            EMAIL_ADDRESS="$(defaults read NSGlobalDomain AppleID)"
        fi;
    else
        EMAIL_ADDRESS="$(git config --global user.email)"
    fi;

    ask_for_input "What's the e-mail address to use with Git? (default: $EMAIL_ADDRESS)"
    [ -n "$REPLY" ] && EMAIL_ADDRESS=$REPLY

    git config --global user.email "$EMAIL_ADDRESS"

    # Suggest the username as git user name
    if [ -z "$(git config --global user.name)" ]; then
        USERNAME="$(whoami)"
    else
        USERNAME="$(git config --global user.name)"
    fi;

    ask_for_input "What's the name to use with Git? (default: $USERNAME)"
    [ -n "$REPLY" ] && USERNAME=$REPLY

    git config --global user.name "$USERNAME"

    print_success "Git global e-mail and user"
}
######################
# Oh-My-Zsh
######################
install_oh_my_zsh() {
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

    print_result $? "Oh-My-Zsh"
}
install_zsh_theme() {
    THEME_PATH="$HOME/.oh-my-zsh/custom/themes/powerlevel9k"
    rm -rf $THEME_PATH
    git clone https://github.com/bhilburn/powerlevel9k.git $THEME_PATH --quiet

    print_success "Zsh-theme"
}
install_ohz_plugins() {
		git clone https://github.com/jasonmccreary/git-trim.git $ZSH_CUSTOM/plugins/git-trim
}
###############################################
# Main for Essentials script
###############################################
main() {
    SSH_DIR="$HOME/.ssh"

    print_with_newline "This will overwrite all your dotfiles, you will lose your aliases and git configs!" "print_warning"

    ask_for_confirmation "Are you really sure you want to copy the dotfiles?"

    if answer_is_yes; then
        print_with_newline
        copy_dotfiles
    else
        print_with_newline
    fi

    brew_install
    brew_update
    brew_upgrade
    brew_permissions
    brew_execute_brewfile
    brew_doctor
    install_xcode_tools
    ssh_folder_and_config
    ssh_key_create
    ssh_show_public_keys
    git_setup
    install_oh_my_zsh
    install_zsh_theme
    install_omz_plugins
}

main $1
