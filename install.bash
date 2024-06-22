#!/bin/bash
set +e

if [ "$(uname -m)" != "x86_64" ]; then
    echo "this script only support x86_64 :<"
    exit 1
fi

if ! lsb_release --id | grep "Ubuntu" > /dev/null; then
    echo "this script only support ubuntu :<"
    exit 1
fi

sudo apt-get update
sudo apt-get install -y software-properties-common

if ! which podman > /dev/null 2>/dev/null ; then
    set -e
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.opensuse.org/repositories/devel:kubic:libcontainers:unstable/xUbuntu_$(lsb_release -rs)/Release.key \
      | gpg --dearmor \
      | sudo tee /etc/apt/keyrings/devel_kubic_libcontainers_unstable.gpg > /dev/null
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/devel_kubic_libcontainers_unstable.gpg]\
        https://download.opensuse.org/repositories/devel:kubic:libcontainers:unstable/xUbuntu_$(lsb_release -rs)/ /" \
      | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:unstable.list > /dev/null
    sudo apt-get update
    sudo apt-get -y install podman
    set +e
fi

if ! podman network inspect podman >/dev/null 2>/dev/null; then
    podman create network podman
fi

sudo add-apt-repository -y ppa:kelleyk/emacs
curl https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb > /tmp/chrome.deb
sudo apt update
sudo apt install -y i3-wm feh maim htop /tmp/chrome.deb emacs28 playerctl rofi python3-pip numlockx xclip ibus-chewing dunst i3lock vim python3-pip git unzip acpid polybar picom libxcb-dpms0
# the fonts for st terminal
sudo apt install -y fonts-linuxlibertine fonts-inconsolata fonts-inconsolata fonts-emojione fonts-symbola byzanz

sudo ln -f "$(which python3)" "$(dirname $(which python3))/python"

pip3 install dbus-python

podman rm -f i3 || echo ""

