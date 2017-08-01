-- @example Implementation of the principal component analysis function.
-- It returns the principal component analysis of a table of vectors computed in R.
-- if an entry is of an incompatible type returns with error.
-- @arg expression a data frame or a CellularSpace.
import("rstats")
R = Rserve{
}

data = DataFrame{
	ctl = {4.17, 5.58, 5.18, 6.11, 4.50, 4.61, 5.17, 4.53, 5.33, 5.14},
	trt = {4.81, 4.17, 4.41, 3.59, 5.87, 3.83, 6.03, 4.89, 4.32, 4.69},
	gfg = {4.16, 5.57, 5.16, 6.08, 4.49, 4.60, 5.14, 4.51, 5.32, 5.13},
	weight = {4.17, 5.18, 4.50, 5.17, 5.33, 4.81, 4.41, 5.87, 4.89, 4.69}
}

x = R:pca{
	data = data,
	terms = {"weight", "trt", "gfg"}
}

print(vardump(x))
