
local compare = {}

local tbOPList = 
{
	[">"] = function(param1, param2)
		return param1 > param2
	end,
	[">="] = function(param1, param2)
		return param1 >= param2
	end,
	["=="] = function(param1, param2)
		return param1 == param2
	end,
	["<="] = function(param1, param2)
		return param1 <= param2
	end,
	["<"] = function(param1, param2)
		return param1 < param2
	end,
}

function compare:doCompare(param1, param2, operation)
	assert(tbOPList[operation], operation, tbOPList[operation])
	return tbOPList[operation](param1, param2)
end

return compare
