#! /usr/bin/env nix-shell
#! nix-shell -i python3 --packages python3 python3Packages.requests

import requests

REPOS = {
    "": "langgraph",
    "checkpoint": "langgraph-checkpoint",
    "checkpointduckdb": "langgraph-checkpoint-duckdb",
    "checkpointpostgres": "langgraph-checkpoint-postgres",
    "checkpointsqlite": "langgraph-checkpoint-sqlite",
    "cli": "langgraph-cli",
    "sdk": "langgraph-sdk",
}


def fetch_github_tags(repo, count=100):
    url = f"https://api.github.com/repos/{repo}/tags"
    params = {'per_page': count}
    response = requests.get(url, params=params)
    response.raise_for_status()
    return response.json()

if __name__ == "__main__":
    repo = "langchain-ai/langgraph"
    tags = fetch_github_tags(repo)
    for tag in tags:
        print(tag['name'])
