{
  buildPythonPackage,
  tensorflow,
  numpy,
  pytest,
  mypy,
  black,
  flake8,
  keras,
  setuptools,
}:

buildPythonPackage {
  pname = "xor-neural-net";
  version = "0.1.0";
  pyproject = true;

  src = ./.;

  build-system = [
    setuptools
  ];

  dependencies = [
    tensorflow
    numpy
    keras
  ];

  nativeCheckInputs = [
    pytest
    mypy
    black
    flake8
  ];

  pythonImportsCheck = [
    "xor_neural_net.model"
  ];
}
