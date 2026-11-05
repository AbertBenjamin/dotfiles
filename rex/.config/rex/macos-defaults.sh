#!/usr/bin/env bash
# Rex app settings (Settings… in the GUI) live in macOS defaults, not init.lua.
# Run once on a new machine with Rex quit, so the app doesn't overwrite them.
# To capture a new setting: defaults read com.superlogical.rex | grep Workspace

set -euo pipefail

if pgrep -xq "Rex"; then
    echo "Quit Rex first, it overwrites these on exit."
    exit 1
fi

d() { defaults write com.superlogical.rex "Workspace.$1" "-$2" "$3"; }

# layout
d paneDensity                string compact
d showsPaneHeaders           bool   false
d showsActivePaneBorder      bool   false
d inactivePaneFadeMode       string both
d animationStyle             string off
d tabIconTintMode            string off

# terminal
d terminalPaddingX           float  5
d terminalPaddingY           float  0
d terminalPaddingColor       string extend
d terminalAllowsLigatures    bool   false

# theme
d interfaceStyle             string blendTheme
d darkThemeID                string merino-dark
d lightThemeID               string merino-light

echo "Rex settings written. Start Rex to use them."
