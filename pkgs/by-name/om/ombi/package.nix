{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
  autoPatchelfHook,
  fixDarwinDylibNames,
  zlib,
  krb5,
  openssl,
  icu,
  nixosTests,
}:

let
  os = if stdenv.hostPlatform.isDarwin then "osx" else "linux";
  arch =
    {
      x86_64-linux = "x64";
      aarch64-linux = "arm64";
      x86_64-darwin = "x64";
    }
    ."${stdenv.hostPlatform.system}" or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  hash =
    {
      x64-linux_hash = "sha256-5pnHuYjT+O/mlGC+arIofwlAwOWOzyYa4/jK+fstkHs=";
      arm64-linux_hash = "sha256-yBZQuTNPIPCa2LqaRd9rFinJpPvJraAe4xo09mt8RD8=";
      x64-osx_hash = "sha256-VZTFsjB08/plpwv0ErwHbyIiSBGxsXAz92X2AdACN1E=";
    }
    ."${arch}-${os}_hash";

in
stdenv.mkDerivation rec {
  pname = "ombi";
  version = "4.47.1";

  src = fetchurl {
    url = "https://github.com/Ombi-app/Ombi/releases/download/v${version}/${os}-${arch}.tar.gz";
    sha256 = hash;
  };

  sourceRoot = "source";

  unpackPhase = ''
    runHook preUnpack
    mkdir -p "$sourceRoot"
    tar xf $src --directory="$sourceRoot"
    runHook postUnpack
  '';

  nativeBuildInputs = [
    makeWrapper
  ]
  ++ lib.optional stdenv.hostPlatform.isLinux autoPatchelfHook
  ++ lib.optional stdenv.hostPlatform.isDarwin fixDarwinDylibNames;

  propagatedBuildInputs = [
    stdenv.cc.cc
    zlib
    krb5
  ];

  installPhase = ''
    mkdir -p $out/{bin,share/${pname}-${version}}
    cp -r * $out/share/${pname}-${version}

    makeWrapper $out/share/${pname}-${version}/Ombi $out/bin/Ombi \
      --prefix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath [
          openssl
          icu
        ]
      } \
      --chdir "$out/share/${pname}-${version}"
  '';

  passthru = {
    updateScript = ./update.sh;
    tests.smoke-test = nixosTests.ombi;
  };

  meta = with lib; {
    description = "Self-hosted web application that automatically gives your shared Plex or Emby users the ability to request content by themselves";
    homepage = "https://ombi.io/";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    license = licenses.gpl2Only;
    maintainers = with maintainers; [ woky ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
    ];
    mainProgram = "Ombi";
  };
}
