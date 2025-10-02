# This script ensures that the custom icon is copied to the right location in the web build

# Create directories if they don't exist
New-Item -ItemType Directory -Force -Path build\web\assets\images\

# Copy the icon file
Copy-Item assets\images\icon.png build\web\assets\images\

Write-Output "Custom icon copied successfully to web build output!"
