TriggerEvent('es:addGroupCommand', 'tp', 'admin', function(source, args, user)
	local x = tonumber(args[1])
	local y = tonumber(args[2])
	local z = tonumber(args[3])
	
	if x and y and z then
		TriggerClientEvent('esx:teleport', source, {
			x = x,
			y = y,
			z = z
		})
	else
		TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Netocne koordinate!")
	end
end, function(source, args, user)
	TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Nemate pristup komandi' } })
end, {help = "Teleport na koordinate", params = {{name = "x", help = "X koord"}, {name = "y", help = "Y koord"}, {name = "z", help = "Z koord"}}})

TriggerEvent('es:addGroupCommand', 'setjob', 'jobmaster', function(source, args, user)
	if tonumber(args[1]) and tonumber(args[2]) then
		local xPlayer = ESX.GetPlayerFromId(args[1])

		if xPlayer then
			if ESX.DoesPosaoExist(tonumber(args[2])) then
				xPlayer.setPosao(tonumber(args[2]))
			else
				TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Taj posao ne postoji.' } })
				TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Lista poslova:' } })
				for i=1, #ESX.Poslovi, 1 do
					TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'ID: '..ESX.Poslovi[i].pID.." | Ime: "..ESX.Poslovi[i].label } })
				end
			end
		else
			TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Igrac nije online.' } })
		end
	else
		TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Krivo koristenje.' } })
		TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', '/setjob [ID igraca][ID posla]' } })
	end
end, function(source, args, user)
	TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Nemate pristup komandi' } })
end, {help = _U('setjob'), params = {{name = "id", help = _U('id_param')}, {name = "posao", help = _U('setjob_param2')}}})

TriggerEvent('es:addGroupCommand', 'setmafija', 'jobmaster', function(source, args, user)
	if tonumber(args[1]) and tonumber(args[2]) and tonumber(args[3]) then
		local xPlayer = ESX.GetPlayerFromId(args[1])
		if xPlayer then
			if ESX.DoesJobExist(tonumber(args[2]), args[3]) then
				xPlayer.setJob(tonumber(args[2]), args[3])
			else
				TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Ta mafija/orga ne postoji.' } })
				TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Lista mafija/orgi:' } })
				for i=1, #ESX.JobsHelper, 1 do
					if ESX.JobsHelper[i] ~= nil then
						TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'ID: '..ESX.JobsHelper[i].ID.." | Ime: "..ESX.JobsHelper[i].Label } })
					end
				end
			end
		else
			TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Igrac nije online.' } })
		end
	else
		TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Krivo koristenje.' } })
		TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', '/setmafija [ID igraca][ID posla][Rank]' } })
	end
end, function(source, args, user)
	TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Nemate pristup komandi' } })
end, {help = _U('setmafia'), params = {{name = "id", help = _U('id_param')}, {name = "job", help = _U('setmafia_param2')}, {name = "grade_id", help = _U('setmafia_param3')}}})

TriggerEvent('es:addGroupCommand', 'loadipl', 'admin', function(source, args, user)
	TriggerClientEvent('esx:loadIPL', -1, args[1])
end, function(source, args, user)
	TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Nemate pristup komandi' } })
end, {help = _U('load_ipl')})

TriggerEvent('es:addGroupCommand', 'unloadipl', 'admin', function(source, args, user)
	TriggerClientEvent('esx:unloadIPL', -1, args[1])
end, function(source, args, user)
	TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Nemate pristup komandi' } })
end, {help = _U('unload_ipl')})

TriggerEvent('es:addGroupCommand', 'playanim', 'admin', function(source, args, user)
	TriggerClientEvent('esx:playAnim', -1, args[1], args[3])
end, function(source, args, user)
	TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Nemate pristup komandi' } })
end, {help = _U('play_anim')})

TriggerEvent('es:addGroupCommand', 'playemote', 'admin', function(source, args, user)
	TriggerClientEvent('esx:playEmote', -1, args[1])
end, function(source, args, user)
	TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Nemate pristup komandi' } })
end, {help = _U('play_emote')})

