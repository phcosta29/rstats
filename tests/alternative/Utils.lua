
return {
	--mean = function(unitTest)
		--local error_func = function()
			--mean()
		--end

		--unitTest:assertError(error_func, mandatoryArgumentMsg(1)) --SKIP

		--error_func = function()
			--mean(2)
		--end

		--unitTest:assertError(error_func, incompatibleTypeMsg(1, "CellularSpace or Society", 2)) --SKIP

		--local cs = CellularSpace{
			--xdim = 5
		--}

		--error_func = function()
			--mean(cs, 2)
		--end

		--unitTest:assertError(error_func, incompatibleTypeMsg(2, "string", 2)) --SKIP

		--error_func = function()
			--mean(cs, "value")
		--end

		--unitTest:assertError(error_func, "Attribute 'value' does not belong to the CellularSpace.") --SKIP

		--local cs = Society{
			--instance = Agent{},
			--quantity = 10
		--}

		--error_func = function()
			--mean(soc, "value")
		--end

		--unitTest:assertError(error_func, "Attribute 'value' does not belong to the Society.") --SKIP
	--end,
	--sd = function(unitTest)
		--local error_func = function()
			--sd()
		--end

		--unitTest:assertError(error_func, mandatoryArgumentMsg(1)) --SKIP

		--error_func = function()
			--sd(2)
		--end

		--unitTest:assertError(error_func, incompatibleTypeMsg(1, "CellularSpace or Society", 2)) --SKIP

		--local cs = CellularSpace{
			--xdim = 5
		--}

		--error_func = function()
			--sd(cs, 2)
		--end

		--unitTest:assertError(error_func, incompatibleTypeMsg(2, "string", 2)) --SKIP

		--error_func = function()
			--sd(cs, "value")
		--end

		--unitTest:assertError(error_func, "Attribute 'value' does not belong to the CellularSpace.") --SKIP

		--local cs = Society{
			--instance = Agent{},
			--quantity = 10
		--}

		--error_func = function()
			--sd(soc, "value")
		--end

		--unitTest:assertError(error_func, "Attribute 'value' does not belong to the Society.") --SKIP
	--end
}

