#!/usr/bin/env bash

# https://github.com/enesanbar/dotfiles/blob/master/bin/install.sh

# This symlinks all the dotfiles to your home directory ~/

declare -a FILES_TO_SYMLINK=(
    'shell/shell_aliases'
    'shell/shell_exports'
    'shell/shell_functions'
    'shell/zshrc'

    'git/gitconfig'
    'git/gitignore'
)

execute() {
    $1 &> /dev/null
    print_result $? "${2:-$1}"
}

answer_is_yes() {
    [[ "$REPLY" =~ ^[Yy]$ ]] \
        && return 0 \
        || return 1
}

ask_for_confirmation() {
    print_question "$1 (y/n) "
    read -n 1
    printf "\n"
}

print_question() {
    # Print output in yellow
    printf "\e[0;33m  [?] $1\e[0m"
}

print_result() {
    [ $1 -eq 0 ] \
        && print_success "$2" \
        || print_error "$2"

    [ "$3" == "true" ] && [ $1 -ne 0 ] \
        && exit
}

print_success() {
    # Print output in green
    printf "\e[0;32m  [✔] $1\e[0m\n"
}


print_error() {
    # Print output in red
    printf "\e[0;31m  [✖] $1 $2\e[0m\n"
}

print_info() {
    # Print output in purple
    printf "\n\e[0;35m $1\e[0m\n\n"
}

main() {

    local i=''
    local sourceFile=''
    local targetFile=''

    for i in ${FILES_TO_SYMLINK[@]}; do

        sourceFile="$(pwd)/$i"
        targetFile="$HOME/.$(printf "%s" "$i" | sed "s/.*\/\(.*\)/\1/g")"

        if [ ! -e "$targetFile" ]; then
            execute "ln -fs $sourceFile $targetFile" "$targetFile → $sourceFile"
        elif [ "$(readlink "$targetFile")" == "$sourceFile" ]; then
            print_success "$targetFile → $sourceFile"
        else
            ask_for_confirmation "'$targetFile' already exists, do you want to overwrite it?"
            if answer_is_yes; then
                rm -rf "$targetFile"
                execute "ln -fs $sourceFile $targetFile" "$targetFile → $sourceFile"
            else
                print_error "$targetFile → $sourceFile"
            fi
        fi

    done

    unset FILES_TO_SYMLINK

}

main

# TODO: Automate the installation of zsh && oh-my-zsh && bullet-train theme.