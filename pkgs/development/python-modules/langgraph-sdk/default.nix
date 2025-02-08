{
  lib,
  buildPythonPackage,
  fetchFromGitHub,

  # build-system
  poetry-core,

  # dependencies
  httpx,
  httpx-sse,
  orjson,
  typing-extensions,

  # passthru
  writers,
  requests,
  nix,
}:

buildPythonPackage rec {
  pname = "langgraph-sdk";
  version = "0.1.53";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "langchain-ai";
    repo = "langgraph";
    tag = "sdk==${version}";
    hash = "sha256-Mx/36+FYZi/XNHJwlNRKE/lVo6nRTXUQwtYkq7HmBu0=";
  };

  sourceRoot = "${src.name}/libs/sdk-py";

  build-system = [ poetry-core ];

  dependencies = [
    httpx
    httpx-sse
    orjson
    typing-extensions
  ];

  disabledTests = [ "test_aevaluate_results" ]; # Compares execution time to magic number

  pythonImportsCheck = [ "langgraph_sdk" ];

  passthru.updateScript = writers.writePython3 "langgraph-updater" {
    libraries = [ requests ];
    flakeIgnore = [ "E501" ];
    makeWrapperArgs = [
      "--prefix"
      "PATH"
      ":"
      (lib.makeBinPath [ nix ])
    ];
  } ./update.py;

  meta = {
    description = "SDK for interacting with the LangGraph Cloud REST API";
    homepage = "https://github.com/langchain-ai/langgraphtree/main/libs/sdk-py";
    changelog = "https://github.com/langchain-ai/langgraph/releases/tag/sdk==${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sarahec ];
  };
}
