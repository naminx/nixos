{
  # FIXME: uncomment the next line if you want to reference your GitHub/GitLab access tokens and other secrets
  # secrets,
  config,
  pkgs,
  username,
  nix-index-database,
  ...
}: let
  unstable-packages = with pkgs.unstable; [
    # FIXME: select your core binaries that you always want on the bleeding-edge
  ];

  custom-chromium = with pkgs;
    import ./chromium/default.nix {
      inherit
        buildPackages
        config
        coreutils
        ed
        electron-source
        fetchgit
        fetchurl
        gcc
        glib
        gn
        gnome
        gnugrep
        gsettings-desktop-schemas
        gtk3
        gtk4
        lib
        libkrb5
        libva
        makeWrapper
        newScope
        nspr
        nss
        pipewire
        pkgs
        pkgsBuildBuild
        pkgsBuildTarget
        runCommand
        stdenv
        wayland
        xdg-utils
        ;
    };

  stable-packages = with pkgs; [
    # FIXME: customize these stable packages to your liking for the languages that you use
    bc
    coreutils
    curl
    du-dust # better du (dust)
    dos2unix
    fcp # better cp
    fd # better find
    ffmpeg
    findutils
    fx
    git
    git-crypt
    htop-vim
    imagemagick
    jq
    killall
    libguestfs-with-appliance
    mosh
    nomacs
    mcomix
    procs
    rar
    rm-improved # better rm (rip)
    sd # better sed
    sqlite
    sqlitebrowser
    tree
    unzip
    wget
    zip

    (
      neovim.override {
        viAlias = true;
        configure = import ./vim.nix {pkgs = pkgs;};
      }
    )

    # key tools
    gnumake # for lunarvim
    gcc # for lunarvim
    gh # for bootstrapping
    just

    cachix

    # core languages
    # rustup
    # go
    # lua
    nodejs
    python
    # typescript

    # haskell
    ghc
    cabal-install
    haskell-language-server
    ormolu

    # rust stuff
    # cargo-cache
    # cargo-expand

    # local dev stuf
    mkcert
    httpie

    # treesitter
    tree-sitter

    # language servers
    ccls # c / c++
    # gopls
    # nodePackages.typescript-language-server
    pkgs.nodePackages.vscode-langservers-extracted # html, css, json, eslint
    nodePackages.yaml-language-server
    # sumneko-lua-language-server
    nil # nix
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
    custom-chromium
    expressvpn
    google-chrome
    krita
    libreoffice-fresh
    libsForQt5.kate
    libsForQt5.kdeplasma-addons
    libsForQt5.libksysguard
    ntfs3g
    qbittorrent
    telegram-desktop
    zoom-us
    vlc
  ];
in {
  imports = [
    nix-index-database.hmModules.nix-index
  ];

  home.stateVersion = "23.11";

  home = {
    username = "${username}";
    homeDirectory = "/home/${username}";

    sessionVariables = {
      PATH = "/home/${username}/.local/bin:$PATH";
      # DISPLAY = "_gateway:0";
      # FIXME: set your preferred $EDITOR
      # EDITOR = "${pkgs.neovim}/bin/nvim";
      # FIXME: set your preferred $SHELL
      # SHELL = "/etc/profiles/per-user/${username}/bin/fish";
      CACHIX_AUTH_TOKEN = "eyJhbGciOiJIUzI1NiJ9.eyJqdGkiOiI1MGJlYzI3Ni1lNmY2LTQyOTMtYmM0MC01Yzk2NzMzZDllNzAiLCJzY29wZXMiOiJ0eCJ9.mJzOYgW1h0MERQQwH1-RKWMKYdD5tGZxp7Lm-L--fN0";
      # DONT_PROMPT_WSL_INSTALL = "1";
      # TIME_STYLE = "$(echo -e '+%e %b  %Y\n%e %b %H:%M')";
      # TIME_STYLE = "+%e %b %Y %H:%M";
      XMODIFIERS = "@im=fcitx";
      INPUT_METHOD = "fcitx";
      XIM_SERVERS = "fcitx";
      # GTK_IM_MODULE = "fcitx";
      # QT_IM_MODULE = "fcitx";
      # SDL_IM_MODULE = "fcitx";
      # PLASMA_USE_QT_SCALING = "1";
      QT_QPA_PLATFORMTHEME = "qt5ct";
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
    bash.enable = true;
    bash.shellAliases = import ./aliases.nix;
    # better cat
    bat.enable = true;
    # better top (btm)
    bottom.enable = true;
    # better tree (br)
    broot.enable = true;
    broot.enableFishIntegration = true;
    fish = {
      enable = true;
      shellAliases = import ./aliases.nix;
      interactiveShellInit = ''
      '';
    };
    # direnv.enable = true;
    # direnv.enableFishIntegration = true;
    # direnv.nix-direnv.enable = true;
    # finder
    fzf.enable = true;
    fzf.enableFishIntegration = true;
    git = {
      enable = true;
      package = pkgs.git;
      delta.enable = true;
      delta.options = {
        line-numbers = true;
        side-by-side = true;
        navigate = true;
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
        merge = {
          conflictstyle = "diff3";
        };
        diff = {
          colorMoved = "default";
        };
      };
    };
    home-manager.enable = true;
    lsd.enable = true;
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
    nix-index.enable = true;
    nix-index.enableFishIntegration = true;
    nix-index-database.comma.enable = true;
    # better grep (rg)
    ripgrep.enable = true;
    starship = {
      enable = true;
      settings = {
        aws.disabled = true; # annoying to always have on
        gcloud.disabled = true; # annoying to always have on
        kubernetes.disabled = false; # annoying to always have on
        git_branch.style = "242";
        directory = {
          style = "blue";
          truncate_to_repo = false;
          # fish_style_pwd_dir_length = 1; # turn on fish directory truncation
          truncation_length = 8; # number of directories not to truncate
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
    wezterm.extraConfig = pkgs.lib.strings.fileContents ./wezterm.lua;
    # better cd (z)
    zoxide.enable = true;
    zoxide.enableFishIntegration = true;
  };

  xdg = {
    configFile = with pkgs.lib.strings; {
      "nvim/coc-settings.json".text = fileContents ./coc-settings.json;
      "chromium/NativeMessagingHosts/dev.namin.mansuki.json".text = fileContents ./dev.namin.mansuki.json;
    };
  };
}
