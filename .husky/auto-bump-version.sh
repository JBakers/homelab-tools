#!/bin/bash
# Auto-bump VERSION file and update commit message
# Called by .husky/prepare-commit-msg

COMMIT_MSG_FILE=$1
COMMIT_SOURCE=$2

# Check if VERSION file exists
if [[ ! -f VERSION ]]; then
    exit 0
fi

# Skip for merge/squash/amend commits
if [[ -n "$COMMIT_SOURCE" ]]; then
    exit 0
fi

CURRENT=$(cat VERSION)

# Only bump dev versions
if [[ ! "$CURRENT" =~ -dev\. ]]; then
    exit 0
fi

# Extract and bump
if [[ "$CURRENT" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)-dev\.([0-9]+)$ ]]; then
    MAJOR="${BASH_REMATCH[1]}"
    MINOR="${BASH_REMATCH[2]}"
    PATCH="${BASH_REMATCH[3]}"
    BUILD="${BASH_REMATCH[4]}"
    
    BUILD=$((10#$BUILD))
    
    if [[ $BUILD -ge 9 ]]; then
        NEW_PATCH=$((PATCH + 1))
        BASE="${MAJOR}.${MINOR}.${NEW_PATCH}"
        NEW_BUILD=0
    else
        BASE="${MAJOR}.${MINOR}.${PATCH}"
        NEW_BUILD=$((BUILD + 1))
    fi
    
    NEW_VERSION="${BASE}-dev.$(printf "%02d" $NEW_BUILD)"
    
    # Update VERSION file
    echo "$NEW_VERSION" > VERSION
    
    # Stage VERSION
    git add VERSION
    
    # Prepend version to commit message
    ORIGINAL_MSG=$(cat "$COMMIT_MSG_FILE")
    echo "[${NEW_VERSION}] ${ORIGINAL_MSG}" > "$COMMIT_MSG_FILE"
    
    echo "🔄 Auto-bumped: $CURRENT → $NEW_VERSION"
fi

exit 0
