{pkgs}: let
  unwrapped_bin = bin_name:
    pkgs.lib.strings.replaceStrings ["/"] ["\\/"]
    "${pkgs.libreoffice-qt-fresh.passthru.unwrapped}/lib/libreoffice/program/${bin_name}";
  exports = ''export LD_LIBRARY_PATH="${pkgs.unixODBC}/lib:$LD_LIBRARY_PATH" GDK_BACKEND=x11'';
  replacement = ''
    do_export=true\
    for arg in "--base"; do\
        if [[ " --calc --draw --impress --math --write " == *" $arg "* ]]; then\
            do_export=false\
            break\
        fi\
    done\
    if [ $do_export == true ]; then\
        ${exports}\
    fi
  '';
in
  pkgs.symlinkJoin {
    name = "libreoffice-qt-fresh-fixed";
    paths = [pkgs.libreoffice-qt-fresh pkgs.unixODBC];
    postBuild = ''
      rm $out/bin/soffice
      sed '/^"${unwrapped_bin "soffice"}" /i\${replacement}' ${pkgs.libreoffice-qt-fresh}/bin/soffice > $out/bin/soffice
      chmod 755 $out/bin/soffice

      rm $out/bin/libreoffice
      ln -s $out/bin/soffice $out/bin/libreoffice

      rm $out/bin/sbase
      sed '/^"${unwrapped_bin "sbase"}" /i\${exports}' ${pkgs.libreoffice-qt-fresh}/bin/sbase > $out/bin/sbase
      chmod 755 $out/bin/sbase
    '';
  }
