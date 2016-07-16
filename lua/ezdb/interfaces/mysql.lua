local Database = {}

function Database:connect(config) 
	require('mysql')

	config = config or self.config

	if (mysql) then
		local err

		self.connection = mysql.Connect(
			config.host or 'localhost', 
			config.username, 
			config.password, 
			config.database, 
			config.port or 3306, 
			config.socket or ''
		)

		self.connection.OnConnected = function(connection)
			if (self.onConnected) then
				self:onConnected()
			elseif (self.onConnectionSuccess) then
				self:onConnectionSuccess()
			end
		end

		self.connection.OnConnectionFailed = function(connection, err)
			if (self.onConnectionFailed) then
				self:onConnectionFailed(err)
			end
		end

		self.config = config
		self.connection:Connect()
	else
		error('mysql module not loaded', 2)
	end

	return self
end

function Database:disconnect()
	return self.connection:Disconnect()
end

function Database:query(query, onSuccess, onError)
	local queryObj = self.connection:Query(query)

	queryObj.OnCompleted = function(queryObj, result)
		result = result[1]

		if (result.Success) then
			self.m_lastID = result.LastID
			self.m_affectedRows = result.Affected

			if (onSuccess) then
				onSuccess(result.Data)
			end
		elseif (onError) then
			self.m_lastError = result.Error

			onError(result.Error, query)
		end
	end

	queryObj:Start()
end

function Database:isConnected()
	return self.connection:Status() == DATABASE_CONNECTED
end

function Database:escape(input)
	return self.connection:Escape(input)
end

function Database:lastError()
	return self.m_lastError or ''
end

function Database:lastId()
	return self.m_lastID or 0
end

function Database:affectedRows()
	return self.m_affectedRows or 0
end

return Database