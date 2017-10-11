from libcpp.vector cimport vector
from libcpp.memory cimport unique_ptr
from libcpp cimport bool
from primitiv._device cimport CppDevice
from primitiv._shape cimport CppShape
from primitiv._tensor cimport CppTensor


cdef extern from "primitiv/graph.h" namespace "primitiv" nogil:
    cdef cppclass CppNode "primitiv::Node":
        CppNode(CppNode &&src) except +
        CppNode() except +
        bool valid() except +
        CppGraph &graph() except +
        unsigned function_id() except +
        unsigned value_id() except +
        const CppShape &shape() except +
        CppDevice &device() except +
        vector[float] to_vector() except +


cdef extern from "node_op.h" namespace "python_primitiv_node":
    cdef CppNode op_node_pos(const CppNode &x) except +
    cdef CppNode op_node_neg(const CppNode &x) except +
    cdef CppNode op_node_add(const CppNode &x, float k) except +
    cdef CppNode op_node_add(float k, const CppNode &x) except +
    cdef CppNode op_node_add(const CppNode &a, const CppNode &b) except +
    cdef CppNode op_node_sub(const CppNode &x, float k) except +
    cdef CppNode op_node_sub(float k, const CppNode &x) except +
    cdef CppNode op_node_sub(const CppNode &a, const CppNode &b) except +
    cdef CppNode op_node_mul(const CppNode &x, float k) except +
    cdef CppNode op_node_mul(float k, const CppNode &x) except +
    cdef CppNode op_node_mul(const CppNode &a, const CppNode &b) except +
    cdef CppNode op_node_div(const CppNode &x, float k) except +
    cdef CppNode op_node_div(float k, const CppNode &x) except +
    cdef CppNode op_node_div(const CppNode &a, const CppNode &b) except +


cdef extern from "primitiv/graph.h" namespace "primitiv" nogil:
    cdef cppclass CppGraph "primitiv::Graph":
        CppGraph() except +
        const CppTensor &forward(const CppNode &node) except +
        void backward(const CppNode &node) except +
        const CppShape &get_shape(const CppNode &node) except +
        CppDevice &get_device(const CppNode &node) except +
        void dump() except +
        unsigned num_functions() except +


cdef class _Node:
    cdef CppNode wrapped


cdef class _Graph:
    cdef CppGraph *wrapped
    cdef CppGraph *wrapped_newed


cdef inline _Node wrapNode(CppNode wrapped) except +:
    cdef _Node node = _Node.__new__(_Node)
    node.wrapped = wrapped
    return node


cdef inline _Graph wrapGraph(CppGraph *wrapped) except +:
    cdef _Graph graph = _Graph.__new__(_Graph)
    graph.wrapped = wrapped
    return graph