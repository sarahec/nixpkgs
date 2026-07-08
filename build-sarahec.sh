#!/usr/bin/env bash
set -euo pipefail

export NIXPKGS_ALLOW_UNFREE=1

BUILDER="nix-build"
DRY_RUN_FLAG=""
SANDBOX_FLAG=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --help)
      echo "Usage: $(basename "$0") [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --builder <tool>  Build tool to use (default: nix-build)"
      echo "  --dry-run         Pass --dry-run to each build command"
      echo "  --no-sandbox      Pass --option sandbox false to each build command"
      echo "  --help            Show this help message"
      exit 0
      ;;
    --dry-run)
      DRY_RUN_FLAG="--dry-run"
      shift
      ;;
    --builder)
      BUILDER="$2"
      shift 2
      ;;
    --no-sandbox)
      SANDBOX_FLAG="--option sandbox false"
      shift
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

build() {
  echo "$1"
  $BUILDER -A "$1" -j 1 --cores 0 $DRY_RUN_FLAG $SANDBOX_FLAG
}

# Packages in pkgs/by-name
build dbmate
build devin-desktop
build dgraph
build firebase-tools
build sqlite-vec
# build vivaldi-ffmpeg-codecs

# No python 3.14 support for aws-sam-translator
build "python313Packages.spacy"
build "python313Packages.torchao"

# Packages in pkgs/development/python-modules (build for python 3.13 and 3.14)
for pkg in \
  anthropic \
  antlr4-python3-runtime \
  betterproto-rust-codec \
  cairosvg \
  chromadb \
  compressed-tensors \
  curl-cffi \
  cytoolz \
  datadog \
  dulwich \
  fickling \
  firebase-admin \
  gguf \
  google-api-core \
  google-api-python-client \
  google-auth-httplib2 \
  google-auth-oauthlib \
  google-auth \
  google-cloud-asset \
  google-cloud-bigtable \
  google-cloud-datacatalog \
  google-cloud-firestore \
  google-cloud-iam \
  google-cloud-kms \
  google-cloud-netapp \
  google-cloud-storage \
  google-cloud-testutils \
  googleapis-common-protos \
  groq \
  gstools-cython \
  httpx-aiohttp \
  ibis-framework \
  langchain-anthropic \
  langchain-aws \
  langchain-azure-dynamic-sessions \
  langchain-chroma \
  langchain-classic \
  langchain-community \
  langchain-core \
  langchain-deepseek \
  langchain-fireworks \
  langchain-google-genai \
  langchain-groq \
  langchain-mistralai \
  langchain-mongodb \
  langchain-ollama \
  langchain-openai \
  langchain-perplexity \
  langchain-protocol \
  langchain-tests \
  langchain-text-splitters \
  langchain-xai \
  langchain \
  langgraph-checkpoint-mongodb \
  langgraph-checkpoint-postgres \
  langgraph-checkpoint-sqlite \
  langgraph-checkpoint \
  langgraph-cli \
  langgraph-prebuilt \
  langgraph-runtime-inmem \
  langgraph-sdk \
  langgraph-store-mongodb \
  langgraph \
  langsmith \
  limits \
  llm-anthropic \
  m2crypto \
  mmh3 \
  opentelemetry-resourcedetector-gcp \
  ormsgpack \
  parfive \
  perplexityai \
  pgmpy \
  pipcl \
  plotly \
  prompt-toolkit \
  pycrdt-store \
  pymongo-search-utils \
  pymupdf \
  pyspark \
  sqlite-vec \
  tables \
  typedunits \
  unidns \
  uuid-utils \
  yamlloader
do
  build "python313Packages.$pkg"
  build "python314Packages.$pkg"
done

# Removed:
# langchain-huggingface # needs python3.13-dlinfo-2.0.0
# scalene  # unsupported on Darwin
# spacy  # no python 3.14 support
# torchao # no python 3.14 support
# datalad Build failure in dependency `unar`, need to check 
# fireworks-ai # overly specified pydantic dependency (has PR)
# google-cloud-error-reporting # RuntimeError: There is no current event loop in thread 'MainThread'.
# google-cloud-spanner (same)
