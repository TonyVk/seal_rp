ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('esx_billing:posaljiTuljana')
AddEventHandler('esx_billing:posaljiTuljana', function(playerId, sharedAccountName, label, amount)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local xTarget = ESX.GetPlayerFromId(playerId)
	amount        = ESX.Math.Round(amount)

	TriggerEvent('esx_addonaccount:getSharedAccount', sharedAccountName, function(account)

		if amount < 0 then
			print(('esx_billing: %s attempted to send a negative bill!'):format(xPlayer.identifier))
		elseif account == nil then

			if xTarget ~= nil then
				MySQL.Async.execute('INSERT INTO billing (identifier, sender, target_type, target, label, amount) VALUES (@identifier, @sender, @target_type, @target, @label, @amount)',
				{
					['@identifier']  = xTarget.getID(),
					['@sender']      = xPlayer.getID(),
					['@target_type'] = 'player',
					['@target']      = xPlayer.identifier,
					['@label']       = label,
					['@amount']      = amount
				}, function(rowsChanged)
					TriggerClientEvent('esx:showNotification', xTarget.source, _U('received_invoice'))
					TriggerEvent("DiscordBot:Racuni", "Igrac "..GetPlayerName(_source).." je dao račun u iznosu od $"..amount.." igracu "..GetPlayerName(playerId))
				end)
			end

		else

			if xTarget ~= nil then
				if xPlayer ~= nil then
					MySQL.Async.execute('INSERT INTO billing (identifier, sender, target_type, target, label, amount) VALUES (@identifier, @sender, @target_type, @target, @label, @amount)',
					{
						['@identifier']  = xTarget.getID(),
						['@sender']      = xPlayer.getID(),
						['@target_type'] = 'society',
						['@target']      = sharedAccountName,
						['@label']       = label,
						['@amount']      = amount
					}, function(rowsChanged)
						TriggerClientEvent('esx:showNotification', xTarget.source, _U('received_invoice'))
						TriggerEvent("DiscordBot:Racuni", "Igrac "..GetPlayerName(_source).." je dao račun u iznosu od $"..amount.." igracu "..GetPlayerName(playerId))
					end)
				else
					MySQL.Async.execute('INSERT INTO billing (identifier, sender, target_type, target, label, amount) VALUES (@identifier, @sender, @target_type, @target, @label, @amount)',
					{
						['@identifier']  = xTarget.getID(),
						['@sender']      = "Kazna",
						['@target_type'] = 'society',
						['@target']      = sharedAccountName,
						['@label']       = label,
						['@amount']      = amount
					}, function(rowsChanged)
						TriggerClientEvent('esx:showNotification', xTarget.source, _U('received_invoice'))
					end)
				end
			end

		end
	end)

end)

ESX.RegisterServerCallback('esx_billing:getBills', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.Async.fetchAll('SELECT * FROM billing WHERE identifier = @identifier', {
		['@identifier'] = xPlayer.getID()
	}, function(result)
		local bills = {}
		for i=1, #result, 1 do
			table.insert(bills, {
				id         = result[i].id,
				identifier = result[i].identifier,
				sender     = result[i].sender,
				targetType = result[i].target_type,
				target     = result[i].target,
				label      = result[i].label,
				amount     = result[i].amount
			})
		end

		cb(bills)
	end)
end)

ESX.RegisterServerCallback('esx_billing:getMBills', function(source, cb)
	MySQL.Async.fetchAll('SELECT amount, users.name, users.firstname, users.lastname FROM billing LEFT JOIN users ON billing.identifier = users.ID WHERE billing.target = "society_mechanic"', {}, function(result)
		local bills = {}
		for i=1, #result, 1 do
			table.insert(bills, {
				amount     = result[i].amount,
				name 	   = result[i].name,
				firstname  = result[i].firstname,
				lastname   = result[i].lastname
			})
		end
		cb(bills)
	end)
end)

ESX.RegisterServerCallback('esx_billing:getTargetBills', function(source, cb, target)
	local xPlayer = ESX.GetPlayerFromId(target)

	MySQL.Async.fetchAll('SELECT * FROM billing WHERE identifier = @identifier', {
		['@identifier'] = xPlayer.getID()
	}, function(result)
		local bills = {}
		for i=1, #result, 1 do
			table.insert(bills, {
				id         = result[i].id,
				identifier = result[i].identifier,
				sender     = result[i].sender,
				targetType = result[i].target_type,
				target     = result[i].target,
				label      = result[i].label,
				amount     = result[i].amount
			})
		end

		cb(bills)
	end)
end)

