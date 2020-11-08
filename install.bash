#!/bin/bash

if [ "$(uname -m)" != "x86_64" ]; then
    echo "this script only support x86_64 :<"
    exit 1
fi

if ! lsb_release --id | grep "Ubuntu" > /dev/null; then
    echo "this script only support ubuntu :<"
    exit 1
fi

if ! which docker > /dev/null ; then
    set -e
    # install docker
    sudo apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg-agent \
        software-properties-common

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository \
        "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) \
        stable"
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
    set +e
fi

if ! groups | grep "docker" > /dev/null; then
    if ! sudo adduser "$USER" "docker"; then
        echo "user $USER join group docker failed :<"
    fi
fi

# check notification daemon exists
if ! gdbus call --session --dest org.freedesktop.DBus --object-path /org/freedesktop/Dbus --method org.freedesktop.DBus.ListNames | grep "org.freedesktop.Notifications" > /dev/null; then
    # install dunst
    set -e
    git clone https://github.com/dunst-project/dunst /tmp/dunst
    cd /tmp/dunst
    make
    sudo make install
    cd -
fi

sudo add-apt-repository -y ppa:kelleyk/emacs
sudo add-apt-repository -y ppa:kgilmer/speed-ricer
curl https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb > /tmp/chrome.deb
sudo apt install -y i3-gaps-wm i3blocks feh compton maim htop /tmp/chrome.deb gcc emacs27

git clone https://github.com/karta0807913/config.git /tmp/config
cd /tmp/config/.local/bin/statusbar/
gcc cpu_usage2.c -o cpu_usage2
cd -
cd /tmp/config
git submodule init
git submodule update
cp -R .vimrc .bashrc .vim .local .config .profile ~/
cd -

echo ":VundleInstall" | vim

git clone https://github.com/karta0807913/emacs.d.git ~/.emacs.d
cp ~/.emacs.d/.custom.el ~/

echo "install finish, please login again"
