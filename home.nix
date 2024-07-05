{
  # FIXME: uncomment the next line if you want to reference your GitHub/GitLab access tokens and other secrets
  secrets,
  # config,
  pkgs,
  username,
  nix-index-database,
  ...
}: let
  unstable-packages = # with pkgs.unstable;
    [
    # FIXME: select your core binaries that you always want on the bleeding-edge
  ];

  stable-packages = with pkgs; [
    # FIXME: customize these stable packages to your liking for the languages that you use
    bc
    coreutils
    curl
    du-dust # better du (dust)
    dos2unix
    fcp # better cp
    fd # better find
    ffmpeg_7
    findutils
    git-crypt
    htop-vim
    imagemagick
    jq
    killall
    mosh
    nomacs
    procs
    rar
    rm-improved # better rm (rip)
    sd # better sed
    sqlite
    sqlitebrowser
    tree
    unzip
    # wezterm
    wget
    zip

    neovim
    wl-clipboard
    xclip

    # key tools
    gnumake # for lunarvim
    gcc # for lunarvim
    gh # for bootstrapping

    # core languages
    # rustup
    go
    # lua
    nodejs
    # typescript

    # haskell
    ghc
    cabal-install
    haskell-language-server
    haskellPackages.fourmolu
    # haskellPackages.hls-fourmolu-plugin

    # rust stuff
    cargo-cache
    cargo-expand

    # local dev stuf
    mkcert
    httpie

    # treesitter
    tree-sitter

    # language servers
    ccls # c / c++
    # gopls
    # nodePackages.typescript-language-server
    nodePackages.vscode-langservers-extracted # html, css, json, eslint
    nodePackages.yaml-language-server
    # sumneko-lua-language-server
    # nil nix
    nixd # nix
    nodePackages.pyright

    # formatters and linters
    alejandra # nix
    black # python
    ruff # python
    deadnix # nix
    # golangci-lint
    # lua52Packages.luacheck
    nodePackages.prettier
    shellcheck
    shfmt
    statix # nix
    sqlfluff
    tflint

    # namin
    bootnext
    chromium
    thorium
    (microsoft-edge.override {
      commandLineArgs = [
        "--enable-wayland-ime"
        "--disable-features=WaylandFractionalScaleV1"
        "--enable-chrome-browser-cloud-management"
        "--gtk-version=4"
      ];
    })
    meson
    krita
    expressvpn
    ntfs3g
    qbittorrent
    telegram-desktop
    zoom-us
    vlc
    mpc-qt
    opera
    # libguestfs-with-appliance
    wxmaxima
    patchelf
    cargo
    rustc
    ngrok


    # For finding text in MS-Word files
    python311Packages.docx2txt
    catdoc

    libreoffice-qt-fresh
    jdk # LibreOffice Base needs this to import some database

    libsForQt5.kate
    mathematica
    mcomix
    remmina # RDP client

    android-tools # for adb
    calibre
    stderred

    brc
    mht2img
    mansuki
  ];
