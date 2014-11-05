# [BTHSControl](https://github.com/JamesFator/BTHSControl)
## Bluetooth Headset Control for OS X
Finally take back control of your Bluetooth headset's media keys!

If you have a pair of Bluetooth headphones and use a music program other
than iTunes, you're probably fed up with iTunes launching when you
connect and when you press any of the media buttons. This hack allows you
to *bypass* the default iTunes controls and utilize the media buttons
on your headset as if they were the standard media keys on your keyboard.
This allows you to control playing, pausing, and skipping tracks in
programs such as Spotify, VLC, and many more!

## What is happening under the hood

Up until OS X 10.9, there was a system app called AVRCPAgent which
was the middle man of Bluetooth remote control profiles on Mac.
When you pressing a button on something such as a Bluetooth headset,
the command would make it's way through this app, only to be hard
coded to iTunes and Quicktime.

This AVRCPAgent app allowed some sort of custom plug-ins, but
documentation of what could be done is no where. Using the basic
disassembling software in OS X's CLI tools, a list of instance methods
within the classes inside the app become apparent. Once the code that
sends commands to iTunes is located, it is swapped out with custom
code written to be more generic.

Even though AVRCPAgent was removed in Yosemite, it is still functional
and can act as a separate Bluetooth service.

## Tested Systems

* OS X 10.10
* OS X 10.9

## Installation

1. Run install.sh
2. Reboot computer

## To Do

* Test different Bluetooth headset devices
