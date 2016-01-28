#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE}")";

git pull origin master;

function doIt() {

	source installscript.sh;

	rsync --exclude ".git/" --exclude ".DS_Store" --exclude "bootstrap.sh" \
		--exclude "README.md" --exclude "LICENSE" \
		--exclude "installscript.sh" --exclude "osx-set-defaults.sh" -avh --no-perms . ~;
	source ~/.bash_profile;

	read -p "If you want, you can set your OSX too? (y/n) " -n 1;
	echo "";
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		source osx-set-defaults.sh;
	fi;

	echo "";
	echo "You can create your own .extra file for setting personal settings such as GIT credentials."
}

if [ "$1" == "--force" -o "$1" == "-f" ]; then
	doIt;
else
	read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1;
	echo "";
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		doIt;
	fi;
fi;
unset doIt;