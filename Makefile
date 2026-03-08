# Dotfiles Root Makefile
# Repository: ~/.config/dotfiles
#
# Usage:
#   make help         Show all available targets
#   make check        Verify what's installed
#   make nvim         Build neovim from source
#   make river        Install river compositor (Ubuntu only)
#
# Targets are designed to be idempotent - safe to run multiple times.

SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c

# ============================================================
# DIRECTORIES
# ============================================================
DOTFILES_DIR := $(shell cd $(dir $(lastword $(MAKEFILE_LIST))) && pwd)
DOT_DIR := $(DOTFILES_DIR)/dot
NIX_DIR := $(DOTFILES_DIR)/nix

# ============================================================
# PLATFORM DETECTION
# ============================================================
UNAME_S := $(shell uname -s)
IS_MACOS := $(filter Darwin,$(UNAME_S))
IS_LINUX := $(filter Linux,$(UNAME_S))
IS_NIXOS := $(if $(wildcard /etc/NIXOS),1,)
IS_UBUNTU := $(if $(shell grep -qi ubuntu /etc/os-release 2>/dev/null && echo 1),1,)

# ============================================================
# TOOL DETECTION
# ============================================================
HAS_NIX := $(if $(shell command -v nix 2>/dev/null),1,)
HAS_HOME_MANAGER := $(if $(shell command -v home-manager 2>/dev/null),1,)
HAS_APT := $(if $(shell command -v apt 2>/dev/null),1,)
HAS_BREW := $(if $(shell command -v brew 2>/dev/null),1,)

# ============================================================
# HELPER FUNCTIONS
# ============================================================
define create_symlink
	@mkdir -p $(dir $(2))
	@ln -sfn $(1) $(2)
	@echo "  $(2) -> $(1)"
endef

.PHONY: all
all: help

.PHONY: help
help:
	@echo "Platform: $(if $(IS_MACOS),macOS,$(if $(IS_NIXOS),NixOS,$(if $(IS_UBUNTU),Ubuntu,Linux)))"
	@echo "Nix: $(if $(HAS_NIX),installed,not installed)"
	@echo "Home-Manager: $(if $(HAS_HOME_MANAGER),installed,not installed)"
	@echo ""
	@echo "Features (auto-detect platform):"
	@echo "  make nvim         Build neovim from source"
	@echo "  make river        River compositor + kwm (Ubuntu only)"
	@echo "  make packaging    Packaging tools + sbuild (Ubuntu only)"
	@echo "  make yubikey      Security/Yubikey tools"
	@echo "  make cli          CLI utilities (ripgrep, btop, etc.)"
	@echo "  make zen-browser  Install Zen Browser"
	@echo "  make flatpak      Install Flatpak"
	@echo "  make desktop      Install desktop environment that I like"
	@echo ""
	@echo "Nix/Home-Manager:"
	@echo "  make nix          Install nix + home-manager"
	@echo "  make home-manager Re-apply home-manager config"
	@echo "  make nix-headless Headless server setup"
	@echo ""
	@echo "Symlinks (home-manager aware):"
	@echo "  make symlinks     All config symlinks"
	@echo "  make symlinks-X   Specific: nvim, river, shell, packaging, git, ghostty, systemd"
	@echo ""
	@echo "Utilities:"
	@echo "  make clean        Clean build artifacts"

.PHONY: clean
clean:
	@echo "Cleaning build artifacts..."
	$(MAKE) -C $(DOT_DIR)/nvim clean 2>/dev/null || true
	@echo "Clean complete"

.PHONY: desktop
desktop: nvim river zen-browser yubikey cli nix
	@echo "Desktop setup complete"

.PHONY: nvim
nvim: nvim-deps symlinks-nvim
	$(MAKE) -C $(DOT_DIR)/nvim all

.PHONY: nvim-deps
nvim-deps:
ifdef IS_UBUNTU
	@echo "Installing nvim dependencies..."
	sudo apt install -y wl-clipboard
endif
	@# Core build deps (cmake, ninja, etc.) handled by dot/nvim/Makefile

.PHONY: nvim-install
nvim-install:
	$(MAKE) -C $(DOT_DIR)/nvim install

.PHONY: river
river: river-deps symlinks-river
	@echo "River setup complete. Run 'river' to start."

