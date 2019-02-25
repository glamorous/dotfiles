#!/usr/bin/env bash

show_header() {
	clear

	COLUMNS=$(tput cols)
	SPACES_TO_CENTER=$(printf "%*s\n" $((($COLUMNS-97)/2)))
	YELLOW_BLACK="\033[48;5;220m\033[38;5;0m"
	echo -e "$YELLOW_BLACK$SPACES_TO_CENTER                                                                                                 $SPACES_TO_CENTER "
	echo -e "$YELLOW_BLACK$SPACES_TO_CENTER                                                                                                 $SPACES_TO_CENTER "
	echo -e "$YELLOW_BLACK$SPACES_TO_CENTER ██████╗  ██████╗  ██████╗ ████████╗███████╗████████╗██████╗  █████╗ ██████╗    ███████╗██╗  ██╗ $SPACES_TO_CENTER "
	echo -e "$YELLOW_BLACK$SPACES_TO_CENTER ██╔══██╗██╔═══██╗██╔═══██╗╚══██╔══╝██╔════╝╚══██╔══╝██╔══██╗██╔══██╗██╔══██╗   ██╔════╝██║  ██║ $SPACES_TO_CENTER "
	echo -e "$YELLOW_BLACK$SPACES_TO_CENTER ██████╔╝██║   ██║██║   ██║   ██║   ███████╗   ██║   ██████╔╝███████║██████╔╝   ███████╗███████║ $SPACES_TO_CENTER "
	echo -e "$YELLOW_BLACK$SPACES_TO_CENTER ██╔══██╗██║   ██║██║   ██║   ██║   ╚════██║   ██║   ██╔══██╗██╔══██║██╔═══╝    ╚════██║██╔══██║ $SPACES_TO_CENTER "
	echo -e "$YELLOW_BLACK$SPACES_TO_CENTER ██████╔╝╚██████╔╝╚██████╔╝   ██║   ███████║   ██║   ██║  ██║██║  ██║██║     ██╗███████║██║  ██║ $SPACES_TO_CENTER "
	echo -e "$YELLOW_BLACK$SPACES_TO_CENTER ╚═════╝  ╚═════╝  ╚═════╝    ╚═╝   ╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝ $SPACES_TO_CENTER "
	echo -e "$YELLOW_BLACK$SPACES_TO_CENTER                                                                                                 $SPACES_TO_CENTER \033[0m"

    print_with_newline
}

answer_is_yes() {
    [[ "$REPLY" =~ ^[Yy]$ ]] \
        && return 0 \
        || return 1
}

ask_for_input() {
    print_question "$1"
    read -r
}

ask_for_confirmation() {
    print_question "$1 (y/n) "
    read -r -n 1
}

ask_for_sudo() {
    msg="Since this script will be altering your computer settings, "
    msg+="it's gonna need sudo privileges. Please enter your password…"

    print_after_newline "$msg" "print_in_purple"
    print_with_newline

    sudo -v

    # Update existing `sudo` time stamp
    # until this script has finished.
    #
    # https://gist.github.com/cowboy/3118588
    while true; do
        sudo -n true
        sleep 60
        kill -0 "$$" || exit
    done &> /dev/null &
}

ask_for_reboot() {
    print_after_newline "Do you want to restart?" "ask_for_confirmation"

    if answer_is_yes; then
        sudo shutdown -r now &> /dev/null
    fi

    print_with_newline
}

ask_to_continue() {
    print_after_newline "Press any key to continue…" "print"
    print_with_newline
	read -n 1
	# Delete the visual inputted key to continue and perform an extra new line
	print_with_newline "\r         "
}

directory_exits() {
    # otherwise directories with ~ aren't recognised
    [ -d "`eval echo ${1//>}`" ]
}

file_exists() {
    [ -f "`eval echo ${1//>}`" ]
}

cmd_exists() {
    command -v "$1" &> /dev/null
}

kill_all_subprocesses() {
    local i=""

    for i in $(jobs -p); do
        kill "$i"
        wait "$i" &> /dev/null
    done
}

