FROM gitpod/workspace-full:latest
USER gitpod
RUN brew install haskell-stack
RUN stack install brittany hlint
RUN git clone https://github.com/haskell/haskell-ide-engine --recurse-submodules \
    && cd haskell-ide-engine \
    && stack ./install.hs hie-8.6.5 \
    && stack ./install.hs data \
    && cd .. \
    && rm -rf haskell-ide-engine
ENV PATH=/home/gitpod/.local/bin:$PATH
