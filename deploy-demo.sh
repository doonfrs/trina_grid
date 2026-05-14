#!/bin/bash

set -e

BRANCH="gh-pages"
DEMO_DIR="demo"
BUILD_DIR="$DEMO_DIR/build/web"
TMP_DIR="../trina_grid_build_web_tmp"

echo "🚀 Building Flutter Web Demo..."

git checkout main
git pull origin main

cd $DEMO_DIR
flutter pub get
flutter build web --release
cd ..

echo "Build Completed!"

git checkout $BRANCH

echo "Preventing build folder from being deleted..."
rm -rf "$TMP_DIR"
mv "$BUILD_DIR" "$TMP_DIR"

echo "Cleaning old deployment files..."
git rm -rf . --quiet 2>/dev/null || true
git clean -fd --quiet 2>/dev/null || true

echo "🔁 Moving demo build files to the repository root..."
mv "$TMP_DIR"/* .
mv "$TMP_DIR"/.[!.]* . 2>/dev/null || true

rm -rf "$TMP_DIR"

# Copy llm.txt files for AI agent discoverability
git checkout main -- llm.txt llms-full.txt 2>/dev/null || true

git add .
git commit -m "🚀 Deploy updated Flutter Web Demo"
git push origin $BRANCH

git checkout main

flutter pub get
cd demo
flutter pub get
cd ..

echo "🎉 Deployment Completed!"
