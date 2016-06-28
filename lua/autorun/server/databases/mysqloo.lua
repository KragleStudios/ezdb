local Database = {}

function Database:Connect(config) 
	require("mysqloo")

	config = config or self.config

	if (mysqloo) then
		self.connection = mysqloo.connect(
			config.host or "localhost", 
			config.username, 
			config.password, 
			config.database, 
			config.port or 3306, 
			config.socket or ""
		)

		self.connection.onConnected = function(connection)
			if (self.OnConnected) then
				self:OnConnected()
			elseif (self.OnConnectionSuccess) then
				self:OnConnectionSuccess()
			end
		end

		self.connection.onConnectionFailed = function(connection, err)
			if (self.OnConnectionFailed) then
				self:OnConnectionFailed(err)
			end
		end

		self.config = config
		self.connection:connect()
	end

	return self
end

function Database:Query(query, onSuccess, onError)
	query = self.connection:query(query)

	query.onSuccess = function(query, result)
		if (onSuccess) then
			onSuccess(result or {})
		end
	end

	query.onError = function(query, err, sql)
		self.m_lastError = err

		if (onError) then
			onError(err, sql)
		end
	end

	query:start()
end

function Database:IsConnected()
	return self.connection != nil and self.connection:status() == mysqloo.DATABASE_CONNECTED
end

function Database:Escape(input)
	return self.connection:escape(input)
end

function Database:LastError()
	return self.m_lastError or ""
end

function Database:LastID()
	return self.connection:lastInsert() or 0
end

function Database:AffectedRows()
	return self.connection:affectedRows() or 0
end

return Database