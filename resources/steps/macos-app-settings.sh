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
    && . "../utils.sh" \
    && . "../utils-macos.sh"


###############################################
# Functions
###############################################
quit_system_preferences() {
    execute \
        "osascript -e 'tell application \"System Preferences\" to quit'" \
        "Quit System preferences pane"
}

macos_backupped_settings() {
    # All the settings in this file are already in backupped through mackup
    # But image I lost my backupped settings, I can recover the most
    # important one by executing this.
    execute \
        "source \"$MAIN_DIR/resources/configs/macos-applicationconfigs.sh\"" \
        "Mac OS backupped application settings (through Mackup)"
}

setup_finder() {
    # Finder: allow quitting via ⌘ + Q; doing so will also hide desktop icons
    defaults write com.apple.finder QuitMenuItem -bool true

    # Finder: disable window animations and Get Info animations
    defaults write com.apple.finder DisableAllAnimations -bool true

    # Set Desktop as the default location for new Finder windows
    # For other paths, use `PfLo` and `file:///full/path/here/`
    defaults write com.apple.finder NewWindowTarget -string "PfDe"
    defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/Desktop/"

    # Finder showX settings
    defaults write com.apple.finder ShowRecentTags -bool false
    defaults write com.apple.finder ShowSidebar -bool true
    defaults write com.apple.finder ShowStatusBar -bool true
    defaults write com.apple.finder ShowTabView -bool true
    defaults write com.apple.finder ShowPreviewPane -bool false
    defaults write com.apple.finder ShowPathbar -bool false

    # Finder: show hidden files by default
    defaults write com.apple.finder AppleShowAllFiles -bool true

    # Finder: show all filename extensions
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true

    # Display full POSIX path as Finder window title
    defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

    # Keep folders on top when sorting by name
    defaults write com.apple.finder _FXSortFoldersFirst -bool true

    # When performing a search, search the current folder by default
    defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

    # Disable the warning when changing a file extension
    defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

    # Use column view in all Finder windows by default
    # Four-letter codes for the other view modes: `icnv`, `clmv`, `Flwv`
    defaults write com.apple.finder FXPreferredViewStyle -string "clmv"

    # Disable the warning before emptying the Trash
    defaults write com.apple.finder WarnOnEmptyTrash -bool false

    # Empty Trash securely by default
    defaults write com.apple.finder EmptyTrashSecurely -bool true

    # Show the ~/Library folder
    chflags nohidden ~/Library

    # Set sidebar icon size to small
    defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 1

    print_success "Finder"
}

setup_app_security() {
    declare -r STATUS=true

    # “Are you sure you want to open this application?” dialog
    defaults write com.apple.LaunchServices LSQuarantine -bool $STATUS

    if $STATUS == true; then
        MESSAGE="enabled"
    else
        MESSAGE="disabled"
    fi;

    print_success "App Security ($MESSAGE)"
}

setup_safari() {
    # Privacy: don’t send search queries to Apple
    defaults write com.apple.Safari UniversalSearchEnabled -bool false
    defaults write com.apple.Safari SuppressSearchSuggestions -bool true

    # Press Tab to highlight each item on a web page
    defaults write com.apple.Safari WebKitTabToLinksPreferenceKey -bool true
    defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2TabsToLinks -bool true

    # Show the full URL in the address bar (note: this still hides the scheme)
    defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true

    # Set Safari’s home page to `about:blank` for faster loading
    defaults write com.apple.Safari HomePage -string "about:blank"

    # Prevent Safari from opening ‘safe’ files automatically after downloading
    defaults write com.apple.Safari AutoOpenSafeDownloads -bool false

    # Show Safari’s bookmarks bar by default
    defaults write com.apple.Safari ShowFavoritesBar -bool true

    # Show Safari’s sidebar in Top Sites
    defaults write com.apple.Safari ShowSidebarInTopSites -bool true

    # Enable Safari’s debug menu
    defaults write com.apple.Safari IncludeInternalDebugMenu -bool true

    # Make Safari’s search banners default to Contains instead of Starts With
    defaults write com.apple.Safari FindOnPageMatchesWordStartsOnly -bool false

    # Remove useless icons from Safari’s bookmarks bar
    defaults write com.apple.Safari ProxiesInBookmarksBar "()"

    # Enable the Develop menu and the Web Inspector in Safari
    defaults write com.apple.Safari IncludeDevelopMenu -bool true
    defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
    defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true

    # Add a context menu item for showing the Web Inspector in web views
    defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

    # Enable continuous spellchecking
    defaults write com.apple.Safari WebContinuousSpellCheckingEnabled -bool true
    # Disable auto-correct
    defaults write com.apple.Safari WebAutomaticSpellingCorrectionEnabled -bool false

    # Warn about fraudulent websites
    defaults write com.apple.Safari WarnAboutFraudulentWebsites -bool true

    # Disable plug-ins
    defaults write com.apple.Safari WebKitPluginsEnabled -bool false
    defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2PluginsEnabled -bool false

    # Disable Java
    defaults write com.apple.Safari WebKitJavaEnabled -bool false
    defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabled -bool false

    # Block pop-up windows
    defaults write com.apple.Safari WebKitJavaScriptCanOpenWindowsAutomatically -bool false
    defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaScriptCanOpenWindowsAutomatically -bool false

    # Enable “Do Not Track”
    defaults write com.apple.Safari SendDoNotTrackHTTPHeader -bool true

    # Update extensions automatically
    defaults write com.apple.Safari InstallExtensionUpdatesAutomatically -bool true

    # Restore last session after quit
    defaults write com.apple.Safari NSQuitAlwaysKeepsWindows -bool true

    print_success "Safari"
}

