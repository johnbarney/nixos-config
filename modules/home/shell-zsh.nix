{ ... }:
{
  programs.zsh = {
    enable = true;
    initContent = ''
      codex() {
        local codex_bin
        codex_bin="$(whence -p codex 2>/dev/null || true)"
        if [ -n "$codex_bin" ]; then
          "$codex_bin" "$@"
        else
          npx -y @openai/codex "$@"
        fi
      }
    '';
  };
}
