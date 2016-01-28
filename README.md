#dotfiles
==========

This repo is for my personal dotfiles. You are free to use them but understand that those are my personal preferences. You can always fork my repository and create your own dotfiles.

This repo is used for mostly new installations.

You can start the script going to the dotfiles directory and do this command:

    ./bootstrap
    
## Your personal settings

If ~/.extra exists, it will be sourced along with the other files. This must be used to store GIT-credentials, adding things to your $PATH (sensitive info) or overwrite stuff for that specific install

My ~/.extra looks something like this:

    GIT_AUTHOR_NAME="Jonas De Smet"
    GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
    git config --global user.name "$GIT_AUTHOR_NAME"
    GIT_AUTHOR_EMAIL="jonas@glamorous.be"
    GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"
    git config --global user.email "$GIT_AUTHOR_EMAIL"


##Credits

The creation of this dotfiles wasn't possible without these resources:

- [Setting Up a Mac Dev Machine From Zero to Hero With Dotfiles](http://code.tutsplus.com/tutorials/setting-up-a-mac-dev-machine-from-zero-to-hero-with-dotfiles--net-35449) by Simon Owen
- [dotfiles Freek Murze](https://github.com/freekmurze/dotfiles)
- [dotfiles Mathias Bynens](https://github.com/mathiasbynens/dotfiles)