execute() {
    local -r CMDS="$1"
    local -r MSG="${2:-$1}"
    local -r ERR_FILE="$(mktemp /tmp/XXXXX)"
    local -r OUT_FILE="$(mktemp /tmp/XXXXX)"

    local exitCode=0
    local cmdsPID=""

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # If the current process is ended,
    # also end all its subprocesses.

    set_trap "EXIT" "kill_all_subprocesses"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Execute commands in background

    eval "$CMDS" \
        &> "$OUT_FILE" \
        2> "$ERR_FILE" &

    cmdsPID=$!

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Show a spinner if the commands
    # require more time to complete.

    show_spinner "$cmdsPID" "$CMDS" "$MSG"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Wait for the commands to no longer be executing
    # in the background, and then get their exit code.

    wait "$cmdsPID" &> /dev/null
    exitCode=$?

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Print output based on what happened.

    print_result $exitCode "$MSG"

    if [ $exitCode -ne 0 ]; then
        if [ -s $ERR_FILE ]; then
            print_error_stream < "$ERR_FILE"
        else
            print_warning_stream < "$OUT_FILE"
        fi
    fi

    rm -rf "$ERR_FILE"
    rm -rf "$OUT_FILE"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    return $exitCode

}

get_answer() {
    printf "%s" "$REPLY"
}

is_git_repository() {
    git rev-parse &> /dev/null
}

mkd() {
    if [ -n "$1" ]; then
        if [ -e "$1" ]; then
            if [ ! -d "$1" ]; then
                print_error "$1 - a file with the same name already exists!"
            else
                print_success "$1"
            fi
        else
            execute "mkdir -p $1" "$1"
        fi
    fi
}

print_in_color() {
    printf "%b" \
        "$(tput setaf "$2" 2> /dev/null)" \
        "$1" \
        "$(tput sgr0 2> /dev/null)"
}

print_in_green() {
    print_in_color "$1" 2
}

print_in_purple() {
    print_in_color "$1" 5
}

print_in_red() {
    print_in_color "$1" 1
}

print_in_yellow() {
    print_in_color "$1" 3
}

print_in_blue() {
    print_in_color "$1" 4
}

print_in_cyan() {
    print_in_color "$1" 6
}

print_result() {

    if [ "$1" -eq 0 ]; then
        print_success "$2"
    else
        print_error "$2"
    fi

    return "$1"

}

print() {
    printf "%b" "$1"
}

print_with_newline() {
    print "$1\n"
}

print_success() {
    print_in_green "[✔] $1\n"
}

print_warning() {
    print_in_yellow "[!] $1\n"
}

print_info() {
    print_in_cyan "[i] $1\n"
}

print_error() {
    print_in_red "[✖] $1\n"
}

print_error_stream() {
    while read -r line; do
        print_in_red "↳ ERROR: $line\n"
    done
    print_with_newline
}

print_warning_stream() {
    while read -r line; do
        print_in_yellow "↳ $line\n"
    done
    print_with_newline
}

print_question() {
    print_in_purple "[?] $1\n"
    print "> "
}

print_step() {
    print_with_newline
    printf "%b" \
        "$(tput smul 2> /dev/null)" \
        "$(tput bold 2> /dev/null)" \
        "$(tput setaf 7 2> /dev/null)" \
        "$(tput setab 0 2> /dev/null)" \
        "Step $1: $2" \
        "$(tput rmul 2> /dev/null)" \
        "$(tput sgr0 2> /dev/null)"
    print_with_newline
}

print_after_newline() {
    print_with_newline
    $2 "$1"
}

set_trap() {
    trap -p "$1" | grep "$2" &> /dev/null \
        || trap '$2' "$1"
}

skip_questions() {
     while :; do
        case $1 in
            -y|--yes) return 0;;
                   *) break;;
        esac
        shift 1
    done

    return 1
}

show_spinner() {
    local -r FRAMES='/-\|'

    # shellcheck disable=SC2034
    local -r NUMBER_OR_FRAMES=${#FRAMES}

    local -r CMDS="$2"
    local -r MSG="$3"
    local -r PID="$1"

    local i=0
    local frameText=""

    # Provide more space so that the text hopefully
    # doesn't reach the bottom line of the terminal window.
    #
    # This is a workaround for escape sequences not tracking
    # the buffer position (accounting for scrolling).
    #
    # See also: https://unix.stackexchange.com/a/278888
    printf "\n\n\n"
    tput cuu 3
    tput sc

    # Display spinner while the commands are being executed.
    while kill -0 "$PID" &>/dev/null; do
        frameText="[${FRAMES:i++%NUMBER_OR_FRAMES:1}] $MSG"
        # Print frame text.
        printf "%s\n" "$frameText"
        sleep 0.2
        tput rc
    done
}
