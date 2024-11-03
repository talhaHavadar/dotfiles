{ config, lib, ... }:
let
  home_config = config.host.home.windowManagers.hyprland;
in
with lib;
{
  config = mkIf (home_config.enable) {

    wayland.windowManager.hyprland.settings = {
      dwindle = {
        pseudotile = "yes";
        preserve_split = "yes";
        special_scale_factor = 0.8;
      };

      master = {
        new_on_top = 1;
        mfact = 0.5;
      };

      general = {
        border_size = 2;
        gaps_in = 6;
        gaps_out = 8;

        resize_on_border = true;

        "col.active_border" = "rgb(0C0C14)";
        "col.inactive_border" = "rgb(FFFDFD)";

        layout = "dwindle";
      };

      input = {
        kb_layout = "us";
        kb_variant = "";
        kb_model = "";
        kb_options = "";
        kb_rules = "";
        repeat_rate = 50;
        repeat_delay = 300;

        sensitivity = 0; # mouse sensitivity
        numlock_by_default = true;
        left_handed = false;
        follow_mouse = true;
        float_switch_override_focus = false;
        natural_scroll = true;

        touchpad = {
          disable_while_typing = true;
          natural_scroll = true;
          clickfinger_behavior = false;
          middle_button_emulation = true;
          tap-to-click = true;
          drag_lock = false;
        };

        # below for devices with touchdevice ie. touchscreen
        touchdevice = {
          enabled = true;
        };

        # below is for table see link above for proper variables
        tablet = {
          transform = 0;
          left_handed = 0;
        };
      };

      gestures = {
        workspace_swipe = true;
        workspace_swipe_fingers = 3;
        workspace_swipe_distance = 500;
        workspace_swipe_invert = true;
        workspace_swipe_min_speed_to_force = 30;
        workspace_swipe_cancel_ratio = 0.5;
        workspace_swipe_create_new = true;
        workspace_swipe_forever = true;
        #workspace_swipe_use_r = true #uncomment if wanted a forever create a new workspace with swipe right
      };

      group = {
        "col.border_active" = "rgb(0C0C14)";

        groupbar = {
          "col.active" = "rgb(FFFDFD)";
        };
      };

      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        vfr = true;
        #vrr = 0
        mouse_move_enables_dpms = true;
        enable_swallow = true;
        swallow_regex = "^(kitty)$";
        focus_on_activate = false;
      };

      #opengl {
      #  nvidia_anti_flicker = true
      #}

      binds = {
        workspace_back_and_forth = true;
        allow_workspace_cycles = true;
        pass_mouse_when_bound = false;
      };

      #Could help when scaling and not pixelating
      xwayland = {
        force_zero_scaling = true;
      };
    };
  };
}
