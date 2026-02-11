#!/bin/bash

# EcoSnap Quick Setup Script
# This script automates the initial setup process

set -e

echo "🌱 EcoSnap - Quick Setup Script"
echo "================================"
echo ""

# Check Flutter installation
echo "📱 Checking Flutter installation..."
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed!"
    echo "Please install Flutter from: https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "✅ Flutter found: $(flutter --version | head -n 1)"
echo ""

# Run Flutter doctor
echo "🔍 Running Flutter doctor..."
flutter doctor
echo ""

# Install dependencies
echo "📦 Installing Flutter dependencies..."
flutter pub get
echo "✅ Dependencies installed"
echo ""

# Check for google-services.json
echo "🔥 Checking Firebase configuration..."
if [ ! -f "android/app/google-services.json" ]; then
    echo "⚠️  WARNING: google-services.json not found!"
    echo ""
    echo "Please complete Firebase setup:"
    echo "1. Go to https://console.firebase.google.com/"
    echo "2. Create a new project or select existing"
    echo "3. Add Android app with package name: com.ecosnap.app"
    echo "4. Download google-services.json"
    echo "5. Place it in: android/app/google-services.json"
    echo ""
    read -p "Press Enter when you've completed Firebase setup..."
fi

if [ -f "android/app/google-services.json" ]; then
    echo "✅ Firebase configuration found"
else
    echo "❌ Firebase configuration still missing. Setup cannot continue."
    exit 1
fi
echo ""

# Check for TensorFlow Lite model
echo "🤖 Checking TensorFlow Lite model..."
if [ ! -f "assets/models/waste_classifier.tflite" ]; then
    echo "⚠️  WARNING: TensorFlow Lite model not found!"
    echo ""
    echo "You have two options:"
    echo ""
    echo "Option 1 - Use pre-trained model (Quick):"
    echo "  Download MobileNetV2 from TensorFlow:"
    echo "  https://www.tensorflow.org/lite/guide/hosted_models"
    echo ""
    echo "Option 2 - Train custom model (Recommended):"
    echo "  1. Install Python dependencies:"
    echo "     cd ml_model && pip install -r requirements.txt"
    echo "  2. Prepare your dataset of waste images"
    echo "  3. Run: python train_model.py"
    echo "  4. Copy generated waste_classifier.tflite to assets/models/"
    echo ""
    read -p "Press Enter when you've added the model file..."
fi

if [ -f "assets/models/waste_classifier.tflite" ]; then
    echo "✅ TensorFlow Lite model found"
else
    echo "⚠️  Model still missing. App will use placeholder classification."
fi
echo ""

# Clean and prepare project
echo "🧹 Cleaning project..."
flutter clean
echo "✅ Project cleaned"
echo ""

echo "📦 Getting dependencies again..."
flutter pub get
echo "✅ Dependencies ready"
echo ""

# Check for connected devices
echo "📱 Checking for connected devices..."
flutter devices
echo ""

echo "✅ Setup Complete!"
echo ""
echo "Next steps:"
echo "1. Connect an Android device or start an emulator"
echo "2. Run: flutter run"
echo ""
echo "For detailed setup instructions, see README.md"
echo ""
echo "Happy coding! 🚀"
