{
  lib,
  stdenv,
  fetchFromGitHub,
  coreutils,
  findutils,
  gitMinimal,
  gnugrep,
  gnused,
  makeWrapper,
}:

stdenv.mkDerivation rec {
  pname = "helm-git";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "aslafy-z";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-/J/RAFNsxwG9aiCe28daJmC2D6Gz7CrPjucqkhC++y0=";
  };

  nativeBuildInputs = [ makeWrapper ];

  # NOTE: helm-git is comprised of shell scripts.
  dontBuild = true;

  installPhase = ''
    install -dm755 $out/helm-git
    install -m644 -Dt $out/helm-git plugin.yaml
    cp helm-git helm-git-plugin.sh $out/helm-git/

    patchShebangs $out/helm-git/helm-git{,-plugin.sh}
    wrapProgram $out/helm-git/helm-git \
        --prefix PATH : ${
          lib.makeBinPath [
            coreutils
            findutils
            gitMinimal
            gnugrep
            gnused
          ]
        }

    runHook postInstall
  '';

  meta = with lib; {
    description = "Helm downloader plugin that provides GIT protocol support";
    homepage = "https://github.com/aslafy-z/helm-git";
    license = licenses.mit;
    maintainers = with maintainers; [ flokli ];
  };
}
