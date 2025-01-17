ESX                      = {}
ESX.Players              = {}
ESX.UsableItemsCallbacks = {}
ESX.Items                = {}
ESX.ServerCallbacks      = {}
ESX.TimeoutCount         = -1
ESX.CancelledTimeouts    = {}
ESX.LastPlayerData       = {}
ESX.Pickups              = {}
ESX.PickupId             = 0
ESX.Jobs                 = {}
ESX.Poslovi              = {}
ESX.JobsHelper           = {}

AddEventHandler('esx:getSharedObject', function(cb)
	cb(ESX)
end)

function getSharedObject()
	return ESX
end

MySQL.ready(function()
	MySQL.Async.fetchAll('SELECT * FROM items', {}, function(result)
		for i=1, #result, 1 do
			ESX.Items[result[i].name] = {
				ID        = result[i].ID,
				label     = result[i].label,
				limit     = result[i].limit,
				rare      = (result[i].rare       == 1 and true or false),
				canRemove = (result[i].can_remove == 1 and true or false),
			}
		end
	end)

	local result4 = MySQL.Sync.fetchAll('SELECT * FROM poslovi order by pID asc', {})

	for i=1, #result4 do
		ESX.Poslovi[tonumber(result4[i].pID)] = result4[i]
	end

	local result = MySQL.Sync.fetchAll('SELECT * FROM jobs order by pID', {})

	for i=1, #result do
		ESX.Jobs[tonumber(result[i].pID)] = result[i]
		ESX.Jobs[tonumber(result[i].pID)].grades = {}
	end

	local result2 = MySQL.Sync.fetchAll('SELECT job_grades.*, jobs.pID  FROM job_grades inner join jobs on job_grades.job_name=jobs.name', {})

	for i=1, #result2 do
		if ESX.Jobs[tonumber(result2[i].pID)] then
			ESX.Jobs[tonumber(result2[i].pID)].grades[tostring(result2[i].grade)] = result2[i]
		else
			print(('es_extended: invalid job "%s" from table job_grades ignored!'):format(result2[i].job_name))
		end
	end

	for k,v in pairs(ESX.Jobs) do
		table.insert(ESX.JobsHelper, {ID = v.pID, Label = v.label})
		if next(v.grades) == nil then
			ESX.Jobs[tonumber(v.pID)] = nil
			table.remove(ESX.JobsHelper, #ESX.JobsHelper)
			print(('es_extended: ignoring job "%s" due to missing job grades!'):format(v.name))
		end
	end
end)

RegisterServerEvent('RefreshPoslove')
AddEventHandler('RefreshPoslove', function()
	ESX.Jobs = {}
	ESX.JobsHelper = {}
	local result = MySQL.Sync.fetchAll('SELECT * FROM jobs', {})

	for i=1, #result do
		ESX.Jobs[tonumber(result[i].pID)] = result[i]
		ESX.Jobs[tonumber(result[i].pID)].grades = {}
	end

	local result2 = MySQL.Sync.fetchAll('SELECT job_grades.*, jobs.pID FROM job_grades inner join jobs on job_grades.job_name=jobs.name', {})

	for i=1, #result2 do
		if ESX.Jobs[tonumber(result2[i].pID)] then
			ESX.Jobs[tonumber(result2[i].pID)].grades[tostring(result2[i].grade)] = result2[i]
		else
			print(('es_extended: invalid job "%s" from table job_grades ignored!'):format(result2[i].job_name))
		end
	end

	for k,v in pairs(ESX.Jobs) do
		table.insert(ESX.JobsHelper, {ID = v.pID, Label = v.label})
		if next(v.grades) == nil then
			ESX.Jobs[tonumber(v.pID)] = nil
			table.remove(ESX.JobsHelper, #ESX.JobsHelper)
			print(('es_extended: ignoring job "%s" due to missing job grades!'):format(v.name))
		end
	end
end)

AddEventHandler('esx:playerLoaded', function(source)
	local xPlayer         = ESX.GetPlayerFromId(source)
	local accounts        = {}
	local items           = {}
	local xPlayerAccounts = xPlayer.getAccounts()
	local xPlayerItems    = xPlayer.getInventory()

	for i=1, #xPlayerAccounts, 1 do
		accounts[xPlayerAccounts[i].name] = xPlayerAccounts[i].money
	end

	for i=1, #xPlayerItems, 1 do
		items[xPlayerItems[i].name] = xPlayerItems[i].count
	end

	ESX.LastPlayerData[source] = {
		accounts = accounts,
		items    = items
	}
end)

RegisterServerEvent('esx:clientLog')
AddEventHandler('esx:clientLog', function(msg)
	RconPrint(msg .. "\n")
end)

RegisterServerEvent('esx:triggerServerCallback')
AddEventHandler('esx:triggerServerCallback', function(name, requestId, ...)
	local _source = source
	ESX.TriggerServerCallback(name, requestID, _source, function(...)
		TriggerClientEvent('esx:serverCallback', _source, requestId, ...)
	end, ...)
end)
