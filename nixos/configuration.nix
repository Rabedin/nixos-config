# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # You can import other NixOS modules here
  imports = [
    # If you want to use modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # You can also split up your configuration and import pieces of it here:
    # ./users.nix

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # If you want to use overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      permittedInsecurePackages = [
        "ventoy-1.1.05"
      ];
    };
  };

  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
      # Opinionated: disable global registry
      flake-registry = "";
      # Workaround for https://github.com/NixOS/nix/issues/9574
      nix-path = config.nix.nixPath;
    };
    # Opinionated: disable channels
    channel.enable = false;

    # Opinionated: make flake registry and nix path match flake inputs
    registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
  };

  ################################################
  ### Start of copy paste from original config ###
  ################################################

  # Bootloader.
  boot = {
    supportedFilesystems = [ "ntfs" ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Toronto";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";

  # Enable X11 and configure keymap
  services.xserver = {
    enable = true;
    xkb = {
      layout = "us";
      variant = "";
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    git
    ventoy-full
    inputs.zen-browser.packages."${system}".default
    cifs-utils
    wireshark
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.iosevka
  ];

  ##############################################
  ### End of copy paste from original config ###
  ##############################################

  networking = {
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22
        80
        443
        47984
        47989
        48010
      ];
      allowedUDPPorts = [
        47999
        48100
        48200
      ];
    };

  };

  fileSystems = {
    "/mnt/NVME2TB" = {
      device = "/dev/disk/by-uuid/062c5520-43b3-45b9-8557-10f80f5d3f0f";
      fsType = "ext4";
    };
    "/mnt/SATA2TB" = {
      device = "/dev/disk/by-uuid/2c4da48a-1b21-45b1-b250-45c693c95080";
      fsType = "ext4";
    };
    "/mnt/redhomeshare" = {
      device = "//192.168.69.102/redhomeshare";
      fsType = "cifs";
      options = let
        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";

      in ["${automount_opts},credentials=/etc/nixos/smb-secrets,uid=1000,gid=100"];
    };
  };

  networking.hostName = "nixbox";

  programs.zsh.enable = true;

  users.users = {
    red = {
      shell = pkgs.zsh;
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        "SHA256:wPOaYpAQSUiZ42HqV6oDLWZz6qfvdbtpsdwpkNzMKjI redwanulabedin"
      ];
      extraGroups = ["networkmanager" "wheel" "docker" "wireshark" ];
    };
  };

  # opengl stuff
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      amdvlk
      intel-media-driver
      intel-vaapi-driver
      libvdpau-va-gl
    ];
  };

  hardware.amdgpu.opencl.enable = true;

  # Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];
  };

  # audio stuff
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  security.rtkit.enable = true;

  # virtshit
  virtualisation = {
    docker = {
      enable = true;
    };
  };

  services = {

    udisks2 = {
      enable = true;
    };

    dnsmasq = {
      enable = true;
    };

    ollama = {
      enable = false;
      acceleration = "rocm";
      environmentVariables = {
        HCC_AMDGPU_TARGET = "gfx1201";
      };
      rocmOverrideGfx = "12.0.1";
    };

    openssh = {
      enable = true;
      settings = {
        # Opinionated: forbid root login through SSH.
        PermitRootLogin = "no";
        # Opinionated: use keys only.
        # Remove if you want to SSH using passwords
        # PasswordAuthentication = false;
      };
    };

    open-webui = {
      enable = false;
    };

    prowlarr = {
      enable = true;
      openFirewall = true;
    };

    radarr = {
      enable = true;
      openFirewall = true;
    };

    sonarr = {
      enable = true;
      openFirewall = true;
    };

    tailscale = {
      enable = false;
    };
  };


  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "25.05";
}
