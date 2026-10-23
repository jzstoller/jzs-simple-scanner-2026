#!/usr/bin/env bash
set -e

# Usage:
#   ./bump.sh 1.2.5
#
# This will:
#   - bump package.json to 1.2.5
#   - run version-bump.mjs (updates manifest.json + versions.json)
#   - verify the plugin builds locally
#   - commit all changes
#   - create a git tag (1.2.5)
#   - push commit + tag to GitHub; the release workflow then builds,
#     attests, and publishes the release assets

VERSION="$1"

if [ -z "$VERSION" ]; then
  echo "Error: No version provided."
  echo "Usage: ./bump.sh 1.2.5"
  exit 1
fi

echo "🔧 Bumping version to $VERSION"

# 1. Update package.json
npm version "$VERSION" --no-git-tag-version

# 2. Run your Node bump script (updates manifest.json + versions.json)
npm run version

# 3. Local build check (the release build and attestation run in CI)
echo "📦 Verifying build..."
npm run build

# 4. Commit changes
echo "Enter commit message:"
read MESSAGE
git add package.json manifest.json versions.json package-lock.json
git commit -m "Release $VERSION: $MESSAGE"

# 5. Create tag without 'v' prefix
git tag "$VERSION"

# 6. Push commit + tag
echo "🚀 Pushing to GitHub..."
git push
git push origin "$VERSION"

echo "✅ Version bump complete: $VERSION"
echo "⏳ GitHub Actions will build, attest, and publish the release:"
echo "   https://github.com/jzstoller/jzs-simple-scanner-2026/actions"
