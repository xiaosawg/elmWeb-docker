FROM alpine

ENV VERSION 1.0.0

WORKDIR /etc/elmWeb

RUN set -xe && \
    UNAME=$(uname -m) && if [ "$UNAME" = "x86_64" ];then export PLATFORM=amd64; else export PLATFORM=arm64; fi && \
    apk add tzdata && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone && \
    apk del tzdata && \
    wget https://github.com/zelang/elmWeb-docker/releases/download/${VERSION}/elmWeb-{PLATFORM}.tar.gz && \
    tar -xvf elmWeb-{PLATFORM}.tar.gz && rm -rf elmWeb-{PLATFORM}.tar.gz

RUN chmod +x /etc/elmWeb/elmWeb
CMD ["/etc/elmWeb/elmWeb"]