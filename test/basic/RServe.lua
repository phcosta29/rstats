
return {
	RServe = function(unitTest)
		local R = RServe()

		unitTest:assertType(R, "RServe")
	end,
	__tostring = function(unitTest)
		unitTest:assertEquals(RServe{}, [[
host   string [localhost] 
port   number [6311]
]])
	end
}

