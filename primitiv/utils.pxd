from libcpp.vector cimport vector
from libcpp cimport bool
from libcpp.string cimport string

from primitiv._device cimport _Device
from primitiv._shape cimport _Shape, normShape
from primitiv._graph cimport _Graph, wrapNode, CppNode, _Node
from primitiv._parameter cimport _Parameter

cimport numpy as np
import numpy as np

cdef inline vector[float] ndarrays_to_vector(list arrays):
    cdef vector[float] result
    cdef np.float32_t *np_data
    cdef unsigned datasize
    cdef np.ndarray data_tmp

    # NOTE(odashi):
    # Below declaration is necessary to prevent large computation cost.
    cdef unsigned j, i

    if len(arrays) == 0:
        raise TypeError("arrays contains no item")
    datasize = arrays[0].size
    shape = arrays[0].shape
    result.resize(len(arrays) * datasize)
    for j, data in enumerate(arrays):
        if shape != data.shape:
            raise TypeError("arrays contains different shaped ndarrays")
        data_tmp = np.array(data, dtype=np.float32, order="F")
        np_data = <np.float32_t *> data_tmp.data
        for i in range(datasize):
            result[j * datasize + i] = np_data[i]
    return result


cdef string str_py2cpp(str s)
cdef str str_cpp2py(string s)
