{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  pytestCheckHook,
  cython,
  setuptools,
  setuptools-git-versioning,
  toolz,
  python,
}:

buildPythonPackage (finalAttrs: {
  pname = "cytoolz";
  version = "1.1.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "pytoolz";
    repo = "cytoolz";
    tag = finalAttrs.version;
    hash = "sha256-beOEhm7+Nq7oA7iDcdORz03D1InHmypqsYUDUXEUPC0=";
  };

  nativeBuildInputs = [
    cython
    setuptools
    setuptools-git-versioning
  ];

  propagatedBuildInputs = [ toolz ];

  preCheck = ''
    cd $out/${python.sitePackages}
  '';

  nativeCheckInputs = [ pytestCheckHook ];

  meta = {
    homepage = "https://github.com/pytoolz/cytoolz/";
    changelog = "https://github.com/pytoolz/cytoolz/releases/tag/${finalAttrs.src.tag}";
    description = "Cython implementation of Toolz: High performance functional utilities";
    license = lib.licenses.bsd3;
  };
})
