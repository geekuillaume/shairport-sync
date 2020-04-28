#!/usr/bin/env bash
set -eo pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd $DIR

if [ ! -z "$CROSS_ENV" ]
then
  sed -i "s/arm32v7/$CROSS_ENV/g" ./Dockerfile_crossarch
fi

docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
docker build ../ --file ./Dockerfile_crossarch --tag crossbuild

docker run --rm --workdir /workspace \
  -v `realpath ../`:/workspace \
  crossbuild bash -c "autoreconf -i -f && \
  ./configure --with-avahi --with-ssl=openssl --with-metadata --with-stdout --with-tinysvcmdns && \
  make"

