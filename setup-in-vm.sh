#!/bin/bash
# brkh linux - paste this entire script into the VM terminal

set -e

BUILD="$HOME/brkh-build"
OUT="$HOME/brkh-out"

echo "[1/4] Installing archiso..."
sudo pacman -Sy --noconfirm archiso

echo "[2/4] Adding BlackArch repo to host..."
sudo bash -c "echo '[blackarch]' >> /etc/pacman.conf"
sudo bash -c "echo 'Server = https://mirror.blackarch.org/\$repo/os/\$arch' >> /etc/pacman.conf"
sudo pacman-key --recv-keys 4345771566D76038C7FEB43863EC0ADBEA87E4E3
sudo pacman-key --lsign-key 4345771566D76038C7FEB43863EC0ADBEA87E4E3
sudo pacman -Sy --noconfirm

echo "[3/4] Creating build profile..."
mkdir -p "$BUILD"
sudo cp -r /usr/share/archiso/configs/releng/. "$BUILD/"
sudo chown -R "$USER:$USER" "$BUILD"

cat > "$BUILD/profiledef.sh" << 'EOF'
#!/usr/bin/env bash
iso_name="brkh-linux"
iso_label="BRKH"
iso_publisher="brkh"
iso_application="brkh Linux - Security Edition"
iso_version="1.0"
install_dir="arch"
buildmodes=('iso')
bootmodes=('bios.syslinux.mbr' 'bios.syslinux.eltorito' 'uefi-ia32.grub.esp' 'uefi-x64.grub.esp')
arch="x86_64"
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'xz' '-Xbcj' 'x86' '-b' '1M' '-Xdict-size' '1M')
file_permissions=(
  ["/etc/shadow"]="0:0:400"
  ["/root"]="0:0:750"
)
EOF

cat > "$BUILD/pacman.conf" << 'EOF'
[options]
HoldPkg     = pacman glibc
Architecture = auto
CheckSpace
ParallelDownloads = 5
SigLevel    = Required DatabaseOptional
LocalFileSigLevel = Optional

[core]
Include = /etc/pacman.d/mirrorlist

[extra]
Include = /etc/pacman.d/mirrorlist

[blackarch]
Server = https://mirror.blackarch.org/$repo/os/$arch
EOF

cat > "$BUILD/packages.x86_64" << 'EOF'
base
base-devel
linux
linux-firmware
mkinitcpio
grub
efibootmgr
networkmanager
openssh
sudo
curl
wget
git
vim
neovim
zsh
tmux
htop
unzip
rsync
man-db
fzf
bat
ripgrep
nmap
wireshark-qt
tcpdump
iproute2
net-tools
whois
traceroute
hashcat
john
hydra
gdb
radare2
binwalk
aircrack-ng
xorg-server
xorg-xinit
i3-wm
i3status
dmenu
alacritty
firefox
ttf-jetbrains-mono-nerd
noto-fonts
EOF

mkdir -p "$BUILD/airootfs/etc"
mkdir -p "$BUILD/airootfs/root/.config/i3"
mkdir -p "$BUILD/airootfs/root/.config/alacritty"

echo "brkh" > "$BUILD/airootfs/etc/hostname"

cat > "$BUILD/airootfs/etc/os-release" << 'EOF'
NAME="brkh Linux"
PRETTY_NAME="brkh Linux 1.0"
ID=brkh
ID_LIKE=arch
BUILD_ID=rolling
ANSI_COLOR="1;36"
EOF

cat > "$BUILD/airootfs/etc/motd" << 'EOF'

  ██████╗ ██████╗ ██╗  ██╗██╗  ██╗
  ██╔══██╗██╔══██╗██║ ██╔╝██║  ██║
  ██████╔╝██████╔╝█████╔╝ ███████║
  ██╔══██╗██╔══██╗██╔═██╗ ██╔══██║
  ██████╔╝██║  ██║██║  ██╗██║  ██║
  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝
         brkh linux - security edition

EOF

cat > "$BUILD/airootfs/root/.zshrc" << 'EOF'
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS SHARE_HISTORY
autoload -Uz compinit && compinit
alias ls='ls --color=auto'
alias ll='ls -la --color=auto'
alias vi='nvim'
alias vim='nvim'
alias myip='curl -s ifconfig.me'
alias ports='ss -tulnp'
alias b64d='base64 -d'
alias serve='python3 -m http.server'
export EDITOR=nvim
EOF

cat > "$BUILD/airootfs/root/.config/i3/config" << 'EOF'
set $mod Mod4
set $term alacritty
font pango:JetBrains Mono Nerd Font 10
default_border pixel 2
bindsym $mod+Return exec $term
bindsym $mod+d exec dmenu_run
bindsym $mod+q kill
bindsym $mod+Shift+r restart
bindsym $mod+h focus left
bindsym $mod+j focus down
bindsym $mod+k focus up
bindsym $mod+l focus right
bindsym $mod+1 workspace 1
bindsym $mod+2 workspace 2
bindsym $mod+3 workspace 3
bindsym $mod+4 workspace 4
bindsym $mod+5 workspace 5
bindsym $mod+Shift+1 move container to workspace 1
bindsym $mod+Shift+2 move container to workspace 2
bindsym $mod+Shift+3 move container to workspace 3
bindsym $mod+f fullscreen toggle
bindsym $mod+Shift+space floating toggle
bar {
    status_command i3status
    position top
}
exec --no-startup-id nm-applet
EOF

cat > "$BUILD/airootfs/root/.config/alacritty/alacritty.toml" << 'EOF'
[window]
padding = { x = 12, y = 10 }
opacity = 0.92
[font]
normal = { family = "JetBrainsMono Nerd Font", style = "Regular" }
size = 12.0
[colors.primary]
background = "#0d0d0d"
foreground = "#00ffcc"
[shell]
program = "/bin/zsh"
EOF

cat > "$BUILD/airootfs/root/.xinitrc" << 'EOF'
#!/bin/sh
exec i3
EOF

echo ""
echo "[4/4] Profile ready! Now building the ISO..."
echo "      This will take 10-30 minutes..."
echo ""
mkdir -p "$OUT"
sudo mkarchiso -v -w /tmp/brkh-work -o "$OUT" "$BUILD"
echo ""
echo "========================================="
echo " brkh linux ISO is ready!"
echo " Location: $OUT"
ls -lh "$OUT"/*.iso
echo "========================================="
