{
  config,
  lib,
  pkgs,
  platform,
  currentConfigSystem,
  ...
}:
{
  config = {
    services.openvpn.servers = {
      tw-vpn = {
        config = ''config /etc/nixos/talha-vpn/tw-tchavadar.conf '';
        autoStart = false;
        #updateResolvConf = true;
      };
      uk-vpn = {
        config = ''config /etc/nixos/talha-vpn/uk-tchavadar.conf '';
        autoStart = false;
        #updateResolvConf = true;
      };
    };
  };
}
