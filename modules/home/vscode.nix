{ pkgs, ... }:
{
  programs.vscode = {
    enable = true;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      jnoortheen.nix-ide
      brettm12345.nixfmt-vscode
      esbenp.prettier-vscode
      oderwat.indent-rainbow
      ms-vscode."makefile-tools"
      ms-python.python
      golang.go
    ];
  };

  home.activation.installVscodeExtensions =
    let
      codeBin = "${pkgs.vscode}/bin/code";
    in
    # Codex is published as openai.chatgpt in VS Code Marketplace.
    ''
      if [ -x "${codeBin}" ]; then
        "${codeBin}" --install-extension ms-vscode.makefile-tools --force >/dev/null 2>&1 || true
        "${codeBin}" --install-extension openai.chatgpt --force >/dev/null 2>&1 || true
      fi
    '';
}
