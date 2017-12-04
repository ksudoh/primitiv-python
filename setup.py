#!/usr/bin/env python3

import os
import sys
import numpy as np

from setuptools.extension import Extension
from Cython.Build import build_ext

dirname = os.path.dirname(os.path.abspath(__file__))

if "--no-build-core" in sys.argv:
    build_core = False
    sys.argv.remove("--no-build-core")
else:
    build_core = os.path.exists(os.path.join(dirname, "primitiv-core/CMakeLists.txt"))

if build_core:
    from skbuild import setup
else:
    from setuptools import setup

bundle_core_library = False
if "--bundle-core-library" in sys.argv:
    if not build_core:
        print("primitiv-core/CMakeLists.txt is not found", file=sys.stderr)
        print("", file=sys.stderr)
        print("Run the following command to download primitiv core library:", file=sys.stderr)
        print("  git clone https://github.com/primitiv/primitiv.git primitiv-core", file=sys.stderr)
        print("", file=sys.stderr)
        sys.exit(1)
    bundle_core_library = True
    sys.argv.remove("--bundle-core-library")

enable_cuda = False
if "--enable-cuda" in sys.argv:
    enable_cuda = True
    sys.argv.remove("--enable-cuda")

enable_opencl = False
if "--enable-opencl" in sys.argv:
    enable_opencl = True
    sys.argv.remove("--enable-opencl")

def extension_common_args(*args, libraries=[], **kwargs):
    if build_core:
        libs = ["primitiv"]
        libs.extend(libraries)
        return Extension(*args, **kwargs,
            language="c++",
            libraries=libs,
            library_dirs = ["_skbuild/cmake-install/lib"],
            include_dirs=[
                np.get_include(),
                "_skbuild/cmake-install/include",
                os.path.join(dirname, "primitiv"),
            ],
            extra_compile_args=["-std=c++11"],
        )
    else:
        return Extension(*args, **kwargs,
            language="c++",
            libraries=["primitiv"],
            include_dirs=[
                np.get_include(),
                os.path.join(dirname, "primitiv"),
            ],
            extra_compile_args=["-std=c++11"],
        )

ext_modules = [
    extension_common_args("primitiv._shape",
                          sources=["primitiv/_shape.pyx"]),
    extension_common_args("primitiv._tensor",
                          sources=["primitiv/_tensor.pyx"]),
    extension_common_args("primitiv._device",
                          sources=["primitiv/_device.pyx"]),
    extension_common_args("primitiv.devices._naive_device",
                          sources=["primitiv/devices/_naive_device.pyx"]),
    extension_common_args("primitiv._parameter",
                          sources=["primitiv/_parameter.pyx"]),
    extension_common_args("primitiv._initializer",
                          sources=["primitiv/_initializer.pyx"]),
    extension_common_args("primitiv.initializers._initializer_impl",
                          sources=["primitiv/initializers/_initializer_impl.pyx"]),
    extension_common_args("primitiv._graph",
                          sources=["primitiv/_graph.pyx"]),
    extension_common_args("primitiv._optimizer",
                          sources=["primitiv/_optimizer.pyx"]),
    extension_common_args("primitiv.optimizers._optimizer_impl",
                          sources=["primitiv/optimizers/_optimizer_impl.pyx"]),
    extension_common_args("primitiv._operator",
                          sources=["primitiv/_operator.pyx"]),
    extension_common_args("primitiv._model",
                          sources=["primitiv/_model.pyx"]),
    extension_common_args("primitiv.config",
                          sources=["primitiv/config.pyx"]),
]

if enable_cuda:
    ext_modules.append(
        extension_common_args(
            "primitiv.devices._cuda_device",
            libraries=[
                "cudart",
                "rt",
                "pthread",
                "cublas",
                "curand",
            ],
            sources=["primitiv/devices/_cuda_device.pyx"],
        )
    )

if enable_opencl:
    ext_modules.append(
        extension_common_args(
            "primitiv.devices._opencl_device",
            libraries=[
                "OpenCL",
                "clBLAS",
            ],
            sources=["primitiv/devices/_opencl_device.pyx"],
        )
    )

setup_kwargs = {}
if build_core:
    setup_kwargs["cmake_source_dir"] = "primitiv-core"
    setup_kwargs["cmake_install_dir"] = "./"
    setup_kwargs["setup_requires"] = ["scikit-build"]
    setup_kwargs["cmake_args"] = ["-DPRIMITIV_BUILD_STATIC_LIBRARY=ON"]
    if enable_cuda:
        setup_kwargs["cmake_args"].append("-DPRIMITIV_USE_CUDA=ON")
    if enable_opencl:
        setup_kwargs["cmake_args"].append("-DPRIMITIV_USE_OPENCL=ON")

with open(os.path.join(dirname, "MANIFEST.in"), "w") as fp:
    print("include README.md", file=fp)
    print("recursive-include primitiv *.pyx *.pxd *.h", file=fp)
    print("exclude primitiv/_optimizer_api.h", file=fp)
    if bundle_core_library:
        print("recursive-include primitiv-core *", file=fp)

setup(
    name = "primitiv",
    version = "0.0.1",
    description = "primitiv: A Neural Network Toolkit. (Python frontend)",
    url = "https://github.com/odashi/primitiv",
    author = "Koichi Akabe",
    author_email = "vbkaisetsu at gmail.com",
    classifiers=[
        "Development Status :: 3 - Alpha",
        "Intended Audience :: Developers",
        "Intended Audience :: Science/Research",
        "License :: OSI Approved :: Apache Software License",
        "Operating System :: POSIX",
        "Programming Language :: C++",
        "Programming Language :: Python :: 3",
        "Topic :: Scientific/Engineering :: Artificial Intelligence",
    ],
    ext_modules = ext_modules,
    cmdclass={'build_ext': build_ext},
    packages = [
        "primitiv",
        "primitiv.devices",
        "primitiv.initializers",
        "primitiv.optimizers",
    ],
    install_requires=[
        "cython",
        "numpy",
    ],
    **setup_kwargs,
)
