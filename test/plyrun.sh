#!/bin/bash

# plymouthd --tty=/dev/tty2
# echo "--------------------------------------------------------- " >> /home/me/plylog
# echo "--------------------------------------------------------- " >> /home/me/plylog
# echo "--------------------------------------------------------- " >> /home/me/plylog
# echo "--------------------------------------------------------- " >> /home/me/plylog
# echo "--------------------------------------------------------- " >> /home/me/plylog
# echo "--------------------------------------------------------- " >> /home/me/plylog

plymouthd --debug #--debug-file=/home/me/plylog

# plymouth change-mode --shutdown
plymouth show-splash
# plymouth change-mode --shutdown


#### |                 | ####
#### | copy to lightdm | ####
#### v                 v ####

for ((I=0; I<6; I++)); do
  plymouth --update=test$I
  sleep 1
done

#### ^                 ^ ####
#### | copy to lightdm | ####
#### |                 | ####

plymouth quit
