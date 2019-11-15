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
setup_computername() {
    COMPUTER_NAME="$(hostname)"
    ask_for_input "What should your computer be named (without spaces)? (default: $COMPUTER_NAME)"
    [ -n "$REPLY" ] && COMPUTER_NAME=$REPLY

    # Set computer name (as done via System Preferences → Sharing)
    sudo scutil --set ComputerName $COMPUTER_NAME
    sudo scutil --set HostName $COMPUTER_NAME
    sudo scutil --set LocalHostName $COMPUTER_NAME
    sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "$computername"

    print_success "Computer name ($COMPUTER_NAME)"
}

setup_apple_id() {
    if [ -n "$(defaults read NSGlobalDomain AppleID 2>&1 | grep -E "( does not exist)$")" ]; then
        APPLE_ID=""
    else
        APPLE_ID="$(defaults read NSGlobalDomain AppleID)"
    fi;
    ask_for_input "What's your Apple ID? (default: $APPLE_ID)"
    [ -n "$REPLY" ] && APPLE_ID=$REPLY

    defaults write NSGlobalDomain AppleID -string $APPLE_ID

    print_success "Apple ID ($APPLE_ID)"
}
setup_loginscreen_message() {
    if [ -n "$(defaults read /Library/Preferences/com.apple.loginwindow LoginwindowText 2>&1 | grep -E "( does not exist)$")" ]; then
        LOGINSCREEN_MESSAGE=""
    else
        LOGINSCREEN_MESSAGE="$(defaults read /Library/Preferences/com.apple.loginwindow LoginwindowText)"
    fi;
    ask_for_input "What should appear on your login screen? (default: $LOGINSCREEN_MESSAGE)"
    [ -n "$REPLY" ] && LOGINSCREEN_MESSAGE=$REPLY
    sudo defaults write /Library/Preferences/com.apple.loginwindow LoginwindowText -string "$LOGINSCREEN_MESSAGE"

    print_success "Loginscreen-message"
}

