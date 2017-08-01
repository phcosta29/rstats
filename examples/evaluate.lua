-- @example Implementation of evaluate function.
-- Execute an R command. It returns an error message or a value.
-- if an entry is of an incompatible type returns with error.
-- @arg expression The expression must be passed to R.
import("rstats")
R = Rserve{
}

x = R:evaluate("d <- c(1,2,3,4); e <- c('red', 'white', 'red', NA); f <- c(TRUE,TRUE,TRUE,FALSE); mydata <- data.frame(d,e,f)")

print(vardump(x))
