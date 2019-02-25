#!/usr/bin/env bash

quit_system_preferences() {
    execute \
        "osascript -e 'tell application \"System Preferences\" to quit'" \
        "Quit System preferences pane"
}
