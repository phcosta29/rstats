-- @example Implementation of the linear regression function.
-- It returns the linear regression of a table of vectors computed in R.
-- if an entry is of an incompatible type returns with error.
-- @arg expression a DataFrame or a CellularSpace.

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
