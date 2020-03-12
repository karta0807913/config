# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.scripts:$PATH"

export GOROOT="$HOME/.local/go"
export TERMINAL="/usr/bin/gnome-terminal"
export BROWSER="/usr/lib/chromium-browser/chromium-browser"
export FILE="nnn"
export EDITOR="vim"
sudo -n loadkeys ~/.scripts/ttymaps.kmap 2>/dev/null
xmodmap ~/.scripts/xmaps.map > /dev/null 2>&1
xrandr --output HDMI-0 --mode 2560x1080
feh --bg-max --random ~/.wallpaper/

