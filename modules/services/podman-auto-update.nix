# in order for this to work, containers that need to be automatically updated
# require the io.containers.autoupdate label:
# ```nix
# labels = {
# 	"io.containers.autoupdate" = "registry";
# };
# ```
{
  flake.modules.nixos.podman-auto-update = {pkgs, ...}: {
    systemd.services.podman-auto-update = {
      wants = ["network-online.target"];
      after = ["network-online.target"];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.podman}/bin/podman auto-update";
        ExecStartPost = "${pkgs.podman}/bin/podman image prune -f";
      };
    };

    systemd.timers.podman-auto-update = {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = "03:30";
        Persistent = true;
      };
    };
  };
}
