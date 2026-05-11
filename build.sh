#!/bin/bash

# Exit on error
set -e

echo "🚀 Starting Gemzi Web Build Pipeline..."

# 1. Install Flutter
if [ ! -d "/vercel/flutter" ]; then
    echo "📥 Cloning Flutter SDK..."
    git clone https://github.com/flutter/flutter.git -b stable /vercel/flutter
fi

export PATH="$PATH:/vercel/flutter/bin"

echo "🔧 Configuring Flutter..."
flutter config --enable-web
flutter doctor -v

# 2. Build Web
echo "📦 Running Flutter Pub Get..."
flutter pub get

echo "🏗️ Building Flutter Web (Release)..."
flutter build web --release --no-wasm-dry-run

# 3. Prepare Output
echo "📂 Preparing deployment directory..."
mkdir -p public
cp -r build/web/* public/

# 4. Verification
if [ -f "public/index.html" ]; then
    echo "✅ Build successful! index.html found in public/"
    ls -lah public/
else
    echo "❌ ERROR: build/web/index.html not found!"
    exit 1
fi

echo "✨ Build Pipeline Complete."
