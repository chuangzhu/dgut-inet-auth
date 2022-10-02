# dgut-inet-auth

Log in to Dongguan University of Technologies campus internet.

## Installation

```console
$ pip install -U dgut-inet-auth
```

## Usage

Create a config file with this structure

```
your user id
your password
```

Then run

```console
$ dgut-inet-auth <config file>
```

Return values:

- Exit code `0`, json output: successfully logged in.
- Exit code `0`, no output: already authenticated, skip.
- Exit code `1`: network is unreachable.

You can optionally configure the firewall mark this program uses with a `FWMARK` environment variable to work with policy routing.

## Use with systemd

Create service unit:

```ini
# /etc/systemd/system/dgut-inet-auth.service
[Unit]
After=network.target
Description=DGUT campus internet authentication

[Service]
ExecStart=dgut-inet-auth /path/to/dgut-inet-auth.conf
Type=oneshot
```

Create timer unit:

```ini
# /etc/systemd/system/dgut-inet-auth.timer
[Unit]
Description=Auto authentication for DGUT campus internet

[Timer]
OnCalendar=minutely

[Install]
WantedBy = timers.target
```

Enable systemd timer

```console
# systemctl daemon-reload
# systemctl enable --now dgut-inet-auth.timer
```

## Use with Nix flakes

```nix
{
  inputs.dgut-inet-auth.url = "github:chuangzhu/dgut-inet-auth";
  outputs = { self, nixpkgs, dgut-inet-auth }: {
    # Replace your-host-name to your machine
    nixosConfigurations.your-host-name = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        dgut-inet-auth.nixosModules.dgut-inet-auth
        {
          services.dgut-inet-auth.enable = true;
          # Specify your config file here
          services.dgut-inet-auth.configPath = ./dgut-inet-auth-config-file;
        }
      ];
    };
  };
}
```

- `services.dgut-inet-auth.enable`: enable systemd timer for auto authentication.
- `services.dgut-inet-auth.configPath`: config file location.
- `services.dgut-inet-auth.checkInterval`: `systemd.time(7)` expression for timer interval.
