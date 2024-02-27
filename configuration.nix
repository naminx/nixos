{
  # FIXME: uncomment the next line if you want to reference your GitHub/GitLab access tokens and other secrets
  # secrets,
  username,
  hostname,
  pkgs,
  ...
}: {
  # Set your time zone.
  time = {
    timeZone = "Asia/Bangkok";
    hardwareClockInLocalTime = true;
  };

  networking.hostName = "${hostname}";
  boot.kernel.sysctl."net.ipv6.conf.enp5s0.disable_ipv6" = true;

  # FIXME: change your shell here if you don't want zsh
  programs = {
    fish.enable = true;
    xwayland.enable = true;
  };

  environment = {
    # List of directories to be symlinked in `/run/current-system/sw`
    shells = [pkgs.fish];
    enableAllTerminfo = true;
    # List packages installed in system profile. To search, run:
    # $ nix search wget
    systemPackages = with pkgs; [
      cachix
      neovim
      # (import ./win32yank.nix {inherit pkgs;})
      canon-cups-ufr2
      sqlite
      unixODBC
      unixODBCDrivers.sqlite
      xwayland
      cloudflared
      # BEGIN required for dwservice
      dpkg
      xdummy
      xorg.xdpyinfo
      xorg.xhost
      xorg.libX11
      xorg.libXpm
      xorg.libXi
      xorg.libXext
      xorg.libXtst
      xorg.libXdamage
      xorg.libXfixes
      libpulseaudio
      gtk3
      # END required for dwservice
      glib
    ];
    unixODBCDrivers = with pkgs.unixODBCDrivers; [sqlite];
    sessionVariables = {
      CACHIX_AUTH_TOKEN = "eyJhbGciOiJIUzI1NiJ9.eyJqdGkiOiI1MGJlYzI3Ni1lNmY2LTQyOTMtYmM0MC01Yzk2NzMzZDllNzAiLCJzY29wZXMiOiJ0eCJ9.mJzOYgW1h0MERQQwH1-RKWMKYdD5tGZxp7Lm-L--fN0";
      PLASMA_USE_QT_SCALING = "1";
    };
    etc."odbc.ini".text = ''
      [mansuki]
      Driver = SQLite
      Database = /home/namin/haskell/mansuki/mansuki.db
    '';
  };

  nix = {
    package = pkgs.nixVersions.stable;
    # package = pkgs.nixFlakes;

    settings = {
      # Enable users to specify extra substituters
      trusted-users = ["root" username];
      # FIXME: use your access tokens from secrets.json here to be able to clone private repos on GitHub and GitLab
      # access-tokens = [
      # "github.com=${secrets.github_token}"
      # "gitlab.com=OAuth2:${secrets.gitlab_token}"
      # ];

      accept-flake-config = true;
      auto-optimise-store = true;

      experimental-features = ["nix-command" "flakes"];

      substituters = [
        "https://cache.nixos.org"
        "https://cache.iog.io"
        "https://nix-community.cachix.org"
        "https://namin.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "namin.cachix.org-1:mMQMl0c2VdPuDoWPJw6c1bRfRJBm6FbhTpCYIdvtzxA="
      ];
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./chrome-remote-desktop/package.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ALL = "en_US.UTF-8";
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
    inputMethod = {
      enabled = "fcitx5";
      fcitx5.addons = with pkgs; [
        fcitx5-configtool
        fcitx5-gtk
        fcitx5-m17n
        fcitx5-mozc
        fcitx5-with-addons
      ];
    };
  };

  security = {
    sudo.wheelNeedsPassword = false;
    pam.services.kwallet = {
        name = "namin";
        enableKwallet = true;
    };
    polkit = {
      enable = true;
      extraConfig = ''
        polkit.addRule(function(action, subject) {
          if (
            subject.isInGroup("users")
              && (
                action.id == "org.freedesktop.login1.reboot" ||
                action.id == "org.freedesktop.login1.reboot-multiple-sessions" ||
                action.id == "org.freedesktop.login1.power-off" ||
                action.id == "org.freedesktop.login1.power-off-multiple-sessions"
              )
            )
          {
            return polkit.Result.YES;
          }
        })
      '';
    };
    acme = {
      acceptTerms = true;
      defaults.email = "naminx@gmail.com";
      certs."namon.xyz" = {
        dnsProvider = "cloudflare";
        credentialsFile = "/home/namin/secrets/cloudflare";
        extraDomainNames = ["*.namon.xyz"];
      };
    };
  };

  # List services that you want to enable:
  services = {
    dbus.enable = true;
    # FIXME: uncomment the next line to enable SSH
    openssh = {
      enable = true;
      # require public key authentication for better security
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
    };
    xserver = {
      # Enable the X11 windowing system.
      enable = true;
      dpi = 192;
      # Enable the KDE Plasma Desktop Environment.
      displayManager.sddm.enable = true;
      displayManager.defaultSession = "plasma"; # or "plasmawayland"
      desktopManager.plasma5.enable = true;

      # Enable the Gnome Desktop Environment.
      # displayManager.gdm.enable = true;
      # displayManager.defaultSession = "gnome-xorg";
      # desktopManager.gnome.enable = true;
      # Configure keymap in X11
      layout = "us";
      xkbVariant = "";
      # Enable touchpad support (enabled default in most desktopManager).
      # libinput.enable = true;
    };
    # xrdp = {
    # enable = true;
    # defaultWindowManager = "startplasma-wayland";
    # openFirewall = true;
    # };
    guacamole-server = {
      enable = true;
      host = "127.0.0.1";
      userMappingXml = ./xdg/user-mapping.xml;
    };
    guacamole-client = {
      enable = true;
      enableWebserver = true;
      settings = {
        guacd-port = 4822;
        guacd-hostname = "localhost";
      };
    };
    caddy = {
      enable = true;
      globalConfig = ''
        auto_https disable_redirects
      '';
      # tls /data/acme/fullchain.cer /data/acme/domain.tld.key
      virtualHosts.":80".extraConfig = ''
        handle_path /* {
          rewrite * /guacamole{path}
          reverse_proxy 127.0.0.1:8080 {
            flush_interval -1
          }
        }
      '';
    };
    cloudflared = {
      enable = true;
      user = "namin";
      tunnels."3cd7c453-197f-4ae1-b23a-cc71281df85b" = {
        credentialsFile = "/home/namin/.cloudflared/3cd7c453-197f-4ae1-b23a-cc71281df85b.json";
        ingress = { "oreo.namon.xyz" = "http://localhost:80"; };
        default = "http_status:404";
      };
    };
    chrome-remote-desktop = {
      enable = true;
      user = "namin";
    };
    onedrive.enable = true;
    # Enable CUPS to print documents.
    # printing = {
    # enable = true;
    # drivers = [pkgs.canon-cups-ufr2];
    # };
    # Enable avahi for printer discovery
    # avahi = {
    # enable = true;
    # nssmdns = true;
    # };
    expressvpn.enable = true;
    openvpn.servers = let
      express-vpn-userpass = {
        username = "sjpnhlxcbn7e6wtlfbkwwnek";
        password = "1nxaoosn4qcjqqb6rr1v6zmu";
      };
    in {
      shibuya = {
        config = ''config /etc/nixos/openvpn/expressvpn-shibuya.ovpn'';
        autoStart = false;
        authUserPass = express-vpn-userpass;
      };
      tokyo = {
        config = ''config /etc/nixos/openvpn/expressvpn-tokyo.ovpn'';
        autoStart = false;
        authUserPass = express-vpn-userpass;
      };
      tokyo2 = {
        config = ''config /etc/nixos/openvpn/expressvpn-tokyo2.ovpn'';
        autoStart = false;
        authUserPass = express-vpn-userpass;
      };
      yokohama = {
        config = ''config /etc/nixos/openvpn/expressvpn-yokohama.ovpn'';
        autoStart = false;
        authUserPass = express-vpn-userpass;
      };
      estonia = {
        config = ''config /etc/nixos/openvpn/expressvpn-estonia.ovpn'';
        autoStart = false;
        authUserPass = express-vpn-userpass;
      };
    };
  };

  nixpkgs.overlays = [
    (_final: prev: {
      chrome-remote-desktop = prev.callPackage ./chrome-remote-desktop/default.nix {};
    })
  ];

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;
    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    wireplumber.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${username} = {
    isNormalUser = true;
    # FIXME: change your shell here if you don't want zsh
    shell = pkgs.fish;
    description = "namin";
    extraGroups = [
      "networkmanager"
      "wheel"
      "storage"
      # FIXME: uncomment the next line if you want to run docker without sudo
      "docker"
    ];
    # FIXME: add your own hashed password
    # hashedPassword = "";
    # FIXME: add your own ssh public key
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC9dO9i8xqIc5XjKr1RTuw4bG06qOfjGs9yJRxngktM2XYDBP53J4pMVOpcBWBQOosk2UmFjZ72PL02+Cpt+Kgw/NgAkc7RiX1z4MccBZGUf/P4NPEvtWOg1QVAemMiAC+HflCNTziV+DePXSM++IMLk8ex0CfTm1Z5YPPHYKJfuqBo4KQUb9DFo1ZTyeMKZvD8xiwCDl21x+0pWwrOORwIDRz0UEvtQnNBqttA8lRNcGNbeJJGGr2KKKdfoXIR8nJukj7ANAq+RlzvlwF8oo7agetmOdZFEAif9GUPX2CTJbnB0fyhJXqu3BJb0Jh87BuW+WmpWSo7CSPBivILc70MeFADTzKwF7QdJYi4NXUeAl4qDnpObagwsTs8NdPs9oetsbRfe5FZDmuBXEBaodFhnsYXDE/eqsjdodsySH9IXZ/wqdBtcSZyv373vt2cEaCyMLJ/rIVg4EFIPRCTpa6FD4J84nkgc8cDCYzmAtpDcZP+Q7N7bW5quwU9MMUPTYSv6tYNJN8uosq+w2on70ZpfSyGI0p1cyfuP26vWXXOc9YztKalDOW/MF5lMglBxC7tJ+b1cZthxN3s35vh9g+uxJJtQrD0MYMVtuMRz807cD8nT/CiOKLZaop+LdBG9DmKd1kcX8r6qCgknYr1Dfk45Fga0ed9iuopLe08sXYOfQ== namin@tokyo"
    ];
    # packages = with pkgs; [
    # git
    # wget
    # ];
  };

  home-manager.users.${username} = {
    imports = [./home.nix];
  };

  # QT
  qt.platformTheme = "qt5ct";

  # Open ports in the firewall.
  # SSH / RDP open necessary ports by default
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  networking.firewall = {
    enable = true;
    # allow all ports from your Tailscale network
    trustedInterfaces = ["tailscale0"];
    #or allow you to SSH in over the public internet
    # allowedTCPPorts = [ 22 ];
    allowedTCPPorts = [80 443 39135];
    allowedUDPPorts = [80 443 39135 41641];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

  fonts = {
    # enableDefaultPackages = true;
    packages = with pkgs; [
      (nerdfonts.override {fonts = ["FiraCode"];})
      (import ./fonts.nix {
        inherit lib fetchzip;
      })
    ];
    fontconfig = {
      defaultFonts = {
        serif = ["DroidSans"];
        sansSerif = ["DroidSans"];
        monospace = ["FiraCode"];
      };
    };
    # fontconfig.localConf = ''
    #   <fontconfig>
    #     <dir>/mnt/c/Windows/Fonts</dir>
    #   </fontconfig>
    # '';
  };

  virtualisation = {
    vmware = {
      host = {
        enable = true;
        package = pkgs.vmware-workstation;
      };
    };
    docker = {
      enable = true;
      enableOnBoot = false;
      extraOptions = "--data-root /mnt/q/docker";
    };
  };

  # wsl = {
  #   enable = true;
  #   wslConf = {
  #     automount.root = "/mnt";
  #     interop.appendWindowsPath = false;
  #     network.generateHosts = false;
  #   };
  #   defaultUser = username;
  #   startMenuLaunchers = true;
  #   # nativeSystemd = true;

  #   # Enable integration with Docker Desktop (needs to be installed)
  #   # docker-desktop.enable = false;
  # };

  # FIXME: uncomment the next block to make vscode running in Windows "just work" with NixOS on WSL
  # solution adapted from: https://github.com/K900/vscode-remote-workaround
  # more information: https://github.com/nix-community/NixOS-WSL/issues/238 and
  #                   https://github.com/nix-community/NixOS-WSL/issues/294
  # systemd.user = {
  #   paths.vscode-remote-workaround = {
  #     wantedBy = ["default.target"];
  #     pathConfig.PathChanged = "%h/.vscode-server/bin";
  #   };
  #   services.vscode-remote-workaround.script = ''
  #     for i in ~/.vscode-server/bin/*; do
  #       echo "Fixing vscode-server in $i..."
  #       ln -sf ${pkgs.nodejs_18}/bin/node $i/node
  #     done
  #   '';
  # };
}
