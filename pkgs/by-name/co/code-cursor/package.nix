{
  lib,
  stdenvNoCC,
  fetchurl,
  appimageTools,
  makeWrapper,
  undmg,
}:
let
  pname = "cursor";
  version = "0.47.8";

  inherit (stdenvNoCC) hostPlatform;

  sources = {
    x86_64-linux = fetchurl {
      url = "https://downloads.cursor.com/production/82ef0f61c01d079d1b7e5ab04d88499d5af500e3/linux/x64/Cursor-0.47.8-82ef0f61c01d079d1b7e5ab04d88499d5af500e3.deb.glibc2.25-x86_64.AppImage";
      hash = "sha256-3Ph5A+x1hW0SOaX8CF7b/8Fq7eMeBkG1ju9vud6Cbn0=";
    };
    # Cursor's release for aarch64-linux is unavailable (for now)e.
    # aarch64-linux = fetchurl {
    #   url = "https://download.todesktop.com/230313mzl4w4u92/cursor-0.45.14-build-250219jnihavxsz-arm64.AppImage";
    #   hash = "sha256-8OUlPuPNgqbGe2x7gG+m3n3u6UDvgnVekkjJ08pVORs=";
    # };
    x86_64-darwin = fetchurl {
      url = "https://downloads.cursor.com/production/82ef0f61c01d079d1b7e5ab04d88499d5af500e3/darwin/x64/Cursor-darwin-x64.dmg";
      hash = "sha256-T5N8b/6HexQ2ZchWUb9CL3t9ks93O9WJgrDtxfE1SgU=";
    };
    aarch64-darwin = fetchurl {
      url = "https://downloads.cursor.com/production/82ef0f61c01d079d1b7e5ab04d88499d5af500e3/darwin/arm64/Cursor-darwin-arm64.dmg";
      hash = "sha256-ycroylfEZY/KfRiXvfOuTdyyglbg/J7DU12u6Xrsk0s=";
    };
  };

  source = sources.${hostPlatform.system};

  # Linux -- build from AppImage
  appimageContents = appimageTools.extractType2 {
    inherit version pname;
    src = source;
  };

  wrappedAppimage = appimageTools.wrapType2 {
    inherit version pname;
    src = source;
  };

in
stdenvNoCC.mkDerivation {
  inherit pname version;

  src = if hostPlatform.isLinux then wrappedAppimage else source;

  nativeBuildInputs =
    lib.optionals hostPlatform.isLinux [ makeWrapper ]
    ++ lib.optionals hostPlatform.isDarwin [ undmg ];

  sourceRoot = lib.optionalString hostPlatform.isDarwin ".";

  # Don't break code signing
  dontUpdateAutotoolsGnuConfigScripts = hostPlatform.isDarwin;
  dontConfigure = hostPlatform.isDarwin;
  dontFixup = hostPlatform.isDarwin;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/

    ${lib.optionalString hostPlatform.isLinux ''
      cp -r bin $out/bin
      mkdir -p $out/share/cursor
      cp -a ${appimageContents}/locales $out/share/cursor
      cp -a ${appimageContents}/resources $out/share/cursor
      cp -a ${appimageContents}/usr/share/icons $out/share/
      install -Dm 644 ${appimageContents}/cursor.desktop -t $out/share/applications/

      substituteInPlace $out/share/applications/cursor.desktop --replace-fail "AppRun" "cursor"

      wrapProgram $out/bin/cursor \
        --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}} --no-update"
    ''}

    ${lib.optionalString hostPlatform.isDarwin ''
      APP_DIR="$out/Applications"
      CURSOR_APP="$APP_DIR/Cursor.app"
      mkdir -p "$APP_DIR"
      cp -Rp Cursor.app "$APP_DIR"
      mkdir -p "$out/bin"
      cat << EOF > "$out/bin/cursor"
      #!${stdenvNoCC.shell}
      open -na "$CURSOR_APP" --args "\$@"
      EOF
      chmod +x "$out/bin/cursor"
    ''}

    runHook postInstall
  '';

  passthru = {
    inherit sources;
    updateScript = ./update.sh;
  };

  meta = {
    description = "AI-powered code editor built on vscode";
    homepage = "https://cursor.com";
    changelog = "https://cursor.com/changelog";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [
      sarahec
      aspauldingcode
    ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    broken = (stdenvNoCC.hostPlatform.isLinux && stdenvNoCC.hostPlatform.isAarch64); # Until Cursor has a working release
    mainProgram = "cursor";
  };
}
