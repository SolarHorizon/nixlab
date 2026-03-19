{pkgs}:
pkgs.writeShellApplication {
  name = "win-open";

  runtimeInputs = with pkgs; [
    coreutils
    openssh
  ];

  text = ''
     set -euo pipefail

    # Defaults (override via env if desired)
    MOUNT_ROOT=''${MOUNT_ROOT:-"/home/matt/Projects/roblox"}
    WIN_DRIVE=''${WIN_DRIVE:-"Z:"}
    SSH_TARGET=''${WIN_SSH_TARGET:-"192.168.122.98"}   # e.g. user@winvm

    usage() {
      echo "Usage: win-open <path/to/file>"
      echo "Opens the file inside the Windows VM using its default application."
      echo
      echo "Env:"
      echo "  MOUNT_ROOT      Linux virtiofs root (current: $MOUNT_ROOT)"
      echo "  WIN_DRIVE       Windows drive letter for virtiofs (current: $WIN_DRIVE)"
      echo "  WIN_SSH_TARGET  SSH destination (current: $SSH_TARGET)"
    }

    [[ $# -eq 1 ]] || { usage; exit 2; }

    INPUT="$1"
    ABS="$(realpath -m -- "$INPUT")" || { echo "error: cannot resolve: $INPUT" >&2; exit 1; }
    [[ -f "$ABS" ]] || { echo "error: not a regular file: $ABS" >&2; exit 1; }

    case "$ABS" in
      "''${MOUNT_ROOT}"/*) : ;;
      *)
        echo "error: $ABS is outside $MOUNT_ROOT" >&2
        echo "       Only files inside $MOUNT_ROOT can be opened in the VM." >&2
        exit 1
        ;;
    esac

    REL="''${ABS#"$MOUNT_ROOT/"}"
    WIN_PATH="''${REL//\//\\}"
    WIN_PATH="''${WIN_DRIVE}\\''${WIN_PATH}"

    # Use default file association (Roblox Studio for .rbxl)
    ssh "$SSH_TARGET" powershell -NoProfile -Command \
      "Start-Process -Verb Open -FilePath \"''${WIN_PATH}\""
  '';
}
