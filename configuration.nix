# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  secrets,
  username,
  hostname,
  pkgs,
  config,
  inputs,
  lib,
  ...
}: {
  # Enable this on WSL
  wsl.enable = false;

  wsl.wslConf.automount.root = "/mnt";
  wsl.wslConf.interop.appendWindowsPath = false;
  wsl.wslConf.network.generateHosts = false;
  wsl.wslConf.network.generateResolvConf = false;
  wsl.defaultUser = username;
  wsl.startMenuLaunchers = true;

  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./packages/onlyoffice/default.nix
  ];

  # Bootloader.
  boot.loader = lib.mkIf (!config.wsl.enable) {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # There are required for VMWare workstation
  boot.kernel.sysctl = lib.mkIf (!config.wsl.enable) {
    "vm.compaction_proactiveness" = 0;
    "vm.extfrag_threshold" = 1000;
  };

  boot.kernelParams =
    []
    ++ (
      if (!config.wsl.enable)
      then [
        # This is required for VMWare workstation
        "transparent_hugepage=never"
      ]
      else []
    )
    ++ (
      if (!config.wsl.enable)
      then [
        # Custom resolution
        "video=HDMI-A-2:2160x1440@60"
        "video=HDMI-A-4:2160x1440@60"
      ]
      else []
    );

  # nix.package = pkgs.nixFlakes;
  nix.package = pkgs.nixVersions.stable;
  nix.settings.trusted-users = ["root" username];
  nix.settings.accept-flake-config = true;
  nix.settings.auto-optimise-store = true;
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # setup binary cache server, include cachix
  nix.settings.substituters = [
    "https://cache.nixos.org"
    "https://cache.iog.io"
    "https://nix-community.cachix.org"
    "https://namin.cachix.org"
  ];
  nix.settings.trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    "namin.cachix.org-1:mMQMl0c2VdPuDoWPJw6c1bRfRJBm6FbhTpCYIdvtzxA="
  ];

  nix.gc.automatic = true;
  nix.gc.dates = "weekly";
  nix.gc.options = "--delete-older-than 7d";

  networking.hostName = "${hostname}"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Static IP breaks Gnome Remote Login
  # Use static IPv4
  # networking.interfaces.enp5s0.ipv4.addresses = [ {
  #   address = "192.168.1.2";
  #   prefixLength = 24;
  # } ];
  # networking.defaultGateway = "192.168.1.1";

  networking.nameservers = [
    "1.1.1.1" # CloudFlare DNS
    "1.0.0.1" # CloudFlare DNS
    "2606:4700:4700::1111"
    "2606:4700:4700::1001"
  ];

  networking.hosts = {
    "192.168.1.1" = ["router"];
    "192.168.1.2" = ["tokyo"];
    "192.168.1.3" = ["osaka"];
    "192.168.1.4" = ["shibuya"];
    "192.168.1.5" = ["mf643cdw"];
    "192.168.1.6" = ["repeater"];
    "192.168.1.7" = ["furano"];
    "192.168.1.9" = ["akita"]; # Chuwi Hi13
    "192.168.1.10" = ["chiyoda"]; # NixOS on WSL on Tokyo
    "192.168.1.11" = ["nagano"]; # Surface Pro 1
  };

  # Set your time zone.
  time.timeZone = "Asia/Bangkok";
  time.hardwareClockInLocalTime = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  i18n.inputMethod = lib.mkIf (!config.wsl.enable) {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-configtool
      fcitx5-gtk
      fcitx5-m17n
      fcitx5-mozc
      fcitx5-with-addons
    ];
  };

  services.xserver = lib.mkIf (!config.wsl.enable) {
    # Enable the X11 windowing system.
    enable = true;

    # Enable the GNOME Desktop Environment.
    displayManager.gdm.enable = true;
    displayManager.gdm.autoSuspend = false;
    desktopManager.gnome.enable = true;

    # Configure keymap in X11
    xkb.layout = "us";
    xkb.variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.browsing = true;

  # Enable avahi for printer discovery
  services.avahi.enable = true;
  services.avahi.nssmdns4 = true;

  hardware.printers.ensurePrinters = [
    {
      name = "mf643cdw";
      deviceUri = "ipp://192.168.1.5/ipp/print";
      model = "everywhere";
    }
  ];

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    # jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    # media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${username} = {
    isNormalUser = true;
    description = "Nawamin M.";
    extraGroups = ["networkmanager" "wheel" "storage" "docker"];

    shell = pkgs.fish;
    # packages = with pkgs; [ thunderbird ];
    openssh.authorizedKeys.keys = ["${secrets.openssh_authorized_keys."namin@tokyo"}"];
  };
  # These users do not have to enter password on `sudo`
  security.sudo.extraRules = [
    {
      users = [username];
      commands = [
        {
          command = "ALL";
          options = ["NOPASSWD"];
        }
      ];
    }
  ];

  # Install firefox.
  # programs.firefox.enable = true;

  # Enable fish shell
  programs.fish.enable = true;
  programs.fish.shellAliases = import ./.config/shell/aliases.nix;

  programs.command-not-found.enable = false;
  programs.nix-index.enable = true;
  programs.nix-index.enableFishIntegration = true;

  programs.onlyoffice = lib.mkIf (!config.wsl.enable) {
    enable = true;
    package = pkgs.onlyoffice-bin_latest;
  };

  programs.starship.enable = true;
  programs.starship.settings = {
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

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.sessionVariables = {
    CACHIX_AUTH_TOKEN = "${secrets.cachix_auth_token}";
    WEZTERM_CONFIG_FILE = "${./.config/wezterm/wezterm.lua}";
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs;
    [
      # Essential packages
      alejandra # Nix file formatter
      bc # calculator for bash script
      cachix
      efibootmgr
      git
      neovim
      nixd # Nix language server
      nodejs # For coc
      parallel
      python3
      rar
      sqlite
      wget # Needed by some packages
      wl-clipboard # Wayland clipboard
      unzip
      zip

      # Convenient packages
      bat # better cat
      bottom # better top (btm)
      broot # better tree (br)
      eza # better ls
      fd # better find
      findutils
      fzf
      htop-vim # alternative top (htop)
      ripgrep # better grep (rg)
      sd # better sed
      tree
      unixODBC
      unixODBCDrivers.mariadb
      unixODBCDrivers.sqlite
      unixODBCDrivers.psql
    ]
    ++ (
      if (!config.wsl.enable)
      then [
        chromium # Convenient browser to get my config files/notes
        gnomeExtensions.gtk4-desktop-icons-ng-ding
        gnomeExtensions.kimpanel
        wezterm # Easy to edit (mouse selection, cut, paste)
      ]
      else []
    );

  environment.unixODBCDrivers = with pkgs.unixODBCDrivers; [mariadb sqlite psql];

  environment.etc."odbc.ini".text = ''
    [mansuki]
    Driver = SQLite
    Database = /home/namin/haskell/mansuki/mansuki.db
  '';

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable Gnome Remote Desktop and Remote Login
  services.gnome.gnome-remote-desktop.enable = !config.wsl.enable;

  # OneDrive cloud storage
  services.onedrive.enable = !config.wsl.enable;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "no";
  services.openssh.settings.PasswordAuthentication = true;

  home-manager.users.${username} = import ./home.nix {
    inherit secrets config pkgs lib username;
    nix-index-database = inputs.nix-index-database;
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [3389 3390];
  networking.firewall.allowedUDPPorts = [3389 3390];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  # networking.enableIPv6 = false;
  # boot.kernel.sysctl."net.ipv6.conf.wlp1s0.disable_ipv6" = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = if config.wsl.enable then "24.05" else "23.11"; # Did you read the comment?

  # Enable Dynamic Update Client (DUC) for No-IP
  systemd.services.noip-duc = {
    wantedBy = ["multi-user.target"];
    after = ["network.target" "auditd.service"];
    serviceConfig = {
      Type = "simple";
      User = "root";
      # ExecStart = ''${pkgs.noip}/bin/noip2 -d -c ${pkgs.noip}/etc/no-ip2.conf'';
      ExecStart = ''
        ${pkgs.noip-duc}/bin/noip-duc \
          --username ${secrets.noip_group_update.username} \
          --password ${secrets.noip_group_update.password} \
          -g namin.ddns.net \
          --ip-method http://ip1.dynupdate6.no-ip.com/
      '';
    };
  };

  # Enable Gnome Remote Login on boot.
  systemd.services."gnome-remote-login" = lib.mkIf (!config.wsl.enable) {
    wantedBy = ["multi-user.target"];
    after = ["network.target"];
    script = ''
      ${pkgs.systemd}/bin/systemctl start gnome-remote-desktop.service
    '';
  };

  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  # Setup the right display scale for GDM login screen
  systemd.tmpfiles.rules =
    if (!config.wsl.enable)
    then [
      "L+ /run/gdm/.config/monitors.xml - - - - ${./.config/gdm/monitors.xml}"
    ]
    else [];

  fonts = {
    # enableDefaultPackages = true;
    packages = with pkgs; [
      (nerdfonts.override {fonts = ["FiraCode"];})
      (callPackage ./packages/custom-fonts/default.nix {})
    ];
    fontconfig = {
      defaultFonts = {
        serif = ["DroidSans"];
        sansSerif = ["DroidSans"];
        monospace = ["FiraCode" "DroidSans"];
      };
    };
    fontconfig.localConf =
      if config.wsl.enable
      then ''
        <fontconfig>
          <dir>/mnt/c/Windows/Fonts</dir>
        </fontconfig>
      ''
      else "";
  };

  virtualisation = lib.mkIf (!config.wsl.enable) {
    vmware.host.enable = true;
    vmware.host.package = pkgs.vmware-workstation;

    docker.enable = true;
    docker.enableOnBoot = false;
    docker.daemon.settings = { data-root = "/var/lib/docker"; };
  };
}
