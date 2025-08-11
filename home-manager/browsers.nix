{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # Browsers without HM options
  home.packages = with pkgs; [
    # mullvad-browser
  ];

  # Browsers with HM options
  programs = {
  # Librewolf
    librewolf = {
      enable = true;
      package = pkgs.librewolf-wayland;
      settings = {
        # TODO add specific settings here
      };
    };
    # Chromium
    chromium = {
      enable = true;
      package = pkgs.ungoogled-chromium;
      commandLineArgs = [
        "--extension-mime-request-handling=always-prompt-for-install"
      ];
      extensions =
        let
          createChromiumExtensionFor = browserVersion: { id, sha256, version }:
            {
              inherit id;
              crxPath = builtins.fetchurl {
                url = "https://clients2.google.com/service/update2/crx?response=redirect&acceptformat=crx2,crx3&prodversion=${browserVersion}&x=id%3D${id}%26installsource%3Dondemand%26uc";
                name = "${id}.crx";
                inherit sha256;
              };
              inherit version;
            };
          createChromiumExtension = createChromiumExtensionFor (lib.versions.major pkgs.ungoogled-chromium.version);
        in
        [
          (createChromiumExtension {
            # ublock origin
            id = "cjpalhdlnbpafiamejdnhcphjbkeiagm";
            sha256 = "sha256:168vr0p31sp5ffsqnrnarw6ab1m95yil4hph0xs6gjbfky7wygki";
            version = "1.65.0";
          })
          (createChromiumExtension {
            # Proton pass
            id = "ghmbeldphafepmbegfdlkpapadhbakde";
            sha256 = "sha256:0582gc1k1xvhafmk60r0pgfxyiajq2rsk374hd2f6yd8jmaxb1zw";
            version = "1.32.2";
          })
          (createChromiumExtension {
            # Tabliss
            id = "hipekcciheckooncpjeljhnekcoolahp";
            sha256 = "sha256:05nd45vpyrrccilblrnmxh2bfnrn445g4f24z1qm8ncxdracgbfx";
            version = "2.6.0";
          })
          (createChromiumExtension {
            # Gruvbox-slate theme
            id = "giokfhncgfjkoamdbhfhfhgpikaioccc";
            sha256 = "sha256:0nv3213dd9s1mfxl6b4rhv6j11rdcl16zjklkj5g06b62imm7d1y";
            version = "1.0";
          })
        ];
    };
  };

}
