{
  cat = "bat";
  cd = "z";
  cls = "clear";
  copy = "cp --interactive";
  cp = "cp --interactive";
  del = "rm --interactive=always";
  dir = "lsd --long --classify --color=always --icon=never";
  fe = "vi $(fzf --ansi --color=16)";
  find = "fd";
  fzf = "fzf --ansi --color=16";
  grep = "rg";
  less = "less --quit-if-one-screen --raw-control-chars --no-init";
  ls = "lsd --classify --color=auto --icon=never";
  lw = "lsd -C --width=$(tput cols) --classify --color=always --icon=never";
  md = "mkdir";
  move = "mv --interactive";
  mv = "mv --interactive";
  rd = "rmdir";
  ren = "mv --interactive";
  rm = "rm --interactive=always";
  seq2 = "seq --format=%02g";
  seq3 = "seq --format=%03g";
}
