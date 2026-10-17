# brkh linux

Arch-based security/CTF distro with i3wm, BlackArch tools, and a clean hacking environment.

## Project structure

```
brkh linux/
├── profiledef.sh               # ISO metadata and build settings
├── pacman.conf                 # Package repos (includes BlackArch)
├── packages.x86_64             # Package list
├── build.sh                    # Build script (run on Arch VM as root)
└── airootfs/                   # Live filesystem overlay
    ├── etc/
    │   ├── hostname            # "brkh"
    │   ├── os-release          # Distro branding
    │   ├── motd                # Login banner
    │   └── i3status.conf       # Status bar config
    └── root/                   # Root user home
        ├── .zshrc              # Shell config + CTF aliases
        ├── .xinitrc            # Starts i3
        └── .config/
            ├── starship.toml   # Prompt theme
            ├── i3/config       # i3 window manager
            └── alacritty/      # Terminal config
```

## Building

1. Install Arch Linux in a VM
2. Copy this whole folder into the VM (or clone from git)
3. Run as root:

```bash
chmod +x build.sh
sudo ./build.sh
```

4. The `.iso` will be in `out/`
5. Flash to USB: `dd if=out/brkh-linux-*.iso of=/dev/sdX bs=4M status=progress`

## Customizing

- **Add packages**: edit `packages.x86_64`
- **Change shell config**: edit `airootfs/root/.zshrc`
- **Change i3 layout**: edit `airootfs/root/.config/i3/config`
- **Add files to the live system**: drop them anywhere under `airootfs/`

## Default tools included

- **Network**: nmap, wireshark, tcpdump, masscan, arp-scan
- **Web**: burpsuite, sqlmap, gobuster, ffuf, nikto
- **Password**: hashcat, john, hydra
- **Exploitation**: metasploit, exploitdb, gdb + pwndbg, pwntools
- **RE**: radare2, ghidra, binwalk
- **Wireless**: aircrack-ng, wifite, bettercap
- **Forensics**: volatility3, autopsy, exiftool, steghide
