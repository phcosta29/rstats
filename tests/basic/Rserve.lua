return {
	Rserve = function(unitTest)

		local error_func = function()
			Rserve(2)
		end
		unitTest:assertError(error_func, namedArgumentsMsg())

		error_func = function()
			Rserve{host = 2}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("host", "string", 2))

		local warning_func = function()
			Rserve{host = "localhost"}
		end
		unitTest:assertWarning(warning_func, defaultValueMsg("host", "localhost"))

		error_func = function()
			Rserve{port = "abc"}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("port", "number", "abc"))

		warning_func = function()
			Rserve{port = 6311}
		end
		unitTest:assertWarning(warning_func, defaultValueMsg("port", 6311))

		--error_func = function()
			--Rserve{port = 987654}
		--end
		--unitTest:assertError(error_func, "Could not connect to Rserve at localhost using port 987654.") --SKIP
	end,
	evaluate = function(unitTest)
		local R = Rserve{}
		local error_func = function()
			R:evaluate(2)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "string", 2))

		error_func = function()
			R:evaluate("x = 2 + v")
		end
		unitTest:assertError(error_func, "[Rserve] Error: object 'v' not found", 1)

		local warning_func = function()
			R:evaluate("x <- 1:10; y <- if (x < 5 ) 0 else 1")
		end
		unitTest:assertWarning(warning_func, "[Rserve] Warning: the condition has length > 1 and only the first element will be used", 1)
	end,
	mean = function(unitTest)
		local R = Rserve{}
		local error_func = function()
			R:mean(2)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "table", 2))
	end,
	sd = function(unitTest)
		local R = Rserve{}
		local error_func = function()
			R:sd(2)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "table", 2))
	end,
	lm = function(unitTest)
		local R = Rserve{}
		local error_func = function()
			R:lm(2)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "table", 2))
	end,
	pca = function(unitTest)
		local R = RServe{}
		local data = DataFrame{ctl = {4.17, 5.58, 5.18, 6.11, 4.50, 4.61, 5.17, 4.53, 5.33, 5.14}, trt = {4.81, 4.17, 4.41, 3.59, 5.87, 3.83, 6.03, 4.89, 4.32, 4.69}, weight = {4.17, 5.18, 4.50, 5.17, 5.33, 4.81, 4.41, 5.87, 4.89, 4.69}}
		local x = R:pca{data = data, terms = {"ctl", "trt", "weight"}}
		unitTest:assertEquals(x.StandardDeviations[1], 1.2342, 0.001)
		unitTest:assertEquals(x.StandardDeviations[2], 0.9735, 0.001)
		unitTest:assertEquals(x.StandardDeviations[3], 0.7274, 0.001)

		data = CellularSpace{file = filePath("amazonia.shp", "base"),}
		x = R:pca{data = data, terms = {"distroads", "protected", "distports"}}
		print(vardump(x))
	end,
	anova = function(unitTest)
		local R = RServe{}
		local data = DataFrame{ctl = {4.17, 5.58, 5.18, 6.11, 4.50, 4.61, 5.17, 4.53, 5.33, 5.14}, trt = {4.81, 4.17, 4.41, 3.59, 5.87, 3.83, 6.03, 4.89, 4.32, 4.69}, weight = {4.17, 5.18, 4.50, 5.17, 5.33, 4.81, 4.41, 5.87, 4.89, 4.69}}
		local x = R:anova{data = data, terms = {"ctl", "trt", "weight"}, typeAnova = "owa", factors = {"ctl", "trt"}}
		unitTest:assertEquals(x[1][2][2][1][1], 1.0)
		unitTest:assertEquals(x[1][2][2][1][2], 8.0)
		unitTest:assertEquals(x[1][2][2][2][1], 0.6409, 0.0001)
		unitTest:assertEquals(x[1][2][2][2][2], 2.4190, 0.0001)
		unitTest:assertEquals(x[1][2][2][3][1], 0.6409, 0.0001)
		unitTest:assertEquals(x[1][2][2][3][2], 0.3023, 0.0001)
		unitTest:assertEquals(x[1][2][2][4][1], 2.1196, 0.0001)
		unitTest:assertEquals(x[1][2][2][5][1], 0.1835, 0.0001)

		data = CellularSpace{file = filePath("amazonia.shp", "base"),}
		x = R:anova{data = data, terms = {"distroads", "protected", "distports"}, typeAnova = "owa", factors = {"distroads", "distports"}}
		unitTest:assertEquals(x[1][2][2][1][1], 1.0)
		unitTest:assertEquals(x[1][2][2][1][2], 2227.0)
		unitTest:assertEquals(x[1][2][2][2][1], 706045403888.55, 0.01)
		unitTest:assertEquals(x[1][2][2][2][2], 13346096413892.0, 0.2)
		unitTest:assertEquals(x[1][2][2][3][1], 706045403888.55, 0.01)
		unitTest:assertEquals(x[1][2][2][3][2], 5992858739.9605, 0.0001)
		unitTest:assertEquals(x[1][2][2][4][1], 117.8145, 0.0001)
		unitTest:assertEquals(x[1][2][2][5][1], 0.000000000000000000000000008801, 0.000000000000000000000000000001)
	end,
	lm = function(unitTest)
		local R = RServe{}
		local data = CellularSpace{file = filePath("amazonia.shp", "base"),}
		local x = R:lm{data = data, response = "prodes_10", terms = {"distroads", "protected", "distports"}}
		unitTest:assertEquals(x[1], 22.4337, 0.0001)
		unitTest:assertEquals(x[2], -0.000087823,0.000000001)
		unitTest:assertEquals(x[3], -11.9502, 0.0001)

		data = DataFrame{ctl = {4.17, 5.58, 5.18, 6.11, 4.50, 4.61, 5.17, 4.53, 5.33, 5.14}, trt = {4.81, 4.17, 4.41, 3.59, 5.87, 3.83, 6.03, 4.89, 4.32, 4.69}, weight = {4.17, 5.18, 4.50, 5.17, 5.33, 4.81, 4.41, 5.87, 4.89, 4.69}}
		x = R:lm{data = data, response = "ctl", terms = {"trt", "weight"}}
		unitTest:assertEquals(x[1], 6.2664, 0.0001)
		unitTest:assertEquals(x[2], -0.3329,0.0001)
		unitTest:assertEquals(x[3], 0.0647, 0.0001)
	end,
	__tostring = function(unitTest)
		unitTest:assertEquals(tostring(RServe{}), [[host  string [localhost]
port  number [6311]
]])
	end
}
