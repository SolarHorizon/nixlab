{
  flake.modules.nixos.yubikey-auto-lock = {pkgs, ...}: {
    services.udev.extraRules = ''
      ACTION=="remove",\
        ENV{DEVTYPE}=="usb_device",\
        ENV{SUBSYSTEM}=="usb",\
        ENV{PRODUCT}=="1050/407/*",\
        RUN+="${pkgs.systemd}/bin/loginctl lock-sessions"
    '';
  };
}
