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