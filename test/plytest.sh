#!/bin/sh

set -x

#plymouthd --tty=/dev/tty2 --debug-log=/tmp/foo
plymouthd --debug #--debug-file=/home/me/plylog

plymouth show-splash

#### |                 | ####
#### | copy to lightdm | ####
#### v                 v ####

plymouth update --status="kitten.service"; sleep 1
plymouth update --status="meows.service"; sleep 1

plymouth update --status="updates.service"; sleep 1
plymouth change-mode --updates
c=1
while [ ! "$c" -gt "100" ]; do
    plymouth system-update --progress="$c"
    sleep 0.005
    c=$(($c+1))
done

plymouth display-message --text="Checking disk drives for errors. This may take several minutes."
plymouth display-message --text="keys:Press C to cancel all checks in progress"
c=1
while [ ! "$c" -gt "100" ]; do
    plymouth update --status="fsck:sda1:$c"
    sleep 0.005
    c=$(($c+1))
done
plymouth watch-keystroke --keys="cC " --command="echo yay"

# plymouth display-message --text="Intermediate Message"; sleep 1
# plymouth hide-message --text="Intermediate Message"; sleep 2

plymouth display-message --text="keys:"
promptString="Unlocking the disk /dev/sda0 (/media)
Enter passphrase: "
plymouth ask-for-password --prompt="${promptString}" --dont-pause-progress

plymouth message --text="Press ENTER to leave"
plymouth watch-keystroke > /dev/null

#### ^                 ^ ####
#### | copy to lightdm | ####
#### |                 | ####

plymouth quit
