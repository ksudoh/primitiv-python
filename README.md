Python frontend of primitiv
===========================

Dependency
----------

* [primitiv core library](https://github.com/primitiv/primitiv)
* Python 3.5 or later
* NumPy 1.11 or later
* Cython 0.27 or later

Installation
------------

1. Install [primitiv core library](http://github.com/primitiv/primitiv) to your machine in advance.

2. Install NumPy and Cython with Python 3

```shell
$ sudo apt install python3-numpy
$ sudo pip3 install cython
```

Currently, Cython 0.27 is not contained in Debian and Ubuntu repositories.

3. Run the following commands in python-primitiv directory:

```shell
$ python3 ./setup.py build [--enable-cuda] [--enable-opencl]
$ python3 ./setup.py test  # (optional)
$ sudo python3 ./setup.py install [--enable-cuda] [--enable-opencl]
```

You also can use `LIBRARY_PATH` and `CPLUS_INCLUDE_PATH` depending on your environment.

To install CUDA and/or OpenCL support, run setup script with `--enable-DEVICE` option.

For developers
--------------

To generate a tar ball with primitiv core library, run `setup.py sdist` command with
`--bundle-core-library` option.