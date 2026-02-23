
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
nvim-deps:
	sudo apt-get install -y ninja-build gettext cmake curl build-essential git

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
	sudo apt install fzf -y
	cargo install --locked viu

.PHONY: unzip
unzip:
	sudo apt install unzip -y

.PHONY: libclang
libclang:
	sudo apt install libclang-dev -y

.PHONY:npm
npm:
	sudo apt install npm -y

.PHONY: go
go:
	sudo snap install go --classic

.PHONY: rustup
rustup:
	sudo snap install rustup --classic && \
	rustup default stable

.PHONY: cargo
cargo: rustup

.PHONY: venv
venv:
	sudo apt install python3-venv -y

.PHONY: git
git:
	sudo apt install git -y

.PHONY: clean
clean:
.PHONY: test
test:
