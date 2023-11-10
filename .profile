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
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

SSH_AUTH_SOCK=$HOME/.local/ssh-agent ssh-add -l 2>/dev/null >&2
if [ "$?" = "2" ]; then
    rm $HOME/.local/ssh-agent 2>/dev/null >&2;
    # startup ssh-agent for emacs continers
    ssh-agent -a $HOME/.local/ssh-agent
    SSH_AUTH_SOCK=$HOME/.local/ssh-agent ssh-add 2>/dev/null
fi


if [ -z "$SSH_AUTH_SOCK" ]; then
    export SSH_AUTH_SOCK;
    export SSH_AGENT_PID;
fi

export FILE="nnn"
export EDITOR="vim"
export BROWSER="google-chrome"
export SUDO_ASKPASS="$HOME/.local/bin/dmenupass"