setup_date_and_time() {
    TIMEZONE="Europe/Brussels"

    sudo /usr/sbin/systemsetup -settimezone "$TIMEZONE" > /dev/null
    sudo /usr/sbin/systemsetup -setnetworktimeserver "time.euro.apple.com" > /dev/null
    sudo /usr/sbin/systemsetup -setusingnetworktime on > /dev/null

    # Set language and text formats
    # Note: if you’re in the US, replace `EUR` with `USD`, `Centimeters` with
    # `Inches`, `nl_BE` with `en_US`, and `true` with `false`.
    defaults write NSGlobalDomain AppleLanguages -array "nl-BE" "en-BE"
    defaults write NSGlobalDomain AppleLocale -string "nl_BE@currency=EUR"
    defaults write NSGlobalDomain AppleMeasurementUnits -string "Centimeters"
    defaults write NSGlobalDomain AppleTemperatureUnit -string "Celsius"
    defaults write NSGlobalDomain AppleMetricUnits -bool true
    defaults write NSGlobalDomain AppleICUForce12HourTime -bool false

    # Set the timezone; see `sudo systemsetup -listtimezones` for other values
    sudo systemsetup -settimezone "$TIMEZONE" > /dev/null

    # Show language menu in the top right corner of the boot screen
    sudo defaults write /Library/Preferences/com.apple.loginwindow showInputMenu -bool true

    print_success "Date, time, language & regio ($TIMEZONE)"
}
setup_screen_and_battery() {
    IS_MACBOOK=`/usr/sbin/system_profiler SPHardwareDataType | grep "Model Identifier" | grep "Book"`
    if [[ "$IS_MACBOOK" != "" ]]; then
        # On charger
        sudo pmset -c sleep 0 disksleep 15 displaysleep 10 halfdim 1 powernap 1
        # On battery
        sudo pmset -b sleep 0 disksleep 10 displaysleep 3 halfdim 1 powernap 0
    else
        pmset sleep 0 disksleep 0 displaysleep 30 halfdim 1
    fi

    # Set standby delay to 24 hours (default is 1 hour)
    sudo pmset -a standbydelay 86400

    # Set computer sleep to 24 hours
    sudo systemsetup -setcomputersleep 86400 > /dev/null

    # Require password immediately after sleep or screen saver begins
    defaults write com.apple.screensaver askForPassword -int 1
    defaults write com.apple.screensaver askForPasswordDelay -int 0

    # Set screensaver to ken burns (with Landscpaes), start after 5 minutes
    defaults -currentHost write com.apple.screensaver moduleDict -dict path -string "/System/Library/Frameworks/ScreenSaver.framework/PlugIns/iLifeSlideshows.appex" moduleName -string "iLifeSlideshows" type -int 0
    defaults -currentHost write com.apple.ScreenSaver.iLifeSlideShows styleKey -string "KenBurns"
    defaults -currentHost write com.apple.screensaver idleTime -int 300

    # Save screenshots to the desktop
    defaults write com.apple.screencapture location -string "${HOME}/Desktop"

    # Save screenshots in JPG format (all options: PNG, BMP, GIF, JPG, PDF, TIFF)
    defaults write com.apple.screencapture type -string "jpg"

    # Disable shadow in screenshots
    defaults write com.apple.screencapture disable-shadow -bool true

    # Enable subpixel font rendering on non-Apple LCDs
    # Reference: https://github.com/kevinSuttle/macOS-Defaults/issues/17#issuecomment-266633501
    defaults write NSGlobalDomain AppleFontSmoothing -int 1

    # Enable HiDPI display modes (requires restart)
    sudo defaults write /Library/Preferences/com.apple.windowserver DisplayResolutionEnabled -bool true

    print_success "Screen saver, screen capture, energy settings"
}
setup_touchbar() {
    # Use the default collapsed touchbar
    defaults delete com.apple.touchbar.agent PresentationModeGlobal

    # Use fn button to show program specific touchbar
    defaults write com.apple.touchbar.agent PresentationModeFnModes -dict fullControlStrip app

    # Configure TouchBar (Mini and Full)
    defaults write com.apple.controlstrip MiniCustomized -array \
        "com.apple.system.brightness" \
        "com.apple.system.volume" \
        "com.apple.system.mute" \
        "com.apple.system.screen-lock"

    defaults write com.apple.controlstrip FullCustomized -array \
        "com.apple.system.show-desktop" \
        "com.apple.system.group.brightness" \
        "com.apple.system.group.keyboard-brightness" \
        "com.apple.system.group.volume" \
        "com.apple.system.screencapture" \
        "com.apple.system.night-shift" \
        "com.apple.system.do-not-disturb" \
        "com.apple.system.workflows" \
        "com.apple.system.screen-lock"

    print_success "MacBook Pro Touchbar"

}

setup_trackpad() {
    # Trackpad: enable tap to click for this user and for the login screen
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
    defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
    defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

    # Trackpad: map bottom right corner to right-click
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 2
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
    defaults -currentHost write NSGlobalDomain com.apple.trackpad.trackpadCornerClickBehavior -int 1
    defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true

    # Enable extra multifinger gestures (such as three finger swipe down = app expose)
    defaults write com.apple.dock showMissionControlGestureEnabled -bool true
    defaults write com.apple.dock showAppExposeGestureEnabled -bool true
    defaults write com.apple.dock showDesktopGestureEnabled -bool true
    defaults write com.apple.dock showLaunchpadGestureEnabled -bool true

    print_success "Trackpad"
}

setup_keyboard_and_mouse() {
    # Two button mouse mode
    defaults write com.apple.AppleMultitouchMouse MouseButtonMode -string TwoButton

    # Set Mouse speed
    # @TODO?

    # Disable “natural” (Lion-style) scrolling
    defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

    # Enable full keyboard access for all controls
    # (e.g. enable Tab in modal dialogs)
    defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

    # Use scroll gesture with the Ctrl (^) modifier key to zoom
    defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool true
    defaults write com.apple.universalaccess HIDScrollZoomModifierMask -int 262144

    # Follow the keyboard focus while zoomed in
    defaults write com.apple.universalaccess closeViewZoomFollowsFocus -bool true

    # Set a keyboard repeat rate
    defaults write NSGlobalDomain KeyRepeat -int 1
    defaults write NSGlobalDomain InitialKeyRepeat -int 30

    # Automatically illuminate built-in MacBook keyboard in low light
    defaults write com.apple.BezelServices kDim -bool true

    # Turn off keyboard illumination when computer is not used for 5 minutes
    defaults write com.apple.BezelServices kDimTime -int 300

    print_success "Keyboard & Mouse"
}

