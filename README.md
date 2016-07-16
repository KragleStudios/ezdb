# ezdb
A modular SQL interface and wrapper for Garry's Mod. Copy the addon's [lua/bin](lua/bin) to your server's `lua/bin`

Supports the following modules

* [mysql](https://facepunch.com/showthread.php?t=1490075)
* [mysqloo](https://facepunch.com/showthread.php?t=1357773)
* [tmysql4](https://facepunch.com/showthread.php?t=1442438)
* sqlite

## Example
Replace the `module` string with any of the modules above.

```lua
hook.Add("InitPostEntity", "LoadDatabase", function()	
	local database = ezdb.create(
	{
		host 		= 	"localhost",
		username 	= 	"root",
		password 	= 	"",
		database 	= 	"serverguard",
		module 		= 	"tmysql4"
	})
	
	function database:OnConnected()
		print("Connected to the database.")
	end

	function database:OnConnectionFailed(err)
		ErrorNoHalt(err.."\n")
	end

	database:Connect()
end)
```

You can execute raw queries or build them with the provided wrapper. For example, the following queries are identical.

```lua
database:Query("SELECT * FROM users WHERE rank = 'user' LIMIT 1;", function(result)
	PrintTable(result)
end, ezdb.error)
```

```lua
local query = database:Select("users")
	query:Where("rank", "user")
	query:Limit(1)
	query:Callback(function(result)
		PrintTable(result)
	end)
query:Execute()
```

The wrapper can also be used in-line, which allows for short and expressive queries to be executed in a single line. The following example would set every user's `money` to 0 if they have $5,000 or more.

```lua
database:Update("users"):Update("money", 0):WhereGTE("money", 5000):Execute()
```

All input using the wrapper is automatically escaped.
