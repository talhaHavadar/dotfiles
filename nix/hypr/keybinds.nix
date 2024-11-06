{ config, lib, ... }:
let
  home_config = config.host.home.windowManagers.hyprland;
in
with lib;
{
  config = mkIf (home_config.enable) {
    wayland.windowManager.hyprland.settings = {
      ###################
      ### KEYBINDINGS ###
      ###################
      "$mainMod" = "SUPER";
      # Default
      "$scriptsDir" = "$HOME/.config/hypr/scripts";
      "$configs" = "$HOME/.config/hypr/configs";
      # User
      "$UserConfigs" = "$HOME/.config/hypr/UserConfigs";
      "$UserScripts" = "$HOME/.config/hypr/UserScripts";

      "$files" = "thunar";
      "$term" = "kitty";
      "$screenlocker" = "hyprlock";

      bind = [
        "CTRL ALT, Delete, exec, hyprctl dispatch exit 0"
        "$mainMod, Q, killactive,"
        "$mainMod, F, fullscreen"
        "$mainMod SHIFT, Q, exec, $scriptsDir/KillActiveProcess.sh"
        "$mainMod SHIFT, F, togglefloating,"
        "$mainMod ALT, F, exec, hyprctl dispatch workspaceopt allfloat"
        "$mainMod, L, exec, pidof $screenlocker || $screenlocker"
        "CTRL ALT, P, exec, $scriptsDir/Wlogout.sh"

        # FEATURES / EXTRAS
        "$mainMod ALT, R, exec, $scriptsDir/Refresh.sh # Refresh waybar, swaync, rofi"
        "$mainMod ALT, E, exec, $scriptsDir/RofiEmoji.sh # emoji"
        "$mainMod, S, exec, $scriptsDir/RofiSearch.sh # Google search from Rofi"
        "$mainMod SHIFT, B, exec, $scriptsDir/ChangeBlur.sh # Toggle blur settings "
        "$mainMod SHIFT, G, exec, $scriptsDir/GameMode.sh # animations ON/OFF"
        "$mainMod ALT, L, exec, $scriptsDir/ChangeLayout.sh # Toggle Master or Dwindle Layout"
        "$mainMod ALT, V, exec, $scriptsDir/ClipManager.sh # Clipboard Manager"
        "$mainMod SHIFT, N, exec, swaync-client -t -sw # swayNC panel"

        # FEATURES / EXTRAS (UserScripts)
        "$mainMod, E, exec, $UserScripts/QuickEdit.sh # Quick Edit Hyprland Settings"
        "$mainMod SHIFT, M, exec, $UserScripts/RofiBeats.sh # online music"
        "$mainMod SHIFT, W, exec, $scriptsDir/wallpaperUpdate.sh # Wallpaper Effects by imagemagickWW"
        "$mainMod ALT, O, exec, hyprctl setprop active opaque toggle #disable opacity to active window"

        # Waybar / Bar related
        "$mainMod, B, exec, pkill -SIGUSR1 waybar # Toggle hide/show waybar "
        "$mainMod CTRL, B, exec, $scriptsDir/WaybarStyles.sh # Waybar Styles Menu"
        "$mainMod ALT, B, exec, $scriptsDir/WaybarLayout.sh # Waybar Layout Menu"

        # Master Layout
        "$mainMod CTRL, D, layoutmsg, removemaster"
        "$mainMod, I, layoutmsg, addmaster"
        "$mainMod, J, layoutmsg, cyclenext"
        "$mainMod, K, layoutmsg, cycleprev"
        "$mainMod, M, exec, hyprctl dispatch splitratio 0.3"
        "$mainMod, P, pseudo, # dwindle"
        "$mainMod CTRL, Return, layoutmsg, swapwithmaster"

        # group
        "$mainMod, G, togglegroup"
        "$mainMod CTRL, tab, changegroupactive  #change focus to another window"

        # Cycle windows if floating bring to top
        "ALT, tab, cyclenext"
        "ALT, tab, bringactivetotop  "
        # Screenshot keybindings NOTE: You may need to press Fn key as well
        "$mainMod, Print, exec, $scriptsDir/ScreenShot.sh --now"
        "$mainMod SHIFT, Print, exec, $scriptsDir/ScreenShot.sh --area"
        "$mainMod CTRL, Print, exec, $scriptsDir/ScreenShot.sh --in5 #screenshot in 5 secs"
        "$mainMod CTRL SHIFT, Print, exec, $scriptsDir/ScreenShot.sh --in10 #screenshot in 10 secs"
        "ALT, Print, exec, $scriptsDir/ScreenShot.sh --active #take screenshot of active window"
        "$mainMod SHIFT, S, exec, $scriptsDir/ScreenShot.sh --area"
        # Move windows
        "$mainMod CTRL, left, movewindow, l"
        "$mainMod CTRL, right, movewindow, r"
        "$mainMod CTRL, up, movewindow, u"
        "$mainMod CTRL, down, movewindow, d"
        # Move focus with mainMod + arrow keys
        "$mainMod, left, movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, up, movefocus, u"
        "$mainMod, down, movefocus, d"
        # Workspaces related
        "$mainMod, tab, workspace, m+1"
        "$mainMod SHIFT, tab, workspace, m-1"
        # Special workspace
        "$mainMod SHIFT, U, movetoworkspace, special"
        "$mainMod, U, togglespecialworkspace,"
        # The following mappings use the key codes to better support various keyboard layouts
        # 1 is code:10, 2 is code 11, etc
        # Switch workspaces with mainMod + [0-9] 
        "$mainMod, code:10, workspace, 1"
        "$mainMod, code:11, workspace, 2"
        "$mainMod, code:12, workspace, 3"
        "$mainMod, code:13, workspace, 4"
        "$mainMod, code:14, workspace, 5"
        "$mainMod, code:15, workspace, 6"
        "$mainMod, code:16, workspace, 7"
        "$mainMod, code:17, workspace, 8"
        "$mainMod, code:18, workspace, 9"
        "$mainMod, code:19, workspace, 10"
        # Move active window and follow to workspace mainMod + SHIFT [0-9]
        "$mainMod SHIFT, code:10, movetoworkspace, 1"
        "$mainMod SHIFT, code:11, movetoworkspace, 2"
        "$mainMod SHIFT, code:12, movetoworkspace, 3"
        "$mainMod SHIFT, code:13, movetoworkspace, 4"
        "$mainMod SHIFT, code:14, movetoworkspace, 5"
        "$mainMod SHIFT, code:15, movetoworkspace, 6"
        "$mainMod SHIFT, code:16, movetoworkspace, 7"
        "$mainMod SHIFT, code:17, movetoworkspace, 8"
        "$mainMod SHIFT, code:18, movetoworkspace, 9"
        "$mainMod SHIFT, code:19, movetoworkspace, 10"
        "$mainMod SHIFT, bracketleft, movetoworkspace, -1 # brackets [ or ]"
        "$mainMod SHIFT, bracketright, movetoworkspace, +1"

        # Move active window to a workspace silently mainMod + CTRL [0-9]
        "$mainMod CTRL, code:10, movetoworkspacesilent, 1"
        "$mainMod CTRL, code:11, movetoworkspacesilent, 2"
        "$mainMod CTRL, code:12, movetoworkspacesilent, 3"
        "$mainMod CTRL, code:13, movetoworkspacesilent, 4"
        "$mainMod CTRL, code:14, movetoworkspacesilent, 5"
        "$mainMod CTRL, code:15, movetoworkspacesilent, 6"
        "$mainMod CTRL, code:16, movetoworkspacesilent, 7"
        "$mainMod CTRL, code:17, movetoworkspacesilent, 8"
        "$mainMod CTRL, code:18, movetoworkspacesilent, 9"
        "$mainMod CTRL, code:19, movetoworkspacesilent, 10"
        "$mainMod CTRL, bracketleft, movetoworkspacesilent, -1 # brackets [ or ]"
        "$mainMod CTRL, bracketright, movetoworkspacesilent, +1"

        # Scroll through existing workspaces with mainMod + scroll
        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"
        "$mainMod ALT, right, workspace, e+1"
        "$mainMod ALT, left, workspace, e-1"

        # Move/resize windows with mainMod + LMB/RMB and dragging
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindowpixel"

        # rofi App launcher
        "$mainMod, space, exec, pkill rofi || rofi -show drun -modi drun,filebrowser,run,window -show-icons"

        # ags overview
        #bind = $mainMod, A, exec, pkill rofi || true && ags -t 'overview'
        "$mainMod, A, hyprexpo:expo, toggle"

        "$mainMod, Return, exec, $term  # Launch terminal"
        "$mainMod, T, exec, $files # Launch file manager"
      ];

      bindn = [
        # User Added Keybinds
        "ALT_L, SHIFT_L, exec, $scriptsDir/SwitchKeyboardLayout.sh # Changing the keyboard layout"
      ];

      # Move/resize windows with mainMod + LMB/RMB and dragging
      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];

      # For passthrough keyboard into a VM
      # bind = $mainMod ALT, P, submap, passthru
      #submap = passthru
      # to unbind
      #bind = $mainMod ALT, P, submap, reset
      #submap = reset
      # Special Keys / Hot Keys
      bindel = [
        ", xf86audioraisevolume, exec, $scriptsDir/volume.sh --inc #volume up"
        ", xf86audiolowervolume, exec, $scriptsDir/volume.sh --dec #volume down"
      ];
      bindl = [
        ", xf86AudioMicMute, exec, $scriptsDir/volume.sh --toggle-mic #mute mic"
        ", xf86audiomute, exec, $scriptsDir/volume.sh --toggle"
        ", xf86Sleep, exec, systemctl suspend  # sleep button "
        ", xf86Rfkill, exec, $scriptsDir/AirplaneMode.sh #Airplane mode"

        # media controls using keyboards
        ", xf86AudioPlayPause, exec, $scriptsDir/MediaCtrl.sh --pause"
        ", xf86AudioPause, exec, $scriptsDir/MediaCtrl.sh --pause"
        ", xf86AudioPlay, exec, $scriptsDir/MediaCtrl.sh --pause"
        ", xf86AudioNext, exec, $scriptsDir/MediaCtrl.sh --nxt"
        ", xf86AudioPrev, exec, $scriptsDir/MediaCtrl.sh --prv"
        ", xf86audiostop, exec, $scriptsDir/MediaCtrl.sh --stop"
      ];

      binde = [
        # Resize windows
        "$mainMod SHIFT, left, resizeactive,-50 0"
        "$mainMod SHIFT, right, resizeactive,50 0"
        "$mainMod SHIFT, up, resizeactive,0 -50"
        "$mainMod SHIFT, down, resizeactive,0 50"
      ];
    };
  };
}
