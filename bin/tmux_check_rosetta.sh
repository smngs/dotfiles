#!/usr/bin/env zsh

if [[ $2 = "ssh" ]]; then
  exit
fi

if (( $+commands[archinfo] )); then
  proc_info=`archinfo --pid $1`
  if [[ `echo $proc_info | grep 'arm64'` ]]; then
    echo " #[bg=colour63,fg=colour255] arm64/$2 #[default]"
  else
    echo " #[bg=colour131,fg=colour255] x86_64/$2 #[default]"
  fi
else
  echo " #[bg=colour63,fg=colour255] $2 #[default]"
fi
