{
  stdenvNoCC,
  lib,
  autoPatchelfHook,
  dpkg,
  fetchurl,
  glib,
  gtk3,
  libdrm,
  libutempter,
  mesa,
  nss,
  pam,
  python3,
  shadow,
  xorg,
  libcxx,
  callPackage,
  pkgs,
  wrapGAppsHook,
  makeWrapper,
  gsettings-desktop-schemas,
  gnome,
  ...
}: let
  replacePrefix = "/opt/google/chrome-remote-desktop";
in
  stdenvNoCC.mkDerivation rec {
    name = "chrome-remote-desktop";
    version = "123.0.6312.16";
    src = fetchurl {
      url = "https://deb.rug.nl/ppa/mirror/dl.google.com/linux/chrome-remote-desktop/deb/pool/main/c/chrome-remote-desktop/chrome-remote-desktop_${version}_amd64.deb";
      sha256 = "1bwzam79f2njx9iw23n35wbzg1cgisxqkcriw7m2rb6jhqbagvl4";
    };

    nativeBuildInputs = [
      autoPatchelfHook
      wrapGAppsHook
      makeWrapper
    ];

    buildInputs = [
      gsettings-desktop-schemas
      glib
      gtk3
      libdrm
      libutempter
      mesa
      nss
      pam
      xorg.libX11
      xorg.libXdamage
      xorg.libXext
      xorg.libXfixes
      xorg.libXrandr
      xorg.libXtst
      libcxx
    ];

    dontBuild = true;
    dontConfigure = true;

    unpackPhase = ''
      runHook preUnpack
      ${dpkg}/bin/dpkg -x $src $out
      runHook postUnpack
    '';

    patchPhase = ''
      runHook prePatch
      sed \
        -e '/^.*sudo_command =/ s/"gksudo .*"/"pkexec"/' \
        -e '/^.*command =/ s/s -- sh -c/s sh -c/' \
        -i $out/opt/google/chrome-remote-desktop/chrome-remote-desktop
      substituteInPlace $out/lib/systemd/system/chrome-remote-desktop@.service \
        --replace /opt/google/chrome-remote-desktop/chrome-remote-desktop '${placeholder "out"}/bin/chrome-remote-desktop'
      substituteInPlace $out/etc/opt/chrome/native-messaging-hosts/com.google.chrome.remote_desktop.json \
        --replace ${replacePrefix}/native-messaging-host $out/${replacePrefix}/native-messaging-host
      substituteInPlace $out/${replacePrefix}/chrome-remote-desktop \
        --replace /usr/bin/python3 ${python3.withPackages (ps: with ps; [psutil pyxdg packaging])}/bin/python3 \
        --replace '"Xvfb"' '"${xorg.xorgserver}/bin/Xvfb"' \
        --replace '"Xorg"' '"${xorg.xorgserver}/bin/Xorg"' \
        --replace '"xrandr"' '"${xorg.xrandr}/bin/xrandr"' \
        --replace '/etc/X11/Xsession' '${gnome.gnome-session}/bin/gnome-session' \
        --replace /usr/lib/xorg/modules ${xorg.xorgserver}/lib/xorg/modules \
        --replace xdpyinfo ${xorg.xdpyinfo}/bin/xdpyinfo \
        --replace /usr/bin/sudo /run/wrappers/bin/sudo \
        --replace /usr/bin/pkexec /run/wrappers/bin/pkexec \
        --replace /usr/bin/gpasswd ${shadow}/bin/gpasswd \
        --replace /usr/sbin/groupadd ${shadow}/bin/groupadd \
        --replace 'DEFAULT_SIZES = "1600x1200,3840x2560"' 'DEFAULT_SIZES = "2160x1440,3840x2160"'
      runHook postPatch
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      for i in "$out/opt/google/chrome-remote-desktop/"*; do
        if [[ ! -x "$i" ]]; then
          continue
        fi
        if [[ ! -d "$i" ]]; then
          wrapProgram "$i" --set XDG_DATA_DIRS "${lib.makeLibraryPath ["$GSETTINGS_SCHEMAS_PATH"]}" \
                           --set XDG_RUNTIME_DIR "/run/user/1000" \
                           --set CHROME_REMOTE_DESKTOP_HOST_EXTRA_PARAMS "--enable-wayland"
        fi
        ln -s "$i" "$out/bin/"
      done
      runHook postInstall
    '';

    meta = {
      description = "Access your computer or share your screen with others using your phone, tablet, or another device";
      homepage = "https://remotedesktop.google.com/";
      platforms = ["x86_64-linux"];
      license = with lib.licenses; [unfree];
      mainProgram = "chrome-remote-desktop";
      maintainers = with lib.maintainers; [thiagokokada];
    };
  }
