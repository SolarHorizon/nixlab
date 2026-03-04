{
  flake.modules.nixos.forgejo = let
    domain = "git.matthewlabs.net";
    httpPort = 3100;
    sshPort = 22;
  in {
    services.openssh.settings = {
      AcceptEnv = "GIT_PROTOCOL";
    };

    services.caddy.virtualHosts = {
      "${domain}" = {
        extraConfig = ''
          reverse_proxy http://127.0.0.1:${toString httpPort}
        '';
      };
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
        mailer = {
          ENABLED = false;
          SMTP_ADDR = "${domain}";
          FROM = "noreply@${domain}";
          USER = "noreply@${domain}";
        };
        security = {
          REVERSE_PROXY_TRUSTED_PROXIES = builtins.concatStringsSep "," [
            "caddy.ts.net"
            "gateway.ts.net"
          ];
        };
        session = {
          COOKIE_SECURE = true;
        };
      };
    };
  };
}
