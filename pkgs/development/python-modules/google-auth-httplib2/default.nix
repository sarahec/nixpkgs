{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  flask,
  google-auth,
  httplib2,
  mock,
  pytest-localserver,
  pytestCheckHook,

  # update
  nix-update-script,
}:

buildPythonPackage rec {
  pname = "google-auth-httplib2";
  version = "0.4.4";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "googleapis";
    repo = "google-cloud-python";
    tag = "google-auth-httplib2-v${version}";
    hash = "sha256-b0FYupZU0ZNeIL9xJIqEXgg7ToRCQLjiswJ67YzX7OI=";
  };

  sourceRoot = "${src.name}/packages/google-auth-httplib2";

  build-system = [ setuptools ];

  dependencies = [
    google-auth
    httplib2
  ];

  __darwinAllowLocalNetworking = true;

  nativeCheckInputs = [
    flask
    mock
    pytestCheckHook
    pytest-localserver
  ];

  # The ATOM feed loses this update most of the time due to a high update volume,
  # so query github directly.
  passthru = {
    # bulk updater uses wrong tag
    skipBulkUpdate = true;
    updateScript = nix-update-script {
      extraArgs = [
        "--version-regex"
        "google-auth-httplib2-v([0-9.]+)"
        "--use-github-releases"
      ];
    };
  };

  meta = {
    description = "Google Authentication Library: httplib2 transport";
    homepage = "https://github.com/googleapis/google-cloud-python/tree/main/packages/google-auth-httplib2";
    changelog = "https://github.com/googleapis/google-cloud-python/blob/google-auth-httplib2-v${version}/packages/google-auth-httplib2/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.sarahec ];
  };
}
