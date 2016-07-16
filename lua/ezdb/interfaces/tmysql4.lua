local Database = {}

function Database:connect(config) 
	require('tmysql4')

	config = config or self.config

	if (tmysql) then
		local err

		self.connection, err = tmysql.initialize(
			config.host or 'localhost', 
			config.username, 
			config.password, 
			config.database, 
			config.port or 3306, 
			config.socket or ''
		)

		if (self.connection) then
			if (self.onConnected) then
				self:onConnected()
			elseif (self.onConnectionSuccess) then
				self:onConnectionSuccess()
			end
		elseif (self.onConnectionFailed) then
			self:onConnectionFailed(err)
		end

		self.config = config
	else
		error('tmysql4 module not loaded', 2)
	end

	return self
end

function Database:disconnect()
	return self.connection:Disconnect()
end

function Database:query(query, onSuccess, onError)
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

function Database:isConnected()
	return self.connection != nil and self.connection != false
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