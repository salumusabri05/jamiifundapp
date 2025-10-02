#!/bin/bash
# This script ensures that the custom icon is copied to the right location in the web build

# Create directories if they don't exist
mkdir -p build/web/assets/images/

# Copy the icon file
cp assets/images/icon.png build/web/assets/images/

echo "Custom icon copied successfully to web build output!"
