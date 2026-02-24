let
  gnupg = "2.4.7";
  claude-code = "2.1.2";
in
{
  # keep this magic handy
  #hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

  nixpkgs.overlays = [
    (final: prev: {
      gnupg = prev.gnupg.overrideAttrs (old: {
        version = gnupg;
        src = prev.fetchurl {
          url = "https://gnupg.org/ftp/gcrypt/gnupg/gnupg-${gnupg}.tar.bz2";
          hash = "sha256-eyRwbk2n4OOwbKBoIxAnQB8jgQLEHJCWMTSdzDuF60Y=";
        };
      });
    })
    #(final: prev: {
    #  claude-code = prev.claude-code.overrideAttrs (oldAttrs: {
    #    version = claude-code;
    #    src = prev.fetchurl {
    #      url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${claude-code}.tgz";
    #      sha256 = "sha256-yCRQtK286EOGVs+0SMokATpvwCeZC4irV1bmhU0kgiI=";
    #    };
    #  });
    #})
    # TODO: disabled checks for xdg-desktop-portal 19 Dec. 2025
    # > (/build/source/build/src/xdg-desktop-portal:5143): xdg-desktop-portal-WARNING **: 14:35:52.293: Failed connect to PipeWire: Couldn't connect to PipeWire
    # >   ----------------------------- Captured stderr call -----------------------------
    # >   bwrap: loopback: Failed RTM_NEWADDR: Operation not permitted
    # >
    # >   (/build/source/build/src/xdg-desktop-portal:5143): xdg-desktop-portal-WARNING **: 14:35:52.493: Sound validation: Rejecting sound because validator failed: Child process exited with code 1
    # >   =========================== short test summary info ============================
    # >   FAILED ../tests/test_notification.py::TestNotification::test_sound_fd - gi.re...
    # >   ======================== 1 failed, 18 passed in 10.83s =========================
    # >
    # >
    # >   24/27 xdg-desktop-portal:integration / integration/screenshot               OK              9.74s
    # >   25/27 xdg-desktop-portal:integration / integration/filechooser              OK             13.95s
    # >   26/27 xdg-desktop-portal:integration / integration/settings                 OK             12.18s
    # >   27/27 xdg-desktop-portal:integration / integration/usb                      OK             14.65s
    # >
    # >   Summary of Failures:
    # >
    # >    6/27 xdg-desktop-portal:integration / integration/dynamiclauncher  FAIL            1.46s   exit status 1
    # >   23/27 xdg-desktop-portal:integration / integration/notification     FAIL           11.21s   exit status 1
    # >
    # >   Ok:                23
    # >   Fail:              2
    # >   Skipped:           2
    # >
    # >   Full log written to /build/source/build/meson-logs/testlog.txt
    (final: prev: {
      xdg-desktop-portal = prev.xdg-desktop-portal.overrideAttrs (old: {
        doCheck = false;
      });
    })
    # (final: prev: {
    #   # Fix xdg-desktop-portal-gnome GVFS library loading error
    #   # Wrap the portal to prevent it from loading incompatible GVFS modules
    #   xdg-desktop-portal-gnome = prev.xdg-desktop-portal-gnome.overrideAttrs (oldAttrs: {
    #     # Set environment variable to prevent GVFS module loading
    #     preFixup = (oldAttrs.preFixup or "") + ''
    #       # Disable GIO module loading to prevent GVFS symbol errors
    #       gappsWrapperArgs+=(
    #         --unset GIO_EXTRA_MODULES
    #         --set GIO_USE_VFS "local"
    #         --set GSETTINGS_BACKEND "memory"
    #       )
    #     '';
    #   });
    # })
  ];
}
