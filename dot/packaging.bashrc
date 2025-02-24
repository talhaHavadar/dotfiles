# mc related
if [ -f /usr/lib/mc/mc.sh ]; then
  . /usr/lib/mc/mc.sh
fi

alias dquilt="quilt --quiltrc=${HOME}/.quiltrc-dpkg"
. /usr/share/bash-completion/completions/quilt
complete -F _quilt_completion $_quilt_complete_opt dquilt

export DEBFULLNAME="Talha Can Havadar"
export DEBEMAIL="talha.can.havadar@canonical.com"
export UBUMAIL="Talha Can Havadar <talha.can.havadar@canonical.com>"

mksbuild() {
    series=$1
    arch=$2

    mk-sbuild "$series" --arch="$arch" && \
    sudo sed -i 's/^union-type=.*/union-type=overlay/' \
        /etc/schroot/chroot.d/sbuild-$series-$arch && \
    sbuild-update -udcar "$series"-"$arch"
}

sbuild-cross() {
    series=$1
    arch=$2
    shift 2
    sbuild -d "$series" -c "$series"-"$arch" --build "$arch" --host "$arch" "$@"
}
