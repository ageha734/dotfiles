#!/bin/bash

set -eufo pipefail

# ═══════════════════════════════════════════════════════════════
# macOS defaults — current machine settings
# ═══════════════════════════════════════════════════════════════

osascript -e 'tell application "System Preferences" to quit' 2>/dev/null || true

# ── Timezone ──────────────────────────────────────────────────
sudo systemsetup -settimezone Asia/Tokyo 2>/dev/null || true

# ── System Preferences ────────────────────────────────────────
defaults write com.apple.systempreferences NSQuitAlwaysKeepsWindows -bool false

# ── Desktop Services ──────────────────────────────────────────
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# ── Dock ──────────────────────────────────────────────────────
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock "autohide-delay" -float 0
defaults write com.apple.dock "autohide-time-modifier" -float 0
defaults write com.apple.dock "expose-group-apps" -bool true
defaults write com.apple.dock launchanim -bool false
defaults write com.apple.dock magnification -bool true
defaults write com.apple.dock mineffect -string scale
defaults write com.apple.dock "minimize-to-application" -bool true
defaults write com.apple.dock orientation -string right
defaults write com.apple.dock "show-process-indicators" -bool false
defaults write com.apple.dock "show-recents" -bool false
defaults write com.apple.dock showDesktopGestureEnabled -bool false
defaults write com.apple.dock showLaunchpadGestureEnabled -bool false
defaults write com.apple.dock showMissionControlGestureEnabled -bool false
defaults write com.apple.dock "springboard-columns" -int 12
defaults write com.apple.dock "springboard-rows" -int 8
defaults write com.apple.dock tilesize -int 36
defaults write com.apple.dock "wvous-br-corner" -int 14
killall Dock 2>/dev/null || true

# ── Launch Services ───────────────────────────────────────────
defaults write com.apple.LaunchServices LSQuarantine -bool false

# ── Finder ────────────────────────────────────────────────────
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write com.apple.finder CreateDesktop -bool false
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
defaults write com.apple.finder NewWindowTarget -string "PfDo"
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowRecentTags -bool false
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true
defaults write com.apple.finder ShowSidebar -bool true
defaults write com.apple.finder ShowStatusBar -bool false
defaults write com.apple.finder ShowTabView -bool true
defaults write com.apple.finder WarnOnEmptyTrash -bool false
defaults write com.apple.finder "_FXShowPosixPathInTitle" -bool true
defaults write com.apple.finder "_FXSortFoldersFirst" -bool true
defaults write com.apple.finder "_FXSortFoldersFirstOnDesktop" -bool false
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false
killall Finder 2>/dev/null || true

# ── Keyboard ──────────────────────────────────────────────────
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write -g ApplePressAndHoldEnabled -bool false

# ── Mouse & Trackpad ─────────────────────────────────────────
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool false
defaults write com.apple.AppleMultitouchTrackpad Dragging -bool false
defaults write com.apple.AppleMultitouchTrackpad DragLock -bool false
defaults write com.apple.AppleMultitouchTrackpad TrackpadHorizScroll -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadMomentumScroll -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadPinch -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadRightClick -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadRotate -bool false
defaults write com.apple.AppleMultitouchTrackpad TrackpadScroll -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool false
defaults write com.apple.AppleMultitouchTrackpad TrackpadTwoFingerDoubleTapGesture -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadTwoFingerFromRightEdgeSwipeGesture -bool false
defaults write com.apple.AppleMultitouchTrackpad TrackpadFiveFingerPinchGesture -int 0
defaults write com.apple.AppleMultitouchTrackpad TrackpadFourFingerPinchGesture -int 0
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerHorizSwipeGesture -int 0
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerVertSwipeGesture -int 0

# ── Screenshots ───────────────────────────────────────────────
defaults write com.apple.screencapture location -string "$HOME/Pictures/Screenshots"
defaults write com.apple.screencapture type -string "png"
defaults write com.apple.screencapture "disable-shadow" -bool true
defaults write com.apple.screencapture "show-thumbnail" -bool false

# ── Misc ──────────────────────────────────────────────────────
sudo nvram StartupMute=%01 2>/dev/null || true
defaults write com.apple.CrashReporter DialogType none
defaults write -g AppleShowScrollBars -string Always

# ── Default Browser ───────────────────────────────────────────
open -a "Arc" --args --make-default-browser 2>/dev/null || true

echo "✓ macOS defaults applied"
