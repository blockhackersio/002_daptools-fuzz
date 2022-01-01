FROM nixos/nix

RUN mkdir -p /app
RUN mkdir -p /nix

ENV USER=me
ENV UID=1000
ENV GID=1000

RUN addgroup -S -g $GID $USER && adduser -S -u $UID $USER -G $USER
RUN chown -R me:me /app
RUN chown -R me:me /nix

RUN apk --no-cache add curl jq git

USER $USER
WORKDIR /app

RUN echo $(curl -sS https://api.github.com/repos/dapphub/dapptools/releases/latest | jq -r .tarball_url) > version
RUN nix-env -iA dapp -f $(cat version) && \
nix-env -iA seth -f $(cat version) && \
nix-env -iA hevm -f $(cat version) && \
nix-env -iA ethsign -f $(cat version)

RUN nix-env -f https://github.com/dapphub/dapptools/archive/master.tar.gz -iA solc-static-versions.solc_0_8_6
RUN git config --global user.email ""
RUN git config --global user.name "anon"

ENV LANG=en_GB.UTF-8
ENV PATH=/home/me/.nix-profile/bin:$PATH