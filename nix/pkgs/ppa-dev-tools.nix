{ lib, python3Packages, fetchgit }:

python3Packages.buildPythonApplication {
  pname = "ppa-dev-tools";
  version = "0.9.0";
  pyproject = true;

  src = fetchgit {
    url = "https://git.launchpad.net/ppa-dev-tools";
    rev = "de115c725287ada31d9ef78b3a7a11c0557c4494";
    hash = "sha256-CZ6jjWXTRCNzhH0ghBszPnQck/Sr9RpK0Kcj0lCEbGs=";
  };

  # upstream pins setuptools == 68.1.2
  postPatch = ''
    substituteInPlace pyproject.toml --replace-fail '"setuptools == 68.1.2"' '"setuptools"'
  '';

  build-system = with python3Packages; [ setuptools wheel ];

  dependencies = with python3Packages; [
    click
    distro-info
    launchpadlib
    lazr-restfulclient
    pyyaml
    python-apt # only needed for `ppa tests --show-rdepends`
  ];

  pythonRelaxDeps = true;
  doCheck = false;

  meta = {
    description = "Command line client for managing PPAs in Launchpad";
    homepage = "https://launchpad.net/ppa-dev-tools";
    license = lib.licenses.gpl2Only;
    mainProgram = "ppa";
  };
}
