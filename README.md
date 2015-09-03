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


## El Capitan (OS X 10.11)

El Capitan introduced "System Integrity Protection", which means we no
longer should be editing the /System/Library/CoreServices directory.
I moved the service to /Library/Services/ and it seems to be working
for me still. I'll keep an eye on it to ensure this is a stable move.


## Upgrading OS X version

If you upgrade your OS X system, you may need to re-install the
service. I noticed this was an issue in OS X 10.11, so it may be
an issue for other versions.


## Contributors

[Timmo Verlaan](https://github.com/tverlaan)


## Tested Systems

* OS X 10.11
* OS X 10.10
* OS X 10.9


## Installation

1. Disconnect Bluetooth device
2. Run "install.sh install"
3. Reconnect Bluetooth device and test


## Uninstalling

1. If uninstalling the old version, run "install.sh uninstall old"
2. If uninstalling the current version, run "install.sh uninstall"
3. Disconnect Bluetooth device, then reconnect.