setup_activity_monitor() {
    # Show the main window when launching Activity Monitor
    defaults write com.apple.ActivityMonitor OpenMainWindow -bool true

    # Visualize CPU usage in the Activity Monitor Dock icon
    defaults write com.apple.ActivityMonitor IconType -int 5

    # Show all processes in Activity Monitor
    defaults write com.apple.ActivityMonitor ShowCategory -int 0

    # Sort Activity Monitor results by CPU usage
    defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
    defaults write com.apple.ActivityMonitor SortDirection -int 0

    # Show Data in the Disk graph (instead of IO)
    defaults write com.apple.ActivityMonitor DiskGraphType -int 1

    # Show Data in the Network graph (instead of packets)
    defaults write com.apple.ActivityMonitor NetworkGraphType -int 1

    print_success "Activity Monitor"
}

setup_photos() {
    # Prevent Photos from opening automatically when devices are plugged in
    defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

    print_success "Photos"
}

setup_textedit() {
    # Use plain text mode for new TextEdit documents
    defaults write com.apple.TextEdit RichText -int 0

    # Open and save files as UTF-8 in TextEdit
    defaults write com.apple.TextEdit PlainTextEncoding -int 4
    defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4

    print_success "TextEdit"
}

setup_mail() {
    # Copy email addresses as `foo@example.com` instead of `Foo Bar <foo@example.com>` in Mail.app
    defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false

    # Disable inline attachments (just show the icons)
    defaults write com.apple.mail DisableInlineAttachmentViewing -bool true

    print_success "Mail"
}

setup_quicktime() {
    # Auto-play videos when opened with QuickTime Player
    defaults write com.apple.QuickTimePlayerX MGPlayMovieOnOpen -bool true

    print_success "Quicktime"
}

setup_diskutility() {
    # Enable the debug menu in Disk Utility
    defaults write com.apple.DiskUtility DUDebugMenuEnabled -bool true
    defaults write com.apple.DiskUtility advanced-image-options -bool true

    print_success "Disk Utility"
}

setup_appstore() {
    # Enable the automatic update check
    defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true

    # Check for software updates daily, not just once per week
    defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

    # Download newly available updates in background
    defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1

    # Install System data files & security updates
    defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1

    # Don't Automatically download apps purchased on other Macs
    defaults write com.apple.SoftwareUpdate ConfigDataInstall -int 0

    # Turn off app auto-update
    defaults write com.apple.commerce AutoUpdate -bool false

    print_success "App Store"
}

restore_mackup_backupfiles() {
    mackup restore

    print_success "Mackup (restore)"
}

###############################################
# Main for Mac OS script
###############################################
main() {
    quit_system_preferences

    macos_backupped_settings
    setup_app_security

    setup_appstore
    setup_finder
    setup_safari
    setup_activity_monitor
    setup_photos
    setup_textedit
    setup_mail
    setup_quicktime

    restore_mackup_backupfiles

    ask_for_reboot
}

main $1
