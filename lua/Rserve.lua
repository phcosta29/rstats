local vstruct = require("vstruct")
local socket = require("socket")
local tcp = assert(socket.tcp())
local QAP1_HEADER_FORMAT = "4*u4"
local QAP1_PARAMETER_HEADER_FORMAT = "u1 u3"
local QAP1_SEXP_HEADER_TYPE_FORMAT = "[1 | b2 u6]"
local QAP1_SEXP_HEADER_LEN_FORMAT = "u3"
local function vectorToString(data)
	local expressionR = table.concat{"c(", table.concat(data, ","), ")"}
	return expressionR
end

local function convertionTypes(data)
	local df = {}
	forEachElement(data.data.cells[1], function(idx)
		if belong(idx, {"FID", "cObj_", "past"}) then
			return
		end

		df[idx] = {}
	end)

	forEachCell(data.data, function(cell)
		forEachElement(df, function(idx, values)
			table.insert(values, cell[idx])
		end)
	end)

	df = DataFrame(df)
	return df
end

Rserve_ = {
	type_ = "Rserve",
	--- Execute an R command. It returns an error message or a value.
	-- if an entry is of an incompatible type returns with error.
	-- @arg data The expression must be passed to R.
	-- @usage import ("rstats")
	-- R = Rserve{}
	-- R:evaluate("x = 4")
	evaluate = function(self, data)
		if type(data) ~= "string" then
			incompatibleTypeError(1, "string", data)
		end

		local result = luaRserveevaluate(self.host, self.port, "Sys.setenv(LANG='en'); tryCatch({"..data.."}, warning = function(war){return(list(war,0))}, error = function(err){return(list(err,1))})")
		if result[1] then
			if result[1][1] and type(result[1][1]) ~= "number" and type(result[1][1]) ~= "string" and type(result[1][1]) ~= "boolean" then
				if result[1][1][3] and type(result[1][1][3]) ~= "number" and type(result[1][1][3]) ~= "string" and type(result[1][1][3]) ~= "boolean" then
					if result[1][1][3][1] == 1 then
						customError("[Rserve] Error: "..result[1][1][2][1][1])
					elseif result[1][1][3][1] == 0 then
						customWarning("[Rserve] Warning: "..result[1][1][2][1][1])
					end
				end
			end
		end

		while type(result) == "table" and #result == 1 do
			result = result[1]
		end

		return result
	end,

	--- It returns the arithmetic mean of a vector of values computed in R.
	-- if an entry is of an incompatible type returns with error.
	-- @arg data a table of numbers.
	-- @usage import ("rstats")
	-- R = Rserve{}
	-- R:mean{1,2,3,4,5,6,7,8,9,10} -- 5.5
	mean = function(self, data)
		if type(data) ~= "table" then
			incompatibleTypeError(1, "table", data)
		end

		local expressionR = table.concat{"mean(", vectorToString(data), ")"}
		local result = self:evaluate(expressionR)
		return result
	end,

	--- It returns the standard deviation of a vector of values computed in R.
	-- if an entry is of an incompatible type returns with error.
	-- @arg data a table of numbers.
	-- @usage import ("rstats")
	-- R = Rserve{}
	-- R:sd{1,2,3,4,5,6,7,8,9,10} -- 3.02765
	sd = function(self, data)
		if type(data) ~= "table" then
			incompatibleTypeError(1, "table", data)
		end

		local expressionR = table.concat{"sd(", vectorToString(data), ")"}
		local result = self:evaluate(expressionR)
		return result
	end,

	--- It returns the linear regression of a table of vectors computed in R.
	-- if an entry is of an incompatible type returns with error.
	-- @arg data.data a DataFrame or a CellularSpace.
	-- @arg data.response Column of DataFrame or CellularSpace.
	-- @arg data.terms Columns of DataFrame or CellularSpace.
	-- @usage import ("rstats")
	-- R = Rserve{}
	-- data = CellularSpace{file = filePath("amazonia.shp", "base"),}
	-- R:lm{data = data, response = "prodes_10", terms = {"distroads", "protected", "distports"}} -- 22.4337, -8.7823e-05, -11.9502
	lm = function(self, data)
		if type(data) ~= "table" then
			incompatibleTypeError(1, "table", data)
		elseif type(data.data) == "CellularSpace" then
			data.data = convertionTypes(data)
		end

		local term = #data.terms
		local stri, df, sumTerms
		local str = vectorToString(data.data[data.response])
		local i = term
		while i > 0 do
			local t = vectorToString(data.data[data.terms[i]])
			if i == term then
				stri = table.concat{data.terms[i], " <- ", t, ";"}
			else
				stri = table.concat{stri, data.terms[i], " <- ", t, ";"}
			end

			i = i - 1
		end

		df = table.concat{data.response, " = ", data.response, ", "}
		i = term
		while i > 0 do
			if i > 1 then
				df = table.concat{df, data.terms[i], " = ", data.terms[i], ", "}
			else
				df = table.concat{df, data.terms[i], " = ", data.terms[i], "); result = lm(formula = "}
			end

			i = i - 1
		end

		i = 1
		while i <= term do
			if i == 1 then
				sumTerms = table.concat{data.terms[i], " + "}
			else
				if i == term then
					sumTerms = table.concat{sumTerms, data.terms[i]}
				else
					sumTerms = table.concat{sumTerms, data.terms[i], " + "}
				end
			end

			i = i + 1
		end

		local result = self:evaluate(table.concat{data.response, " <- ", str, "; ", stri, "; df = data.frame(", df, data.response, " ~ ", sumTerms, ", data = df)"})
		local resultTable = {result[2][2][1], result[2][2][2], result[2][2][3]}
		return resultTable
	end,

	--- It returns the principal component analysis of a table of vectors computed in R.
	-- if an entry is of an incompatible type returns with error.
	-- @arg data.data a DataFrame or a CellularSpace.
	-- @arg data.terms Columns of DataFrame or CellularSpace.
	-- @usage import ("rstats")
	-- R = Rserve{}
	-- data = DataFrame{ctl = {4.17, 5.58, 5.18, 6.11, 4.50, 4.61, 5.17, 4.53, 5.33, 5.14},
	-- trt = {4.81, 4.17, 4.41, 3.59, 5.87, 3.83, 6.03, 4.89, 4.32, 4.69},
	-- weight = {4.17, 5.18, 4.50, 5.17, 5.33, 4.81, 4.41, 5.87, 4.89, 4.69}}
	-- R:pca{data = data, terms = {"ctl", "trt", "weight"}} -- 1.2342, 0.9735, 0.7274
	pca = function(self, data)
		if type(data) ~= "table" then
			incompatibleTypeError(1, "table", data)
		elseif type(data.data) == "CellularSpace" then
			data.data = convertionTypes(data)
		end

		local term = #data.terms
		local str, df, i, j, resultTable
		local rotation = {}
		i = 1
		while i <= term do
			if i == 1 then
				str = table.concat{data.terms[i], " <- ", vectorToString(data.data[data.terms[i]]), "; "}
				df = table.concat{data.terms[i], " = ", data.terms[i], ", "}
			else
				str = table.concat{str, data.terms[i], " <- ", vectorToString(data.data[data.terms[i]]), "; "}
				if i ~= term then
					df = table.concat{df, data.terms[i], " = ", data.terms[i], ", "}
				else
					df = table.concat{df, data.terms[i], " = ", data.terms[i], "); "}
				end
			end

			i = i + 1
		end

		local result = self:evaluate(table.concat{str, "df = data.frame(", df, "ir.pca <- prcomp(df, center = TRUE, scale. = TRUE); ir.pca;"})
		i = 1
		while i <= term do
			j = 0
			rotation[i] = {data.terms[i],{}}
			while j <= term do
				table.insert(rotation[i][2], result[2][3][(term * j) + i])
				j = j + 1
			end

			i = i + 1
		end

		resultTable = {StandardDeviations = result[2][1], Rotation = rotation}
		return resultTable
	end,

	--- It returns the analysis of variance of a table of vectors computed in R.
	-- if an entry is of an incompatible type returns with error.
	-- @arg data.data a DataFrame or a CellularSpace.
	-- @arg data.terms Columns of DataFrame or CellularSpace.
	-- @arg data.strategy Type of ANOVA model to be used.
	-- @arg data.factors Columns of DataFrame or CellularSpace that will be the factors.
	-- @tabular strategy
	-- Strategy & Description \
	-- "owa" & One Way Anova (Completely Randomized Design) \
	-- "rbd" & Randomized Block Design (B is the blocking factor) \
	-- "twfd" & Two Way Factorial Design \
	-- "aoc" & Analysis of Covariance \
	-- "owf" & One Within Factor \
	-- ""twftbf" & Two Within Factors, Two Between Factors \
	-- @usage import ("rstats")
	-- R = Rserve{}
	-- data = DataFrame{ctl = {4.17, 5.58, 5.18, 6.11, 4.50, 4.61, 5.17, 4.53, 5.33, 5.14},
	-- trt = {4.81, 4.17, 4.41, 3.59, 5.87, 3.83, 6.03, 4.89, 4.32, 4.69},
	-- weight = {4.17, 5.18, 4.50, 5.17, 5.33, 4.81, 4.41, 5.87, 4.89, 4.69}}
	-- R:anova{data = data, terms = {"ctl", "trt", "weight"}, strategy = "owa", factors = {"ctl", "trt"}} -- 1.0, 8.0, 0.6409, 2.4190, 0.6409, 0.3023, 2.1196, 0.1835
	anova = function(self, data)
		if type(data) ~= "table" then
			incompatibleTypeError(1, "table", data)
		elseif type(data.data) == "CellularSpace" then
			data.data = convertionTypes(data)
		end

		local term = #data.terms
		local str, df, i, fit
		i = 1
		while i <= term do
			if i == 1 then
				str = table.concat{data.terms[i], " <- ", vectorToString(data.data[data.terms[i]]), "; "}
				df = table.concat{data.terms[i], " = ", data.terms[i], ", "}
			else
				str = table.concat{str, data.terms[i], " <- ", vectorToString(data.data[data.terms[i]]), "; "}
				if i ~= term then
					df = table.concat{df, data.terms[i], " = ", data.terms[i], ", "}
				else
					df = table.concat{df, data.terms[i], " = ", data.terms[i], "); "}
				end
			end

			i = i + 1
		end

		switch(data, "strategy"):caseof{
			owa = function() fit = table.concat{"fit <- aov(", data.factors[1], " ~ ", data.factors[2], ",data = df); x = summary(fit); x;"} end,
			rbd = function() fit = table.concat{"fit <- aov(", data.factors[1], " ~ ", data.factors[2], " + ", data.factors[3], ",data = df); x = summary(fit); x;"} end,
			twfd = function() fit = table.concat{"fit <- aov(", data.factors[1], " ~ ", data.factors[2], " * ", data.factors[3], ",data = df); x = summary(fit); x;"} end,
			aoc = function() fit = table.concat{"fit <- aov(", data.factors[1], " ~ ", data.factors[2], " + ", data.factors[3], ",data = df); x = summary(fit); x;"} end,
			owf = function() fit = table.concat{"fit <- aov(", data.factors[1], " ~ ", data.factors[2], " + Error(Subject/", data.factors[2], "),data = df); x = summary(fit); x;"} end,
			twftbf = function() fit = table.concat{"fit <- aov(", data.factors[1], " ~ (", data.factors[2], " * ", data.factors[3], " * ", data.factors[4], " * ", data.factors[5], ") + Error(Subject/(", data.factors[2], " * ", data.factors[3], ")) + (", data.factors[4], " * ", data.factors[5] "),data = df); x = summary(fit); x;"} end
		}
		local result = self:evaluate(table.concat{str, "df = data.frame(", df, fit})
		return result
	end

	--declare = function(self, data)
	--	if type(data) ~= "table" then
	--		incompatibleTypeError(1, "table", data)
	--	elseif type(data.data) == "CellularSpace" then
	--		data.data = convertionTypes(data)
	--	end
	--	return data.data
		--local result = self:evaluate(table.concat(data.index, " = ", data.data))
		--return result
	--end
}
metaTableRserve_ = {
	__index = function(index)
		if Rserve_[index] then
			return Rserve_[index]
		end
		return function(self, value)
			return self:evaluate(index.."("..value..")")
		end
	end,
	__tostring = _Gtme.tostring
	--__newindex = function(self, index, value)
		--return self:declare({index = index, data = value})
	--end
}
--- Establishes host and port for communication with R.
-- if an entry is of an incompatible type returns with error.
-- @arg attrTab.host The host name can be passed to R.
-- @arg attrTab.port The port number can be passed to R.
-- @usage import ("rstats")
-- R = Rserve{}
function Rserve(attrTab)
	if type(attrTab) ~= "table" and attrTab ~= nil then
		verifyNamedTable(attrTab)
	else
		if type(attrTab) ~= "table" and attrTab == nil then
			attrTab = {host = "localhost", port = 6311}
		else
			if type(attrTab.host) ~= "string" and attrTab.host ~= nil then
				incompatibleTypeError("host", "string", attrTab.host)
			elseif attrTab.host == "localhost" or attrTab.host == nil then
				defaultTableValue(attrTab, "host", "localhost")
			end

			if type(attrTab.port) ~= "number" and attrTab.port then
				incompatibleTypeError("port", "number", attrTab.port)
			elseif attrTab.port == 6311 or attrTab.port == nil then
				defaultTableValue(attrTab, "port", 6311)
			end
		end
	end

	setmetatable(attrTab, metaTableRserve_)
	return attrTab
