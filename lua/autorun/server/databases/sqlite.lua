local Database = {}

function Database:Connect()
	if (self.OnConnected) then
		self:OnConnected()
	elseif (self.OnConnectionSuccess) then
		self:OnConnectionSuccess()
	end

	return self
end

function Database:Query(query, onSuccess, onError)
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

function Database:IsConnected() 
	return true 
end

function Database:Escape(input) 
	return sql.SQLStr(input) 
end

function Database:LastError()
	return sql.LastError() or ""
end

function Database:LastID()
	return self.m_lastID or 0
end

function Database:AffectedRows()
	return self.m_affectedRows or 0
end

return Database