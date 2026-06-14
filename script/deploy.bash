#!/bin/bash

# Asset precompile fails on docker build due to bug with hardware architecture and tailwind gem.
# This script runs the full deployment pipeline to work around this:
# 1. Checkout out temp deploy branch
# 2. Precompile assets
# 3. Commit asset build in assets/ (git doesn't commit this, so kamal doesn't see it)
# 4. Run Kamal deploy
# 5. Clean up deploy branch

set -e

TEMP_BRANCH="kamal-deploy-$(date +%s)"

# load env variables
set -a
source .env.production
set +a

# check if work director is clean
if [ -n "$(git status --porcelain)" ]; then
  echo "❌ Error: Your working directory has uncommitted changes. Clean them up first."
  exit 1
fi

# 5. clean up trap, runs no matter what
cleanup() {
  echo "🧹 Cleaning up deployment artifacts..."
  git checkout -f main > /dev/null 2>&1
  git branch -D "$TEMP_BRANCH" > /dev/null 2>&1
  echo "✨ Back on main. Temp branch deleted."
}
trap cleanup EXIT

echo "🚀 Starting deployment workflow..."

# 1.
git checkout main
git fetch origin main
git pull origin main
git checkout -b "$TEMP_BRANCH"

# 2.
echo "📦 Precompiling assets..."
RAILS_ENV=production SECRET_KEY_BASE_DUMMY=1 bin/rails assets:precompile

# 3.
echo "💾 Committing assets to temporary branch..."
cp -r /public/assets /assets
git add assets/
git commit -m "Internal: Compiled assets for Kamal deployment" --allow-empty

# 4.
echo "🚢 Deploying with Kamal..."
kamal deploy

echo "🎉 Deployment successful!"
