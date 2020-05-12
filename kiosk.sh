#!/bin/bash
xset s noblank
xset s off
xset -dpms

unclutter -idle 0.5 -root &

sed -i 's/"exited_cleanly":false/"exited_cleanly":true/' /home/pi/.config/chromium/Default/Preferences
sed -i 's/"exit_type":"Crashed"/"exit_type":"Normal"/' /home/pi/.config/chromium/Default/Preferences

export KIOSKPAGE
export ZOOM
export RESTART

echo 'Kiosk' + "$KIOSKPAGE"

while true; do
  while read -r line; do
    if [[ $line =~ ^"["(.+)"]"$ ]]; then
      arrname=${BASH_REMATCH[1]}
      declare -A "$arrname"
    elif [[ $line =~ ^([_[:alpha:]][_[:alnum:]]*)"="(.*) ]]; then
      declare "${arrname}"["${BASH_REMATCH[1]}"]="${BASH_REMATCH[2]}"
    fi
  done < /home/pi/vemcount/kiosk.ini

  if ! pgrep chromium > /dev/null && ! test -z "${OPTIONS[url]}"; then
    RESTART=true
  fi

  if ! [[ $KIOSKPAGE == "${OPTIONS[url]}" ]] || ! [[ $ZOOM == "${OPTIONS[zoom]}" ]] || [ -f "/tmp/reload-chromium" ] || $RESTART; then
    if ! [[ "$ZOOM" == "${OPTIONS[zoom]}" ]]; then
      pkill -o chromium
    fi
    KIOSKPAGE="${OPTIONS[url]}"
    ZOOM="${OPTIONS[zoom]}"
    /usr/bin/chromium-browser --force-device-scale-factor="$ZOOM" --hide-scrollbars --check-for-update-interval=7776000 --no-first-run --noerrdialogs --disable-infobars --kiosk "$KIOSKPAGE" &
    if [ -f "/tmp/reload-chromium" ]; then
      rm "/tmp/reload-chromium"
    fi
    RESTART=false
  fi

  sleep 10
done
