#################################
# Core brew stuff
#################################

tap "homebrew/bundle"
tap "homebrew/cask"
tap "homebrew/core"
tap "homebrew/services"


#################################
# Development
#################################

brew "composer"
brew "dnsmasq", restart_service: true
brew "gh"
brew "git"
brew "httpie"
brew "mysql@5.7", restart_service: true, link: true
brew "nginx", restart_service: true
brew "php", link: true
brew "pkg-config"
brew "redis", restart_service: true
brew "wget"
brew "yarn"


#################################
# Image & Video
#################################
brew "libvpx"
brew "youtube-dl"
brew "imagemagick"
brew "ffmpeg"


#################################
# Mac Store Applications
#################################
tap "mas-cli/tap", pin: true
brew "mas-cli/tap/mas"

mas "Keynote", id: 409183694
mas "Numbers", id: 409203825
mas "Pages", id: 409201541
mas "Slack", id: 803453959
mas "Spark", id: 1176895641
mas "The Unarchiver", id: 425424353
mas "WhatsApp", id: 1147396723
mas "Wunderlist", id: 410628904
mas "Xcode", id: 497799835


#################################
# OSX Applications
#################################
cask_args appdir: "/Applications"

cask "adobe-acrobat-reader"
cask "caffeine"
cask "cyberduck"
cask "dropbox"
cask "docker"
cask "firefox"
cask "gas-mask"
cask "google-chrome"
cask "handbrake"
cask "insomnia"
cask "iterm2"
cask "jumpcut"
cask "kitematic"
cask "libreoffice"
cask "libreoffice-language-pack"
cask "microsoft-teams"
cask "mysqlworkbench"
cask "imageoptim"
cask "phpstorm"
cask "poedit"
cask "postman"
cask "pref-setter"
cask "pycharm-ce"
cask "raspberry-pi-imager"
cask "sdformatter"
cask "sequel-pro"
cask "skype"
cask "sonos"
cask "sourcetree"
cask "spectacle"
cask "steam"
cask "sublime-text"
cask "tableplus"
cask "timemachineeditor"
cask "transmission"
cask "tunnelblick"
cask "virtualbox"
cask "visual-studio-code"
cask "vlc"

tap "homebrew/cask-eid"
cask "eid-be"
cask "eid-be-viewer"


#################################
# OSX Quicklook improvement
#################################
cask "qlstephen"
cask "qlcolorcode"
cask "qlmarkdown"
cask "quicklook-json"
cask "qlprettypatch"
cask "quicklook-csv"
cask "betterzip"
cask "webpquicklook"
cask "suspicious-package"


#################################
# Drivers (+ apps)
#################################
tap "homebrew/cask-drivers"
cask "ubiquiti-unifi-controller"


#################################
# ZSH
#################################
brew "zsh"
brew "zsh-completions"
brew "zsh-autosuggestions"
brew "zsh-syntax-highlighting"
tap "sambadevi/powerlevel9k"
brew "powerlevel9k"
cask "font-hack-nerd-font"


#################################
# Macport (preferences sync)
#################################
brew "mackup"
