{
  lib,
  buildPythonPackage,
  click,
  fetchFromGitHub,
  justbackoff,
  pyserial-asyncio-fast,
  pythonOlder,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "nessclient";
  version = "1.2.0";
  pyproject = true;

  disabled = pythonOlder "3.8";

  src = fetchFromGitHub {
    owner = "nickw444";
    repo = "nessclient";
    tag = version;
    hash = "sha256-AKZwKEwICuwKyCjIFxx4Zb2r9EriC0+3evBsBE9Btak=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail "version = '0.0.0-dev'" "version = '${version}'"
  '';

  build-system = [ setuptools ];

  dependencies = [
    justbackoff
    pyserial-asyncio-fast
  ];

  optional-dependencies = {
    cli = [ click ];
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  pythonImportsCheck = [ "nessclient" ];

  meta = with lib; {
    description = "Python implementation/abstraction of the Ness D8x/D16x Serial Interface ASCII protocol";
    homepage = "https://github.com/nickw444/nessclient";
    changelog = "https://github.com/nickw444/nessclient/releases/tag/${version}";
    license = licenses.mit;
    maintainers = with maintainers; [ fab ];
    mainProgram = "ness-cli";
  };
}
