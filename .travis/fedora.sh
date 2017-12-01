#!/bin/bash
set -xe

# before_install
docker pull fedora:latest
docker run --name travis-ci -v $TRAVIS_BUILD_DIR:/primitiv-python -td fedora:latest /bin/bash

# install
docker exec travis-ci bash -c "dnf update -y"
docker exec travis-ci bash -c "dnf install -y git rpm-build gcc-c++ cmake python3-devel python3-numpy"
docker exec travis-ci bash -c "pip3 install cython scikit-build"

# install OpenCL environment
docker exec travis-ci bash -c "dnf install -y opencl-headers hwloc-devel libtool-ltdl-devel ocl-icd-devel ocl-icd clang llvm-devel clang-devel zlib-devel blas-devel boost-devel patch --setopt=install_weak_deps=False"
docker exec travis-ci bash -c "git clone https://github.com/clMathLibraries/clBLAS.git"
docker exec travis-ci bash -c "cd ./clBLAS/src && cmake . -DCMAKE_INSTALL_PREFIX=/usr -DBUILD_TEST=OFF -DBUILD_KTEST=OFF"
docker exec travis-ci bash -c "cd ./clBLAS/src && make && make install"
# pocl 0.13 does not contain mem_fence() function that is used by primitiv.
# We build the latest pocl instead of using distribution's package.
# See: https://github.com/pocl/pocl/issues/294
docker exec travis-ci bash -c "git clone https://github.com/pocl/pocl.git"
docker exec travis-ci bash -c "cd ./pocl && cmake . -DCMAKE_INSTALL_PREFIX=/usr"
docker exec travis-ci bash -c "cd ./pocl && make && make install"

if [ "${WITH_CORE_LIBRARY}" = "yes" ]; then
    # script
    docker exec travis-ci bash -c "cd /primitiv-python && git clone https://github.com/primitiv/primitiv.git primitiv-core"
    docker exec travis-ci bash -c "cd /primitiv-python && ./setup.py build --enable-opencl && ./setup.py test"

    # test installing by "pip install"
    docker exec travis-ci bash -c "cd /primitiv-python && ./setup.py sdist --bundle-core-library"
    docker exec travis-ci bash -c "pip3 install --user /primitiv-python/dist/primitiv-*.tar.gz --verbose"
    docker exec travis-ci bash -c "python3 -c 'import primitiv; dev = primitiv.devices.Naive()'"
    docker exec travis-ci bash -c "pip3 uninstall -y primitiv"
else
    # install core library
    docker exec travis-ci bash -c "git clone https://github.com/primitiv/primitiv.git libprimitiv"
    docker exec travis-ci bash -c "cd ./libprimitiv && cmake . -DPRIMITIV_USE_OPENCL=ON -DCMAKE_INSTALL_PREFIX=/usr"
    docker exec travis-ci bash -c "cd ./libprimitiv && make && make install"

    # script
    docker exec travis-ci bash -c "cd /primitiv-python && ./setup.py build --enable-opencl && ./setup.py test"
fi

# test installing by "./setup.py install"
docker exec travis-ci bash -c "cd /primitiv-python && ./setup.py install --enable-opencl"
docker exec travis-ci bash -c "python3 -c 'import primitiv; dev = primitiv.devices.Naive()'"
docker exec travis-ci bash -c "pip3 uninstall -y primitiv"

# after_script
docker stop travis-ci
