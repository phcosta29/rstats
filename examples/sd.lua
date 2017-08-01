-- @example Implementation of standard deviation function.
-- It returns the standard deviation of a vector of values computed in R.
-- if an entry is of an incompatible type returns with error.
-- @arg expression a table of numbers.
import("rstats")
R = Rserve{
}

x = R:sd{1, 2, 3, 4, 5, 6, 7, 8, 9, 10}

print(vardump(x))
