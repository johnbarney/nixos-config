{ ... }:
{
  imports = [
    ./ssh.nix
  ];

  programs.ssh = {
    settings."*" = {
      IdentityAgent = "~/.1password/agent.sock";
    };
  };
}
