{
  lib,
  buildPythonPackage,
  fetchPypi,

  # build-system
  pdm-backend,

  # local dependencies
  black,
  mypy,

  # dependencies
  aiohttp,
  attrs,
  grpcio,
  grpclib,
  httpx-sse,
  httpx-ws,
  httpx,
  mmh3,
  openai,
  pillow,
  protobuf,
  pydantic,
  python-dateutil,
  rich,
  reward-kit,
  toml,
  typing-extensions,

  # optional dependencies
  fastapi,
  gitignore-parser,
  openapi-spec-validator,
  prance,
  safetensors,
  tabulate,
  torch,
  tqdm,
}:

let
  asyncstdlib-fw = buildPythonPackage rec {
    pname = "asyncstdlib_fw";
    version = "3.13.2";
    pyproject = true;

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-Ua0JTCBMWTbDBA84wy/W1UmzkcmA8h8foJW2X7aAah8=";
    };

    build-system = [
      pdm-backend
    ];

    dependencies = [
      black
      mypy
    ];

    pythonImportsCheck = [
      "asyncstdlib"
    ];
  };

  betterproto-fw = buildPythonPackage rec {
    pname = "betterproto_fw";
    version = "2.0.3";
    pyproject = true;

    src = fetchPypi {
      inherit version pname;
      hash = "sha256-ut5GchUiTygHhC2hj+gSWKCoVnZrrV8KIKFHTFzba5M=";
    };

    build-system = [
      pdm-backend
    ];

    dependencies = [
      grpclib
      python-dateutil
      typing-extensions
    ];

    pythonImportsCheck = [
      "betterproto"
    ];

  };
in
buildPythonPackage rec {
  pname = "fireworks-ai";
  version = "0.19.14";
  pyproject = true;

  # no repo
  src = fetchPypi {
    pname = "fireworks_ai";
    inherit version;
    hash = "sha256-m8cw7dTZCtipIEHQDT8t2fhrZmk3mgDGSan1hsmkM9U=";
  };

  build-system = [
    pdm-backend
  ];

  pythonRelaxDeps = [
    "protobuf"
  ];

  dependencies = [
    aiohttp
    asyncstdlib-fw
    attrs
    betterproto-fw
    grpcio
    grpclib
    httpx
    httpx-sse
    httpx-ws
    mmh3
    openai
    pillow
    protobuf
    pydantic
    python-dateutil
    rich
    reward-kit
    toml
    typing-extensions
  ];

  optional-dependencies = {
    flumina = [
      fastapi
      gitignore-parser
      openapi-spec-validator
      prance
      safetensors
      tabulate
      torch
      tqdm
    ];
  };

  # no tests available
  doCheck = false;

  pythonImportsCheck = [
    "fireworks"
  ];

  meta = {
    description = "Client library for the Fireworks.ai platform";
    homepage = "https://pypi.org/project/fireworks-ai/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sarahec ];
  };
}
