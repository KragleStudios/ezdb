--[[
	The MIT License (MIT)

	Copyright (c) 2014 Alex Grist-Hucker

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the 'Software'), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.
--]]

local wrapper = {}

local type = type
local tostring = tostring
local table = table

QUERY_CLASS = {}
QUERY_CLASS.__index = QUERY_CLASS

function QUERY_CLASS:new(tableName, queryType, database)
	local newObject = setmetatable({}, QUERY_CLASS)
		newObject.queryType = queryType
		newObject.tableName = tableName
		newObject.selectList = {}
		newObject.insertList = {}
		newObject.updateList = {}
		newObject.createList = {}
		newObject.whereList = {}
		newObject.orderByList = {}
		newObject.database = database
	return newObject
end

function QUERY_CLASS:escape(text)
	return self.database:escape(tostring(text))
end

function QUERY_CLASS:forTable(tableName)
	self.tableName = tableName
	return self
end

function QUERY_CLASS:where(key, value)
	self:whereEqual(key, value)
	return self
end

function QUERY_CLASS:whereEqual(key, value)
	self.whereList[#self.whereList + 1] = '`'..key..'` = \''..self:escape(value)..'\''
	return self
end

function QUERY_CLASS:whereNotEqual(key, value)
	self.whereList[#self.whereList + 1] = '`'..key..'` != \''..self:escape(value)..'\''
	return self
end

function QUERY_CLASS:whereLike(key, value)
	self.whereList[#self.whereList + 1] = '`'..key..'` LIKE \''..self:escape(value)..'\''
	return self
end

function QUERY_CLASS:whereNotLike(key, value)
	self.whereList[#self.whereList + 1] = '`'..key..'` NOT LIKE \''..self:escape(value)..'\''
	return self
end

function QUERY_CLASS:whereGT(key, value)
	self.whereList[#self.whereList + 1] = '`'..key..'` > \''..self:escape(value)..'\''
	return self
end

function QUERY_CLASS:whereLT(key, value)
	self.whereList[#self.whereList + 1] = '`'..key..'` < \''..self:escape(value)..'\''
	return self
end

function QUERY_CLASS:whereGTE(key, value)
	self.whereList[#self.whereList + 1] = '`'..key..'` >= \''..self:escape(value)..'\''
	return self
end

function QUERY_CLASS:whereLTE(key, value)
	self.whereList[#self.whereList + 1] = '`'..key..'` <= \''..self:escape(value)..'\''
	return self
end

function QUERY_CLASS:orderByDesc(key)
	self.orderByList[#self.orderByList + 1] = '`'..key..'` DESC'
	return self
end

function QUERY_CLASS:orderByAsc(key)
	self.orderByList[#self.orderByList + 1] = '`'..key..'` ASC'
	return self
end

function QUERY_CLASS:callback(queryCallback)
	self.callback = queryCallback
	return self
end

function QUERY_CLASS:select(fieldName)
	self.selectList[#self.selectList + 1] = '`'..fieldName..'`'
	return self
end

function QUERY_CLASS:insert(key, value)
	self.insertList[#self.insertList + 1] = {'`'..key..'`', '\''..self:escape(value)..'\''}
	return self
end

function QUERY_CLASS:update(key, value)
	self.updateList[#self.updateList + 1] = {'`'..key..'`', '\''..self:escape(value)..'\''}
	return self
end

function QUERY_CLASS:create(key, value)
	self.createList[#self.createList + 1] = {'`'..key..'`', value}
	return self
end

function QUERY_CLASS:primaryKey(key)
	self.primaryKey = '`'..key..'`'
	return self
end

function QUERY_CLASS:limit(value)
	self.limit = value
	return self
end

function QUERY_CLASS:offset(value)
	self.offset = value
	return self
end

local function buildSelectQuery(queryObj)
	local queryString = {'SELECT'}

	if (type(queryObj.selectList) != 'table' or #queryObj.selectList == 0) then
		queryString[#queryString + 1] = ' *'
	else
		queryString[#queryString + 1] = ' '..table.concat(queryObj.selectList, ', ')
	end

	if (type(queryObj.tableName) == 'string') then
		queryString[#queryString + 1] = ' FROM `'..queryObj.tableName..'` '
	else
		
		return
	end

	if (type(queryObj.whereList) == 'table' and #queryObj.whereList > 0) then
		queryString[#queryString + 1] = ' WHERE '
		queryString[#queryString + 1] = table.concat(queryObj.whereList, ' AND ')
	end

	if (type(queryObj.orderByList) == 'table' and #queryObj.orderByList > 0) then
		queryString[#queryString + 1] = ' ORDER BY '
		queryString[#queryString + 1] = table.concat(queryObj.orderByList, ', ')
	end

	if (type(queryObj.limit) == 'number') then
		queryString[#queryString + 1] = ' LIMIT '
		queryString[#queryString + 1] = queryObj.limit
	end

	return table.concat(queryString)
end

local function buildInsertQuery(queryObj)
	local queryString = {'INSERT INTO'}
	local keyList = {}
	local valueList = {}

	if (type(queryObj.tableName) == 'string') then
		queryString[#queryString + 1] = ' `'..queryObj.tableName..'`'
	else		
		return
	end

	for i = 1, #queryObj.insertList do
		keyList[#keyList + 1] = queryObj.insertList[i][1]
		valueList[#valueList + 1] = queryObj.insertList[i][2]
	end

	if (#keyList == 0) then
		return
	end

	queryString[#queryString + 1] = ' ('..table.concat(keyList, ', ')..')'
	queryString[#queryString + 1] = ' VALUES ('..table.concat(valueList, ', ')..')'

	return table.concat(queryString)
end

local function buildUpdateQuery(queryObj)
	local queryString = {'UPDATE'}

	if (type(queryObj.tableName) == 'string') then
		queryString[#queryString + 1] = ' `'..queryObj.tableName..'`'
	else		
		return
	end

	if (type(queryObj.updateList) == 'table' and #queryObj.updateList > 0) then
		local updateList = {}

		queryString[#queryString + 1] = ' SET'

		for i = 1, #queryObj.updateList do
			updateList[#updateList + 1] = queryObj.updateList[i][1]..' = '..queryObj.updateList[i][2]
		end

		queryString[#queryString + 1] = ' '..table.concat(updateList, ', ')
	end

	if (type(queryObj.whereList) == 'table' and #queryObj.whereList > 0) then
		queryString[#queryString + 1] = ' WHERE '
		queryString[#queryString + 1] = table.concat(queryObj.whereList, ' AND ')
	end

	if (type(queryObj.offset) == 'number') then
		queryString[#queryString + 1] = ' OFFSET '
		queryString[#queryString + 1] = queryObj.offset
	end

	return table.concat(queryString)
end

local function buildDeleteQuery(queryObj)
	local queryString = {'DELETE FROM'}

	if (type(queryObj.tableName) == 'string') then
		queryString[#queryString + 1] = ' `'..queryObj.tableName..'`'
	else		
		return
	end

	if (type(queryObj.whereList) == 'table' and #queryObj.whereList > 0) then
		queryString[#queryString + 1] = ' WHERE '
		queryString[#queryString + 1] = table.concat(queryObj.whereList, ' AND ')
	end

	if (type(queryObj.limit) == 'number') then
		queryString[#queryString + 1] = ' LIMIT '
		queryString[#queryString + 1] = queryObj.limit
	end

	return table.concat(queryString)
end

local function buildDropQuery(queryObj)
	local queryString = {'DROP TABLE'}

	if (type(queryObj.tableName) == 'string') then
		queryString[#queryString + 1] = ' `'..queryObj.tableName..'`'
	else		
		return
	end

	return table.concat(queryString)
end

local function buildTruncateQuery(queryObj)
	local queryString = {'TRUNCATE TABLE'}

	if (type(queryObj.tableName) == 'string') then
		queryString[#queryString + 1] = ' `'..queryObj.tableName..'`'
	else		
		return
	end

	return table.concat(queryString)
end

local function buildCreateQuery(queryObj)
	local queryString = {'CREATE TABLE IF NOT EXISTS'}

	if (type(queryObj.tableName) == 'string') then
		queryString[#queryString + 1] = ' `'..queryObj.tableName..'`'
	else		
		return
	end

	queryString[#queryString + 1] = ' ('

	if (type(queryObj.createList) == 'table' and #queryObj.createList > 0) then
		local createList = {}

		for i = 1, #queryObj.createList do
			if (queryObj.database.config.module == 'sqlite') then
				createList[#createList + 1] = queryObj.createList[i][1]..' '..string.gsub(string.gsub(string.gsub(queryObj.createList[i][2], 'AUTO_INCREMENT', ''), 'AUTOINCREMENT', ''), 'INT ', 'INTEGER ')
			else
				createList[#createList + 1] = queryObj.createList[i][1]..' '..queryObj.createList[i][2]
			end
		end

		queryString[#queryString + 1] = ' '..table.concat(createList, ', ')
	end

	if (type(queryObj.primaryKey) == 'string') then
		queryString[#queryString + 1] = ', PRIMARY KEY'
		queryString[#queryString + 1] = ' ('..queryObj.primaryKey..')'
	end

	queryString[#queryString + 1] = ' )'

	return table.concat(queryString) 
end

function QUERY_CLASS:execute(callback)
	local queryString = nil
	local queryType = string.lower(self.queryType)

	if (queryType == 'select') then
		queryString = buildSelectQuery(self)
	elseif (queryType == 'insert') then
		queryString = buildInsertQuery(self)
	elseif (queryType == 'update') then
		queryString = buildUpdateQuery(self)
	elseif (queryType == 'delete') then
		queryString = buildDeleteQuery(self)
	elseif (queryType == 'drop') then
		queryString = buildDropQuery(self)
	elseif (queryType == 'truncate') then
		queryString = buildTruncateQuery(self)
	elseif (queryType == 'create') then
		queryString = buildCreateQuery(self)
	end

	if (type(queryString) == 'string') then
		return self.database:query(queryString, callback or self.callback, ezdb.error)
	end
end

function wrapper:select(tableName)
	return QUERY_CLASS:new(tableName, 'SELECT', self)
end

function wrapper:insert(tableName)
	return QUERY_CLASS:new(tableName, 'INSERT', self)
end

function wrapper:update(tableName)
	return QUERY_CLASS:new(tableName, 'UPDATE', self)
end

function wrapper:delete(tableName)
	return QUERY_CLASS:new(tableName, 'DELETE', self)
end

function wrapper:drop(tableName)
	return QUERY_CLASS:new(tableName, 'DROP', self)
end

function wrapper:truncate(tableName)
	return QUERY_CLASS:new(tableName, 'TRUNCATE', self)
end

function wrapper:create(tableName)
	return QUERY_CLASS:new(tableName, 'CREATE', self)
end

return wrapper
