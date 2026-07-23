/// Creates an object without runtime parameters.
typedef Factory<T extends Object> = T Function();

/// Creates an object from one required runtime parameter.
typedef ParamFactory<T extends Object, P extends Object> = T Function(P param);
