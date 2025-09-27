{
  config,
  lib,
  pkgs,
  ...
}:
let
  zen-browser_config = config.host.features.zen-browser;
in
{
  options = {
    host.features.zen-browser = {
      enable = lib.mkOption {
        default = false;
        type = with lib.types; bool;
        description = "Zen Browser";
      };
    };
  };

  config = lib.mkIf zen-browser_config.enable {
    # programs.zen-browser = {
    #   enable = true;
    #   nativeMessagingHosts = [ pkgs.firefoxpwa ];
    #   policies = {
    #     AutofillAddressEnabled = true;
    #     AutofillCreditCardEnabled = false;
    #     DisableAppUpdate = true;
    #     DisableFeedbackCommands = true;
    #     DisableFirefoxStudies = true;
    #     DisablePocket = true; # save webs for later reading
    #     DisableTelemetry = true;
    #     DontCheckDefaultBrowser = true;
    #     NoDefaultBookmarks = true;
    #     OfferToSaveLogins = false;
    #   };
    # };
  };
}
