# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  lib,
  config,
  pkgs,
  pkgsUnstable,
  ...
}: {
  # You can import other home-manager modules here
  imports = [
    # If you want to use home-manager modules from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModule

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
    ./hyprland.nix
    ./browsers.nix
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
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };

  home = {
    username = "red";
    homeDirectory = "/home/red";
    packages = with pkgs; [
      ripgrep
      gnumake
      discord
      grimblast
      wl-clipboard
      prismlauncher
      ranger
      qbittorrent
      btop
      glxinfo
      pavucontrol
      wofi
      freshfetch
      tmux
      killall
      lact
      obsidian
      rustup
      wine
      wine-wayland
      swww
      waypaper
      eww
      swaybg
      pokemonsay
      fortune
      gcc
      pkg-config
      gtk3
      pango
      gtk-layer-shell
      libdbusmenu-gtk3
      cairo
      libgcc
      glibc
      socat
      gawk
      jq
      coreutils
      playerctl
      lrzip
      kicad
      unzip
      qmk
      vlc
      python3
      bottles
      docker
      qdirstat
      temurin-jre-bin-17 # Java 17
      hardinfo2
      stress
      sysbench
      _7zz
      godot
      kdePackages.dolphin
      gcr
      osu-lazer-bin
      r2modman
      gthumb
      kdePackages.gwenview
      fdupes
      freetube
      btrfs-progs
      wireshark
      protonup-qt
      iamb
      floorp
    ];
  };

  programs = {
    neovim = {
      enable = true;
      defaultEditor = true;
      extraConfig = ''
        set number relativenumber
      '';
      extraLuaConfig = ''
        vim.g.mapleader = " "
	vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
	${builtins.readFile ./nvim/options.lua}
      '';
      viAlias = true;
      vimAlias = true;
      plugins = [
        pkgs.vimPlugins.telescope-nvim
	pkgs.vimPlugins.gruvbox-nvim
      ];
    };

    element-desktop = {
      enable = true;
    };

    kitty = {
      enable = true;
      themeFile = "GruvboxMaterialDarkMedium";
      shellIntegration.enableZshIntegration = true;
      settings = {
        # Theming
	shell = ".";
        include = "/home/red/.config/kitty/current-theme.conf";
        background_opacity = "0.95";

        # Font
        font_size = 12;
        font_family = "Iosevka nerd font";
        bold_font = "auto";
        italic_font = "auto";
        bold_italic_font = "auto";
      };
    };

    wofi = {
      enable = true;
      style = ''
        * {
          font-family: Iosevka nerd font;
          color: #cdd6f4;
        }

        window {
          background-color: #1e1e2e;
          border-style: double;
          border-width: 4px;
          border-color: #585b70;
          padding: 8px;
          border-radius: 4px;
        }

        scrolledwindow {
          padding: 8px;
        }

        flowboxchild {
          background-color: #313244;
          margin-top: 1px;
          margin-bottom: 1px;
        }

        entry {
          background-color: #1e1e2e;
          border-style: double;
          border-width: 4px;
          border-color: #fab387;
          border-radius: 4px;
        }
      '';
    };

    git = {
      enable = true;
      userName = "Redwanul Abedin";
      userEmail = "chromeplated@protonmail.com";
      aliases = {
        cm = "commit";
        co = "checkout";
      };
    };

    zsh = {
      enable = true;
      oh-my-zsh = {
        enable = true;
	theme = "agnoster";
      };
    };

    lutris = {
      enable = true;
    };

    obs-studio = {
      enable = true;
    };

  };

  services = {
    udiskie = {
      enable = true;
      settings = {
      };
    };
  };

  services = {
    gnome-keyring.enable = true;
  };

  # Enable home-manager and git
  programs.home-manager.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "25.05";
}
