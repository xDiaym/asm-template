from math import log

# Function tabulation range
FROM, TO = -1, 1

A = 2.0

# Function itself
def f(x: float) -> float:
    return log(abs(x - A/2))