podman run --name i3 ubuntu:22.04 bash -c "
apt-get update;
DEBIAN_FRONTEND=noninteractive apt-get install -y gcc meson pkg-config libstartup-notification0-dev libxcb1-dev libxcb-xkb-dev libxcb-randr0-dev libxcb-shape0-dev libxcb-util-dev libxcb-cursor-dev libxcb-keysyms1-dev libxcb-icccm4-dev libxcb-xrm-dev libxkbcommon-dev libxkbcommon-x11-dev libyajl-dev libxkbcommon-x11-dev libpcre2-dev  libcairo2-dev libpango1.0-dev libglib2.0-dev libev-dev asciidoc-base ninja-build wget xz-utils libxcb-xinerama0-dev;
wget https://i3wm.org/downloads/i3-4.22.tar.xz;
tar -xvf i3-4.22.tar.xz;
cd i3-4.22;
meson build -Ddocs=true -Dmans=true;
ninja -C build/ install;
"
rm -rf /tmp/i3;
mkdir -p /tmp/i3/share /tmp/i3/bin /tmp/i3/share/man /tmp/i3/doc;
podman cp i3:/usr/local/share/doc/i3 /tmp/i3/share/doc;
podman cp i3:/usr/local/share/man/man1 /tmp/i3/share/man/;
podman cp i3:/usr/local/etc/i3 /tmp/i3/etc;
podman cp i3:/i3-4.22/build/i3 /tmp/i3/bin;
podman cp i3:/i3-4.22/build/i3bar /tmp/i3/bin;
podman cp i3:/i3-4.22/build/i3-config-wizard /tmp/i3/bin;
podman cp i3:/i3-4.22/build/i3-dump-log /tmp/i3/bin;
podman cp i3:/i3-4.22/build/i3-input /tmp/i3/bin;
podman cp i3:/i3-4.22/build/i3-msg /tmp/i3/bin;
podman cp i3:/i3-4.22/build/i3-nagbar /tmp/i3/bin;
podman cp i3:/i3-4.22/i3-dmenu-desktop /tmp/i3/bin;
podman cp i3:/i3-4.22/i3-migrate-config-to-v4 /tmp/i3/bin;
podman cp i3:/i3-4.22/i3-save-tree /tmp/i3/bin;
podman cp i3:/i3-4.22/i3-sensible-editor /tmp/i3/bin;
podman cp i3:/i3-4.22/i3-sensible-pager /tmp/i3/bin;
podman cp i3:/i3-4.22/i3-sensible-terminal /tmp/i3/bin;
sudo cp -R /tmp/i3/* /usr/local/;
podman rm -f i3;

podman rm -f picom || echo "no picon found"

podman run --name picom ubuntu:22.04 bash -c "
apt-get update;
DEBIAN_FRONTEND=noninteractive apt-get install -y git gcc g++ libxext-dev libxcb1-dev libxcb-damage0-dev libxcb-dpms0-dev libxcb-xfixes0-dev libxcb-shape0-dev libxcb-render-util0-dev libxcb-render0-dev libxcb-randr0-dev libxcb-composite0-dev libxcb-image0-dev libxcb-present-dev libxcb-xinerama0-dev libxcb-glx0-dev libpixman-1-dev libdbus-1-dev libconfig-dev libgl-dev libegl-dev libpcre2-dev libevdev-dev uthash-dev libev-dev libx11-xcb-dev meson;
git clone --depth 1 https://github.com/yshui/picom;
cd picom;
git submodule update --init --recursive;
meson --buildtype=release . build;
ninja -C build;"

mkdir -p ~/.local/bin
podman cp picom:/picom/build/src/picom ~/.local/bin

podman rm -f picom;

podman rm -f polybar || echo "no polybar found"

podman run --name polybar ubuntu:22.04 bash -c "
apt-get update;
DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential git cmake cmake-data pkg-config python3-sphinx python3-packaging libcairo2-dev libxcb1-dev libxcb-util0-dev libxcb-randr0-dev libxcb-composite0-dev python3-xcbgen xcb-proto libxcb-image0-dev libxcb-ewmh-dev libxcb-icccm4-dev gcc g++ make libxcb-xkb-dev libxcb-xrm-dev libxcb-cursor-dev libasound2-dev libpulse-dev libuv1-dev i3-wm libjsoncpp-dev libmpdclient-dev libcurl4-openssl-dev libnl-genl-3-dev;
git clone --recursive --depth 1 https://github.com/polybar/polybar.git
cd polybar;
mkdir build
cd build
cmake ..
make -j$(nproc)
# Optional. This will install the polybar executable in /usr/local/bin
make install"

podman cp polybar:/usr/bin/polybar ~/.local/bin
podman cp polybar:/usr/bin/polybar-msg ~/.local/bin

podman rm -f polybar;

# compile st
podman rm -f st;
podman run --name st ubuntu:22.04 bash -c "
apt update && apt install -y libharfbuzz-dev libx11-dev libxft-dev gcc make git
git clone --depth 1 https://github.com/karta0807913/st /tmp/st
cd /tmp/st
make all
cp ./st ~/.local/bin
# enable the delete key
cd -
";
echo "set enable-keypad on" >> ~/.inputrc
podman cp st:/tmp/st/st ~/.local/bin/
podman rm -f st;

podman rm -f alacritty;
podman run --name alacritty docker.io/rust:1.78-buster bash -c "
set -e;
git clone --depth 1 -b v0.13.2 https://github.com/alacritty/alacritty.git;
cd alacritty;
apt-get update && apt-get install -y cmake pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev python3;
cargo build --release;
";
podman cp alacritty:/alacritty/target/release/alacritty ~/.local/bin/
podman rm -f alacritty;

git clone --depth 1 https://github.com/karta0807913/config.git /tmp/config
cd /tmp/config
# vim-plug
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
cp -R .vimrc .bashrc .local .config .profile .Xmodmap .xprofile .xinputrc ~/
mkdir ~/.local/wallpaper
cd -

git clone --depth 1 https://github.com/karta0807913/emacs.d.git ~/.emacs.d
cp ~/.emacs.d/.custom.el ~/

if ! [ -f "/tmp/CascadiaCode.zip" ]; then
    curl -L https://github.com/microsoft/cascadia-code/releases/download/v2106.17/CascadiaCode-2106.17.zip > /tmp/CascadiaCode.zip
fi
cd /tmp
unzip -u CascadiaCode.zip
cd -

# set font and gnome terminal theme
mkdir ~/.local/share/fonts
mv /tmp/ttf/CascadiaCode.ttf ~/.local/share/fonts
fc-cache -f -v
dconf load /org/gnome/terminal/legacy/profiles:/ < /tmp/config/gnome-terminal-profiles.dconf
# hide menubar
gsettings set org.gnome.Terminal.Legacy.Settings default-show-menubar false
sudo cp 60-custom.quirks /usr/share/libinput/60-custom.quirks

# add i3 configure
# cat<<EOF | sudo tee /usr/share/xsessions/i3.desktop
# [Desktop Entry]
# Name=i3
# Comment=improved dynamic tiling window manager
# Exec=i3
# TryExec=i3
# Type=Application
# X-LightDM-DesktopName=i3
# DesktopNames=i3
# Keywords=tiling;wm;windowmanager;window;manager;
# EOF
#
echo "install finish, please login again"
