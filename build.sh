#!/bin/bash

# Install Flutter
if [ ! -d "$HOME/flutter" ]; then
  echo "Cloning Flutter SDK..."
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 $HOME/flutter
fi

# Add Flutter to PATH
export PATH="$PATH:$HOME/flutter/bin"

# Enable Web
echo "Enabling Web support..."
flutter config --enable-web
flutter config --no-analytics

# Build the project
echo "Running pub get..."
flutter pub get

echo "Building for Web..."
flutter build web --release

# Create public directory for Vercel
echo "Preparing public directory..."
rm -rf public
mkdir -p public
cp -r build/web/* public/

echo "Build complete."
