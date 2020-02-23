FROM gitpod/workspace-full:latest
USER gitpod
RUN brew install haskell-stack
RUN stack install brittany hlint
RUN stack install haskell-ide-engine
ENV PATH=/home/gitpod/.local/bin:$PATH
