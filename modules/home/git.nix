{ ... }:
{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Example User";
        email = "example@example.com";
      };
      init.defaultBranch = "main";
      pull.rebase = false;
      push.autoSetupRemote = true;
    };
  };
}
