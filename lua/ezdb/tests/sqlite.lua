require 'ezdb'

local database = ezdb.create(
{
	module      =   'sqlite'
})

function database:onConnected()
	self:create('ezdb_test')
		:create('name', 'VARCHAR(255) NOT NULL')
		:create('money', 'INTEGER NOT NULL')
	:execute(function()
		print('created ezdb_test table')

		self:insert('ezdb_test')
			:insert('name', 'John Doe')
			:insert('money', 5000)
		:execute(function()
			print('inserted row')

			self:update('ezdb_test'):update('money', 200):whereGTE('money', 5000):execute(function()
				print('updated money, '..tostring(self:affectedRows())..' row affected')

				self:select('ezdb_test'):where('money', 200):execute(function(result)
					print('got result')

					PrintTable(result)

					self:delete('ezdb_test'):execute(function()
						print('deleted ezdb_test table')
					end)
				end)
			end)
		end)
	end)
end

database:connect()