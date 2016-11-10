local vstruct = require("vstruct")
local socket = require("socket")
local tcp = assert(socket.tcp())
local server = {}
local QAP1_HEADER_FORMAT = "4*u4"			
local QAP1_PARAMETER_HEADER_FORMAT = "u1 u3"         
local QAP1_SEXP_HEADER_TYPE_FORMAT = "[1 | b2 u6]"
local QAP1_SEXP_HEADER_LEN_FORMAT = "u3"

RServe_ = {
	type_ = "RServe",
	--- Returns an error message or a value.
	-- if an entry is of an incompatible type returns with error.
	-- @arg expression The expression must be passed to R.
	-- @usage import ("rstats")
	-- R = RServe{}
	-- R:evaluate("x=4") 
	evaluate = function(self,expression)
		if type(expression) ~= "string" then
			incompatibleTypeError(1, "string", expression)
		end
		local result = luarserveevaluate(self.host, self.port, "tryCatch({"..expression.."}, warning = function(war){return(list(war,0))}, error = function(err){return(list(err,1))})")
		if result[1] then
			if result[1][1] and type(result[1][1]) ~= "number" and type(result[1][1]) ~= "string" and type(result[1][1]) ~= "boolean" then		
				if result[1][1][3] and type(result[1][1][3]) ~= "number" and type(result[1][1][3]) ~= "string" and type(result[1][1][3]) ~= "boolean" then		
					if result[1][1][3][1] == 1 then
						return customError("[RServe] Error: "..result[1][1][2][1][1])
					else if result[1][1][3][1] == 0 then
						return customWarning("[RServe] Warning: "..result[1][1][2][1][1])
					else
						return result
               				end	
					end
				else				
					return result
				end
			else
				return result
			end
		else
			return result	
		end
	end
}

metaTableRServe_ = {
	__index = RServe_,
	__tostring = _Gtme.tostring
}

--- Establishes host and port for communication with R.
-- if an entry is of an incompatible type returns with error.
-- @arg attrTab.host The host name can be passed to R.
-- @arg attrTab.port The port number can be passed to R.
-- @usage import ("rstats")
-- R = RServe{}
function RServe(attrTab)
	local host
	local port
	if type(attrTab) ~= "table" and attrTab ~= nil then
		verifyNamedTable(attrTab)
	else
		if type(attrTab) ~= "table" and attrTab == nil then
			attrTab = {host = "localhost", port = 6311}
			host = "localhost"
			port = 6311
		else
			if type(attrTab.host) ~= "string" and attrTab.host ~= nil then
				incompatibleTypeError("host", "string", attrTab.host)
			elseif attrTab.host == "localhost" or attrTab.host == nil then
				defaultTableValue(attrTab, "host", "localhost")
				host = attrTab.host
			else
				host = attrTab.host
			end

			if type(attrTab.port) ~= "number" and attrTab.port then
				incompatibleTypeError("port", "number", attrTab.port)
			elseif attrTab.port == 6311 or attrTab.port == nil then
				defaultTableValue(attrTab, "port", 6311)
				port = attrTab.port
			else	
				port = attrTab.port
			end
		end
	end
	setmetatable(attrTab, metaTableRServe_)
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

local function getserverdata(rsserver, rsport)
  local s, status, partial = calltcp(rsserver, rsport, " ")
  local res = s or partial
  server = luarserveparseids(string.sub(res , 1 , 32), rsserver, rsport)
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
    local data = ""
    if header.exptype == 0 then  
      data = "XT_NULL"
    elseif header.exptype == 3 or header.exptype == 19 then 
      data = vstruct.read(#content .. "*s", content)
    elseif header.exptype == 16 or header.exptype == 21 or header.exptype == 23
        or header.exptype == 20 or header.exptype == 22 then 
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

local function luarserveparseids(idstring, rsserver, rsport)
  local rsid = string.sub(idstring, 1, 4)
  local rspver = string.sub(idstring, 5, 8)
  local rsp = string.sub(idstring, 9, 12)
  local rsatts = string.sub(idstring, 13)
  local server = {serverid = rsid, protocol = rsp, protversion = rspver,
                  attributes = rsatts, host = rsserver, port = rsport}
  return server
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

local function luarservegetserverid(rsserver, rsport)
  if(#server == 0) then
    getserverdata(rsserver, rsport)
  end
end

--- Establishes connection with R and returns value.
-- if an entry is of an incompatible type returns with error.
-- @arg rsserver The rsserver(host name) must be passed to R, but not necessarily by the user.
-- @arg rsport The rsport(port number) must be passed to R, but not necessarily by the user.
-- @arg rexp The rexp(expression) must be passed to R.
-- @usage import ("rstats")
-- luarserveevaluate("localhost", 6311, "x=2") 
function luarserveevaluate(rsserver, rsport, rexp)
  local parameters = {}
  local msgbin = buildstrmsg(rexp)
  local s, status, partial = calltcp(rsserver, rsport, msgbin)
  local res = s or partial
  local idstring = string.sub(res, 1, 32)
  local qmsg = string.sub(res, 33)
  server = luarserveparseids(string.sub(idstring , 1 , 32), rsserver, rsport)
  local qmsgheader = vstruct.read(QAP1_HEADER_FORMAT, string.sub(qmsg, 1, 16))
  local qmsgdata = string.sub(qmsg, 17)
  local token = 1 
  local pcounter = 1
  repeat

    local paramheader = vstruct.read(QAP1_PARAMETER_HEADER_FORMAT, string.sub(qmsgdata, token, token + 3))
    token = token + 4 
    local parambody = string.sub(qmsgdata, token, token + paramheader[2] - 1)
    if paramheader[1] == 1 then                              
      parameters[pcounter] = vstruct.read("u4", parambody)   
    elseif paramheader[1] == 3 then                          
      parameters[pcounter] = vstruct.read("f4", parambody)   
    elseif paramheader[1] == 2 or paramheader[1] == 4 then   
      parameters[pcounter] = vstruct.read("s", parambody)    
    elseif paramheader[1] == 10 then                         
      parameters[pcounter] = parsesexp(parambody)
    else
      return("ERROR: parameter type " .. paramheader[1] .. " not implemented")
    end
    token = token + paramheader[2] 
    pcounter = pcounter + 1
  until token > qmsgheader[2]
  return(parameters)
end

