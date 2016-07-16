require 'ezdb'

local database = ezdb.create(
{
	module      =   'sqlite'
})

function database:OnConnected()
	self:Create('ezdb_test')
		:Create('name', 'VARCHAR(255) NOT NULL')
		:Create('money', 'INTEGER NOT NULL')
	:Execute(function()
		print('created ezdb_test table')

		self:Insert('ezdb_test')
			:Insert('name', 'John Doe')
			:Insert('money', 5000)
		:Execute(function()
			print('inserted row')

			self:Update('ezdb_test'):Update('money', 200):WhereGTE('money', 5000):Execute(function()
				print('updated money, '..tostring(self:AffectedRows())..' row affected')

				self:Select('ezdb_test'):Where('money', 200):Execute(function(result)
					print('got result')

					PrintTable(result)

					self:Delete('ezdb_test'):Execute(function()
						print('deleted ezdb_test table')
					end)
				end)
			end)
		end)
	end)
end

database:Connect()