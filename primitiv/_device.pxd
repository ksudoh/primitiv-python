from libcpp.vector cimport vector
from libcpp.string cimport string
from libcpp cimport bool
from libc.stdint cimport uintptr_t

from primitiv._tensor cimport CppTensor
from primitiv._shape cimport CppShape


cdef extern from "primitiv/device.h":
    cdef cppclass CppDevice "primitiv::Device":
        void dump_description() except +


cdef extern from "primitiv/device.h":
    cdef CppDevice &CppDevice_get_default "primitiv::Device::get_default"()
    cdef void CppDevice_set_default "primitiv::Device::set_default"(CppDevice &dev)


cdef class _Device:
    cdef CppDevice *wrapped
    cdef object __weakref__


# This is used for holding python instances related to C++.
# Without this variable, python instances are always created when C++ class
# instances are returned from functions.
# It means that users can not compare instances by using "is" operator.
cdef object py_primitiv_device_weak_dict

cdef inline _Device wrapDevice(CppDevice *wrapped) except +:
    global py_primitiv_device_weak_dict

    # _Device instances should be created and be registered before this
    # function is called.
    return py_primitiv_device_weak_dict[<uintptr_t> wrapped]
