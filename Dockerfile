FROM golang:latest

ENV VERSION 1.0.0

WORKDIR /etc/elmWeb

# Set the timezone to Asia/Shanghai and synchronize time
RUN ln -snf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone && \
    apt-get update && apt-get install -y tzdata && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN set -xe && \
    UNAME=$(uname -m) && if [ "$UNAME" = "x86_64" ];then export PLATFORM=amd64; else export PLATFORM=arm64; fi && \
    wget https://github.com/zelang/elmWeb-docker/releases/download/${VERSION}/elmWeb-${PLATFORM}.tar.gz && \
    tar -xvf elmWeb-${PLATFORM}.tar.gz && rm -rf elmWeb-${PLATFORM}.tar.gz && \
	mv elmWeb-${PLATFORM} elmWeb

RUN chmod +x /etc/elmWeb/elmWeb
CMD ["/etc/elmWeb/elmWeb"]