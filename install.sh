#! /bin/bash
# File:         install.sh
# Author:       James Fator (jamesfator@gmail.com)
# Description:  Primary installation script for the BTHSControl project.
# Running:      "install.sh"

SERVICESDIR="/Library/Services/"
AVRCPAGENTDIR="$SERVICESDIR/AVRCPAgent"

LAUNCHAGENTDIR="/Library/LaunchAgents/"
LAUNCHAGENTPLIST="$LAUNCHAGENTDIR/com.bths.AVRCPAgent.plist"

launchctlUnload () {
    # If the launchagent can't be found it returns an error but it
    # isn't necessarily wrong. Ignore errors for this line only.
    set +e
    LAUNCHAGENTSTATUS=$((launchctl list com.bths.AVRCPAgent) 2>&1)
    set -e
    if [[ $LAUNCHAGENTSTATUS != "Could not find service"* ]]; then
        echo "Deactivating Service: AVRCPAgent"
        launchctl unload $LAUNCHAGENTPLIST
    fi
}

install () {
    echo "Installing"

    # Any commands that fail will cause the script to fail.
    set -e

    # BTHSControl
    echo "Building plug-in: BTHSControl"
    xcodebuild -project BTHSControl.xcodeproj
    PLUGIN_DIR=./AVRCPAgent/PlugIns/
    if [ ! -d "$PLUGIN_DIR" ]; then
        mkdir "$PLUGIN_DIR"
    fi
    cp -r ./build/Release/BTHSControl.bundle "$PLUGIN_DIR"

    # AVRCPAgent
    echo "Setting up Service: AVRCPAgent"
    sudo cp -r ./AVRCPAgent $SERVICESDIR

    # LaunchAgent
    echo "Setting up LaunchAgent: com.bths.AVRCPAgent"
    sudo cp ./com.bths.AVRCPAgent.plist $LAUNCHAGENTDIR
    sudo chmod 755 $LAUNCHAGENTPLIST

    # Unload the service if it is loaded
    launchctlUnload

    echo "Activating Service: AVRCPAgent"
    launchctl load $LAUNCHAGENTPLIST

    echo "Installation complete!"
}

uninstall () {
    echo "Uninstalling"

    # Remove AVRCPAgent
    echo "Removing Service: AVRCPAgent"
    sudo rm -r $AVRCPAGENTDIR

    # Unload LaunchAgent if it is loaded
    launchctlUnload

    # Remove LaunchAgent
    echo "Removing LaunchAgent: com.bths.AVRCPAgent"
    sudo rm $LAUNCHAGENTPLIST

    echo "Uninstallation complete!"
}

printUsage () {
    echo "Usage $0 [install|uninstall]"
    exit
}

# Check for sudo from within the script
if [[ $( sudo sh -c 'echo $EUID' ) != 0 ]]; then
    echo "You need to have sudo access to install"
    exit
fi

if [ $# -eq 0 ] || ( [ $1 != "install" ] && [ $1 != "uninstall" ] )
then
    printUsage
elif [ $1 == "install" ]
then
    install
elif [ $1 == "uninstall" ]
then
    if [ $# -eq 2 ] && [ $2 == "old" ]
    then
        echo "Uninstalling old"
        SERVICESDIR="/System/Library/CoreServices/"
        AVRCPAGENTDIR="$SERVICESDIR/AVRCPAgent"
    fi
    uninstall
fi
