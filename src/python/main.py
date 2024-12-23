def examplefunction(arg1, arg2, kwarg='something'):
    """
    This is an example on how documentation is generated using doxygen and python with doxypypy as a filter.

    Args:
        arg1:   A positional argument.
        arg2:   Another positional argument.

    Kwargs:
        kwarg:  A keyword argument.

    Returns:
        A string holding the result.

    Raises:
        ZeroDivisionError, AssertionError, & ValueError.

    Examples:
        >>> examplefunction(2, 3)
        '5 -0, whatever.'
        >>> examplefunction(5, 0, 'oops.')
        Traceback (most recent call last):
            ...
        ZeroDivisionError: integer division or modulo by zero
        >>> examplefunction(4, 1, 'got it.')
        '5 - 4, got it.'
    """
    assert(isinstance(arg1, int), "Woah!")
    return f'{arg1+arg2} - {arg1 / arg2}, {kwarg}'


class ExampleClass:
    """
    This is an example of class documentation.

    Args:
        arg1:    [in] some param that goes in
    """
    def __init__(self, arg1):
        """
        This is an example of an init declaration.
        """
        pass
