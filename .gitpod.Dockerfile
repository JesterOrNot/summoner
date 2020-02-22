FROM gitpod/workspace-full:latest
USER gitpod
# Install ghc, cabal, stack, and hlint with brew
RUN brew install \
    ghc \
    cabal-install \
    haskell-stack \
    hlint
# Install Deps
RUN sudo apt-get update \
    && sudo apt-get install -y \
        libtinfo-dev
# Install haskell-ide-engine from source code
RUN git clone https://github.com/haskell/haskell-ide-engine --recurse-submodules \
    && cd haskell-ide-engine \
    && stack ./install.hs hie \
    && cd .. \
    && rm -rf haskell-ide-engine
# Add /home/gitpod/.local/bin to $PATH for hlint
ENV PATH=/home/gitpod/.local/bin:$PATH
