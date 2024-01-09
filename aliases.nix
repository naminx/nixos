{
  cat = "bat";
  copy = "cp -i";
  cls = "clear";
  cp = "cp -i";
  del = "rm -i";
  dir = "ansi lsd --icon=never -lF";
  ffwh = "ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=s=x:p=0";
  ipv6-off = "sudo sysctl -w net.ipv6.conf.enp5s0.disable_ipv6=1";
  ls = "ansi ls -CF --width=$(tput cols)";
  md = "mkdir";
  move = "mv -i";
  mv = "mv -i";
  rd = "rmdir";
  ren = "mv -i";
  rm = "rm -i";
  seq2 = "seq -f %02g";
  seq3 = "seq -f %03g";
}
