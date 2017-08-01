-- @example Implementation of the linear regression function.
-- It returns the linear regression of a table of vectors computed in R.
-- if an entry is of an incompatible type returns with error.
<<<<<<< HEAD
-- @arg expression a data frame or a CellularSpace.
import("rstats")
=======
-- @arg expression a DataFrame or a CellularSpace.

>>>>>>> 53f199203386cc11ad500b5e631121663120f374
R = RServe{
}

amazonia = CellularSpace{
	file = filePath("amazonia.shp", "base"),
}

x = R:lm{
	data = amazonia,
	response = "prodes_10",
	terms = {"distroads", "protected", "distports"}
}

print(x)
