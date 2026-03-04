{
  flake.factory.forgejo-actions-runner = {
    name,
    labels ? [
      "ubuntu-latest:docker://ghcr.io/catthehacker/ubuntu:act-latest"
      "ubuntu-22.04:docker://ghcr.io/catthehacker/ubuntu:act-22.04"
      "ubuntu-20.04:docker://ghcr.io/catthehacker/ubuntu:act-20.04"
    ],
  }: {
    nixos.forgejo = {pkgs, ...}: {
      services.gitea-actions-runner = {
        package = pkgs.forgejo-runner;
        instances."${name}" = {
          enable = true;
          name = "${name}";
          url = "https://git.matthewlabs.net/";
          labels = labels;
          # token = TODO_FORGEJO_RUNNER_TOKEN;
        };
      };

      # add docker bridge interface for cache actions
      networking.firewall.trustedInterfaces = ["br-+"];
    };
  };
}
