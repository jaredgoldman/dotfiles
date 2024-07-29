#!/bin/bash

# Turn on Bluetooth
bluetoothctl power on

# Enable the agent
bluetoothctl agent on

# Default agent
bluetoothctl default-agent

# Trust the device
bluetoothctl trust DD:14:67:9C:B7:89

# Connect to the device
bluetoothctl connect DD:14:67:9C:B7:89
