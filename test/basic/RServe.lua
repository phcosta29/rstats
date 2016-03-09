
return {
	RServe = function(unitTest)
		local R = RServe()

		unitTest:assertType(R, "RServe")
	end,
	evaluate = function(unitTest)
		local R = Rserve{}

		unitTest:assertEquals(R:evaluate("x = 2"), 2)
	end,
	__tostring = function(unitTest)
		unitTest:assertEquals(RServe{}, [[
host   string [localhost] 
port   number [6311]
]])
	end
}

