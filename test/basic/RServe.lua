
return {
	RServe = function(unitTest)
		local R = RServe()

		unitTest:assertType(R, "RServe")
	end,
	evaluate = function(unitTest)
		local R = Rserve{}

		unitTest:assertEquals(R:evaluate("x = 2"), 2)

		error_func = function()
			R:evaluate("x = 2 + v")
		end

		unitTest:assertError(error_func, "[RServe] object 'v' not found.")
	end,
	__tostring = function(unitTest)
		unitTest:assertEquals(RServe{}, [[
host   string [localhost] 
port   number [6311]
]])
	end
}