TriggerEvent('es:addGroupCommand', 'car', 'admin', function(source, args, user)
	TriggerClientEvent('esx:spawnVehicle', source, args[1])
end, function(source, args, user)
	TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Nemate pristup komandi' } })
end, {help = _U('spawn_car'), params = {{name = "car", help = _U('spawn_car_param')}}})

TriggerEvent('es:addGroupCommand', 'cardel', 'admin', function(source, args, user)
	TriggerClientEvent('esx:deleteVehicle', source)
end, function(source, args, user)
	TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Nemate pristup komandi' } })
end, {help = _U('delete_vehicle')})

TriggerEvent('es:addGroupCommand', 'dv', 'admin', function(source, args, user)
	TriggerClientEvent('esx:deleteVehicle', source, args[1])
end, function(source, args, user)
	TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Insufficient Permissions.' } })
end, {help = _U('delete_vehicle'), params = {
	{name = 'radius', help = 'Neobavezno, brise sva vozila unutar upisanog rangea'}
}})

TriggerEvent('es:addGroupCommand', 'spawnped', 'admin', function(source, args, user)
	TriggerClientEvent('esx:spawnPed', source, args[1])
end, function(source, args, user)
	TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Nemate pristup komandi' } })
end, {help = _U('spawn_ped'), params = {{name = "name", help = _U('spawn_ped_param')}}})

TriggerEvent('es:addGroupCommand', 'spawnobject', 'admin', function(source, args, user)
	TriggerClientEvent('esx:spawnObject', source, args[1])
end, function(source, args, user)
	TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Nemate pristup komandi' } })
end, {help = _U('spawn_object'), params = {{name = "name"}}})

RegisterNetEvent('amenu:SetMoney')
AddEventHandler('amenu:SetMoney', function(igr, typ, br)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	if xPlayer.getPerm() >= 69 then
		local target = igr
		local money_type = typ
		local money_amount = br
		
		local yPlayer = ESX.GetPlayerFromId(target)

		if target and money_type and money_amount and yPlayer ~= nil then
			if money_type == 'cash' then
				yPlayer.setMoney(money_amount)
			elseif money_type == 'bank' then
				yPlayer.setAccountMoney('bank', money_amount)
			elseif money_type == 'black' then
				yPlayer.setAccountMoney('black_money', money_amount)
			else
				TriggerClientEvent('chatMessage', src, "SYSTEM", {255, 0, 0}, "^2" .. money_type .. " ^0 nije vazeci tip novca!")
				return
			end
		else
			TriggerClientEvent('chatMessage', src, "SYSTEM", {255, 0, 0}, "Krivi argumenti.")
			return
		end
		
		print('es_extended: ' .. GetPlayerName(source) .. ' just set $' .. money_amount .. ' (' .. money_type .. ') to ' .. yPlayer.name)
		
		if yPlayer.source ~= src then
			TriggerClientEvent('esx:showNotification', yPlayer.source, _U('money_set', money_amount, money_type))
		end
	end
end)

RegisterNetEvent('amenu:AccountMoney')
AddEventHandler('amenu:AccountMoney', function(igr, acc, br)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	if xPlayer.getPerm() >= 69 then
		local yPlayer = ESX.GetPlayerFromId(igr)
		local account = acc
		local amount  = br

		if amount ~= nil then
			if yPlayer.getAccount(account) ~= nil then
				yPlayer.addAccountMoney(account, amount)
			else
				TriggerClientEvent('esx:showNotification', src, _U('invalid_account'))
			end
		else
			TriggerClientEvent('esx:showNotification', src, _U('amount_invalid'))
		end
	end
end)

TriggerEvent('es:addGroupCommand', 'giveitem', 'admin', function(source, args, user)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(args[1])
	local item    = args[2]
	local count   = (args[3] == nil and 1 or tonumber(args[3]))

	if count ~= nil then
		if xPlayer.getInventoryItem(item) ~= nil then
			xPlayer.addInventoryItem(item, count)
		else
			TriggerClientEvent('esx:showNotification', _source, _U('invalid_item'))
		end
	else
		TriggerClientEvent('esx:showNotification', _source, _U('invalid_amount'))
	end
end, function(source, args, user)
	TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Nemate pristup komandi' } })
end, {help = _U('giveitem'), params = {{name = "id", help = _U('id_param')}, {name = "item", help = _U('item')}, {name = "amount", help = _U('amount')}}})

