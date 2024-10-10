{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  homeDirectory = config.home.homeDirectory;
in
with lib;
{

  programs.git = {
    enable = true;
    contents = ''
      [commit]
      	gpgSign = true
      [user]
      	email = havadartalha@gmail.com
      	name = Talha Can Havadar
      [includeIf "gitdir:~/workspace/"]
      	path = ~/workspace/.gitconfig
    '';
  };
}
