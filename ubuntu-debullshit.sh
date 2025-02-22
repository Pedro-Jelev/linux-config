#!/usr/bin/env bash

remove_snaps() {
  while [ "$(snap list | wc -l)" -gt 0 ]; do
    for snap in $(snap list | tail -n +2 | cut -d ' ' -f 1); do
      snap remove --purge "$snap"
    done
  done

  systemctl stop snapd
  systemctl disable snapd
  systemctl mask snapd
  apt purge snapd -y
  rm -rf /snap /var/lib/snapd
  for userpath in /home/*; do
    rm -rf $userpath/snap
  done
  cat <<-EOF | tee /etc/apt/preferences.d/nosnap.pref
      Package: snapd
      Pin: release a=*
      Pin-Priority: -10
      EOF 
}

update_system() {
  apt update && apt upgrade -y
}

cleanup() {
  apt autoremove -y
}

set_flathub() {
  apt install flatpak -y
  flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  apt install gnome-software -y
}

set_zsh() {
  apt install zsh
  chsh -s $(which zsh)
}

main() {
  update_system
  remove_snaps
  set_flathub
  set_zsh
}

main
