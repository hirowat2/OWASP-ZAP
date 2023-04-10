#!/bin/sh

# Intial "bloat"
pacman -Syyuu --noconfirm && yay --aur --noconfirm
pacman -S --noconfirm \
    chromium \
    docker \
    docker-compose \
    firefox \
    pulseaudio \
    pulseaudio-alsa \
    zsh
pacman -Rc conky
yay -S --noconfirm \
    calibre-git \
    deluge-git
    etcher-git \
    inkscape-git \
    kdenlive \
    neovim-git \
    pavucontrol-git \
    picocom-git \
    telegram-desktop-bin \
    thunderbird \
    visual-studio-code-bin \
    youtube-dl-git

# oh-my-zsh config
chsh -s $(which zsh)
sudo chsh -s $(which zsh)
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions

# docker config
systemctl enable docker
systemctl start docker
groupadd docker
usermod -aG docker $USER

### REBOOT HERE

## docker multi-arch support
cp dockermultiarch.service /etc/systemd/system/
cp dockermultiarch /usr/bin/
chmod 755 /usr/bin/dockermultiarch
systemctl enable dockermultiarch.service
systemctl start dockermultiarch.service

### REBOOT HERE --only if 'dockermultiarch.service' has not started

docker build --platform=local -o . git://github.com/docker/buildx
mkdir -p ~/.docker/cli-plugins
mv buildx ~/.docker/cli-plugins/docker-buildx
docker buildx create --name mybuilder
docker buildx use mybuilder
docker buildx inspect --bootstrap
# https://github.com/docker/docker-ce/blob/master/components/cli/experimental/README.md
sudo printf "{\n\t\"experimental\": true\n}\n" | sudo tee /etc/docker/daemon.json

SHELL_RC="/dev/null"
MY_SHELL=($(echo $SHELL | tr '/' '\n'))
MY_SHELL="${MY_SHELL[-1]}"

if [ "zsh" == MY_SHELL ]
then
    SHELL_RC="/.zshrc"
fi
if [ "bash" == MY_SHELL ]
then
    SHELL_RC="/.bashrc"
fi

cat << EOF >> $HOME$SHELL_RC
# multiarch script configurations
DOCKER_CLI_EXPERIMENTAL=enabled
DOCKER_BUILDKIT=1
EOF

# rxvt-unicode (urxvt)
