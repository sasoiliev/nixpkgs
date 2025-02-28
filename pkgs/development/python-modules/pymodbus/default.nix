{
  lib,
  aiohttp,
  buildPythonPackage,
  click,
  fetchFromGitHub,
  prompt-toolkit,
  pygments,
  pyserial,
  pytest-asyncio,
  pytest-xdist,
  pytestCheckHook,
  pythonOlder,
  redis,
  setuptools,
  sqlalchemy,
  twisted,
  typer,
}:

buildPythonPackage rec {
  pname = "pymodbus";
  version = "3.8.1";
  pyproject = true;

  disabled = pythonOlder "3.9";

  src = fetchFromGitHub {
    owner = "pymodbus-dev";
    repo = "pymodbus";
    rev = "refs/tags/v${version}";
    hash = "sha256-WuQddane7NPqGo6EHBPlFAZDmkcksDdWmHKdVSsSf+o=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "--cov-report html " ""
  '';

  build-system = [ setuptools ];

  optional-dependencies = {
    repl = [
      aiohttp
      typer
      prompt-toolkit
      pygments
      click
    ];
    serial = [ pyserial ];
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytest-xdist
    pytestCheckHook
    redis
    sqlalchemy
    twisted
  ] ++ lib.flatten (builtins.attrValues optional-dependencies);

  preCheck = ''
    pushd test
  '';

  postCheck = ''
    popd
  '';

  pythonImportsCheck = [ "pymodbus" ];

  disabledTests =
    [
      # Tests often hang
      "test_connected"
    ]
    ++ lib.optionals (lib.versionAtLeast aiohttp.version "3.9.0") [
      "test_split_serial_packet"
      "test_serial_poll"
      "test_simulator"
    ];

  meta = with lib; {
    description = "Python implementation of the Modbus protocol";
    longDescription = ''
      Pymodbus is a full Modbus protocol implementation using twisted,
      torndo or asyncio for its asynchronous communications core. It can
      also be used without any third party dependencies if a more
      lightweight project is needed.
    '';
    homepage = "https://github.com/pymodbus-dev/pymodbus";
    changelog = "https://github.com/pymodbus-dev/pymodbus/releases/tag/v${version}";
    license = with licenses; [ bsd3 ];
    maintainers = with maintainers; [ fab ];
    mainProgram = "pymodbus.simulator";
  };
}
