#!/bin/sh
#
is_macos=`uname -a | grep Darwin`
is_linux=`uname -a | grep Linux`

if [ -n "$is_macos" ]; then
    echo "Detected a macos system..."
    sh <(curl -L https://nixos.org/nix/install)
elif [ -n "$is_linux" ]; then
    echo "Detected a linux system..."
    sh <(curl -L https://nixos.org/nix/install) --daemon
fi
