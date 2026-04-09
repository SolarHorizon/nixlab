{self, ...}: let
  host = "monolith";
  domain = "gworkspace-mcp.matt.you";
  port = 8800;
  user = "google-workspace-mcp";
  uid = 901;
  group = user;
  gid = uid;
in {
  flake.modules.nixos.google-workspace-mcp = {config, ...}: {
    users.groups.${group}.gid = gid;
    users.users.${user} = {
      isSystemUser = true;
      inherit group uid;
    };

    sops.secrets."google-workspace-mcp/client_id" = {
      sopsFile = ../../../secrets/services/google-workspace-mcp.yaml;
    };
    sops.secrets."google-workspace-mcp/client_secret" = {
      sopsFile = ../../../secrets/services/google-workspace-mcp.yaml;
    };

    sops.templates."google-workspace-mcp.env" = {
      content = ''
        GOOGLE_OAUTH_CLIENT_ID=${config.sops.placeholder."google-workspace-mcp/client_id"}
        GOOGLE_OAUTH_CLIENT_SECRET=${config.sops.placeholder."google-workspace-mcp/client_secret"}
      '';
    };

    virtualisation.oci-containers.containers.google-workspace-mcp = {
      image = "ghcr.io/taylorwilsdon/google_workspace_mcp:1.18.0@sha256:619da5a4a622497e1880a5830c5d2aa038bd0af12a950c7d131f1b570dd288f7";
      serviceName = "google-workspace-mcp";
      extraOptions = [
        "--uidmap=0:100000:1000"
        "--uidmap=1000:${toString uid}:1"
        "--gidmap=0:100000:1000"
        "--gidmap=1000:${toString gid}:1"
      ];
      environment = {
        TOOLS = builtins.concatStringsSep " " [
          "calendar"
          "docs"
          "drive"
          "search"
          "sheets"
        ];
        WORKSPACE_MCP_HOST = "0.0.0.0";
        WORKSPACE_MCP_PORT = "8000";
        GOOGLE_MCP_CREDENTIALS_DIR = "/data/credentials";
        GOOGLE_OAUTH_REDIRECT_URI = "https://${domain}/oauth2callback";
      };
      environmentFiles = [
        config.sops.templates."google-workspace-mcp.env".path
      ];
      ports = [
        "${toString port}:8000"
      ];
      volumes = [
        "/var/lib/google-workspace-mcp:/data"
      ];
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/google-workspace-mcp 0700 ${user} ${group} -"
      "d /var/lib/google-workspace-mcp/credentials 0700 ${user} ${group} -"
    ];
  };

  flake.modules.nixos.caddy-internal = self.lib.mkReverseProxy {
    inherit domain host port;
  };

  flake.modules.nixos.${host} = {
    imports = with self.modules.nixos; [
      google-workspace-mcp
    ];
  };
}
