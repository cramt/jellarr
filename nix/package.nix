{
  lib,
  pkgs,
  ...
}:
let
  # pnpm-lock.yaml is lockfileVersion 9, written by pnpm 11. nixpkgs promoted
  # `pkgs.pnpm` to the Rust rewrite (12), which resolves into a different store
  # layout and so invalidates pnpmDeps.hash. Pin the resolver to the major that
  # wrote the lockfile; bump both together when the lockfile is regenerated.
  pnpm = pkgs.pnpm_11;
in
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

  # pnpmConfigHook no longer carries a pnpm of its own (the deprecated
  # `pnpm.configHook` propagated one), so the resolver goes in explicitly.
  nativeBuildInputs = [
    pkgs.makeBinaryWrapper
    pkgs.nodejs_24
    pkgs.pnpmConfigHook
    pnpm
  ];

  pname = "jellarr";

  # `pnpm.fetchDeps` / `pnpm.configHook` were deprecated in favour of the
  # top-level attributes and are absent from pnpm 12 entirely.
  pnpmDeps = pkgs.fetchPnpmDeps {
    inherit pnpm;
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
