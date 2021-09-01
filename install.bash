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

podman rm -f picom || echo "no picon found"

podman run --name picom ubuntu:20.04 bash -c "
apt-get update;
DEBIAN_FRONTEND=noninteractive apt-get install -y git libxext-dev libxcb1-dev libxcb-damage0-dev libxcb-xfixes0-dev libxcb-shape0-dev libxcb-render-util0-dev libxcb-render0-dev libxcb-randr0-dev libxcb-composite0-dev libxcb-image0-dev libxcb-present-dev libxcb-xinerama0-dev libxcb-glx0-dev libpixman-1-dev libdbus-1-dev libconfig-dev libgl1-mesa-dev libpcre2-dev libpcre3-dev libevdev-dev uthash-dev libev-dev libx11-xcb-dev meson gcc g++;
git clone --depth 1 https://github.com/yshui/picom;
cd picom;
git submodule update --init --recursive;
meson --buildtype=release . build;
ninja -C build;"

mkdir -p ~/.local/bin
podman cp picom:/picom/build/src/picom ~/.local/bin

podman rm -f picom;

podman rm -f polybar || echo "no polybar found"

podman run --name polybar ubuntu:20.04 bash -c "
apt-get update;
DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential git cmake cmake-data pkg-config python3-sphinx python3-packaging libcairo2-dev libxcb1-dev libxcb-util0-dev libxcb-randr0-dev libxcb-composite0-dev python3-xcbgen xcb-proto libxcb-image0-dev libxcb-ewmh-dev libxcb-icccm4-dev gcc g++ make;
git clone --recursive --depth 1 https://github.com/polybar/polybar.git
cd polybar;
mkdir build
cd build
cmake ..
make -j$(nproc)
# Optional. This will install the polybar executable in /usr/local/bin
make install"

podman cp polybar:/usr/local/bin/polybar ~/.local/bin

podman rm -f polybar;

sudo add-apt-repository -y ppa:kelleyk/emacs
sudo add-apt-repository -y ppa:regolith-linux/release
curl https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb > /tmp/chrome.deb
sudo apt update
sudo apt install -y i3-gaps-wm i3blocks feh maim htop /tmp/chrome.deb emacs27 font-manager playerctl rofi python3-pip numlockx xclip ibus-chewing dunst i3lock vim libxcb-damage0 libconfig9 python3-pip git make gcc g++
# the fonts for st terminal
sudo apt install -y fonts-linuxlibertine fonts-inconsolata fonts-inconsolata fonts-emojione fonts-symbola

sudo ln -f "$(which python3)" "$(dirname $(which python3))/python"

pip3 install dbus-python

# compile st
git clone --depth 1 https://github.com/karta0807913/st /tmp/st
cd /tmp/st
sudo apt install -y libharfbuzz-dev libx11-dev libxft-dev
make all
cp ./st ~/.local/bin
cd -

git clone --depth 1 https://github.com/karta0807913/config.git /tmp/config
cd /tmp/config
# vim-plug
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
cp -R .vimrc .bashrc .local .config .profile .Xmodmap .xprofile .xinputrc ~/
mkdir .local/wallpaper
cd -

git clone https://github.com/karta0807913/emacs.d.git ~/.emacs.d
cp ~/.emacs.d/.custom.el ~/

if ! [ -f "/tmp/CascadiaCode.zip" ]; then
    curl -L https://github.com/microsoft/cascadia-code/releases/download/v2106.17/CascadiaCode-2106.17.zip > /tmp/CascadiaCode.zip
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