in {
  imports = [
    nix-index-database.hmModules.nix-index
  ];

  home.stateVersion = "24.05";

  home = {
    username = "${username}";
    homeDirectory = "/home/${username}";

    sessionVariables = {
      # DISPLAY = "_gateway:0";
      # FIXME: set your preferred $EDITOR
      # EDITOR = "${pkgs.neovim}/bin/nvim";
      # FIXME: set your preferred $SHELL
      # SHELL = "/etc/profiles/per-user/${username}/bin/fish";
      CACHIX_AUTH_TOKEN = "${secrets.cachix_auth_token}";
      # DONT_PROMPT_WSL_INSTALL = "1";
      # TIME_STYLE = "$(echo -e '+%e %b  %Y\n%e %b %H:%M')";
      NIXOS_OZONE_WL = "1";
      XMODIFIERS = "@im=fcitx";
      INPUT_METHOD = "fcitx";
      XIM_SERVERS = "fcitx";
      # GTK_IM_MODULE = "fcitx";
      # QT_IM_MODULE = "fcitx";
      # SDL_IM_MODULE = "fcitx";
      LS_COLORS = "rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=00:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.zst=01;31:*.tzst=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.cab=01;31:*.wim=01;31:*.swm=01;31:*.dwm=01;31:*.esd=01;31:*.avif=01;35:*.cbz=01;35:*.cbr=01;35:*.jpg=01;35:*.jpeg=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.webp=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.webp=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:*~=00;90:*#=00;90:*.bak=00;90:*.old=00;90:*.orig=00;90:*.part=00;90:*.rej=00;90:*.swp=00;90:*.tmp=00;90:*.dpkg-dist=00;90:*.dpkg-old=00;90:*.ucf-dist=00;90:*.ucf-new=00;90:*.ucf-old=00;90:*.rpmnew=00;90:*.rpmorig=00;90:*.rpmsave=00;90:";
    };
  };

  home.packages =
    stable-packages
    ++ unstable-packages
    ++
    # FIXME: you can add anything else that doesn't fit into the above two lists in here
    [
      # pkgs.some-package
      # pkgs.unstable.some-other-package
    ];

  # FIXME: if you want to version your LunarVim config, add it to the root of this repo and uncomment the next line
  # home.file.".config/lvim/config.lua".source = ./lvim_config.lua;

  programs = {
    bash = {
      enable = true;
      shellAliases = import ./.config/shell/aliases.nix;
    };
    # better cat
    bat = {
      enable = true;
      config = {
        # map-syntax = [
        #   "*.jenkinsfile:Groovy"
        #   "*.props:Java Properties"
        # ];
        pager = "less -FRX";
        theme = "gruvbox-dark";
      };
    };
    # better top (btm)
    bottom.enable = true;
    # better tree (br)
    broot = {
      enable = true;
      enableFishIntegration = true;
    };
    fish = {
      enable = true;
      shellAliases = import ./.config/shell/aliases.nix;
      interactiveShellInit = ''
        fish_add_path ~/.local/bin
      '';
      functions = {
        # ffwh = pkgs.lib.strngs.fileContents ./fish/ffwh.fish;
      };
    };
    # direnv.enable = true;
    # direnv.enableFishIntegration = true;
    # direnv.nix-direnv.enable = true;
    # finder
    eza = {
      enable = true;
      git = true;
    };
    fzf = {
      enable = true;
      enableFishIntegration = true;
    };
    git = {
      enable = true;
      package = pkgs.git;
      delta = {
        enable = true;
        options = {
          line-numbers = true;
          side-by-side = true;
          navigate = true;
        };
      };
      userEmail = "naminx@gmail.com"; # FIXME: set your git email
      userName = "Nawamin M."; #FIXME: set your git username
      extraConfig = {
        # FIXME: uncomment the next lines if you want to be able to clone private https repos
        # url = {
        #   "https://oauth2:${secrets.github_token}@github.com" = {
        #     insteadOf = "https://github.com";
        #   };
        #   "https://oauth2:${secrets.gitlab_token}@gitlab.com" = {
        #     insteadOf = "https://gitlab.com";
        #   };
        # };
        push = {
          default = "current";
          autoSetupRemote = true;
        };
        merge.conflictstyle = "diff3";
        diff.colorMoved = "default";
      };
    };
    home-manager.enable = true;
    # lsd.enable = true;
    # lsd.enableAliases = true;
    mpv = {
      enable = true;
      bindings = {
        WHEEL_UP = "add volume 5";
        WHEEL_DOWN = "add volume -5";
        "Ctrl+WHEEL_UP" = "seek 10";
        "Ctrl+WHEEL_DOWN" = "seek -10";
      };
    };
    nix-index = {
      enable = true;
      enableFishIntegration = true;
    };
    nix-index-database.comma.enable = true;
    # better grep (rg)
    ripgrep.enable = true;
    # FIXME: disable this if you don't want to use the starship prompt
    starship = {
      enable = true;
      settings = {
        aws.disabled = true; # annoying to always have on
        gcloud.disabled = true; # annoying to always have on
        kubernetes.disabled = true; # annoying to always have on
        git_branch.style = "242";
        directory = {
          style = "blue";
          truncate_to_repo = false;
          # fish_style_pwd_dir_length = 1; # turn on fish directory truncation
          truncation_length = 0; # number of directories not to truncate
        };
        python.disabled = true;
        # shlvl.disabled = false;
        ruby.disabled = true;
        hostname.ssh_only = false;
        # hostname.style = "bold green"; # don't like the default
        memory_usage.disabled = true; # because it includes cached memory it's reported as full a lot
        # username.style_user = "bold blue"; # don't like the default
      };
    };
    wezterm.enable = true;
    wezterm.extraConfig = pkgs.lib.strings.fileContents ./.config/wezterm/wezterm.lua;
    # better cd (z)
    zoxide.enable = true;
    zoxide.enableFishIntegration = true;
  };

  xdg = {
    configFile = {
      "nvim/coc-settings.json".text =
        pkgs.lib.strings.fileContents ./.config/neovim/coc-settings.json;

      "google-chrome/NativeMessagingHosts/dev.namin.mansuki.json".text = builtins.replaceStrings ["@mansuki@"] ["${pkgs.mansuki}"] (pkgs.lib.strings.fileContents ./.config/chrome/dev.namin.mansuki.json);
      "chromium/NativeMessagingHosts/dev.namin.mansuki.json".text = builtins.replaceStrings ["@mansuki@"] ["${pkgs.mansuki}"] (pkgs.lib.strings.fileContents ./.config/chrome/dev.namin.mansuki.json);
      "thorium/NativeMessagingHosts/dev.namin.mansuki.json".text = builtins.replaceStrings ["@mansuki@"] ["${pkgs.mansuki}"] (pkgs.lib.strings.fileContents ./.config/chrome/dev.namin.mansuki.json);

      # "google-chrome/NativeMessagingHosts/com.google.chrome.remote_desktop.json".source = "${pkgs.chrome-remote-desktop}/etc/opt/chrome/native-messaging-hosts/com.google.chrome.remote_desktop.json";
      # "chromium/NativeMessagingHosts/com.google.chrome.remote_desktop.json".source = "${pkgs.chrome-remote-desktop}/etc/opt/chrome/native-messaging-hosts/com.google.chrome.remote_desktop.json";
      # "thorium/NativeMessagingHosts/com.google.chrome.remote_desktop.json".source = "${pkgs.chrome-remote-desktop}/etc/opt/chrome/native-messaging-hosts/com.google.chrome.remote_desktop.json";

      # "thorium/NativeMessagingHosts/org.freedownloadmanager.fdm5.cnh.json".text = builtins.replaceStrings ["@freedownloadmanager@"] ["${pkgs.free-download-manager}"] (fileContents ./.config/chrome/org.freedownloadmanager.fdm5.cnh.json);

      # "fourmolu.yaml".text = fileContents ./xdg/fourmolu.yaml;
      "mimeapps.list".force = true;
    };
    mimeApps = {
      enable = true;
      defaultApplications = {
        "application/epub+zip" = [ "calibre-ebook-viewer.desktop" ]; # .epub
        "application/msword" = [ "onlyoffice-desktopeditors.desktop" "writer.desktop" ]; # .doc
        "application/pdf" = [ "org.gnome.Evince.desktop" "mcomix.desktop" ]; # .pdf
        "application/vnd.comicbook-rar" = [ "mcomix.desktop" "org.gnome.FileRoller.desktop" ]; # .cbr
        "application/vnd.comicbook+zip" = [ "mcomix.desktop" "org.gnome.FileRoller.desktop" ]; # .cbz
        "application/vnd.ms-excel" = [ "onlyoffice-desktopeditors.desktop" "calc.desktop" ]; # .xls
        "application/vnd.openxmlformats-officedocument.presentationml.presentation" = [ "onlyoffice-desktopeditors.desktop" "impress.desktop" ]; # .pptx
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = [ "onlyoffice-desktopeditors.desktop" "calc.desktop" ]; # .xlsx
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = [ "onlyoffice-desktopeditors.desktop" "writer.desktop" ]; # .docx
        "application/vnd.ms-powerpoint" = [ "onlyoffice-desktopeditors.desktop" "impress.desktop" ]; # .ppt
        "default-web-browser" = [ "thorium-browser.desktop" "microsoft-edge.desktop" ];
        "image/jpeg" = [ "mcomix.desktop" "org.nomacs.ImageLounge.desktop" "org.kde.krita.desktop" ]; # .jpg, .jpeg
        "image/png" = [ "mcomix.desktop" "org.nomacs.ImageLounge.desktop" "org.kde.krita.desktop" ]; # .png .webp
        "image/webp" = [ "mcomix.desktop" "org.nomacs.ImageLounge.desktop" "org.kde.krita.desktop" ]; # .webp
        "text/html" = [ "thorium-browser.desktop" "microsoft-edge.desktop" ]; # .html
        "text/plain" = [ "org.kde.kate.desktop" ]; # .txt
        "video/mp4" = [ "mpv.desktop" "org.gnome.Totem.desktop" "vlc.desktop" "io.github.mpc_qt.Mpc-Qt.desktop" ]; # .mp4
        "video/vnd.avi" = [ "mpv.desktop" "org.gnome.Totem.desktop" "vlc.desktop" "io.github.mpc_qt.Mpc-Qt.desktop" ]; # .avi
        "video/x-matroska" = [ "mpv.desktop" "org.gnome.Totem.desktop" "vlc.desktop" "io.github.mpc_qt.Mpc-Qt.desktop" ]; # .mkv
        "x-scheme-handler/about" = [ "thorium-browser.desktop" "google-chrome.desktop" "microsoft-edge.desktop" ];
        "x-scheme-handler/http" = [ "thorium-browser.desktop" "google-chrome.desktop" "microsoft-edge.desktop" ];
        "x-scheme-handler/https" = [ "thorium-browser.desktop" "google-chrome.desktop" "microsoft-edge.desktop" ];
        "x-scheme-handler/unknown" = [ "thorium-browser.desktop" "google-chrome.desktop" "microsoft-edge.desktop" ];
      };
    };
  };
}
