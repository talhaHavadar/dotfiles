{ config
, lib
, pkgs
, ...
}:
let
  debian_packaging_config = config.host.features.debian-packaging;
  mkOutOfStoreSymlink = config.lib.file.mkOutOfStoreSymlink;
  dotfiles = "${config.home.homeDirectory}/.config/dotfiles/dot";
  link = path: { source = mkOutOfStoreSymlink "${dotfiles}/${path}"; };
in
{
  config = lib.mkIf debian_packaging_config.enable {
    home.packages = with pkgs; [
      ppa-dev-tools
    ];

    home.file = {
      # Run via `contained` when the real tool is missing from PATH
      ".local/bin/dch" = link "bin/packaging/contained-shim";
      ".local/bin/debuild" = link "bin/packaging/contained-shim";
      ".local/bin/uscan" = link "bin/packaging/contained-shim";
      ".local/bin/dput" = link "bin/packaging/contained-shim";
      ".local/bin/sbuild" = link "bin/packaging/contained-shim";
      ".local/bin/gbp" = link "bin/packaging/contained-shim";
      ".local/bin/quilt" = link "bin/packaging/contained-shim";
      ".local/bin/lintian" = link "bin/packaging/contained-shim";
      ".local/bin/git-ubuntu" = link "bin/packaging/contained-shim";
      ".devscripts" = link "devscripts";
      ".gbp.conf" = link "gbp.conf";
      ".quiltrc-dpkg" = link "quiltrc-dpkg";
      ".config/sbuild/config.pl" = link "sbuild/config.pl";
      ".packaging.bashrc" = link "packaging.bashrc";
      ".local/bin/packaging" = link "bin/packaging/packaging";
      ".local/bin/packaging-get-uploads" = link "bin/packaging/get-uploads";
      ".local/bin/packaging-convert-symbols" = link "bin/packaging/convert-symbols";
      ".local/bin/packaging-dch-auto" = link "bin/packaging/dch-auto";
      ".local/bin/packaging-dep-viz" = link "bin/packaging/dep-viz";
      ".local/bin/packaging-copy-from-ubuntu" = link "bin/packaging/copy-from-ubuntu";
      ".local/bin/packaging-ppa-build" = link "bin/packaging/ppa-build";
      ".local/bin/packaging-trigger-tests" = link "bin/packaging/trigger-tests.py";
      ".local/bin/lp-tools" = link "bin/lp-tools/lp-tools.sh";
      ".local/bin/lp-tools-create-bug" = link "bin/lp-tools/lp-tools-create-bug.py";
      ".local/bin/lp-tools-propose-merge" = link "bin/lp-tools/lp-tools-propose-merge.py";
      ".lp-tools-completion" = link "lp-tools-completion";
    };

    programs.git = {
      enable = true;
      settings = {
        core.excludesfile = "~/.gitignore_global";
        sparse.user.id = "talhaHavadar";
        gitubuntu.lpuser = "tchavadar";
        rebase.autoSquash = true;
        commit.gpgSign = "true";
        tag.gpgSign = true;
        log.showSignature = true;
        includeIf."gitdir:~/workspace/".path = "~/workspace/.gitconfig";
        includeIf."gitdir:~/projects/".path = "~/projects/.gitconfig";
      };
    };
  };
}
