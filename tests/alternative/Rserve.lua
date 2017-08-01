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
		local R = Rserve{}
		local error_func = function()
			R:pca(2)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "table", 2))
	end,
	anova = function(unitTest)
		local R = Rserve{}
		local error_func = function()
			R:anova(2)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "table", 2))
	end
}
