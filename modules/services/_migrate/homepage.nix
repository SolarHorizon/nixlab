{config, ...}: let
  # path: secrets/services/homepage.yaml
  home_assistant_key = "";
  omada_password = "";
  jellyfin_key = "";
  jellyseerr_key = "";
  radarr_key = "";
  sonarr_key = "";
  qbittorrent_password = "";
  syncthing_whatbox_key = "";
  speedtest_tracker_key = "";

  mkSyncthingWidget = {
    url,
    api-key,
  }: {
    icon = "sh-syncthing";
    href = url;
    widget = {
      type = "customapi";
      url = "${url}/rest/svc/report";
      headers = {
        "X-API-Key" = api-key;
      };
      mappings = [
        {
          field = "totMiB";
          label = "Stored (MB)";
          format = "number";
        }
        {
          field = "numFolders";
          label = "Folders";
          format = "number";
        }
        {
          field = "totFiles";
          label = "Files";
          format = "number";
        }
        {
          field = "numDevices";
          label = "Devices";
          format = "number";
        }
      ];
    };
  };
in {
  services.homepage-dashboard = {
    enable = true;
    openFirewall = true;

    settings = {
      title = "Nixlab";
      theme = "dark";
      headerStyle = "boxedWidgets";
    };

    settings.layout = {
      media = {
        style = "row";
        columns = 4;
      };
      network = {
        style = "row";
        columns = 2;
      };
    };

    allowedHosts = "dashboard.matthewlabs.net";

    services = [
      {
        "network" = [
          {
            "Speedtest Tracker" = let
              url = "https://speedtest.matthewlabs.net";
            in {
              href = url;
              icon = "sh-speedtest";
              widget = {
                type = "speedtest";
                url = url;
                key = speedtest_tracker_key;
                version = 2;
              };
            };
          }
          {
            "Omada Controller" = let
              url = "https://omada.matthewlabs.net";
            in {
              href = url;
              icon = "sh-omada";
              widget = {
                type = "omada";
                url = url;
                username = "matt";
                password = omada_password;
                site = "Tiverton";
                fields = ["activeUser" "alerts"];
              };
            };
          }
        ];
      }
      {
        "legacy services" = [
          {
            "Home Assistant" = let
              url = "https://home.matthewlabs.net";
            in {
              href = url;
              icon = "sh-home-assistant";
              widget = {
                url = url;
                type = "homeassistant";
                key = home_assistant_key;
                custom = [
                  {
                    state = "sensor.t_h_sensor_temperature";
                    label = "Closet Temperature";
                  }
                  {
                    state = "sensor.151732604901582_indoor_temperature";
                    label = "AC Temperature";
                  }
                ];
              };
            };
          }
        ];
      }
      {
        media = [
          {
            Jellyfin = let
              url = "https://watch.matthewlabs.net";
            in {
              href = url;
              icon = "sh-jellyfin";
              widget = {
                type = "jellyfin";
                url = url;
                key = jellyfin_key;
                enableBlocks = true;
                enableNowPlaying = false;
              };
            };
          }
          {
            Jellyseerr = let
              url = "https://request.matthewlabs.net";
            in {
              href = url;
              icon = "sh-jellyseerr";
              widget = {
                type = "jellyseerr";
                url = url;
                key = jellyseerr_key;
              };
            };
          }
          {
            Radarr = let
              url = "https://radarr.matthewlabs.net";
            in {
              href = url;
              icon = "sh-radarr";
              widget = {
                type = "radarr";
                url = url;
                key = radarr_key;
              };
            };
          }
          {
            Sonarr = let
              url = "https://sonarr.matthewlabs.net";
            in {
              href = url;
              icon = "sh-sonarr";
              widget = {
                type = "sonarr";
                url = url;
                key = sonarr_key;
              };
            };
          }
          {
            qBittorrent = let
              url = "https://qbittorrent.genialshark.box.ca";
            in {
              href = url;
              icon = "sh-qbittorrent";
              widget = {
                type = "qbittorrent";
                url = url;
                username = "solarhrzn";
                password = qbittorrent_password;
                enableLeechProgress = true;
              };
            };
          }
          {
            "Syncthing (whatbox)" = mkSyncthingWidget {
              url = "https://syncthing.genialshark.box.ca";
              api-key = syncthing_whatbox_key;
            };
          }
        ];
      }
      {
        minecraft = let
          cfg = config.services.minecraft-servers.servers;

          getPort = server: let
            properties = cfg.${server}.serverProperties;
          in
            toString (
              if properties ? server-port
              then properties.server-port
              else "25565"
            );
        in [
          {
            "Vanilla 1.21.8" = {
              icon = "sh-minecraft";
              widget = {
                type = "minecraft";
                url = "udp://localhost:${getPort "vanilla"}";
              };
            };
          }
          {
            "Prominence II: Hasturian Era" = {
              icon = "https://cdn2.steamgriddb.com/logo_thumb/81ccbcaad7360e869f135698783ac7f4.png";
              widget = {
                type = "minecraft";
                url = "udp://localhost:${getPort "hasturian"}";
              };
            };
          }
          {
            "Kingdoms 4" = {
              icon = "sh-minecraft";
              widget = {
                type = "minecraft";
                url = "udp://localhost:${getPort "kingdoms"}";
              };
            };
          }
        ];
      }
    ];

    widgets = [
      {logo = {};}
      {
        search = {
          provider = "google";
          target = "_blank";
        };
      }
      {
        resources = {
          cpu = true;
          cputemp = true;
        };
      }
      {
        resources = {
          memory = true;
        };
      }
      {
        resources = {
          uptime = true;
        };
      }
    ];
  };

  services.caddy.virtualHosts = let
    port = toString config.services.homepage-dashboard.listenPort;
    url = "http://127.0.0.1:${port}";
  in {
    "dashboard.matthewlabs.net" = {
      extraConfig = ''
        reverse_proxy ${url}
      '';
    };
  };
}
