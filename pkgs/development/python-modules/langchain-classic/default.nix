{
  lib,
  buildPythonPackage,
  fetchFromGitHub,

  # build-system
  hatchling,

  # dependencies
  langchain-core,
  langchain-text-splitters,
  langsmith,
  pydantic,
  pyyaml,
  requests,
  sqlalchemy,

  # tests
  blockbuster,
  cffi,
  freezegun,
  langchain-openai,
  langchain-tests,
  lark,
  numpy,
  pandas,
  pytest-asyncio,
  pytest-dotenv,
  pytest-mock,
  pytest-socket,
  pytest-xdist,
  pytestCheckHook,
  requests-mock,
  responses,
  syrupy,
  toml,
}:

buildPythonPackage rec {
  pname = "langchain-classic";
  version = "1.0.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "langchain-ai";
    repo = "langchain";
    # no tagged releases avaialble
    rev = "47d89b1e47ba7d3ae434e4b191b910bfcccfa014";
    hash = "sha256-s7FXcUls5wcyn5W/t2Htt0DEQR0lNIXlSZm6QpPvqSU=";
  };

  sourceRoot = "${src.name}/libs/langchain";

  build-system = [ hatchling ];

  pythonRelaxDeps = [
    # Each component release requests the exact latest core.
    "langchain-core"
  ];

  propagatedBuildInputs = [
    langchain-core
    langchain-text-splitters
    langsmith
    pydantic
    pyyaml
    requests
    sqlalchemy
  ];

  checkInputs = [
    pytestCheckHook
    pytest-dotenv
    pytest-asyncio
    pytest-mock
    pytest-socket
    pytest-xdist
    numpy
    cffi
    freezegun
    responses
    lark
    pandas
    syrupy
    requests-mock
    blockbuster
    toml
    langchain-tests
    langchain-core
    langchain-text-splitters
    langchain-openai
  ];

  meta = {
    description = "Classic version of LangChain library for building applications with LLMs";
    homepage = "https://github.com/langchain-ai/langchain/tree/master/libs/langchain";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sarahec ];
  };
}
