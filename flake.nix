{
  edition = 201909;

  outputs = { self }: {
    nixosModules.home-manager = ./nixos/default.nix;
  };
}