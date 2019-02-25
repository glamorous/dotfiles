Personal .dotfiles and installer script
========================================

This repo contains my personal dotfiles and setup script for my computer(s) based on MacOS. You are free to use them but understand that those are my **personal preferences**. You can always fork my repository and create your own dotfiles.

This repo is used for mostly new installations but can be used to setup you computer again.

You can execute the script with the following command, it will destroy itself if its ready (probably, so if you don't press restart computer and "clean" exit):

    mkdir dotfiles_installation && cd dotfiles_installation && curl -#L https://github.com/glamorous/dotfiles/archive/master.zip | tar -xzv --strip-components 1 && chmod +x bootstrap.sh && ./bootstrap.sh && cd .. && rm -rf dotfiles_installation

You can also start the script by downloading the code and going to the dotfiles directory and execute this command:

	chmod +x bootstrap.sh && ./bootstrap.sh

*When a question is asked and a default is given, you can just hit `enter` to accept the default.*

Requirements
------------
- Sign in, in the Mac App Store! (to download applications through Brew)


What to expect after finishing?
--------------------------------
- Fresh installed OSX with custom settings for your dock, finder, ...
- Development machine: Git, PHP-versions, MySQL, Nginx, ...
- Default applications installed through Brew (App store and not-app store) ([Brew bundle](https://github.com/Homebrew/homebrew-bundle#usage))
- Settings backup (through iCloud) for some applications ([Mackup](https://github.com/lra/mackup))
- Some default composer global packages (Laravel Valet, Envoy, ...)


Credits
--------

The creation of this dotfiles wasn't possible without these resources:

- [Setting Up a Mac Dev Machine From Zero to Hero With Dotfiles](http://code.tutsplus.com/tutorials/setting-up-a-mac-dev-machine-from-zero-to-hero-with-dotfiles--net-35449) by Simon Owen
- [dotfiles Freek Murze](https://github.com/freekmurze/dotfiles)
- [dotfiles Mathias Bynens](https://github.com/mathiasbynens/dotfiles)
- [ASCI generator (Ansi Shadow)](http://patorjk.com/software/taag/#p=display&h=0&v=0&f=ANSI%20Shadow)
- [Touchbar-configuration](https://blog.eriknicolasgomez.com/2016/11/28/managing-or-setting-the-mini-touchbar-control-strip/)
- [dotdiles Alrra](https://github.com/alrra/dotfiles)


Instuctions
------------

when a default is given and you don't want to change something: just press enter


Best Practices
---------------
1. After installation create a project with this repo and check for updates when you try to re-use it.
2. Set FileVault to encrypt hard disk
3. Allow guest account for "Find My Mac"
4. Set `full write access` for Terminal & iTerm2 in OSX system preferences (Privacy)


To consider
-----------
- Test mouse speed
- Automatic capitalizatio (disable?)
- Quarantain-check `Are you sure?` (disable?)


To Do
------
- Set scaled screen size to everything is looking a bit smaller
- Finder Sidebar items
- Default applications in dock
- TimeMachineEditor config
- Attach file extensions to applications (for example `.pdf`)
- Delete alias for show/hide files (it's included in om-my-zsh plugins)
- Sudo check if password is correct inserted and abort script if it doesn't
- PHP ini files
- Nginx config files
- Add an extra step with a list of best practises
