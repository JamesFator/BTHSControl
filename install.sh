#! /bin/bash
# File:         install.sh
# Author:       James Fator (jamesfator@gmail.com)
# Description:  Primary installation script for the BTHSControl project.
# Running:      "install.sh"

# Any commands that fail will cause the script to fail.
set -e

# Check for sudo from within the script
if [[ $( sudo sh -c 'echo $EUID' ) != 0 ]]; then
    echo "You need to have sudo access to install"
    exit
fi

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
sudo cp -r ./AVRCPAgent /System/Library/CoreServices/

# LaunchAgent
echo "Setting up LaunchAgent: com.bths.AVRCPAgent"
sudo cp ./com.bths.AVRCPAgent.plist /Library/LaunchAgents/
sudo chmod 755 /Library/LaunchAgents/com.bths.AVRCPAgent.plist

# If the launchagent can't be found it returns an error but it isn't necessarily wrong. Ignore errors for this line only.
set +e
LAUNCHAGENTSTATUS=$((launchctl list com.bths.AVRCPAgent) 2>&1)
set -e
if [[ $LAUNCHAGENTSTATUS != "Could not find service"* ]]; then
    echo "Deactivating Service: AVRCPAgent"
    launchctl unload /Library/LaunchAgents/com.bths.AVRCPAgent.plist
fi

echo "Activating Service: AVRCPAgent"
launchctl load /Library/LaunchAgents/com.bths.AVRCPAgent.plist

echo "Installation complete!"
