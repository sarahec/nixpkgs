{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  google-api-core,
  google-auth,
  grpcio,
  grpcio-status,
  mock,
  pytestCheckHook,

  # update
  nix-update-script,
}:

buildPythonPackage rec {
  pname = "google-cloud-core";
  version = "2.5.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "googleapis";
    repo = "google-cloud-python";
    tag = "google-cloud-core-v${version}";
    hash = "sha256-lfB544cDaywiGTV0KlecU7oEl2Gbb4Ou8UCp+YjGtOA=";
  };

  sourceRoot = "${src.name}/packages/google-cloud-core";

  build-system = [ setuptools ];

  dependencies = [
    google-auth
    google-api-core
  ];

  optional-dependencies = {
    grpc = [
      grpcio
      grpcio-status
    ];
  };

  nativeCheckInputs = [
    mock
    pytestCheckHook
  ]
  ++ optional-dependencies.grpc;

  # prevent google directory from shadowing google imports
  preCheck = ''
    rm -r google
  '';

  pythonImportsCheck = [ "google.cloud" ];

  # The ATOM feed loses this update most of the time due to a high update volume,
  # so query github directly.
  passthru = {
    # bulk updater uses wrong tag
    skipBulkUpdate = true;
    updateScript = nix-update-script {
      extraArgs = [
        "--version-regex"
        "google-cloud-core-v([0-9.]+)"
        "--use-github-releases"
      ];
    };
  };

  meta = {
    description = "API Client library for Google Cloud: Core Helpers";
    homepage = "https://github.com/googleapis/google-cloud-python/tree/main/packages/google-cloud-core";
    changelog = "https://github.com/googleapis/google-cloud-python/blob/google-cloud-core-v${version}/packages/google-cloud-core/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
