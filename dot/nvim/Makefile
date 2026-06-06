# ============================================================
# PLATFORM DETECTION
# ============================================================
UNAME_S := $(shell uname -s)
IS_MACOS := $(filter Darwin,$(UNAME_S))
IS_LINUX := $(filter Linux,$(UNAME_S))
IS_NIXOS := $(if $(wildcard /etc/NIXOS),1,)
IS_UBUNTU := $(if $(shell grep -qi ubuntu /etc/os-release 2>/dev/null && echo 1),1,)

.PHONY: all
all: nvim install

.PHONY: nvim
nvim: .nvim-git/build/bin/nvim

install: .nvim-git/build/bin/nvim
	sudo make -C .nvim-git install

.nvim-git/build/bin/nvim: .nvim-git
	make -C .nvim-git CMAKE_BUILD_TYPE=Release

.nvim-git: | nvim-deps git
	git clone https://github.com/neovim/neovim .nvim-git

.PHONY: nvim-deps
nvim-deps: treesitter gopls bashls ruff fzf-lua
ifdef IS_UBUNTU
	sudo apt-get install -y ninja-build gettext cmake curl build-essential git
endif
ifdef IS_MACOS
	brew install ninja gettext cmake curl gcc git
endif

.PHONY: treesitter
treesitter: cargo libclang
	cargo install --locked tree-sitter-cli

.PHONY: gopls
gopls: go

.PHONY: bashls
bashls: npm

.PHONY: ruff
ruff: unzip venv

.PHONY: fzf-lua
fzf-lua: cargo
ifdef IS_UBUNTU
	sudo apt install fzf -y
endif
ifdef IS_MACOS
	brew install fzf
endif
	cargo install --locked viu

.PHONY: unzip
unzip:
ifdef IS_UBUNTU
	sudo apt install unzip -y
endif

.PHONY: libclang
libclang:
ifdef IS_UBUNTU
	sudo apt install libclang-dev -y
endif

.PHONY:npm
npm:
ifdef IS_UBUNTU
	sudo apt install npm -y
endif

.PHONY: go
go:
ifdef IS_UBUNTU
	sudo snap install go --classic
endif
ifdef IS_MACOS
	brew install go
endif

.PHONY: rustup
rustup:
ifdef IS_UBUNTU
	sudo snap install rustup --classic && rustup default stable
endif
ifdef IS_MACOS
	brew install rustup && rustup default stable
endif

.PHONY: cargo
cargo: rustup

.PHONY: venv
venv:
ifdef IS_UBUNTU
	sudo apt install python3-venv -y
endif

.PHONY: git
git:
ifdef IS_UBUNTU
	sudo apt install git -y
endif

.PHONY: clean
clean:
	rm -rf .nvim-git nvim-offline-*.tar.gz

.PHONY: test
test:

# ============================================================================
# OFFLINE EXPORT / INSTALL
# ============================================================================

NVIM_DATA := $(HOME)/.local/share/nvim
NVIM_CONFIG := $(HOME)/.config/nvim
EXPORT_DIR := nvim-offline-export
EXPORT_TARBALL := nvim-offline-$$(date +%Y%m%d).tar.gz

.PHONY: export
export:
	@echo "==> Creating offline nvim export..."
	rm -rf $(EXPORT_DIR)
	mkdir -p $(EXPORT_DIR)/bin
	mkdir -p $(EXPORT_DIR)/share
	mkdir -p $(EXPORT_DIR)/config
	mkdir -p $(EXPORT_DIR)/data/site
	mkdir -p $(EXPORT_DIR)/data/mason
	@echo "==> Copying nvim binary..."
	cp $$(which nvim) $(EXPORT_DIR)/bin/
	@echo "==> Copying nvim runtime..."
	cp -r /usr/local/share/nvim $(EXPORT_DIR)/share/ 2>/dev/null || \
		cp -r /usr/share/nvim $(EXPORT_DIR)/share/ 2>/dev/null || \
		echo "Warning: Could not find nvim runtime, will use built-in"
	@echo "==> Copying nvim config..."
	cp -r $(NVIM_CONFIG)/* $(EXPORT_DIR)/config/ 2>/dev/null || true
	@echo "==> Copying plugins (vim.pack)..."
	cp -r $(NVIM_DATA)/site/pack $(EXPORT_DIR)/data/site/ 2>/dev/null || true
	@echo "==> Copying treesitter parsers..."
	cp -r $(NVIM_DATA)/site/parser $(EXPORT_DIR)/data/site/ 2>/dev/null || true
	cp -r $(NVIM_DATA)/site/parser-info $(EXPORT_DIR)/data/site/ 2>/dev/null || true
	@echo "==> Copying treesitter queries (dereferencing symlinks)..."
	cp -rL $(NVIM_DATA)/site/queries $(EXPORT_DIR)/data/site/ 2>/dev/null || true
	@echo "==> Copying mason packages (LSPs, formatters, linters)..."
	cp -r $(NVIM_DATA)/mason $(EXPORT_DIR)/data/ 2>/dev/null || true
	@echo "==> Copying lock file..."
	cp $(NVIM_DATA)/nvim-pack-lock.json $(EXPORT_DIR)/data/ 2>/dev/null || true
	@echo "==> Copying install script..."
	cp $(CURDIR)/offline-install.sh $(EXPORT_DIR)/install.sh
	chmod +x $(EXPORT_DIR)/install.sh
	@echo "==> Creating tarball..."
	tar -czvf $(EXPORT_TARBALL) $(EXPORT_DIR)
	rm -rf $(EXPORT_DIR)
	@echo ""
	@echo "==> Export complete: $(EXPORT_TARBALL)"
	@echo "    Transfer this file to your offline machine and run:"
	@echo "      tar -xzvf $(EXPORT_TARBALL)"
	@echo "      cd nvim-offline-export && ./install.sh"
