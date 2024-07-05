{pkgs}:
pkgs.gnome
// {
  gdm = pkgs.gnome.gdm.overrideAttrs (oldAttrs: {
    # Merge branch 'persistent-sessions' into 'main'
    version = "8-Jun-2024"; # 8 Jun 2024 01:48:30 GMT+7
    src = pkgs.fetchgit {
      url = "https://gitlab.gnome.org/GNOME/gdm.git";
      rev = "81ee658c11381912131dd4a29e84190f7f9cd039";
      sha256 = "sha256-fhHdFC0rTYGf2y/eGw+6f22N/BTEK8BHfsJssZMhSEY=";
    };
  });

  gnome-remote-desktop = pkgs.gnome.gnome-remote-desktop.overrideAttrs (oldAttrs: {
    # daemon-handover: Don't logout on handover fail
    # version = "8-Jun-2024"; # 8 Jun 2024 18:16:53 GMT+7
    # src = pkgs.fetchgit {
    #   url = "https://gitlab.gnome.org/GNOME/gnome-remote-desktop.git";
    #   rev = "c7e4df8bcdcc3fbcd183ea1cc9beb177061e2d1f";
    #   sha256 = "sha256-Z4blQ26oMpIL0CMXY5+9pUMPNoGubRk7wr4vbb6NbWQ=";
    # };

    # Latest commit on master branch
    version = "5-Jul-2024"; # 5 Jul 2024 04:04 GMT+7"
    src = pkgs.fetchgit {
      url = "https://gitlab.gnome.org/GNOME/gnome-remote-desktop.git";
      rev = "bd436e5901d3d857ca830f386f8ababa9fca3106";
      sha256 = "sha256-Nh3jc+91qbVphI+mt3nRMv/Em+zWh5XgfWfJAGZ4q0M=";
    };
  });
}