.PHONY: river-deps
river-deps: pwvucontrol overskride
ifdef IS_UBUNTU
	@echo "Adding river PPA..."
	sudo add-apt-repository -y ppa:tchavadar/river-unstable || true
	sudo apt update
	@echo "Installing river and dependencies..."
	sudo apt install -y river waylock wlr-randr grim slurp wl-clipboard kanshi wlogout wlsunset network-manager-applet
else
	@echo "WARNING: River is only available on Ubuntu via PPA."
	@echo "On NixOS/macOS, configure in your nix config instead."
	@false
endif

.PHONY: pwvucontrol
pwvucontrol: flatpak
ifdef IS_UBUNTU
	flatpak install flathub com.saivert.pwvucontrol
else ifdef IS_MACOS
	@echo "No pwvucontrol for you macos"
endif

.PHONY: overskride
overskride: flatpak
ifdef IS_UBUNTU
	@if flatpak list --app | grep -q io.github.kaii_lb.Overskride; then \
		echo "Overskride already installed. Run 'make overskride-update' to update."; \
	else \
		$(MAKE) overskride-install; \
	fi
endif

.PHONY: overskride-update overskride-install
overskride-update overskride-install: flatpak
ifdef IS_UBUNTU
	@echo "Downloading Overskride (Bluetooth client)..."
	curl -sSL -o /tmp/overskride.flatpak https://github.com/kaii-lb/overskride/releases/latest/download/overskride.flatpak
	sudo flatpak install -y /tmp/overskride.flatpak || sudo flatpak update -y io.github.kaii_lb.Overskride
	rm -f /tmp/overskride.flatpak
	@echo "Overskride installed/updated successfully."
endif

# ============================================================
# PACKAGING FEATURE (Ubuntu only)
# ============================================================
.PHONY: packaging
packaging: packaging-deps symlinks-packaging packaging-setup
	@echo ""
	@echo "Packaging setup complete."
	@echo "NOTE: Log out and back in for group membership to take effect."

.PHONY: packaging-deps
packaging-deps:
ifdef IS_UBUNTU
	@echo "Installing packaging tools..."
	sudo apt update
	sudo apt install -y sbuild \
		ubuntu-dev-tools \
		autopkgtest \
		lintian \
		git-buildpackage \
		config-package-dev \
		lxc-templates \
		dh-sequence-gir \
		python3-venv
	sudo snap install git-ubuntu --classic || true
	sudo snap install lxd || true
	sudo snap install ppa-dev-tools || true
else
	@echo "ERROR: Packaging tools are only available on Ubuntu."
	@false
endif

.PHONY: packaging-setup
packaging-setup:
ifdef IS_UBUNTU
	@echo "Creating sbuild directories..."
	mkdir -p $(HOME)/sbuild/build
	mkdir -p $(HOME)/sbuild/logs
	mkdir -p $(HOME)/sbuild/scratch
	@echo "Adding user to sbuild group..."
	sudo adduser $(USER) sbuild || true
	@echo "Adding user to lxd group..."
	sudo adduser $(USER) lxd || true
	@echo "Make sure to run 'setup-packaging-environment' to complete the setup"
endif

# ============================================================
# YUBIKEY FEATURE
# ============================================================
.PHONY: yubikey
yubikey: yubikey-deps
	@echo "Yubikey setup complete."
	@echo "Use 'pamu2fcfg > ~/.config/Yubico/u2f_keys' to setup keys"

.PHONY: yubikey-deps
yubikey-deps:
ifdef IS_UBUNTU
	@echo "Installing Yubikey tools..."
	sudo apt update
	sudo apt install -y pcscd sssd libpam-sss scdaemon yubikey-manager libpam-u2f libfido2-dev
else ifdef HAS_NIX
	@echo "Yubikey tools are managed via home-manager."
	@echo "Run 'make home-manager' to apply nix config."
else
	@echo "ERROR: Install nix first with 'make nix', then 'make home-manager'"
	@false
endif

.PHONY: cli
cli: cli-deps
	@echo "CLI tools installed."

.PHONY: cli-deps
cli-deps: flatpak jj rustup
ifdef IS_UBUNTU
	@echo "Installing CLI tools via apt..."
	sudo apt update
	sudo apt install -y btop tree ripgrep flatpak
	@echo "Installing snaps..."
	sudo snap install ghostty --classic || true
	sudo snap install git-ubuntu --classic || true
	sudo snap install snapcraft --classic || true
	sudo snap install glow || true
	sudo snap install lxd || true
	sudo snap install ppa-dev-tools || true
else ifdef HAS_NIX
	@echo "CLI tools are managed via home-manager."
	@echo "Run 'make home-manager' to apply nix config."
