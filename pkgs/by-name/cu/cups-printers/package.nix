{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "cups-printers";
  version = "1.0.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "audiusGmbH";
    repo = "cups-printers";
    tag = version;
    hash = "sha256-HTR9t9ElQmCzJfdWyu+JQ8xBfDNpXl8XtNsJxGSfBXk=";
  };

  pythonRelaxDeps = [
    "typer"
    "validators"
  ];

  build-system = with python3.pkgs; [ poetry-core ];

  dependencies = with python3.pkgs; [
    pycups
    typer
    validators
  ];

  # Project has no tests
  doCheck = false;

  pythonImportsCheck = [ "cups_printers" ];

  meta = {
    description = "Tool for interacting with a CUPS server";
    homepage = "https://github.com/audiusGmbH/cups-printers";
    changelog = "https://github.com/audiusGmbH/cups-printers/blob/${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "cups-printers";
  };
}
