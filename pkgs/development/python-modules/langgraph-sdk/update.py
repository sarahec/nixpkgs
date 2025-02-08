#1 /usr/bin/env nix-shell
#! nix-shell -i python -p python3 python3.pkgs.requests
import requests
import os
import subprocess
import json
import argparse
from collections import defaultdict

PACKAGES = [
    "langgraph",
    "langgraph-checkpoint",
    "langgraph-cli",
    "langgraph-checkpoint-duckdb",
    "langgraph-checkpoint-postgres",
    "langgraph-checkpoint-sqlite",
    "langgraph-sdk"
]

# Map package names back to their tag prefixes
PACKAGE_TO_PREFIX = {
    "langgraph": "langgraph",
    "langgraph-checkpoint": "checkpoint",
    "langgraph-cli": "cli",
    "langgraph-checkpoint-duckdb": "checkpointduckdb",
    "langgraph-checkpoint-postgres": "checkpointpostgres",
    "langgraph-checkpoint-sqlite": "checkpointsqlite",
    "langgraph-sdk": "sdk"
}


def get_installed_version(package, nixpkgs_path, verbose=False):
    cmd = f'nix-instantiate --expr "with import {nixpkgs_path} {{}}; lib.getVersion python312Packages.{package}" --eval --strict --json'
    try:
        result = subprocess.run(
            cmd, shell=True, check=True, capture_output=True, text=True)
        version = json.loads(result.stdout.strip())
        return version
    except subprocess.CalledProcessError as e:
        if verbose:
            print(f"Failed to get installed version for {package}: {e}")
        return None
    except json.JSONDecodeError as e:
        if verbose:
            print(f"Failed to parse version for {package}: {e}")
        return None


def fetch_tags(repo, page=1, verbose=False):
    url = f'https://api.github.com/repos/{repo}/tags?per_page=100&page={page}'
    headers = {}
    if "GITHUB_TOKEN" in os.environ:
        headers["Authorization"] = f"Bearer {os.environ['GITHUB_TOKEN']}"

    response = requests.get(url, headers=headers)
    if response.status_code == 200:
        return [tag['name'] for tag in response.json()]
    else:
        if verbose:
            print(f'Failed to fetch tags: {response.status_code}')
        return []


def extract_latest_versions(tags):
    # Create dictionary to store highest version for each package
    package_versions = defaultdict(str)

    for tag in tags:
        if '==' in tag:
            # Handle prefix==version format
            prefix, version = tag.split('==')
            # Map prefix back to package name if it exists
            for package, pkg_prefix in PACKAGE_TO_PREFIX.items():
                if pkg_prefix == prefix and version > package_versions[package]:
                    package_versions[package] = version
        elif tag[0].isdigit():
            # Handle X.Y.Z format (langgraph)
            if tag > package_versions['langgraph']:
                package_versions['langgraph'] = tag

    return dict(package_versions)


def get_update_commands(package_versions, nixpkgs_path, verbose=False):
    commands = []
    for package in sorted(PACKAGES):
        new_version = package_versions.get(package)
        if new_version:
            current_version = get_installed_version(
                package, nixpkgs_path, verbose)
            if current_version is None:
                if verbose:
                    print(
                        f"Warning: Could not determine current version for {package}, including in update")
                cmd = f'nix-update --commit --version {new_version} python312Packages.{package}'
                commands.append((package, current_version, new_version, cmd))
            elif new_version > current_version:
                cmd = f'nix-update --commit --version {new_version} python312Packages.{package}'
                commands.append((package, current_version, new_version, cmd))
            elif verbose:
                print(
                    f"Skipping {package}: current version {current_version} >= new version {new_version}")
    return commands


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description='Update LangGraph package versions')
    parser.add_argument('--dry-run', action='store_true',
                        help='Print commands without executing them')
    parser.add_argument('-v', '--verbose', action='store_true',
                        help='Show detailed progress')
    parser.add_argument('--nixpkgs', default='.',
                        help='Path to nixpkgs (default: .)')
    args = parser.parse_args()

    repo = 'langchain-ai/langgraph'
    current_page = 1
    all_tags = []
    package_versions = {}
    found_packages = set()

    while len(found_packages) < len(PACKAGES):
        page_tags = fetch_tags(repo, current_page, args.verbose)

        if not page_tags:  # No more tags to fetch
            break

        all_tags.extend(page_tags)
        package_versions = extract_latest_versions(all_tags)
        found_packages = set(package_versions.keys())
        current_page += 1

    commands = get_update_commands(
        package_versions, args.nixpkgs, args.verbose)

    if args.dry_run:
        if args.verbose:
            print('\nAvailable updates:')
            print('-' * 50)
            print(f"{'Package':<40} {'Current':<10} {'New':<10}")
            print('-' * 50)
        for package, current, new, cmd in commands:
            if args.verbose:
                print(f"{package:<40} {current or 'unknown':<10} {new:<10}")
            print(cmd)
    else:
        if args.verbose:
            print('\nExecuting update commands:')
            print('-' * 50)
        for _, _, _, cmd in commands:
            if args.verbose:
                print(f"Running: {cmd}")
            try:
                subprocess.run(cmd, shell=True, check=True)
                if args.verbose:
                    print(" Success")
            except subprocess.CalledProcessError as e:
                print(f" Failed with exit code {e.returncode}")
            if args.verbose:
                print()
