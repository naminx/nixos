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
    ];
    unixODBCDrivers = with pkgs.unixODBCDrivers; [ sqlite ];
    sessionVariables = {
      CACHIX_AUTH_TOKEN = "eyJhbGciOiJIUzI1NiJ9.eyJqdGkiOiI1MGJlYzI3Ni1lNmY2LTQyOTMtYmM0MC01Yzk2NzMzZDllNzAiLCJzY29wZXMiOiJ0eCJ9.mJzOYgW1h0MERQQwH1-RKWMKYdD5tGZxp7Lm-L--fN0";
    };
    etc."odbc.ini".text = ''
      [mansuki]
      Driver = SQLite
      Database = /home/namin/mansuki/mansuki.db
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

  security.sudo.wheelNeedsPassword = false;
  security.polkit.extraConfig = ''
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

  # List services that you want to enable:
  services = {
    dbus.enable = true;
    # FIXME: uncomment the next line to enable SSH
    # openssh.enable = true;
    xserver = {
      # Enable the X11 windowing system.
      enable = true;
      # dpi = 144;
      # Enable the KDE Plasma Desktop Environment.
      displayManager.sddm.enable = true;
      displayManager.defaultSession ="plasmawayland";
      desktopManager.plasma5.enable = true;
      # Configure keymap in X11
      layout = "us";
      xkbVariant = "";
      dpi = 192;
      # Enable touchpad support (enabled default in most desktopManager).
      # libinput.enable = true;
    };
    xrdp = {
      enable = true;
      defaultWindowManager = "startplasma-wayland";
      openFirewall = true;
    };
    onedrive.enable = true;
    # Enable CUPS to print documents.
    printing = {
      enable = true;
      drivers = [ pkgs.canon-cups-ufr2 ];
    };
    # Enable avahi for printer discovery
    avahi = {
      enable = true;
      nssmdns = true;
    };
    expressvpn.enable = true;
    openvpn.servers = let
      express-vpn-userpass = {
        username = "sjpnhlxcbn7e6wtlfbkwwnek";
        password = "1nxaoosn4qcjqqb6rr1v6zmu";
      };
    in {
      shibuya = {
        config = ''config /etc/nixos/openvpn/expressvpn-shibuya.ovpn '';
        autoStart = false;
        authUserPass = express-vpn-userpass;
      };
      tokyo = {
        config = ''config /etc/nixos/openvpn/expressvpn-tokyo.ovpn '';
        autoStart = false;
        authUserPass = express-vpn-userpass;
      };
      tokyo2 = {
        config = ''config /etc/nixos/openvpn/expressvpn-tokyo2.ovpn '';
        autoStart = false;
        authUserPass = express-vpn-userpass;
      };
      yokohama = {
        config = ''config /etc/nixos/openvpn/expressvpn-yokohama.ovpn '';
        autoStart = false;
        authUserPass = express-vpn-userpass;
      };
      estonia = {
        config = ''config /etc/nixos/openvpn/expressvpn-estonia.ovpn '';
        autoStart = false;
        authUserPass = express-vpn-userpass;
      };
    };
  };

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
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    # media-session.enable = true;
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
    # openssh.authorizedKeys.keys = [
      # "ssh-rsa ..."
    # ];
    # packages = with pkgs; [
      # git
      # google-chrome
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
    # fontconfig = {
      # defaultFonts = {
        # serif = [ "Vazirmatn" "Ubuntu" ];
        # sansSerif = [ "Vazirmatn" "Ubuntu" ];
        # monospace = [ "Ubuntu" ];
      # };
    # };
    # fontconfig.localConf = ''
      # <fontconfig>
        # <dir>/mnt/c/Windows/Fonts</dir>
      # </fontconfig>
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
}
