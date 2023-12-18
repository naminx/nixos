{
  copy = "cp -i";
  chrome = "chromium --enable-features=UseOzonePlatform --ozone-platform=wayland --enable-wayland-ime";
  cls = "clear";
  cp = "cp -i";
  del = "rm -i";
  dir = "lsd -lF --color=auto";
  ffwh = "ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=s=x:p=0";
  ldir = "/etc/profiles/per-user/namin/bin/ls -lF --color=auto";
  ls = "lsd -F --color=auto";
  lls = "/etc/profiles/per-user/namin/bin/ls -F --color=auto";
  md = "mkdir";
  move = "mv -i";
  mv = "mv -i";
  rd = "rmdir";
  ren = "mv -i";
  rm = "rm -i";
  seq2 = "seq -f %02g";
  seq3 = "seq -f %03g";
}
