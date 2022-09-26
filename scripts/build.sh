#!/usr/bin/bash

set -e

source /opt/build/semver.sh

# Clean out folder
find /opt/out/ -mindepth 1 -maxdepth 1 -exec rm -r -- {} +

cd /opt
mkdir src

rsync -r /opt/orig/inochi-session/ /opt/src/inochi-session/

rsync -r /opt/orig/inochi2d/ /opt/src/inochi2d/
rsync -r /opt/orig/bindbc-imgui/ /opt/src/bindbc-imgui/
rsync -r /opt/orig/gitver/ /opt/src/gitver/
rsync -r /opt/orig/facetrack-d/ /opt/src/facetrack-d/
rsync -r /opt/orig/fghj/ /opt/src/fghj/
rsync -r /opt/orig/inmath/ /opt/src/inmath/
rsync -r /opt/orig/inui/ /opt/src/inui/
rsync -r /opt/orig/vmc-d/ /opt/src/vmc-d/
rsync -r /opt/orig/i18n/ /opt/src/i18n/
rsync -r /opt/orig/bindbc-spout2/ /opt/src/bindbc-spout2/

# apply patches

pushd patch
for d in */ ; do
    for p in ${d}*.patch; do
        echo "patch /opt/patch/$p"
        git -C /opt/src/${d} apply /opt/patch/$p
    done
done
popd

# Add dlang deps
dub add-local /opt/src/inochi2d/        "$(semver /opt/src/inochi2d/)"
dub add-local /opt/src/gitver/          "$(semver /opt/src/gitver/)"
dub add-local /opt/src/bindbc-imgui/    "$(semver /opt/src/bindbc-imgui/)"
dub add-local /opt/src/facetrack-d/     "$(semver /opt/src/facetrack-d/)"
dub add-local /opt/src/fghj/            "$(semver /opt/src/fghj/)"
dub add-local /opt/src/inmath/          "$(semver /opt/src/inmath/)"
dub add-local /opt/src/inui/            "$(semver /opt/src/inui/ 1.0.0)"
dub add-local /opt/src/vmc-d/           "$(semver /opt/src/vmc-d/)"
dub add-local /opt/src/i18n/            "$(semver /opt/src/i18n/)"
dub add-local /opt/src/bindbc-spout2/   "$(semver /opt/src/bindbc-spout2/)"

# Build bindbc-imgui deps
pushd src
pushd bindbc-imgui
mkdir -p deps/build_linux_x64_cimguiDynamic

ARCH=$(uname -m)
if [ "${ARCH}" == 'x86_64' ]; then
    if [[ -z ${DEBUG} ]]; then
        cmake -S deps -B deps/build_linux_x64_cimguiDynamic
        cmake --build deps/build_linux_x64_cimguiDynamic --config Release
    else
        cmake -DCMAKE_BUILD_TYPE=Debug -S deps -B deps/build_linux_x64_cimguiDynamic
        cmake --build deps/build_linux_x64_cimguiDynamic --config Debug
    fi
elif [ "${ARCH}" == 'aarch64' ]; then
    if [[ -z ${DEBUG} ]]; then
        cmake -S deps -B deps/build_linux_aarch64_cimguiDynamic
        cmake --build deps/build_linux_aarch64_cimguiDynamic --config Release
    else
        cmake -DCMAKE_BUILD_TYPE=Debug -S deps -B deps/build_linux_aarch64_cimguiDynamic
        cmake --build deps/build_linux_aarch64_cimguiDynamic --config Debug
    fi
fi

popd
popd

# Build inochi-session
pushd src
pushd inochi-session
if [[ ! -z ${DEBUG} ]]; then
    export DFLAGS='-g --d-debug'
fi
dub build --config=barebones
popd
popd

# Install
rsync -r /opt/src/inochi-session/out/ /opt/out/inochi/

dub list > /opt/out/version_dump