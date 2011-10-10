#!/bin/bash

#This script is for the dreamGEAR Broadcaster (DGPS3-3828) Playstation 3 USB Headset - 
#It controls PulseAudio Volume up and down on device when keys are pressed
#accoringly

 
SINK_NAME="alsa_output.usb-szmy-power_USB_Headphone-00-Headphone.analog-stereo"
VOL_STEP="0x01000"
 
VOL_NOW=`pacmd dump | grep "set-sink-volume $SINK_NAME" | perl -p -i -e 's/.+\s(.x.+)$/$1/'`
 
case "$1" in
  plus)
    VOL_NEW=$((VOL_NOW + VOL_STEP))
    if [ $VOL_NEW -gt $((0x28000)) ]
     then
        VOL_NEW=$((0x28000))
    fi
    pactl set-sink-volume $SINK_NAME `printf "0x%X" $VOL_NEW`
 
  ;;
  minus)
    VOL_NEW=$((VOL_NOW - VOL_STEP))
    if [ $(($VOL_NEW)) -lt $((0x00000)) ]
     then
        VOL_NEW=$((0x00000))
    fi
    pactl set-sink-volume $SINK_NAME `printf "0x%X" $VOL_NEW`
  ;;
  mute)
 
    #MUTE_STATE=`pacmd dump | grep "set-sink-mute $SINK_NAME" | cut -d " " -f 3`
    MUTE_STATE=`pacmd dump | grep "set-sink-mute $SINK_NAME" | perl -p -i -e 's/.+\s(yes|no)$/$1/'`
    if [ $MUTE_STATE = no ]
     then
        pactl set-sink-mute $SINK_NAME 1
    elif [ $MUTE_STATE = yes ]
     then
        pactl set-sink-mute $SINK_NAME 0
    fi
esac
