{
  flake.factory.forgejo-actions-runner = {
    name,
    tokenFile,
    url ? "https://git.matthewlabs.net/",
    labels ? [
      "ubuntu-latest:docker://ghcr.io/catthehacker/ubuntu:act-latest"
      "ubuntu-24.04:docker://ghcr.io/catthehacker/ubuntu:act-24.04"
      "ubuntu-22.04:docker://ghcr.io/catthehacker/ubuntu:act-22.04"
    ],
  }: {
    nixos.forgejo-actions-runner = {pkgs, ...}: {
      services.gitea-actions-runner = {
        package = pkgs.forgejo-runner;
        instances."${name}" = {
          inherit tokenFile name labels url;
          enable = true;
        };
      };

      # add docker bridge interface for cache actions
      networking.firewall.trustedInterfaces = ["br-+"];
    };
  };
}
