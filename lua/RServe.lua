RServe_ = {
	type_ = "RServe",
	--- Returns an error message  or a value.
	-- ff an entry is of an incompatible type returns with error.
	-- @arg expression The expression must be passed to R.
	-- @usage import RServe
	-- R = RServe{}
	-- R:evaluate(2)
	evaluate = function(self,expression)
		if type(expression)~="string" then
			incompatibleTypeError(1, "string", expression)
		end
	end
}

metaTableRServe_ = {
	__index = RServe_,
	__tostring = _Gtme.tostring
}

--- Type to check the configuration options passed by the modeler. It defines default values ​​
-- and returns unexpected error types or call errors.
-- @arg attrTab.host The host name (optional).
-- @arg attrTab.port The port number (optional).
-- @usage import RServe
-- R1 = RServe{host="name", port=6312}
function RServe(attrTab)
	local host
	local port
	if type(attrTab)~="table" and attrTab~=nil then
		verifyNamedTable(attrTab)
	else
		if type(attrTab)~="table" and attrTab==nil then
			attrTab={host="localhost",port=6311}
			host="localhost"
			port=6311
		else
			if type(attrTab.host)~="string" and attrTab.host~=nil then
				incompatibleTypeError("host", "string", attrTab.host)
			elseif attrTab.host=="localhost" or attrTab.host==nil then
				defaultTableValue(attrTab, "host", "localhost")
				host=attrTab.host
			else
				host=attrTab.host
			end

			if type(attrTab.port)~="number" and attrTab.port then
				incompatibleTypeError("port", "number", attrTab.port)
			elseif attrTab.port==6311 or attrTab.port==nil then
				defaultTableValue(attrTab, "port", 6311)
				port=attrTab.port
			else
				port=attrTab.port
			end
		end
	end
	setmetatable(attrTab, metaTableRServe_)
	return attrTab
end
