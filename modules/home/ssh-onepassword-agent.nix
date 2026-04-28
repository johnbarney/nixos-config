{ ... }:
{
  imports = [
    ./ssh.nix
  ];

  programs.ssh = {
    matchBlocks."*" = {
      identityAgent = "~/.1password/agent.sock";
    };
  };
}
