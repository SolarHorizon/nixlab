{
  flake.modules.nixos.test-vm = {
    virtualisation.vmVariant = {
      virtualisation = {
        memorySize = 16384;
        cores = 8;
      };
    };
  };
}
