{
  description = "Log in to Dongguan University of Technologies campus internet.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    }:

    flake-utils.lib.eachDefaultSystem
      (system:
      let pkgs = import nixpkgs { inherit system; overlays = [ self.overlay ]; }; in
      {
        defaultPackage = pkgs.dgut-inet-auth;
      }) //

    {
      nixosModules.dgut-inet-auth = { config, lib, pkgs, ... }:
        let
          cfg = config.services.dgut-inet-auth;
        in
        {
          # Interface
          options.services.dgut-inet-auth = {
            enable = lib.mkEnableOption "Enable DGUT campus internet auto authentication.";
            configPath = lib.mkOption {
              description = "Configuration path";
              example = "/run/secrets/dgut-inet-auth";
              type = lib.types.path;
            };
            checkInterval = lib.mkOption {
              description = "systemd.time(7) expression";
              default = "minutely";
              type = lib.types.str;
            };
          };
          # Implementation
          config = lib.mkIf cfg.enable {
            nixpkgs.overlays = [ self.overlay ];
            systemd.services.dgut-inet-auth = {
              description = "DGUT campus internet authentication";
              after = [ "network.target" ];
              serviceConfig = {
                Type = "oneshot";
                ExecStart = "${pkgs.dgut-inet-auth}/bin/dgut-inet-auth ${cfg.configPath}";
              };
            };

            systemd.timers.dgut-inet-auth = {
              description = "Auto authentication for DGUT campus internet";
              timerConfig.OnCalendar = cfg.checkInterval;
              wantedBy = [ "timers.target" ];
            };
          };
        };

      overlay = final: prev: {
        dgut-inet-auth = with prev.python3Packages; buildPythonPackage {
          pname = "dgut-inet-auth";
          version = "0.1";
          src = ./.;
          propagatedBuildInputs = [
            requests
            pycryptodome
          ];
          doCheck = false;
        };
      };
    };
}