else
	@echo "ERROR: Install nix first with 'make nix', then 'make home-manager'"
	@false
endif

.PHONY: zen-browser
zen-browser: flatpak
ifdef IS_UBUNTU
	flatpak install flathub app.zen_browser.zen
else ifdef IS_MACOS
	brew install --cask zen-browser
endif

.PHONY: flatpak
flatpak:
ifdef IS_UBUNTU
	@echo "Installing flatpak via apt..."
	sudo apt update
	sudo apt install -y flatpak
	@echo "Setting up flatpak..."
	@flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true
else
	@echo "flatpak is not available on this platform"
endif

.PHONY: jj
jj: cargo
	cargo install --locked --bin jj jj-cli

.PHONY: rustup
rustup:
ifdef IS_UBUNTU
	sudo snap install rustup --classic && \
	rustup default stable
else ifdef HAS_NIX
	@echo "CLI tools are managed via home-manager."
	@echo "Run 'make home-manager' to apply nix config."
else
	@echo "ERROR: Install nix first with 'make nix', then 'make home-manager'"
	@false
endif

.PHONY: cargo
cargo: rustup

# ============================================================
# NIX TARGETS
# ============================================================
.PHONY: nix
nix: nix-install home-manager

.PHONY: nix-install
nix-install:
ifdef IS_NIXOS
	@echo "On NixOS, nix is already available."
	@echo "Use 'sudo nixos-rebuild switch --flake $(NIX_DIR)#<hostname>'"
else ifndef HAS_NIX
	@echo "Installing nix..."
ifdef IS_MACOS
	@curl -L https://nixos.org/nix/install | sh
else
	@curl -L https://nixos.org/nix/install | sh -s -- --daemon
endif
	mkdir -p $(HOME)/.config/nix
	ln -sf $(DOTFILES_DIR)/nix.conf $(HOME)/.config/nix/nix.conf
	@echo ""
	@echo "Nix installed. Restart your shell and run 'make home-manager'."
else
	@echo "Nix is already installed."
endif

.PHONY: home-manager
home-manager: nix-install
ifdef IS_NIXOS
	@echo "On NixOS, use 'sudo nixos-rebuild switch --flake $(NIX_DIR)#<hostname>'"
else ifdef HAS_HOME_MANAGER
	@echo "Running home-manager switch..."
	home-manager switch --flake $(NIX_DIR)#linux --impure -b backup
else ifdef HAS_NIX
	@echo "Running home-manager init..."
	nix run home-manager -- init --switch $(NIX_DIR)#linux --impure -b backup
else
	@echo "ERROR: Nix not installed. Run 'make nix-install' first."
	@false
endif

.PHONY: nix-headless
nix-headless: nix-install
ifdef HAS_HOME_MANAGER
	home-manager switch --flake $(NIX_DIR)#ubuntu-headless --impure -b backup
else ifdef HAS_NIX
	nix run home-manager -- init --switch $(NIX_DIR)#ubuntu-headless --impure -b backup
else
	@echo "ERROR: Nix not installed. Run 'make nix-install' first."
	@false
endif

# ============================================================
# SYMLINK TARGETS (home-manager aware)
# ============================================================
.PHONY: symlinks
symlinks:
ifdef HAS_HOME_MANAGER
	@echo "Symlinks are managed by home-manager."
	@echo "Run 'make home-manager' to apply your nix configuration."
else
	@echo "home-manager not found, creating symlinks manually..."
	$(MAKE) _symlinks-manual
endif

.PHONY: _symlinks-manual
_symlinks-manual: _symlinks-nvim _symlinks-river _symlinks-shell _symlinks-packaging _symlinks-git _symlinks-ghostty _symlinks-systemd
	@echo "All symlinks created."

# Individual symlink targets (check for home-manager)
.PHONY: symlinks-nvim
symlinks-nvim:
ifdef HAS_HOME_MANAGER
	@echo "nvim symlinks managed by home-manager. Run 'make home-manager'."
else
	$(MAKE) _symlinks-nvim
endif

.PHONY: symlinks-river
symlinks-river:
ifdef HAS_HOME_MANAGER
	@echo "river symlinks managed by home-manager. Run 'make home-manager'."
else
	$(MAKE) _symlinks-river
endif

.PHONY: symlinks-shell
symlinks-shell:
ifdef HAS_HOME_MANAGER
	@echo "shell symlinks managed by home-manager. Run 'make home-manager'."
