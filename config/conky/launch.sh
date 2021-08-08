#!/usr/bin/env sh

## Add this to your wm startup file.

killall -q conky

while pgrep -u $UID -x conky >/dev/null; do sleep 1; done

conky &
