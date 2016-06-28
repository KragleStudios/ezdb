local Database = {}

function Database:Connect(config) 
	require("mysql")

	config = config or self.config

	if (mysql) then
		local err

		self.connection = mysql.Connect(
			config.host or "localhost", 
			config.username, 
			config.password, 
			config.database, 
			config.port or 3306, 
			config.socket or ""
		)

		self.connection.OnConnected = function(connection)
			if (self.OnConnected) then
				self:OnConnected()
			elseif (self.OnConnectionSuccess) then
				self:OnConnectionSuccess()
			end
		end

		self.connection.OnConnectionFailed = function(connection, err)
			if (self.OnConnectionFailed) then
				self:OnConnectionFailed(err)
			end
		end

		self.config = config
		self.connection:Connect()
	end

	return self
end

function Database:Disconnect()
	return self.connection:Disconnect()
end

function Database:Query(query, onSuccess, onError)
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

function Database:IsConnected()
	return self.connection:Status() == DATABASE_CONNECTED
end

function Database:Escape(input)
	return self.connection:Escape(input)
end

function Database:LastError()
	return self.m_lastError or ""
end

function Database:LastID()
	return self.m_lastID or 0
end

function Database:AffectedRows()
	return self.m_affectedRows or 0
end

return Database