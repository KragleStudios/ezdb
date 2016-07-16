print "loading ezdb"

local ezdb = {}
ezdb.wrapper = include("ezdb/wrapper.lua")

function ezdb.create(config)
	local database = {__index = ezdb[config.module or "sqlite"], config = config}

	return setmetatable(database, database)
end

-- A generic error handler you can use for queries.
function ezdb.error(err, query)
	ErrorNoHalt(("SQL Error: %s\n%s\n"):format(err, query))
end

for k, v in pairs(file.Find("ezdb/interfaces/*", "LUA")) do
	local database, name = include("ezdb/interfaces/"..v)

	ezdb[name or v:StripExtension()] = table.Merge(database, ezdb.wrapper)
end

return ezdb