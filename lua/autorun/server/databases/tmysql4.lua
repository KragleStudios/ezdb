local Database = {}

function Database:Connect(config) 
	tmysql = tmysql or require("tmysql4")

	config = config or self.config

	if (tmysql) then
		local err

		self.connection, err = tmysql.initialize(
			config.host or "localhost", 
			config.username, 
			config.password, 
			config.database, 
			config.port or 3306, 
			config.socket or ""
		)

		if (self.connection) then
			if (self.OnConnected) then
				self:OnConnected()
			elseif (self.OnConnectionSuccess) then
				self:OnConnectionSuccess()
			end
		elseif (self.OnConnectionFailed) then
			self:OnConnectionFailed(err)
		end

		self.config = config
	end

	return self
end

function Database:Disconnect()
	return self.connection:Disconnect()
end

function Database:Query(query, onSuccess, onError)
	self.connection:Query(query, function(result)
		result = result[1]

		if (result.status) then
			self.m_lastID = result.lastid
			self.m_affectedRows = result.affected

			if (onSuccess) then
				onSuccess(result.data)
			end
		elseif (onError) then
			self.m_lastError = result.error

			onError(result.error, query)
		end
	end)
end

function Database:IsConnected()
	return self.connection != nil and self.connection != false
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