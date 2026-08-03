{ ... }:
{
  # Run common prebuilt Linux applications without recreating their runtime
  # environment by hand.
  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  programs.nix-ld.enable = true;
}
