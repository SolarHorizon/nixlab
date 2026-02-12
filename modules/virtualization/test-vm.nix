{
  flake.modules.nixos.test-vm = {
    virtualisation.vmVariant = {
      # TODO: remove hardcoded test password
      users.users.matt.password = "password";

      virtualisation = {
        memorySize = 16384;
        cores = 8;
      };
    };
  };
}
