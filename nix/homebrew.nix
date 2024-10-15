{ pkgs, device, ... }:
{

  homebrew = {
    enable = true;
    masApps = { };
    onActivation = {
      autoUpdate = true;
      cleanup = true;
    };
    global = {
      brewfile = true;
    };
  };
}
