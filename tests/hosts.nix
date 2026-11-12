# Synthetic evaluation fixtures; these are never published as real host outputs.
{ config, ... }:
let
  fixture = {
    system = "x86_64-linux";
    primaryUser = "validation";
    module = {
      boot.isContainer = true;
      system.stateVersion = "26.05";
      users.users.validation.isNormalUser = true;
    };
  };
in
{
  fleet.hosts = {
    check-workstation = fixture;
    check-server = fixture // {
      profiles = config.fleet.sharedProfiles ++ [ "server" ];
    };
  };
}
