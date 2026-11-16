{
  lib,
  fetchFromGitHub,
  buildPythonPackage,

  # build-system
  cython,
  hatchling,
  mypy-protobuf,
  setuptools,

  # dependencies
  cryptography,
  pandas,
  protobuf_33,
  pyarrow,
  pytz,
  tomlkit,

  # check inputs
  brotli,
  hypothesis,
  numpy,
  pytest-cov-stub,
  pytest-xdist,
  pytestCheckHook,
  requests,
  tzdata,
  writableTmpDirAsHomeHook,
  zstandard,
}:

buildPythonPackage (finalAttrs: {
  pname = "snowflake-connector-python";
  version = "5.2.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "snowflakedb";
    repo = "drivers";
    tag = "snowflake-connector-python/${finalAttrs.version}";
    hash = "sha256-DN0leGnaDXorOApbEnEnSdHGKK55v5h+LLGWBrwWrag=";
  };

  sourceRoot = "${finalAttrs.src.name}/python";

  build-system = [
    cython
    hatchling
    mypy-protobuf
    setuptools
  ];

  dependencies = [
    cryptography
    protobuf_33 # upstream requires protobuf 6.x<7
    pytz
    tomlkit
  ];

  optional-dependencies = {
    pandas = [
      pandas
      pyarrow
    ];
  };


  nativeCheckInputs = [
    brotli
    hypothesis
    numpy
    pytest-cov-stub
    pytest-xdist
    pytestCheckHook
    requests
    tzdata
    writableTmpDirAsHomeHook
    zstandard
  ]
  ++ lib.concatAttrValues finalAttrs.passthru.optional-dependencies;

  # disabledTestPaths = [
  #   # Tests require encrypted secrets, see
  #   # https://github.com/snowflakedb/snowflake-connector-python/tree/master/.github/workflows/parameters
  #   "test/extras/simple_select1.py"
  #   "test/integ"
  #   # error getting schema from stream, error code: 0, error info: Expected to
  #   # be able to read 19504 bytes for message body but got 19503
  #   "test/unit/test_connection.py"
  #   "test/unit/test_cursor.py"
  #   "test/unit/test_error_arrow_stream.py"
  #   "test/unit/test_ocsp.py"
  #   "test/unit/test_retry_network.py"
  #   "test/unit/test_s3_util.py"
  #   # AssertionError: /build/source/.wiremock/wiremock-standalone.jar does not exist
  #   "test/unit/test_programmatic_access_token.py"
  #   "test/unit/test_oauth_token.py"
  #   "test/unit/test_proxies.py"
  #   "test/unit/aio/test_programmatic_access_token_async.py"
  #   "test/unit/aio/test_oauth_token_async.py"
  #   "test/unit/aio/test_proxies_async.py"
  #   # aio tests that connect to the internet
  #   "test/unit/aio/test_connection_async_unit.py"
  #   "test/unit/aio/test_ocsp.py"
  #   "test/unit/aio/test_s3_util_async.py::test_accelerate_in_china_endpoint"
  #   "test/unit/aio/test_s3_util_async.py::test_download_expiry_error"
  #   "test/unit/aio/test_s3_util_async.py::test_download_retry_exceeded_error"
  #   "test/unit/aio/test_s3_util_async.py::test_get_header_expiry_error"
  #   "test/unit/aio/test_s3_util_async.py::test_upload_expiry_error"
  #   "test/unit/aio/test_telemetry_async.py"
  #   "test/unit/test_storage_client.py"

  #   # snowflake.connector.errors.ProgrammingError: 251008: 251008: Failed to load private key:
  #   # argument 'password': Cannot convert "<class 'int'>" instance to a buffer.
  #   "test/unit/aio/test_auth_keypair_async.py::test_auth_keypair"
  #   # test/unit/aio/test_connection_async_unit.py - RuntimeError: There is no current event loop in thread 'MainThread'.
  #   "test/unit/aio/test_connection_async_unit.py"
  #   # test/unit/aio/test_secondary_roles_async.py - Failed: 'anyio' not found in `markers` configuration option
  #   "test/unit/aio/test_secondary_roles_async.py"
  #   # AssertionError: /build/source/.wiremock/wiremock-standalone.jar does not exist
  #   "test/unit/aio/test_auth_jwt_error_codes_async.py"
  #   "test/unit/aio/test_result_batch_async.py"
  #   "test/unit/test_auth_jwt_error_codes.py"
  #   "test/unit/test_redirect_retry.py"
  #   "test/unit/test_result_batch.py"
  # ];

  # disabledTests = [
  #   # Tests connect to the internet
  #   "test_aks_path_plumbs_mi_token_to_api"
  #   "test_status_when_num_of_chunks_is_zero"
  #   "test_test_socket_get_cert"
  #   # Missing .wiremock/wiremock-standalone.jar
  #   "test_wiremock"
  # ];

  __darwinAllowLocalNetworking = true;

  pythonImportsCheck = [
    "snowflake"
    "snowflake.connector"
  ];

  meta = {
    description = "Snowflake Connector for Python";
    homepage = "https://github.com/snowflakedb/drivers/tree/main/python";
    changelog = "https://github.com/snowflakedb/drivers/blob/main/python/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ sarahec ];
  };
})
