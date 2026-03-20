{self, ...}: let
  host = "monolith";
  domain = "git.matthewlabs.net";
  httpPort = 3100;
  sshPort = 22;
in {
  flake.modules.nixos.forgejo = {
    services.openssh.settings = {
      AcceptEnv = "GIT_PROTOCOL";
    };

    services.forgejo = {
      enable = true;
      database.type = "sqlite3";
      lfs = {
        enable = true;
        # contentDir = "/mnt/truenas/forgejo/lfs";
      };
      settings = {
        server = {
          DOMAIN = "${domain}";
          ROOT_URL = "https://${domain}/";
          HTTP_PORT = httpPort;
          SSH_PORT = sshPort;
          SSH_CREATE_AUTHORIZED_KEYS_FILE = true;
        };
        service = {
          DISABLE_REGISTRATION = true;
        };
        repository = {
          ENABLE_PUSH_CREATE_USER = true;
          ENABLE_PUSH_CREATE_ORG = true;
          DEFAULT_REPO_UNITS = builtins.concatStringsSep "," [
            "repo.code"
            "repo.releases"
            "repo.issues"
            "repo.pulls"
            "repo.packages"
            "repo.actions"
          ];
        };
        actions = {
          ENABLED = true;
          DEFAULT_ACTIONS_URL = "github";
        };
        webhook = {
          ALLOWED_HOST_LIST = "*";
        };
        mailer = {
          ENABLED = false;
          SMTP_ADDR = "${domain}";
          FROM = "noreply@${domain}";
          USER = "noreply@${domain}";
        };
        security = {
          REVERSE_PROXY_TRUSTED_PROXIES = builtins.concatStringsSep "," [
            "monolith.ts.net"
            "floodgate.ts.net"
          ];
        };
        session = {
          COOKIE_SECURE = true;
        };
      };
    };
  };

  flake.modules.nixos.caddy-external = self.lib.mkReverseProxy {
    inherit domain host;
    port = httpPort;
  };

  flake.modules.nixos.${host} = {
    imports = with self.modules.nixos; [
      forgejo
    ];
  };
}