TriggerEvent('es:addGroupCommand', 'giveweapon', 'admin', function(source, args, user)
	local xPlayer    = ESX.GetPlayerFromId(args[1])
	local weaponName = string.upper(args[2])
	local valja = 0
	for i=1, #Config.Weapons, 1 do
		if Config.Weapons[i].name == weaponName then
			xPlayer.addWeapon(weaponName, tonumber(args[3]))
			valja = 1
		end
	end
	if valja == 0 then
		TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'To oruzje ne postoji!' } })
	end
end, function(source, args, user)
	TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Nemate pristup komandi' } })
end, {help = _U('giveweapon'), params = {{name = "id", help = _U('id_param')}, {name = "weapon", help = _U('weapon')}, {name = "ammo", help = _U('amountammo')}}})

TriggerEvent('es:addGroupCommand', 'disc', 'admin', function(source, args, user)
	DropPlayer(source, 'Odspojili ste se sa servera')
end, function(source, args, user)
	TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Nemate pristup komandi' } })
end)

TriggerEvent('es:addGroupCommand', 'disconnect', 'admin', function(source, args, user)
	DropPlayer(source, 'Odspojili ste se sa servera')
end, function(source, args, user)
	TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Nemate pristup komandi' } })
end, {help = _U('disconnect')})

TriggerEvent('es:addGroupCommand', 'clear', 'user', function(source, args, user)
	TriggerClientEvent('chat:clear', source)
end, function(source, args, user)
	TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Nemate pristup komandi' } })
end, {help = _U('chat_clear')})

TriggerEvent('es:addGroupCommand', 'cls', 'user', function(source, args, user)
	TriggerClientEvent('chat:clear', source)
end, function(source, args, user)
	TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Nemate pristup komandi' } })
end)

TriggerEvent('es:addGroupCommand', 'clsall', 'admin', function(source, args, user)
	TriggerClientEvent('chat:clear', -1)
end, function(source, args, user)
	TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Nemate pristup komandi' } })
end)

TriggerEvent('es:addGroupCommand', 'clearall', 'admin', function(source, args, user)
	TriggerClientEvent('chat:clear', -1)
end, function(source, args, user)
	TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Nemate pristup komandi' } })
end, {help = _U('chat_clear_all')})

TriggerEvent('es:addGroupCommand', 'clearinventory', 'admin', function(source, args, user)
	local xPlayer

	if args[1] then
		xPlayer = ESX.GetPlayerFromId(args[1])
	else
		xPlayer = ESX.GetPlayerFromId(source)
	end

	if not xPlayer then
		TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Igrac nije online.' } })
		return
	end

	for i=1, #xPlayer.inventory, 1 do
		if xPlayer.inventory[i].count > 0 then
			xPlayer.setInventoryItem(xPlayer.inventory[i].name, 0)
		end
	end
end, function(source, args, user)
	TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Nemate pristup komandi' } })
end, {help = _U('command_clearinventory'), params = {{name = "playerId", help = _U('command_playerid_param')}}})

TriggerEvent('es:addGroupCommand', 'clearloadout', 'admin', function(source, args, user)
	local xPlayer

	if args[1] then
		xPlayer = ESX.GetPlayerFromId(args[1])
	else
		xPlayer = ESX.GetPlayerFromId(source)
	end

	if not xPlayer then
		TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Igrac nije online.' } })
		return
	end

	for i=#xPlayer.loadout, 1, -1 do
		xPlayer.removeWeapon(xPlayer.loadout[i].name)
	end
end, function(source, args, user)
	TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Nemate pristup komandi' } })
end, {help = _U('command_clearloadout'), params = {{name = "playerId", help = _U('command_playerid_param')}}})
