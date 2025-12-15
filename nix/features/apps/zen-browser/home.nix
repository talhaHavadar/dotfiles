{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
let
  zen-browser_config = config.host.features.apps.zen-browser;
in
{
  options = {
    host.features.apps.zen-browser = {
      enable = lib.mkOption {
        default = false;
        type = with lib.types; bool;
        description = "Zen Browser";
      };
    };
  };

  imports = [
    inputs.zen-browser.homeModules.beta
  ];

  config = lib.mkIf zen-browser_config.enable {
    programs.zen-browser = {
      enable = true;
      # TODO: firefoxpwa failing in macos 15/12/2025
      # nativeMessagingHosts = [ pkgs.firefoxpwa ];
      # Add any other native connectors here
      policies = {
        AutofillAddressEnabled = true;
        AutofillCreditCardEnabled = false;
        DisableAppUpdate = true;
        DisableFeedbackCommands = true;
        DisableFirefoxStudies = true;
        DisablePocket = true; # save webs for later reading
        DisableTelemetry = true;
        DontCheckDefaultBrowser = true;
        NoDefaultBookmarks = true;
        OfferToSaveLogins = false;
      };
    };
  };
}
