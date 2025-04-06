#!/usr/bin/env nix-shell
#!nix-shell -i bash -p common-updater-scripts coreutils

set -euo pipefail

# Map packages to their release names
# Each name is of the form {prefix}{version} where the 
# prefixes don't always match the package names.

# Note that langgraph-prebuilt isn't here. It is a submodule
# of langgraph and updated separately.
declare -Ar packages=(
    [langgraph-checkpoint]="checkpoint=="
    [langgraph-checkpoint-postgres]="checkpointpostgres=="
    [langgraph-checkpoint-sqlite]="checkpointsqlite=="
    [langgraph-cli]="cli=="
    [langgraph-prebuilt]="prebuilt=="
    [langgraph-sdk]="sdk=="
)

tags=$(git ls-remote --tags --refs "https://github.com/langchain-ai/langgraph" | cut --delimiter=/ --field=3-)

# Will be printed as JSON at the end to list what  needs updating
updates=""

baseURL="https://github.com/langchain-ai/langgraph/archive/refs/tags"

# Function to update the source version in the default.nix file
applyUpdate() {
    local package="$1"
    local prefix="$2"
    local oldVersion="$3"
    local newVersion="$4"

    pyPackage="python3Packages.${package}"
    url="${baseURL}/${prefix}${newVersion}.tar.gz"
    hash=$(nix hash convert --to sri --hash-algo sha256 $(nix-prefetch-url $url))
    update-source-version $pyPackage "$newVersion" "$hash"
    updates+="{
    \"attrPath\": \"python3Packages.${pyPackage}\",
    \"oldVersion\": \"$oldVersion\",
    \"newVersion\": \"$newVersion\",
    \"files\": [
        \"$PWD/pkgs/development/python-modules/${package}/default.nix\"
    ]
},"
}

for package in ${!packages[@]}
do
    prefix="${packages[$package]}"
    pyPackage="python3Packages.${package}"
    oldVersion="$(nix-instantiate --eval -E "with import ./. {}; lib.getVersion $pyPackage" | tr -d '"')"
    newVersion=$(echo "$tags" | grep -Po "(?<=${prefix})\d+\.\d+\.\d+$" | sort --version-sort --reverse | head -1 )
    if [[ "$newVersion" != "$oldVersion" ]]; then
        applyUpdate "$package" "$prefix" "$oldVersion" "$newVersion"
    fi
done

# Langgraph's release just has a version number (no prefix)
newLanggraph=$(echo "$tags" | grep -Po "^\d+\.\d+\.\d+$" | sort --version-sort --reverse | head -1 )
oldLanggraph="$(nix-instantiate --eval -E "with import ./. {}; lib.getVersion python3Packages.langgraph" | tr -d '"')"
if [[ "$newLanggraph" != "$oldLanggraph" ]]; then
    applyUpdate "langgraph" "" "$oldLanggraph" "$newLanggraph"
fi

# Remove trailing comma and print the updates
updates=${updates%,}
echo "[ $updates ]"
