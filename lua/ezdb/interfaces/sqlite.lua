local Database = {}

function Database:connect()
	if (self.onConnected) then
		self:onConnected()
	elseif (self.onConnectionSuccess) then
		self:onConnectionSuccess()
	end

	return self
end

function Database:query(query, onSuccess, onError)
	local result = sql.Query(query)

	if (result != false) then
		self.m_lastID = sql.QueryValue("SELECT last_insert_rowid()")
		self.m_affectedRows = sql.QueryValue("SELECT changes()")

		if (onSuccess) then
			onSuccess(result or {})
		end
	elseif (onError) then
		onError(sql.LastError(), query)
	end
end

function Database:isConnected() 
	return true 
end

function Database:escape(input) 
	return (sql.SQLStr(input, true)):gsub('"', '""')
end

function Database:lastError()
	return sql.LastError() or ""
end

function Database:lastId()
	return self.m_lastID or 0
end

function Database:affectedRows()
	return self.m_affectedRows or 0
end

return Database