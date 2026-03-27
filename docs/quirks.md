# Quirks

Things I've run into that aren't obvious.

## NixOS

### libvirtd hooks require a service restart

`virtualisation.libvirtd.hooks.qemu` files get copied to `/var/lib/libvirt/hooks/qemu.d/` when libvirtd starts. `nixos-rebuild switch` updates the store paths but won't restart the service, so hook changes need a `sudo systemctl restart libvirtd` or a reboot.

## Intel Arc B580 (VFIO passthrough)

### Spontaneous GPU faults freeze the host

The B580 randomly faults during normal VM operation, causing IOMMU timeouts (`AMD-Vi: Completion-Wait loop timed out`, `IOTLB_INV_TIMEOUT`) that freeze the whole host. Been happening intermittently for ~8 months. See [intel/compute-runtime#880](https://github.com/intel/compute-runtime/issues/880).

Mitigations applied:

- Kernel params `pci=noats` and `pcie_aspm=off`

Things that don't work:

- Shrinking ReBAR via `resource2_resize`. The Windows Intel driver requires the BAR to cover the full 12GB VRAM, anything smaller gives code 43.

### xe-vfio-pci vs vfio-pci

The B580 needs `xe-vfio-pci` (Intel-specific VFIO driver), not generic `vfio-pci`. If it binds to the wrong one, the guest gets no display. On NixOS, `xe-vfio-pci` might not be loaded at boot. Just let libvirt's managed passthrough handle binding instead of doing it in hooks.
