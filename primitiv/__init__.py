from primitiv._device import _Device as Device
from primitiv._graph import _Graph as Graph
from primitiv._initializer import _Initializer as Initializer
from primitiv._graph import _Node as Node
from primitiv._parameter import _Parameter as Parameter
from primitiv._shape import _Shape as Shape
from primitiv._tensor import _Tensor as Tensor
from primitiv._optimizer import _Optimizer as Optimizer

from primitiv import devices
from primitiv import initializers
from primitiv._operator import _operators as operators
from primitiv._operator import _tensor_operators as tensor_operators
from primitiv import optimizers
from primitiv import config

# NOTE(vbkaisetsu):
# Python uses unicode for string management, but C++ only uses raw byte arrays.
# This code sets the current locale information for the default encoding to convert
# strings between Python and C++.
config.set_encoding()


__all__ = [
    "Device",
    "Graph",
    "Initializer",
    "Node",
    "Parameter",
    "Shape",
    "Tensor",
    "Optimizer",

    "devices",
    "initializers",
    "operators",
    "tensor_operators",
    "optimizers",
    "config",
]
