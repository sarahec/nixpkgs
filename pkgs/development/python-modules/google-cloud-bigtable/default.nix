{
  lib,
  buildPythonPackage,
  fetchFromGitHub,

  # build-system
  setuptools,

  # dependencies
  google-api-core,
  google-auth,
  google-cloud-core,
  google-cloud-monitoring,
  google-crc32c,
  grpc-google-iam-v1,
  grpcio,
  opentelemetry-api,
  opentelemetry-sdk,
  proto-plus,
  protobuf,

  # optional dependencies
  libcst,

  # testing
  mock,
  pytest-asyncio,
  pytestCheckHook,

  # update
  nix-update-script,
}:

buildPythonPackage rec {
  pname = "google-cloud-bigtable";
  version = "2.50.2";

  src = fetchFromGitHub {
    owner = "googleapis";
    repo = "google-cloud-python";
    tag = "google-cloud-bigtable-v${version}";
    hash = "sha256-JFfLSMoa6gxREaG25oauufAyHq53SwtqPgWlB5KVebA=";
  };

  sourceRoot = "${src.name}/packages/google-cloud-bigtable";

  pyproject = true;

  build-system = [ setuptools ];

  pythonRelaxDeps = [
    "protobuf"
  ];

  dependencies = [
    google-api-core
    google-auth
    google-cloud-core
    google-cloud-monitoring
    google-crc32c
    grpcio
    grpc-google-iam-v1
    opentelemetry-api
    opentelemetry-sdk
    proto-plus
    protobuf
  ]
  ++ google-api-core.optional-dependencies.grpc;

  optional-dependencies = {
    libcst = [ libcst ];
  };

  nativeCheckInputs = [
    mock
    pytest-asyncio
    pytestCheckHook
  ];

  preCheck = ''
    # Prevent google directory from shadowing google imports
    rm -r google
  '';

  disabledTests = [ "policy" ];

  disabledTestPaths = [
    # requires credentials
    "samples/"
    "tests/system"
    # duplicate protobuf symbols
    "test_proxy/"
    # checks generated files are in sync with .cross_sync codegen
    "tests/unit/data/test_sync_up_to_date.py"
  ];

  pythonImportsCheck = [
    "google.cloud.bigtable_admin_v2"
    "google.cloud.bigtable_v2"
    "google.cloud.bigtable"
  ];

  # The ATOM feed loses this update most of the time due to a high update volume,
  # so query github directly.
  passthru = {
    # bulk updater uses wrong tag
    skipBulkUpdate = true;
    updateScript = nix-update-script {
      extraArgs = [
        "--version-regex"
        "google-cloud-bigtable-v([0-9.]+)"
        "--use-github-releases"
      ];
    };
  };

  meta = {
    description = "Google Cloud Bigtable API client library";
    homepage = "https://github.com/googleapis/google-cloud-python/tree/main/packages/google-cloud-bigtable";
    changelog = "https://github.com/googleapis/google-cloud-python/blob/google-cloud-bigtable-v${version}/packages/google-cloud-bigtable/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.sarahec ];
  };
}