else
	$(MAKE) _symlinks-shell
endif

.PHONY: symlinks-packaging
symlinks-packaging:
ifdef HAS_HOME_MANAGER
	@echo "packaging symlinks managed by home-manager. Run 'make home-manager'."
else
	$(MAKE) _symlinks-packaging
endif

.PHONY: symlinks-git
symlinks-git:
ifdef HAS_HOME_MANAGER
	@echo "git symlinks managed by home-manager. Run 'make home-manager'."
else
	$(MAKE) _symlinks-git
endif

.PHONY: symlinks-ghostty
symlinks-ghostty:
ifdef HAS_HOME_MANAGER
	@echo "ghostty symlinks managed by home-manager. Run 'make home-manager'."
else
	$(MAKE) _symlinks-ghostty
endif

.PHONY: symlinks-systemd
symlinks-systemd:
ifdef HAS_HOME_MANAGER
	@echo "systemd symlinks managed by home-manager. Run 'make home-manager'."
else
	$(MAKE) _symlinks-systemd
endif

# Internal manual symlink targets (prefixed with _)
# NOTE: Most configs symlink whole directories (like home-manager does)
# Exception: systemd symlinks individual service files (not the whole dir)

.PHONY: _symlinks-nvim
_symlinks-nvim:
	@echo "Creating nvim symlinks..."
	$(call create_symlink,$(DOT_DIR)/nvim,$(HOME)/.config/nvim)

.PHONY: _symlinks-river
_symlinks-river:
	@echo "Creating river/kwm symlinks (directories)..."
	$(call create_symlink,$(DOT_DIR)/river,$(HOME)/.config/river)
	$(call create_symlink,$(DOT_DIR)/kanshi,$(HOME)/.config/kanshi)
	$(call create_symlink,$(DOT_DIR)/kwm,$(HOME)/.config/kwm)
	$(call create_symlink,$(DOT_DIR)/wlogout,$(HOME)/.config/wlogout)
	$(call create_symlink,$(DOT_DIR)/waybar,$(HOME)/.config/waybar)

.PHONY: _symlinks-shell
_symlinks-shell:
	@echo "Creating shell symlinks..."
	$(call create_symlink,$(DOT_DIR)/starship.toml,$(HOME)/.config/starship.toml)
	$(call create_symlink,$(DOT_DIR)/complete_alias,$(HOME)/.complete_alias)
	$(call create_symlink,$(DOT_DIR)/tmux-completion,$(HOME)/.tmux-completion)

.PHONY: _symlinks-packaging
_symlinks-packaging:
	@echo "Creating packaging symlinks..."
	$(call create_symlink,$(DOT_DIR)/sbuildrc,$(HOME)/.sbuildrc)
	$(call create_symlink,$(DOT_DIR)/mk-sbuild.rc,$(HOME)/.mk-sbuild.rc)
	$(call create_symlink,$(DOT_DIR)/quiltrc-dpkg,$(HOME)/.quiltrc-dpkg)
	$(call create_symlink,$(DOT_DIR)/devscripts,$(HOME)/.devscripts)
	$(call create_symlink,$(DOT_DIR)/gbp.conf,$(HOME)/.gbp.conf)
	$(call create_symlink,$(DOT_DIR)/packaging.bashrc,$(HOME)/.packaging.bashrc)

.PHONY: _symlinks-git
_symlinks-git:
	@echo "Creating git symlinks..."
	$(call create_symlink,$(DOT_DIR)/gitconfig.projects,$(HOME)/.gitconfig.projects)
	$(call create_symlink,$(DOT_DIR)/gitconfig.workspace,$(HOME)/.gitconfig.workspace)

.PHONY: _symlinks-ghostty
_symlinks-ghostty:
	@echo "Creating ghostty symlinks..."
	$(call create_symlink,$(DOT_DIR)/ghostty,$(HOME)/.config/ghostty)

.PHONY: _symlinks-systemd
_symlinks-systemd:
	@echo "Creating systemd symlinks (individual service files)..."
	@mkdir -p $(HOME)/.config/systemd/user
	$(call create_symlink,$(DOT_DIR)/systemd/user/river-session.target,$(HOME)/.config/systemd/user/river-session.target)
	$(call create_symlink,$(DOT_DIR)/systemd/tq.service,$(HOME)/.config/systemd/user/tq.service)
	$(call create_symlink,$(DOT_DIR)/systemd/tq.timer,$(HOME)/.config/systemd/user/tq.timer)
