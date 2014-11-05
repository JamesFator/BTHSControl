#! /bin/bash
# File:         install.sh
# Author:       James Fator (jamesfator@gmail.com)
# Description:  Primary installation script for the BTHSControl project.
# Running:      "sudo install.sh"

# Any commands that fail will cause the script to fail.
set -e

# LaunchAgent
echo "Setting up LaunchAgent: com.bths.AVRCPAgent"
cp ./com.bths.AVRCPAgent.plist /Library/LaunchAgents/
chmod 755 /Library/LaunchAgents/com.bths.AVRCPAgent.plist

# AVRCPAgent
echo "Setting up Service: AVRCPAgent"
cp -r ./AVRCPAgent /System/Library/CoreServices/

echo "Installation complete!"
echo "Reboot required."