setup_ssd() {
    # Disable hibernation (speeds up entering sleep mode)
    sudo pmset -a hibernatemode 0

    # # Disable the sudden motion sensor (fall detection) as it’s not useful for SSDs
    sudo pmset -a sms 0

    print_success "SSD-tweaks"
}

setup_bluetooth() {
    # Increase sound quality for Bluetooth headphones/headsets
    defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40

    print_success "Bluetooth"
}

setup_dock() {
    # Enable highlight hover effect for the grid view of a stack (Dock)
    defaults write com.apple.dock mouse-over-hilite-stack -bool true

    # Don't auto-hide dock
    defaults write com.apple.dock autohide -bool false

    # Set the icon size of Dock items to 28 pixels
    defaults write com.apple.dock tilesize -int 28

    # Enable magnification
    defaults write com.apple.dock magnification -bool true
    defaults write com.apple.dock largesize -int 52

    # Minimize windows into their application’s icon
    defaults write com.apple.dock minimize-to-application -bool false

    # Enable spring loading for all Dock items
    defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true

    # Show indicator lights for open applications in the Dock
    defaults write com.apple.dock show-process-indicators -bool true

    # Speed up Mission Control animations
    defaults write com.apple.dock expose-animation-duration -float 0.2

    # Don’t animate opening applications from the Dock
    defaults write com.apple.dock launchanim -bool false

    # Don’t show Dashboard as a Space
    defaults write com.apple.dock dashboard-in-overlay -bool true

    # Don’t automatically rearrange Spaces based on most recent use
    defaults write com.apple.dock mru-spaces -bool false

    # Make Dock icons of hidden applications translucent
    defaults write com.apple.dock showhidden -bool true

    print_success "Dock"
}

setup_hot_corners() {
    # Possible values:
    #  0: no-op
    #  2: Mission Control
    #  3: Show application windows
    #  4: Desktop
    #  5: Start screen saver
    #  6: Disable screen saver
    #  7: Dashboard
    # 10: Put display to sleep
    # 11: Launchpad
    # 12: Notification Center

    # Top right screen corner → Show desktop
    defaults write com.apple.dock wvous-tr-corner -int 4
    defaults write com.apple.dock wvous-tr-modifier -int 0
    # Top left screen corner → Start screensaver
    defaults write com.apple.dock wvous-tl-corner -int 5
    defaults write com.apple.dock wvous-tl-modifier -int 0
    # Bottom right screen corner → Show Mission Control
    defaults write com.apple.dock wvous-br-corner -int 2
    defaults write com.apple.dock wvous-br-modifier -int 0
    # Bottom left screen corner → Put Display into sleep
    defaults write com.apple.dock wvous-bl-corner -int 10
    defaults write com.apple.dock wvous-bl-modifier -int 0

    print_success "Hot corners"
}

