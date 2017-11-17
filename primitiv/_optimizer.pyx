from primitiv._model cimport _Model
from primitiv._parameter cimport _Parameter
from primitiv.config cimport pystr_to_cppstr, cppstr_to_pystr


cdef class _Optimizer:

    # NOTE(vbkaisetsu):
    # This method should be called in the __init__() method of a
    # custom Optimizer class.
    #
    # Users can define custom optimizers written in Python. This method
    # generates an instance of a helper optimizer called "PyOptimizer" that
    # can call methods implemented in child classes of Optimizer.
    def __init__(self):
        if self.wrapped is not NULL:
            raise TypeError("__init__() has already been called.")
        self.wrapped = new CppPyOptimizer(self)

    # NOTE(vbkaisetsu):
    # This method is also used by child classes implemented in
    # optimizers/_optimizer_impl.pyx
    # Please be careful when you change behavior around pointer of PyOptimizer.
    def __dealloc__(self):
        # NOTE(vbkaisetsu):
        # DO NOT delete C++ instance without checking NULL.
        # __init__() is not guaranteed to be called when an instance is created.
        # e.g. __new__() method, inherited without __init__(), etc.
        if self.wrapped is not NULL:
            del self.wrapped
            self.wrapped = NULL

    def load(self, str path):
        self.wrapped.load(pystr_to_cppstr(path))
        return

    def save(self, str path):
        self.wrapped.save(pystr_to_cppstr(path))
        return

    def get_epoch(self):
        return self.wrapped.get_epoch()

    def set_epoch(self, unsigned epoch):
        self.wrapped.set_epoch(epoch)
        return

    def get_learning_rate_scaling(self):
        return self.wrapped.get_learning_rate_scaling()

    def set_learning_rate_scaling(self, float scale):
        self.wrapped.set_learning_rate_scaling(scale)
        return

    def get_weight_decay(self):
        return self.wrapped.get_weight_decay()

    def set_weight_decay(self, float strength):
        self.wrapped.set_weight_decay(strength)
        return

    def get_gradient_clipping(self):
        return self.wrapped.get_gradient_clipping()

    def set_gradient_clipping(self, float threshold):
        self.wrapped.set_gradient_clipping(threshold)
        return

    def add_parameter(self, _Parameter param):
        self.wrapped.add_parameter(param.wrapped[0])
        return

    def add_model(self, _Model model):
        self.wrapped.add_model(model.wrapped[0])
        return

    def reset_gradients(self):
        self.wrapped.reset_gradients()
        return

    def update(self):
        self.wrapped.update()
        return

    def get_configs(self):
        cdef unordered_map[string, unsigned] uint_configs
        cdef unordered_map[string, float] float_configs
        self.wrapped.get_configs(uint_configs, float_configs)
        return ({cppstr_to_pystr(k): v for k, v in dict(uint_configs).items()},
                {cppstr_to_pystr(k): v for k, v in dict(float_configs).items()})

    def set_configs(self, dict uint_configs, dict float_configs):
        self.wrapped.set_configs({pystr_to_cppstr(k): v for k, v in uint_configs.items()},
                                 {pystr_to_cppstr(k): v for k, v in float_configs.items()})
        return

    def __copy__(self):
        raise NotImplementedError(type(self).__name__ + " does not support `__copy__` for now.")

    def __deepcopy__(self, memo):
        raise NotImplementedError(type(self).__name__ + " does not support `__deepcopy__` for now.")


cdef public api int python_primitiv_optimizer_configure_parameter(
                        object self,
                        CppParameter &param) except -1:
    # NOTE(vbkaisetsu):
    # `hasattr(self.__class__, "configure_parameter")` also scans a parent class.
    # We want check that the function is overrided or not.
    if "configure_parameter" in self.__class__.__dict__ and callable(self.configure_parameter):
        self.configure_parameter(_Parameter.get_wrapper(&param))
        return 0
    raise NotImplementedError("'configure_parameter()' is not implemented in '%s'"
                                        % self.__class__.__name__)


cdef public api int python_primitiv_optimizer_update_parameter(
                        object self,
                        float scale,
                        CppParameter &param) except -1:
    # NOTE(vbkaisetsu):
    # `hasattr(self.__class__, "update_parameter")` also scans a parent class.
    # We want check that the function is overrided or not.
    if "update_parameter" in self.__class__.__dict__ and callable(self.update_parameter):
        self.update_parameter(scale, _Parameter.get_wrapper(&param))
        return 0
    raise NotImplementedError("'update_parameter()' is not implemented in '%s'"
                                        % self.__class__.__name__)


cdef public api int python_primitiv_optimizer_get_configs(
                        object self,
                        unordered_map[string, unsigned] &uint_configs,
                        unordered_map[string, float] &float_configs) except -1:
    # NOTE(vbkaisetsu):
    # `hasattr(self.__class__, "get_configs")` also scans a parent class.
    # We want check that the function is overrided or not.
    if "get_configs" in self.__class__.__dict__ and callable(self.get_configs):
        uint_configs_tmp, float_configs_tmp = self.get_configs()
        uint_configs.swap({pystr_to_cppstr(k): v for k, v in uint_configs_tmp.items()})
        float_configs.swap({pystr_to_cppstr(k): v for k, v in float_configs_tmp.items()})
        return 0
    raise NotImplementedError("'get_configs()' is not implemented in '%s'"
                                        % self.__class__.__name__)


cdef public api int python_primitiv_optimizer_set_configs(
                        object self,
                        const unordered_map[string, unsigned] &uint_configs,
                        const unordered_map[string, float] &float_configs) except -1:
    # NOTE(vbkaisetsu):
    # `hasattr(self.__class__, "set_configs")` also scans a parent class.
    # We want check that the function is overrided or not.
    if "set_configs" in self.__class__.__dict__ and callable(self.set_configs):
        self.set_configs({cppstr_to_pystr(k): v for k, v in dict(uint_configs).items()},
                         {cppstr_to_pystr(k): v for k, v in dict(float_configs).items()})
        return 0
    raise NotImplementedError("'set_configs()' is not implemented in '%s'"
                                        % self.__class__.__name__)
