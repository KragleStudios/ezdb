local Database = {}

function Database:connect(config) 
	require('mysqloo')

	config = config or self.config

	if (mysqloo) then
		self.connection = mysqloo.connect(
			config.host or 'localhost', 
			config.username, 
			config.password, 
			config.database, 
			config.port or 3306, 
			config.socket or ''
		)

		self.connection.onConnected = function(connection)
			if (self.onConnected) then
				self:onConnected()
			elseif (self.onConnectionSuccess) then
				self:onConnectionSuccess()
			end
		end

		self.connection.onConnectionFailed = function(connection, err)
			if (self.onConnectionFailed) then
				self:onConnectionFailed(err)
			end
		end

		self.config = config
		self.connection:connect()
	else
		error('mysqloo module not loaded', 2)
	end

	return self
end

function Database:query(query, onSuccess, onError)
	query = self.connection:query(query)

	query.onSuccess = function(query, result)
		if (onSuccess) then
			self.m_lastID = query:lastInsert()
			self.m_affectedRows = query:affectedRows()

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

function Database:isConnected()
	return self.connection != nil and self.connection:status() == mysqloo.DATABASE_CONNECTED
end

function Database:escape(input)
	return self.connection:escape(input)
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