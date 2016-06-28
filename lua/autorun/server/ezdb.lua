ezdb = {}
ezdb.Wrapper = include("ezdb-wrapper/wrapper.lua")

function ezdb.Create(config)
	local database = {__index = ezdb[config.module or "sqlite"], config = config}

	return setmetatable(database, database)
end

-- A generic error handler you can use for queries.
function ezdb.Error(err, query)
	ErrorNoHalt(("SQL Error: %s\n%s\n"):format(err, query))
end

for k, v in pairs(file.Find("autorun/server/databases/*", "LUA")) do
	local database, name = include("databases/"..v)

	ezdb[name or v:StripExtension()] = table.Merge(database, ezdb.Wrapper)
end