setup_spotlight() {
    # Change indexing order and disable some search results
    # Yosemite-specific search results (remove them if you are using macOS 10.9 or older):
    # 	MENU_DEFINITION
    # 	MENU_CONVERSION
    # 	MENU_EXPRESSION
    # 	MENU_SPOTLIGHT_SUGGESTIONS (send search queries to Apple)
    # 	MENU_WEBSEARCH             (send search queries to Apple)
    # 	MENU_OTHER
    defaults write com.apple.spotlight orderedItems -array \
        '{"enabled" = 1;"name" = "APPLICATIONS";}' \
        '{"enabled" = 1;"name" = "SYSTEM_PREFS";}' \
        '{"enabled" = 1;"name" = "DIRECTORIES";}' \
        '{"enabled" = 1;"name" = "PDF";}' \
        '{"enabled" = 0;"name" = "FONTS";}' \
        '{"enabled" = 1;"name" = "DOCUMENTS";}' \
        '{"enabled" = 0;"name" = "MESSAGES";}' \
        '{"enabled" = 1;"name" = "CONTACT";}' \
        '{"enabled" = 0;"name" = "EVENT_TODO";}' \
        '{"enabled" = 0;"name" = "IMAGES";}' \
        '{"enabled" = 0;"name" = "BOOKMARKS";}' \
        '{"enabled" = 0;"name" = "MUSIC";}' \
        '{"enabled" = 0;"name" = "MOVIES";}' \
        '{"enabled" = 0;"name" = "PRESENTATIONS";}' \
        '{"enabled" = 0;"name" = "SPREADSHEETS";}' \
        '{"enabled" = 0;"name" = "SOURCE";}' \
        '{"enabled" = 0;"name" = "MENU_DEFINITION";}' \
        '{"enabled" = 0;"name" = "MENU_OTHER";}' \
        '{"enabled" = 1;"name" = "MENU_CONVERSION";}' \
        '{"enabled" = 1;"name" = "MENU_EXPRESSION";}' \
        '{"enabled" = 0;"name" = "MENU_WEBSEARCH";}' \
        '{"enabled" = 0;"name" = "MENU_SPOTLIGHT_SUGGESTIONS";}'

    # Load new settings before rebuilding the index
    killall mds > /dev/null 2>&1

    # Make sure indexing is enabled for the main volume
    sudo mdutil -i on / > /dev/null

    # Rebuild the index from scratch
    sudo mdutil -E / > /dev/null

    print_success "Spotlight"
}

setup_desktop() {
    # Show specific desktop icons
    defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
    defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
    defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
    defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

    # Show item info near icons on the desktop and in other icon views
    /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist
    /usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist
    /usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist

    # Show item info to the right of the icons on the desktop
    /usr/libexec/PlistBuddy -c "Set DesktopViewSettings:IconViewSettings:labelOnBottom true" ~/Library/Preferences/com.apple.finder.plist

    # Enable snap-to-grid for icons on the desktop and in other icon views and sort on creation date
    /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy dateCreated" ~/Library/Preferences/com.apple.finder.plist
    /usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy dateCreated" ~/Library/Preferences/com.apple.finder.plist
    /usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy dateCreated" ~/Library/Preferences/com.apple.finder.plist

    # Set grid spacing for icons on the desktop and in other icon views
    /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:gridSpacing 60" ~/Library/Preferences/com.apple.finder.plist
    /usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:gridSpacing 60" ~/Library/Preferences/com.apple.finder.plist
    /usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:gridSpacing 60" ~/Library/Preferences/com.apple.finder.plist

    # Set the size of icons on the desktop and in other icon views
    /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:iconSize 36" ~/Library/Preferences/com.apple.finder.plist
    /usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:iconSize 36" ~/Library/Preferences/com.apple.finder.plist
    /usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:iconSize 36" ~/Library/Preferences/com.apple.finder.plist

    print_success "Desktop"
}

setup_menubar() {
    # Menu bar: hide things first, to include them in the next script
    defaults write ~/Library/Preferences/ByHost/com.apple.systemuiserver dontAutoLoad -array \
        "/System/Library/CoreServices/Menu Extras/Bluetooth.menu" \
        "/System/Library/CoreServices/Menu Extras/Eject.menu" \
        "/System/Library/CoreServices/Menu Extras/ExpressCard.menu" \
        "/System/Library/CoreServices/Menu Extras/Ink.menu" \
        "/System/Library/CoreServices/Menu Extras/IrDA.menu" \
        "/System/Library/CoreServices/Menu Extras/PPP.menu" \
        "/System/Library/CoreServices/Menu Extras/PPPoE.menu" \
        "/System/Library/CoreServices/Menu Extras/Script Menu.menu" \
        "/System/Library/CoreServices/Menu Extras/UniversalAccess.menu" \
        "/System/Library/CoreServices/Menu Extras/VPN.menu" \
        "/System/Library/CoreServices/Menu Extras/WWAN.menu" \
        "/System/Library/CoreServices/Menu Extras/PPP.menu" \
        "/System/Library/CoreServices/Menu Extras/iChat.menu"

    defaults write com.apple.systemuiserver menuExtras -array \
        "/System/Library/CoreServices/Menu Extras/AirPort.menu" \
        "/System/Library/CoreServices/Menu Extras/Battery.menu" \
        "/System/Library/CoreServices/Menu Extras/Displays.menu" \
        "/System/Library/CoreServices/Menu Extras/Volume.menu" \
        "/System/Library/CoreServices/Menu Extras/TextInput.menu" \
        "/System/Library/CoreServices/Menu Extras/User.menu" \
        "/System/Library/CoreServices/Menu Extras/Clock.menu" \
        "/System/Library/CoreServices/Menu Extras/RemoteDesktop.menu" \
        "/System/Library/CoreServices/Menu Extras/TimeMachine.menu"

    # Show battery percentage
    defaults write com.apple.menuextra.battery ShowPercent -bool true

    print_success "Menu Bar"
}