ESX.RegisterServerCallback('esx_billing:getMechanicBills', function(source, cb, target)
	local xPlayer = ESX.GetPlayerFromId(target)
	MySQL.Async.fetchAll('SELECT amount FROM billing WHERE identifier = @identifier AND target = "society_mechanic"', {
		['@identifier'] = xPlayer.getID()
	}, function(result)
		local bills = {}
		for i=1, #result, 1 do
			table.insert(bills, {
				amount = result[i].amount
			})
		end
		cb(bills)
	end)
end)

ESX.RegisterServerCallback('esx_platiii:platituljanu', function(source, cb, id)
	local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.Async.fetchAll('SELECT * FROM billing WHERE id = @id', {
		['@id'] = id
	}, function(result)

		local sender     = result[1].sender
		local targetType = result[1].target_type
		local target     = result[1].target
		local amount     = result[1].amount

		local xTarget = ESX.GetPlayerFromIdentifier(sender)

		if targetType == 'player' then

			if xTarget ~= nil then

				if xPlayer.getMoney() >= amount then

					MySQL.Async.execute('DELETE from billing WHERE id = @id', {
						['@id'] = id
					}, function(rowsChanged)
						xPlayer.removeMoney(amount)
						xTarget.addMoney(amount)
						ESX.SavePlayer(xPlayer, function() 
						end)
						ESX.SavePlayer(xTarget, function() 
						end)
						TriggerClientEvent('esx:showNotification', xPlayer.source, _U('paid_invoice', ESX.Math.GroupDigits(amount)))
						TriggerClientEvent('esx:showNotification', xTarget.source, _U('received_payment', ESX.Math.GroupDigits(amount)))

						cb()
					end)

				elseif xPlayer.getBank() >= amount then

					MySQL.Async.execute('DELETE from billing WHERE id = @id', {
						['@id'] = id
					}, function(rowsChanged)
						xPlayer.removeAccountMoney('bank', amount)
						xTarget.addAccountMoney('bank', amount)
						TriggerEvent("banka:Povijest", xPlayer.source, (-1*tonumber(amount)), "Plaćanje računa od igrača")
						TriggerEvent("banka:Povijest", xTarget.source, tonumber(amount), "Plaćen račun od igrača")
						ESX.SavePlayer(xPlayer, function() 
						end)
						ESX.SavePlayer(xTarget, function() 
						end)
						TriggerClientEvent('esx:showNotification', xPlayer.source, _U('paid_invoice', ESX.Math.GroupDigits(amount)))
						TriggerClientEvent('esx:showNotification', xTarget.source, _U('received_payment', ESX.Math.GroupDigits(amount)))

						cb()
					end)

				else
					TriggerClientEvent('esx:showNotification', xTarget.source, _U('target_no_money'))
					TriggerClientEvent('esx:showNotification', xPlayer.source, _U('no_money'))

					cb()
				end

			else
				TriggerClientEvent('esx:showNotification', xPlayer.source, _U('player_not_online'))
				cb()
			end

		else

			TriggerEvent('esx_addonaccount:getSharedAccount', target, function(account)

				if xPlayer.getMoney() >= amount then

					MySQL.Async.execute('DELETE from billing WHERE id = @id', {
						['@id'] = id
					}, function(rowsChanged)
						xPlayer.removeMoney(amount)
						account.addMoney(amount)
						account.save()
						ESX.SavePlayer(xPlayer, function() 
						end)
						TriggerClientEvent('esx:showNotification', xPlayer.source, _U('paid_invoice', ESX.Math.GroupDigits(amount)))
						if xTarget ~= nil then
							TriggerClientEvent('esx:showNotification', xTarget.source, _U('received_payment', ESX.Math.GroupDigits(amount)))
						end

						cb()
					end)

				elseif xPlayer.getBank() >= amount then

					MySQL.Async.execute('DELETE from billing WHERE id = @id', {
						['@id'] = id
					}, function(rowsChanged)
						xPlayer.removeAccountMoney('bank', amount)
						TriggerEvent("banka:Povijest", xPlayer.source, (-1*tonumber(amount)), "Plaćanje računa od igrača")
						account.addMoney(amount)
						account.save()
						ESX.SavePlayer(xPlayer, function() 
						end)
						TriggerClientEvent('esx:showNotification', xPlayer.source, _U('paid_invoice', ESX.Math.GroupDigits(amount)))
						if xTarget ~= nil then
							TriggerClientEvent('esx:showNotification', xTarget.source, _U('received_payment', ESX.Math.GroupDigits(amount)))
						end

						cb()
					end)

				else
					TriggerClientEvent('esx:showNotification', xPlayer.source, _U('no_money'))

					if xTarget ~= nil then
						TriggerClientEvent('esx:showNotification', xTarget.source, _U('target_no_money'))
					end

					cb()
				end
			end)

		end

	end)
end)
