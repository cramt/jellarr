{
  lib,
  pkgs,
  ...
}:
pkgs.stdenvNoCC.mkDerivation (finalAttrs: {
  buildPhase = ''
    runHook preBuild
    pnpm build
    runHook postBuild
  '';

  checkPhase = ''
    runHook preCheck
    pnpm test
    runHook postCheck
  '';

  CI = "true";

  installPhase = ''
    runHook preInstall
    install -Dm644 -t $out/share bundle.cjs
    makeWrapper ${lib.getExe pkgs.nodejs_24} $out/bin/jellarr \
      --add-flags "$out/share/bundle.cjs"
    runHook postInstall
  '';

  meta = {
    description = "Declarative Jellyfin configuration engine (TypeScript, bundled)";
    homepage = "https://github.com/venkyr77/jellarr";
    license = lib.licenses.agpl3Only;
    mainProgram = "jellarr";
    platforms = lib.platforms.all;
  };

  nativeBuildInputs = [
    pkgs.makeBinaryWrapper
    pkgs.nodejs_24
    pkgs.pnpm.configHook
  ];

  pname = "jellarr";

  pnpmDeps = pkgs.pnpm.fetchDeps {
    # fetcherVersion 3 was dropped for pnpm_11 (nixpkgs assert in
    # build-support/node/fetch-pnpm-deps). pnpm 11.9.0 needs fetcherVersion 4.
    # See https://nixos.org/manual/nixpkgs/stable/#javascript-pnpm-fetcherVersion.
    fetcherVersion = 4;
    hash = "sha256-jo1BjRAjjfNKF0xb5cLCuELSveHeJ98iLPhMDKP1QbI=";
    inherit (finalAttrs) pname src version;
  };

  src = ../.;

  version = "0.1.0";
})
