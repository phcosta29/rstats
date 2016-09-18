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
	end
}
