return {
	RServe = function(unitTest)

		local error_func = function()
			RServe(2)
		end
		unitTest:assertError(error_func, namedArgumentsMsg())

		error_func = function()
			RServe{host = 2}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("host", "string", 2))

		error_func = function()
			RServe{host = "localhost"}
		end
		unitTest:assertError(error_func, defaultValueMsg("host", "localhost"))

		error_func = function()
			RServe{port = "abc"}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("port", "number", "abc"))

		error_func = function()
			RServe{port = 6311}
		end
		unitTest:assertError(error_func, defaultValueMsg("port", 6311))

		--error_func = function()
			--RServe{port = 987654}
		--end
		--unitTest:assertError(error_func, "Could not connect to RServe at localhost using port 987654.") --SKIP
	end,
	evaluate = function(unitTest)
		local R = RServe{}
		local error_func = function()
			R:evaluate(2)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "string", 2))

		error_func = function()
			R:evaluate("x = 2 + v")
		end
		unitTest:assertError(error_func, "[RServe] Error: object 'v' not found", 1)

		error_func = function()
			R:evaluate("x <- 1:10; y <- if (x < 5 ) 0 else 1")
		end
		unitTest:assertError(error_func, "[RServe] Warning: the condition has length > 1 and only the first element will be used", 1)
	end,
	mean = function(unitTest)
		local R = RServe{}
		local error_func = function()
			R:mean(2)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "table", 2))
	end,
	sd = function(unitTest)
		local R = RServe{}
		local error_func = function()
			R:sd(2)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "table", 2))
	end,
	lm = function(unitTest)
		local R = RServe{}
		local error_func = function()
			R:lm(2)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "table", 2))
	end
}
