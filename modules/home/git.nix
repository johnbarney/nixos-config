{ ... }:
{
  programs.git = {
    enable = true;
    userName = "Example User";
    userEmail = "example@example.com";
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = false;
      push.autoSetupRemote = true;
    };
  };
}
