FROM docker.io/library/debian:bullseye
ENV DEBIAN_FRONTEND=noninteractive
RUN echo "deb http://archive.debian.org/debian bullseye main" > /etc/apt/sources.list  && echo "deb http://archive.debian.org/debian-security bullseye-security main" >> /etc/apt/sources.list  && apt-get -o Acquire::Check-Valid-Until=false update  && apt-get install -y --no-install-recommends     gcc g++ make bison flex m4 texinfo     libncurses-dev zlib1g-dev libexpat1-dev     python3 file ca-certificates  && rm -rf /var/lib/apt/lists/*
WORKDIR /work