end

local function splitstring(str, sep)
	local res = {}
	local counter = 1
	local pos = 1
	for i = 1, #str do
		if (string.sub(str, i, i) == sep) then
			res[counter] = string.sub(str, pos, i)
			pos  = i + 1
			counter = counter + 1
		end
	end

	return res
end

local function buildstrmsg(rexp)
	local command = 3
	local length = (#rexp + 4)
	local offset = 0
	local length2 = 0
	local dptype = 4
	local data = {command, length, offset, length2, dptype, #rexp, rexp}
	local dp_fmt = "u1 u3 s" .. #rexp
	local fmt = QAP1_HEADER_FORMAT .. " " .. dp_fmt
	return vstruct.write(fmt, " ", data)
end

local function getheader(str)
	if #str < 4 then
		return("ERROR: Invalid header (too short)")
	end

	local header = string.sub(str, 1, 4)
	local type = vstruct.read(QAP1_SEXP_HEADER_TYPE_FORMAT, string.sub(header, 1, 1))
	local len = vstruct.read(QAP1_SEXP_HEADER_LEN_FORMAT, string.sub(header, 2, 4))
	return({["exptype"] = type[2], ["hasatts"] = type[1], ["explen"] = len[1]})
end

local function parsesexp(sexp)
	if #sexp < 4 then
		return("WARNING: Invalid SEXP (too short) - " .. #sexp)
	end

	local sexpexps = {}
	local sexpcounter = 1
	local token = 1
	repeat
	local header = getheader(string.sub(sexp, token, token + 3))
	token = token + 4
	local sexpend = token + header.explen - 1
	if header.hasatts then
		local attheader = getheader(string.sub(sexp, token, token + 3))
		local att = parsesexp(string.sub(sexp, token, token + attheader.explen + 3))
		token = token + 4 + attheader.explen
		sexpexps[sexpcounter] = att
		sexpcounter = sexpcounter + 1
	end

	local content = string.sub(sexp, token, sexpend)
	token = sexpend + 1
	local data
	if header.exptype == 0 then
		data = "XT_NULL"
	elseif header.exptype == 3 or header.exptype == 19 then
		data = vstruct.read(#content .. "*s", content)
	elseif header.exptype == 16 or header.exptype == 21 or header.exptype == 23 or header.exptype == 20 or header.exptype == 22 then
		data = parsesexp(content)
	elseif header.exptype == 32 then
		local len = #content / 4
		data = vstruct.read(len .. "*u4", content)
	elseif header.exptype == 33 then
		local len = #content / 8
		data = vstruct.read(len .. "*f8", content)
	elseif header.exptype == 34 then
		data = splitstring(content, string.char(0))
	elseif header.exptype == 36 then
		local len = vstruct.read("u4", string.sub(content, 1, 4))[1]
		data = vstruct.read(len .. "*b1", string.sub(content, 5))
	elseif header.exptype == 48 then
		data = "XT_UNKNOWN"
	else
		return("ERROR: unknown QAP1 expression type:" .. header.exptype)
	end

	sexpexps[sexpcounter] = data
	sexpcounter = sexpcounter + 1
	until token > #sexp
	return(sexpexps)
end

local function calltcp(rsserver, rsport, msg)
	tcp = socket.tcp()
	tcp:settimeout(1, 'b')
	tcp:connect(rsserver, rsport)
	if msg and msg ~= " " then
		tcp:send(msg)
	end

	local s, status, partial = tcp:receive('*a')
	tcp:close()
	return s, status, partial
end

--- Establishes connection with R and returns value.
-- if an entry is of an incompatible type returns with error.
-- @arg rsserver The rsserver(host name) must be passed to R, but not necessarily by the user.
-- @arg rsport The rsport(port number) must be passed to R, but not necessarily by the user.
-- @arg rexp The rexp(expression) must be passed to R.
-- @usage import ("rstats")
-- luaRserveevaluate("localhost", 6311, "x=2")
function luaRserveevaluate(rsserver, rsport, rexp)
	local parameters = {}
	local msgbin = buildstrmsg(rexp)
	local s, _, partial = calltcp(rsserver, rsport, msgbin)
	local res = s or partial
	local qmsg = string.sub(res, 33)
	local qmsgheader = vstruct.read(QAP1_HEADER_FORMAT, string.sub(qmsg, 1, 16))
	local qmsgdata = string.sub(qmsg, 17)
	local token = 1
	local pcounter = 1
	repeat
	local paramheader = vstruct.read(QAP1_PARAMETER_HEADER_FORMAT, string.sub(qmsgdata, token, token + 3))
	token = token + 4
	local parambody = string.sub(qmsgdata, token, token + paramheader[2] - 1)
	if paramheader[1] == 10 then
		parameters[pcounter] = parsesexp(parambody)
	else
		return("ERROR: parameter type " .. paramheader[1] .. " not implemented")
	end

	token = token + paramheader[2]
	pcounter = pcounter + 1
	until token > qmsgheader[2]
	return(parameters)
end
