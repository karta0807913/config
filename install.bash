#!/bin/bash

if [ "$(uname -m)" != "x86_64" ]; then
    echo "this script only support x86_64 :<"
    exit 1
fi

if ! lsb_release --id | grep "Ubuntu" > /dev/null; then
    echo "this script only support ubuntu :<"
    exit 1
fi

sudo apt update
sudo apt install -y software-properties-common

if ! which podman > /dev/null 2>/dev/null ; then
    set -e
    . /etc/os-release
    echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_${VERSION_ID}/ /" | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
    curl -L "https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_${VERSION_ID}/Release.key" | sudo apt-key add -
    sudo apt-get update
    sudo apt-get -y upgrade
    sudo apt-get -y install podman
    set +e
fi

if ! podman network inspect podman >/dev/null 2>/dev/null; then
    podman create network podman
fi

sudo add-apt-repository -y ppa:kelleyk/emacs
sudo add-apt-repository -y ppa:kgilmer/speed-ricer
curl https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb > /tmp/chrome.deb
sudo apt update
sudo apt install -y i3-gaps-wm i3blocks feh compton maim htop /tmp/chrome.deb emacs27 font-manager playerctl polybar rofi python3-pip numlockx xclip polybar ibus-chewing dunst i3lock vim

sudo ln -f "$(which python3)" "$(dirname $(which python3))/python"

pip3 install dbus-python

git clone --depth 1 https://github.com/karta0807913/config.git /tmp/config
cd /tmp/config
git submodule init
git submodule update
cp -R .vimrc .bashrc .vim .local .config .profile .Xmodmap .xprofile .xinputrc ~/
mkdir .local/wallpaper
cd -

echo ":VundleInstall" | vim

git clone https://github.com/karta0807913/emacs.d.git ~/.emacs.d
cp ~/.emacs.d/.custom.el ~/

if [ -f "/tmp/CascadiaCode.zip" ]; then
    curl -L https://github.com/microsoft/cascadia-code/releases/download/v2009.22/CascadiaCode-2009.22.zip > /tmp/CascadiaCode.zip
fi
cd /tmp
unzip -u CascadiaCode.zip
cd -

# set font and gnome terminal theme
font-manager -i /tmp/ttf/CascadiaCode.ttf
fc-cache -f -v
dconf load /org/gnome/terminal/legacy/profiles:/ < /tmp/config/gnome-terminal-profiles.dconf
# hide menubar
gsettings set org.gnome.Terminal.Legacy.Settings default-show-menubar false

# add i3 configure
cat<<EOF | sudo tee /usr/share/xsessions/i3.desktop
[Desktop Entry]
Name=i3
Comment=improved dynamic tiling window manager
Exec=i3
TryExec=i3
Type=Application
X-LightDM-DesktopName=i3
DesktopNames=i3
Keywords=tiling;wm;windowmanager;window;manager;
EOF

echo "install finish, please login again"
