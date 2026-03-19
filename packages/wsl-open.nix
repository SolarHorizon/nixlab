{pkgs}:
pkgs.writeShellScriptBin "wsl-open" ''
  powershell.exe -c "${"Start \${@}"}"
''
