
return {
	mean = function(unitTest)
		local cs = CellularSpace{
			xdim = 5
		}

		local i = 1

		forEachCell(cs, function(cell)
			cell.value = i
			i = i + 1
		end)

		unitTest:assertEquals(mean(cs, "value"), 13)

		local soc = Society{
			instance = Agent{},
			quantity = 10
		}

		local i = 1

		forEachAgent(soc, function(ag)
			ag.value = i
			i = i + 1
		end)

		unitTest:assertEquals(mean(soc, "value"), 5.5)
	end,
	sd = function(unitTest)
		local cs = CellularSpace{
			xdim = 5
		}

		local i = 1

		forEachCell(cs, function(cell)
			cell.value = i
			i = i + 1
		end)

		unitTest:assertEquals(sd(cs, "value"), 7.359, 0.001)

		local soc = Society{
			instance = Agent{},
			quantity = 10
		}

		local i = 1

		forEachAgent(soc, function(ag)
			ag.value = i
			i = i + 1
		end)

		unitTest:assertEquals(sd(soc, "value"), 3.027, 0.001)
	end
}

