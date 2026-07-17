#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DERIVED_DATA_PATH="$PROJECT_ROOT/build/debug"
APP_PATH="$DERIVED_DATA_PATH/Build/Products/Debug/Harvie.app"

echo "Building Harvie (Debug)..."
xcodebuild \
    -project "$PROJECT_ROOT/Harvie.xcodeproj" \
    -scheme Harvie \
    -configuration Debug \
    -destination "platform=macOS" \
    -derivedDataPath "$DERIVED_DATA_PATH" \
    build

echo "Launching $APP_PATH"
open -n "$APP_PATH"