setup_external_volumes() {
    # Show the /Volumes folder
    chflags nohidden /Volumes

    # Automatically open a new Finder window when a volume is mounted
    defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
    defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
    defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true

    # Avoid creating .DS_Store files on network or USB volumes
    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
    defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

    print_success "External Volumes"
}

setup_animations() {
    # Enable spring loading for directories (dragging into other folder and that folder will open)
    defaults write NSGlobalDomain com.apple.springing.enabled -bool true

    # Set small spring loading delay for directories
    defaults write NSGlobalDomain com.apple.springing.delay -float 0.5

    # Scrollbars behavior
    # Possible values: `WhenScrolling`, `Automatic` and `Always`
    defaults write NSGlobalDomain AppleShowScrollBars -string "WhenScrolling"

    print_success "Animations"
}

disable_notification_center() {
    # Disable Notification Center and remove the menu bar icon
    launchctl unload -w /System/Library/LaunchAgents/com.apple.notificationcenterui.plist 2> /dev/null

    print_success "Notification Center disabled"
}

disable_siri() {
    # Disable Siri and remove the menu bar icon
    launchctl unload -w /System/Library/LaunchAgents/com.apple.Siri.plist 2> /dev/null

    print_success "Siri disabled"
}

setup_panels() {
    # Expand the following File Info panes:
    # “General”, “Open with”, and “Sharing & Permissions”
    defaults write com.apple.finder FXInfoPanesExpanded -dict \
        General -bool true \
        OpenWith -bool true \
        Privileges -bool true

    # Expand save panel by default
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

    # Expand print panel by default
    defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
    defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

    # Automatically quit printer app once the print jobs complete
    defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

    print_success "Panels"
}

setup_spelling() {
    # Disable automatic capitalization as it’s annoying when typing code
    # @TODO automatic capitalization
    #defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

    # Disable smart dashes as they’re annoying when typing code
    defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

    # Disable automatic period substitution as it’s annoying when typing code
    defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

    # Disable smart quotes as they’re annoying when typing code
    defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

    # Disable auto-correct
    defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

    print_success "Spelling"
}

setup_save_preferences() {
    # Save to disk (not to iCloud) by default
    defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

    print_success "Save preferences"
}

setup_airdrop() {
    # Enable AirDrop over Ethernet and on unsupported Macs running Lion
    defaults write com.apple.NetworkBrowser BrowseAllInterfaces -bool true

    print_success "Airdrop"
}

setup_error_control() {
    # Restart automatically if the computer freezes
    sudo systemsetup -setrestartfreeze on

    print_success "Error control (restart when freeze)"
}

system_cleanup() {
    # Remove duplicates in the “Open With” menu (also see `lscleanup` alias)
    /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user

    print_success "System cleanup"
}

disable_dashboard() {
    defaults write com.apple.dashboard mcx-disabled -bool true

    print_success "Dashboard disabled"
}


###############################################
# Main for Mac OS setup
###############################################
main() {

    quit_system_preferences
    system_cleanup

    setup_computername
    setup_apple_id
    setup_loginscreen_message

    setup_date_and_time
    setup_spelling
    setup_screen_and_battery

    setup_touchbar
    setup_trackpad
    setup_keyboard_and_mouse
    setup_ssd
    setup_bluetooth
    setup_external_volumes

    setup_dock
    setup_hot_corners
    setup_desktop
    setup_menubar
    setup_spotlight
    setup_panels

    setup_animations

    disable_notification_center
    disable_siri
    disable_dashboard

    setup_save_preferences
    setup_airdrop

    setup_error_control

    ask_for_reboot
}

main $1