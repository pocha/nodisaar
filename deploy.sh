#!/bin/bash
set -e

source .env

# Parse flags
BUILD_ANDROID=true
BUILD_IOS=true

for arg in "$@"; do
  case $arg in
    --android-only) BUILD_IOS=false ;;
    --ios-only)     BUILD_ANDROID=false ;;
    *) echo "Unknown flag: $arg"; echo "Usage: ./deploy.sh [--android-only | --ios-only]"; exit 1 ;;
  esac
done

# Extract version from pubspec.yaml (e.g. 1.1.1+2 → 1.1.1)
VERSION=$(grep '^version:' pubspec.yaml | sed 's/version: //' | cut -d'+' -f1)
APK_NAME="nodisaar-v${VERSION}.apk"
STORAGE_PATH="gs://nodi-saar.firebasestorage.app/releases/${APK_NAME}"
PUBLIC_URL="https://storage.googleapis.com/nodi-saar.firebasestorage.app/releases/${APK_NAME}"

echo "Deploying version ${VERSION}..."

if $BUILD_ANDROID; then
  echo "Building Android..."
  flutter build apk --split-per-abi --release

  echo "Uploading ${APK_NAME} to Firebase Storage..."
  gcloud storage cp \
    build/app/outputs/flutter-apk/app-arm64-v8a-release.apk \
    "${STORAGE_PATH}"

  gcloud storage objects update \
    "${STORAGE_PATH}" \
    --add-acl-grant=entity=allUsers,role=READER

  echo "Updating index.html with new APK link..."
  sed -i '' "s|const ANDROID_LINK.*|const ANDROID_LINK    = '${PUBLIC_URL}';|" index.html
fi

if $BUILD_IOS; then
  echo "Building iOS..."
  flutter build ipa

  echo "Uploading to TestFlight..."
  xcrun altool --upload-app \
    -f build/ios/ipa/nodisaar.ipa \
    -t ios \
    --apiKey $ASC_KEY_ID \
    --apiIssuer $ASC_ISSUER_ID
fi

echo "Done! 🚀 Version ${VERSION} deployed."