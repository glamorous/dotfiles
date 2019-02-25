# Add `~/bin` to the `$PATH`
export PATH="$HOME/bin:$PATH";

# Load the shell dotfiles, and then some:
# * ~/.extra can be used for other settings you don’t want to commit such as git credentials or extending `$PATH`.
for file in ~/.{exports,aliases,extra,functions,path}; do
	[ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;
