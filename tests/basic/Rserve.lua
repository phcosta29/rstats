return {
	Rserve = function(unitTest)
		local R = Rserve()
		unitTest:assertType(R, "Rserve")
	end,

	luaRserveevaluate = function(unitTest)
		local R = Rserve{}
		local x = R:evaluate("x = 2")
		unitTest:assertEquals(x, 2)
	end,

	__index = function(unitTest)
		local R = Rserve{}
		local x = R:sum("c(1, 2, 3)")
		unitTest:assertEquals(x, 6)
	end,

	evaluate = function(unitTest)
		local R = Rserve{}
		local x = R:evaluate("x = 2")
		unitTest:assertEquals(x, 2)

		x = R:evaluate("rnorm(100)")
		unitTest:assertEquals(#x, 100)

		x = R:evaluate("runif(1, 5.0, 7.5)")
		unitTest:assert(x > 5)
		unitTest:assert(x < 7.5)

		x = R:evaluate("replicate(5, rnorm(7))")
		unitTest:assertEquals(#x[2], 35)
		unitTest:assertEquals(x[1][1][1][1], 7)
		unitTest:assertEquals(x[1][1][1][2], 5)

		x = R:evaluate("a <- c(1, 2, 5.3, 6, -2, 4)")
		unitTest:assertEquals(x[1], 1)
		unitTest:assertEquals(x[2], 2)
		unitTest:assertEquals(x[3], 5.3)
		unitTest:assertEquals(x[4], 6)
		unitTest:assertEquals(x[5], -2)
		unitTest:assertEquals(x[6], 4)

		x = R:evaluate("b <- c('one','two','three')")
		unitTest:assertEquals(x[1], "one", 1)
		unitTest:assertEquals(x[2], "two", 1)
		unitTest:assertEquals(x[3], "three", 1)

		x = R:evaluate("c <- c(TRUE,TRUE,TRUE,FALSE,TRUE,FALSE)")
		unitTest:assertEquals(x[1], true)
		unitTest:assertEquals(x[2], true)
		unitTest:assertEquals(x[3], true)
		unitTest:assertEquals(x[4], false)
		unitTest:assertEquals(x[5], true)
		unitTest:assertEquals(x[6], false)

		x = R:evaluate("y <- matrix(1:20, nrow=5,ncol=4)")
		unitTest:assertEquals(x[1][1][1][1], 5)
		unitTest:assertEquals(x[1][1][1][2], 4)
		unitTest:assertEquals(x[2][1], 1)
		unitTest:assertEquals(x[2][2], 2)
		unitTest:assertEquals(x[2][3], 3)
		unitTest:assertEquals(x[2][4], 4)
		unitTest:assertEquals(x[2][5], 5)
		unitTest:assertEquals(x[2][6], 6)
		unitTest:assertEquals(x[2][7], 7)
		unitTest:assertEquals(x[2][8], 8)
		unitTest:assertEquals(x[2][9], 9)
		unitTest:assertEquals(x[2][10], 10)
		unitTest:assertEquals(x[2][11], 11)
		unitTest:assertEquals(x[2][12], 12)
		unitTest:assertEquals(x[2][13], 13)
		unitTest:assertEquals(x[2][14], 14)
		unitTest:assertEquals(x[2][15], 15)
		unitTest:assertEquals(x[2][16], 16)
		unitTest:assertEquals(x[2][17], 17)
		unitTest:assertEquals(x[2][18], 18)
		unitTest:assertEquals(x[2][19], 19)
		unitTest:assertEquals(x[2][20], 20)

		x = R:evaluate("B = matrix(c(2, 4, 3, 1, 5, 7), nrow=3, ncol=2)")
		unitTest:assertEquals(x[1][1][1][1], 3)
		unitTest:assertEquals(x[1][1][1][2], 2)
		unitTest:assertEquals(x[2][1], 2)
		unitTest:assertEquals(x[2][2], 4)
		unitTest:assertEquals(x[2][3], 3)
		unitTest:assertEquals(x[2][4], 1)
		unitTest:assertEquals(x[2][5], 5)
		unitTest:assertEquals(x[2][6], 7)

		x = R:evaluate("B = matrix(c(2, 4, 3, 1, 5, 7), nrow=2, ncol=3)")
		unitTest:assertEquals(x[1][1][1][1], 2)
		unitTest:assertEquals(x[1][1][1][2], 3)
		unitTest:assertEquals(x[2][1], 2)
		unitTest:assertEquals(x[2][2], 4)
		unitTest:assertEquals(x[2][3], 3)
		unitTest:assertEquals(x[2][4], 1)
		unitTest:assertEquals(x[2][5], 5)
		unitTest:assertEquals(x[2][6], 7)

		x = R:evaluate("B = matrix(c(2, 4, 3, 1, 5, 7), nrow=2, ncol=3, byrow=TRUE)")
		unitTest:assertEquals(x[1][1][1][1], 2)
		unitTest:assertEquals(x[1][1][1][2], 3)
		unitTest:assertEquals(x[2][1], 2)
		unitTest:assertEquals(x[2][2], 1)
		unitTest:assertEquals(x[2][3], 4)
		unitTest:assertEquals(x[2][4], 5)
		unitTest:assertEquals(x[2][5], 3)
		unitTest:assertEquals(x[2][6], 7)

		x = R:evaluate("B = matrix(c(2, 4, 3, 1, 5, 7), nrow=2, ncol=3, byrow=FALSE)")
		unitTest:assertEquals(x[1][1][1][1], 2)
		unitTest:assertEquals(x[1][1][1][2], 3)
		unitTest:assertEquals(x[2][1], 2)
		unitTest:assertEquals(x[2][2], 4)
		unitTest:assertEquals(x[2][3], 3)
		unitTest:assertEquals(x[2][4], 1)
		unitTest:assertEquals(x[2][5], 5)
		unitTest:assertEquals(x[2][6], 7)

		x = R:evaluate("d <- c(1,2,3,4); e <- c('red', 'white', 'red', NA); f <- c(TRUE,TRUE,TRUE,FALSE); mydata <- data.frame(d,e,f)")
		unitTest:assertEquals(x[1][1][1][1], "d", 1)
		unitTest:assertEquals(x[1][1][1][2], "e", 1)
		unitTest:assertEquals(x[1][1][1][3], "f", 1)
		unitTest:assertEquals(x[2][1][1], 1)
		unitTest:assertEquals(x[2][1][2], 2)
		unitTest:assertEquals(x[2][1][3], 3)
		unitTest:assertEquals(x[2][1][4], 4)
		unitTest:assertEquals(x[2][2][1][1][1], "red", 1)
		unitTest:assertEquals(x[2][2][1][1][2], "white", 1)
		unitTest:assertEquals(x[2][4][1], true)
		unitTest:assertEquals(x[2][4][2], true)
		unitTest:assertEquals(x[2][4][3], true)
		unitTest:assertEquals(x[2][4][4], false)

		x = R:evaluate("d <- c(1,2,3,4); e <- c('red', 'white', 'red', NA); f <- c(TRUE,TRUE,TRUE,FALSE); mydata <- data.frame(d,e,f); names(mydata) <- c('ID','Color','Passed'); mydata")
		unitTest:assertEquals(x[1][1][1][1], "ID", 1)
		unitTest:assertEquals(x[1][1][1][2], "Color", 1)
		unitTest:assertEquals(x[1][1][1][3], "Passed", 1)
		unitTest:assertEquals(x[2][1][1], 1)
		unitTest:assertEquals(x[2][1][2], 2)
		unitTest:assertEquals(x[2][1][3], 3)
		unitTest:assertEquals(x[2][1][4], 4)
		unitTest:assertEquals(x[2][2][1][1][1], "red", 1)
		unitTest:assertEquals(x[2][2][1][1][2], "white", 1)
		unitTest:assertEquals(x[2][4][1], true)
		unitTest:assertEquals(x[2][4][2], true)
		unitTest:assertEquals(x[2][4][3], true)
		unitTest:assertEquals(x[2][4][4], false)

		x = R:evaluate("gender <- c(rep('male',2), rep('female', 3)); gender <- factor(gender)")
		unitTest:assertEquals(x[1][1][1][1], "female", 1)
		unitTest:assertEquals(x[1][1][1][2], "male", 1)
		unitTest:assertEquals(x[2][1], 2)
		unitTest:assertEquals(x[2][2], 2)
		unitTest:assertEquals(x[2][3], 1)
		unitTest:assertEquals(x[2][4], 1)
		unitTest:assertEquals(x[2][5], 1)

		x = R:evaluate("v <- c(1,3,5,8,2,1,3,5,3,5); x <- factor(v)")
		unitTest:assertEquals(x[1][1][1][1], "1", 1)
		unitTest:assertEquals(x[1][1][1][2], "2", 1)
		unitTest:assertEquals(x[1][1][1][3], "3", 1)
		unitTest:assertEquals(x[1][1][1][4], "5", 1)
		unitTest:assertEquals(x[1][1][1][5], "8", 1)
		unitTest:assertEquals(x[2][1], 1)
		unitTest:assertEquals(x[2][2], 3)
		unitTest:assertEquals(x[2][3], 4)
		unitTest:assertEquals(x[2][4], 5)
		unitTest:assertEquals(x[2][5], 2)
		unitTest:assertEquals(x[2][6], 1)
		unitTest:assertEquals(x[2][7], 3)
		unitTest:assertEquals(x[2][8], 4)
		unitTest:assertEquals(x[2][9], 3)
		unitTest:assertEquals(x[2][10], 4)

		x = R:evaluate("n <- c(2, 3, 5); s <- c('aa', 'bb', 'cc'); b <- c(TRUE, FALSE, TRUE); df <- data.frame(n, s, b)")
		unitTest:assertEquals(x[1][1][1][1], "n", 1)
		unitTest:assertEquals(x[1][1][1][2], "s", 1)
		unitTest:assertEquals(x[1][1][1][3], "b", 1)
		unitTest:assertEquals(x[2][1][1], 2)
		unitTest:assertEquals(x[2][1][2], 3)
		unitTest:assertEquals(x[2][1][3], 5)
		unitTest:assertEquals(x[2][3][1], 1)
		unitTest:assertEquals(x[2][3][2], 2)
		unitTest:assertEquals(x[2][3][3], 3)
		unitTest:assertEquals(x[2][4][1], true)
		unitTest:assertEquals(x[2][4][2], false)
		unitTest:assertEquals(x[2][4][3], true)

		x = R:evaluate("library(MASS); data(cats); lm(Hwt ~ Bwt, data=cats[1:5,])")
		unitTest:assertEquals(#x[2][20][1], 5)
		unitTest:assertEquals(#x[2][20][2], 5)
	end,

	mean = function(unitTest)
		local R = Rserve{}
		local x = R:mean{1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
		unitTest:assertEquals(x, 5.5)
	end,

	sd = function(unitTest)
		local R = Rserve{}
		local x = R:sd{1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
		unitTest:assertEquals(x, 3.02765, 0.00001)
	end,

	pca = function(unitTest)
		local R = Rserve{}
		local data = DataFrame{ctl = {4.17, 5.58, 5.18, 6.11, 4.50, 4.61, 5.17, 4.53, 5.33, 5.14}, trt = {4.81, 4.17, 4.41, 3.59, 5.87, 3.83, 6.03, 4.89, 4.32, 4.69}, weight = {4.17, 5.18, 4.50, 5.17, 5.33, 4.81, 4.41, 5.87, 4.89, 4.69}}
		local x = R:pca{data = data, terms = {"ctl", "trt", "weight"}}
		unitTest:assertEquals(x.StandardDeviations[1], 1.2201, 0.001)
		unitTest:assertEquals(x.StandardDeviations[2], 0.9845, 0.001)
		unitTest:assertEquals(x.StandardDeviations[3], 0.7363, 0.001)

		data = CellularSpace{file = filePath("amazonia.shp", "base"),}
		x = R:pca{data = data, terms = {"distroads", "protected", "distports"}}
		unitTest:assertEquals(x.StandardDeviations[1], 1.1967, 0.001)
		unitTest:assertEquals(x.StandardDeviations[2], 0.9137, 0.001)
		unitTest:assertEquals(x.StandardDeviations[3], 0.8562, 0.001)
	end,

	anova = function(unitTest)
		local R = Rserve{}
		local data = DataFrame{ctl = {4.17, 5.58, 5.18, 6.11, 4.50, 4.61, 5.17, 4.53, 5.33, 5.14}, trt = {4.81, 4.17, 4.41, 3.59, 5.87, 3.83, 6.03, 4.89, 4.32, 4.69}, weight = {4.17, 5.18, 4.50, 5.17, 5.33, 4.81, 4.41, 5.87, 4.89, 4.69}}
		local x = R:anova{data = data, terms = {"ctl", "trt", "weight"}, strategy = "owa", factors = {"ctl", "trt"}}
		unitTest:assertEquals(x[2][2][1][1], 1.0)
		unitTest:assertEquals(x[2][2][1][2], 8.0)
		unitTest:assertEquals(x[2][2][2][1], 0.6409, 0.0001)
		unitTest:assertEquals(x[2][2][2][2], 2.4190, 0.0001)
		unitTest:assertEquals(x[2][2][3][1], 0.6409, 0.0001)
		unitTest:assertEquals(x[2][2][3][2], 0.3023, 0.0001)
		unitTest:assertEquals(x[2][2][4][1], 2.1196, 0.0001)
		unitTest:assertEquals(x[2][2][5][1], 0.1835, 0.0001)

		data = CellularSpace{file = filePath("amazonia.shp", "base"),}
		x = R:anova{data = data, terms = {"distroads", "protected", "distports"}, strategy = "owa", factors = {"distroads", "distports"}}
		unitTest:assertEquals(x[2][2][1][1], 1.0)
		unitTest:assertEquals(x[2][2][1][2], 2227.0)
		unitTest:assertEquals(x[2][2][2][1], 706045403888.55, 0.01)
		unitTest:assertEquals(x[2][2][2][2], 13346096413892.0, 0.2)
		unitTest:assertEquals(x[2][2][3][1], 706045403888.55, 0.01)
		unitTest:assertEquals(x[2][2][3][2], 5992858739.9605, 0.0001)
		unitTest:assertEquals(x[2][2][4][1], 117.8145, 0.0001)
		unitTest:assertEquals(x[2][2][5][1], 0.000000000000000000000000008801, 0.000000000000000000000000000001)
	end,

	lm = function(unitTest)
		local R = Rserve{}
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
		unitTest:assertEquals(tostring(Rserve{}), [[host  string [localhost]
port  number [6311]
]])
	end

}
