{
  lib,
  stdenv,
  buildPythonPackage,
  fetchFromGitHub,

  # dependencies
  google-generativeai,
  huggingface-hub,
  joblib,
  networkx,
  numpy,
  opt-einsum,
  pandas,
  pyparsing,
  pyro-ppl,
  scikit-base,
  scikit-learn,
  scipy,
  statsmodels,
  torch,
  tqdm,
  xgboost,

  # tests
  jsonschema,
  pytestCheckHook,
  pytest-cov-stub,
  mock,
  writableTmpDirAsHomeHook,
}:
buildPythonPackage (finalAttrs: {
  pname = "pgmpy";
  version = "1.1.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "pgmpy";
    repo = "pgmpy";
    tag = "v${finalAttrs.version}";
    hash = "sha256-qZoyeUaRsatWUiFoL1VaRqApjM/AFS8xqTjVBcUpYas=";
  };

  dependencies = [
    google-generativeai
    huggingface-hub
    joblib
    networkx
    numpy
    opt-einsum
    pandas
    pyparsing
    pyro-ppl
    scikit-base
    scikit-learn
    scipy
    statsmodels
    torch
    tqdm
    xgboost
  ];

  disabledTests = [
    # flaky:
    # AssertionError: -45.78899127622197 != -45.788991276221964
    "test_score"

    # self.assertTrue(np.isclose(coef, dep_coefs[i], atol=1e-4))
    # AssertionError: False is not true
    "test_pillai"

    # requires optional dependency daft
    "test_to_daft"

    # AssertionError
    "test_estimate_example_smoke_test"
    "test_gcm"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # Failures due to numeric precision differences on Darwin
    "test_generalized_cov_approx"
    "test_hotelling_indep"
    "test_roys_no_cond"
    "test_roys_indep"
    "test_roys_dependent"
    "test_wilks_indep"
  ];

  enabledTestPaths = [
    "pgmpy/tests"
  ];

  disabledTestPaths = [
    # requires network access
    "pgmpy/tests/test_datasets"

    # Very slow
    "pgmpy/tests/test_estimators"
    "pgmpy/tests/test_models"
  ];

  nativeCheckInputs = [
    jsonschema
    pytestCheckHook
    pytest-cov-stub
    mock
    writableTmpDirAsHomeHook
  ];

  pythonImportsCheck = [ "pgmpy" ];

  meta = {
    description = "Python Library for learning (Structure and Parameter), inference (Probabilistic and Causal), and simulations in Bayesian Networks";
    homepage = "https://github.com/pgmpy/pgmpy";
    changelog = "https://github.com/pgmpy/pgmpy/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [
      happysalada
      sarahec
    ];
  };
})
