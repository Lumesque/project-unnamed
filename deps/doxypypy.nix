{pkgs, ...}:

let
  dxypy = pkgs.python312Packages.buildPythonApplication {
    name = "doxypypy";
    pname = "doxypypy";
    src = pkgs.fetchFromGitHub {
      owner = "Feneric";
      repo = "doxypypy";
      rev = "364981da1cab240595db853d190a0c7598ba2497";
      hash = "sha256-GfsMD6cTiew3o4PQTouTYV39FDNqDCYjZj5e3aJ8TD0=";
    };

    nativeBuildInputs = [
      (pkgs.python312.withPackages (pp: [
        pp.pytest
        pp.tox
      ]))
    ];

    propagatedBuildInputs = [
      (pkgs.python312.withPackages (pp: [
        pp.chardet
      ]))
    ];

  };
in
  {default = dxypy;}
