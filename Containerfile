FROM fedora:37

RUN dnf update -y \
    && \
    dnf groupinstall -y \
        "Development Tools" \
        "Development Libraries"
RUN dnf update -y \
    && \
    dnf install -y \
        ldc \
        rsync \
        cmake \
        gcc \
        gcc-c++ \
        SDL2-devel \
        freetype-devel \
        dub \
        git

RUN dnf install -y \
        luajit-devel

ADD scripts /opt/build

WORKDIR /opt/build/

CMD ./build.sh
