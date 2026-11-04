{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  google-auth,
  googleapis-common-protos,
  grpcio,
  grpcio-gcp,
  grpcio-status,
  proto-plus,
  protobuf,
  pytest-asyncio,
  pytest-mock,
  pytestCheckHook,
  requests,
  setuptools,

  # update
  nix-update-script,
}:

buildPythonPackage rec {
  pname = "google-api-core";
  version = "2.29.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "googleapis";
    repo = "google-cloud-python";
    tag = "google-api-core-v${version}";
    hash = "sha256-/5P6zgeK1enOVpi4Vx18BQrs66coPJzSwwy7AYfbBJk=";
  };

  sourceRoot = "${src.name}/packages/google-api-core";

  build-system = [ setuptools ];

  dependencies = [
    googleapis-common-protos
    google-auth
    protobuf
    proto-plus
    requests
  ];

  pythonRelaxDeps = [ "protobuf" ];

  optional-dependencies = {
    async_rest = [ google-auth ] ++ google-auth.optional-dependencies.aiohttp;
    grpc = [
      grpcio
      grpcio-status
    ];
    grpcgcp = [ grpcio-gcp ];
    grpcio-gcp = [ grpcio-gcp ];
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytest-mock
    pytestCheckHook
  ];

  pytestFlags = [
    "-Wignore::pytest.PytestRemovedIn10Warning"
  ];

  # prevent google directory from shadowing google imports
  preCheck = ''
    rm -r google
  '';

  disabledTests = [
    # Those grpc_helpers tests are failing
    "test_wrap_unary_errors"
    "test_wrap_stream_errors_raised"
    "test_wrap_stream_errors_read"
    "test_wrap_stream_errors_aiter"
    "test_wrap_stream_errors_write"
    "test_wrap_unary_errors"
    "test___next___w_rpc_error"
    "test_wrap_stream_errors_invocation"
    "test_wrap_stream_errors_iterator_initialization"
    "test_wrap_stream_errors_during_iteration"
    "test_exception_with_error_code"
  ];

  pythonImportsCheck = [ "google.api_core" ];

  # The ATOM feed loses this update most of the time due to a high update volume,
  # so query github directly.
  passthru = {
    # bulk updater uses wrong tag
    skipBulkUpdate = true;
    updateScript = nix-update-script {
      extraArgs = [
        "--version-regex"
        "google-api-core-v([0-9.]+)"
        "--use-github-releases"
      ];
    };
  };

  meta = {
    description = "Core Library for Google Client Libraries";
    longDescription = ''
      This library is not meant to stand-alone. Instead it defines common
      helpers used by all Google API clients.
    '';
    homepage = "https://github.com/googleapis/google-cloud-python/tree/main/packages/google-api-core";
    changelog = "https://github.com/googleapis/google-cloud-python/blob/google-api-core-v${version}/packages/google-api-core/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [
      sarahec
    ];
  };
}
