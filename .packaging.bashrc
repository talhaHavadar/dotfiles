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
