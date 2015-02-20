# A simple Makefile for automating the installation of GHC and Cabal in your home directory.
# Should be used if you want a clean and minimal environment with just the latest GHC and Cabal, no
# Haskell-platform or any ot that other stuff.
#
# Inspired by https://gist.github.com/ion1/2815423

# Change this if wanting different version
GHC_VERSION=7.8.4
CABAL_VERSION=1.20.0.6

# URLs get builed based on the variables above
GHC_URL=https://www.haskell.org/ghc/dist/${GHC_VERSION}/ghc-${GHC_VERSION}-x86_64-unknown-linux-deb7.tar.xz
CABAL_INSTALL_URL=http://hackage.haskell.org/package/cabal-install-${CABAL_VERSION}/cabal-install-${CABAL_VERSION}.tar.gz

BUILD_DIR=/tmp/dhaskell-install

.phony: help check clean libgmp temp-dir download-ghc-tarball extract-ghc-tarball install-ghc download-cabal-install-tarball \
	extract-cabal-install-tarball install-cabal install

help:
	@echo "Please use \`make <target>' where <target> is one of"
	@echo '  install       to install both GHC (into $$HOME/.ghc) and Cabal (into $$HOME/.cabal).'
	@echo '  install-ghc   to install just GHC.'
	@echo '  install-cabal to install just Cabal.'
	@echo "  clean         to remove the temp directory ${BUILD_DIR} created during install."

check:
	@if [ -d $$HOME/.ghc ] || [ -d $$HOME/.cabal ]; then \
		echo 'Found existing installation!'; \
		echo 'To proceed please remove $$HOME/.ghc, $$HOME/.cabal and $$HOME/.cabal-sandbox'; \
		exit 1; \
	fi

deps:
	sudo apt-get install libgmp-dev build-essential

temp-dir:
	@echo "Making temp directory ${BUILD_DIR}..."
	@if [ ! -d ${BUILD_DIR}  ]; then \
		mkdir ${BUILD_DIR}; \
	fi

download-ghc-tarball: temp-dir
	@echo "Downloading GHC tarball..."
	@wget -O ${BUILD_DIR}/ghc.tar.xz ${GHC_URL}

extract-ghc-tarball: download-ghc-tarball
	@echo "Extracting GHC tarball"
	@cd ${BUILD_DIR} && tar xvf ghc.tar.xz

install-ghc: deps extract-ghc-tarball
	@echo "Compiling GHC..."
	@cd ${BUILD_DIR}/ghc-${GHC_VERSION} && ./configure --prefix=${HOME}/.ghc && make install

download-cabal-install-tarball: temp-dir
	@echo "Downloading cabala-install tarball..."
	@wget -O ${BUILD_DIR}/cabal-install.tar.gz ${CABAL_INSTALL_URL}

extract-cabal-install-tarball: download-cabal-install-tarball
	@echo "Extracting cabal-install tarball..."
	@cd ${BUILD_DIR} && tar zxvf cabal-install.tar.gz

install-cabal: deps extract-cabal-install-tarball
	@echo "Installing Cabal..."
	@cd ${BUILD_DIR}/cabal-install-${CABAL_VERSION} && EXTRA_CONFIGURE_OPTS=-p sh bootstrap.sh

install: install-ghc install-cabal
	@echo "Please make sure to update your PATH.\n"
	@echo 'export PATH="$$HOME/.ghc/bin:$$HOME/.cabal/bin:$$HOME/.cabal-sandbox/bin:$$PATH"'
	@echo "\nTo persist the PATH change add this to your .zshrc or .bashrc file."

clean:
	@rm -rf ${BUILD_DIR}


