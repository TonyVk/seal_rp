ESX = nil
local Grebalice = {}
local COruzje = {}
--local LotoBrojevi = {}
--local Igraci = {}
local Zvukovi = {}
local Kontenjer = {}
local Vozila = {}

local arrayWeight = {}
local VehicleList = {}
local Tablice = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterNetEvent("prodajoruzje:Posalji")
AddEventHandler('prodajoruzje:Posalji', function(id, oruzje, cijena, ammo, pid)
	TriggerClientEvent("prodajoruzje:Saljem", id, oruzje, cijena, ammo, pid)
end)

RegisterNetEvent("prodajoruzje:PosaljiAdmOdgovor")
AddEventHandler('prodajoruzje:PosaljiAdmOdgovor', function(id, odg)
	local xPlayer = ESX.GetPlayerFromId(id)
	if xPlayer ~= nil then
		TriggerClientEvent("prodajoruzje:VratiAdmOdgovor", id, odg)
	else
		TriggerClientEvent('esx:showNotification', source, "Igrac nije online!")
	end
end)

MySQL.ready(function()
	MySQL.Async.fetchAll(
        'SELECT name, weight FROM items', {},
        function(result)
            if result ~= nil and #result > 0 then
                for _, v in pairs(result) do
					table.insert(arrayWeight, {Item = v.name, Tezina = v.weight})
                end
				TriggerClientEvent("gepek:EoTiTezine", -1, arrayWeight)
            end
		end
	)
end)

ESX.RegisterServerCallback('esx_truck:checkvehicle', function(source, cb, vehicleplate)
    local isFound = false
    local _source = source
    local plate = vehicleplate
	local moze = true
	for a = 1, #Tablice, 1 do
        if Tablice[a].plate == plate then
			if Tablice[a].id ~= _source then
				if GetGameTimer()-Tablice[a].vrijeme < 2000 then
					moze = false
				end
			end
		end
	end
	if moze then
		if plate ~= " " or plate ~= nil or plate ~= "" then
			for _, v in pairs(VehicleList) do
				if (plate == v.vehicleplate) then
					isFound = true
					break
				end
			end
		else
			isFound = true
		end
	else
		isFound = true
	end
    cb(isFound)
end)

function putInTrunk(plate, qtty, item, name, itemType, ownedV)
    MySQL.Async.execute('INSERT INTO truck_inventory (item,count,plate,name,itemt,owned) VALUES (@item,@qty,@plate,@name,@itemt,@owned) ON DUPLICATE KEY UPDATE count=count+ @qty',
        {
            ['@plate'] = plate,
            ['@qty'] = qtty,
            ['@item'] = item,
            ['@name'] = name,
            ['@itemt'] = itemType,
            ['@owned'] = ownedV,
        })
end

RegisterServerEvent('gepeke:addInventoryItem')
AddEventHandler('gepeke:addInventoryItem', function(type, model, plate, item, qtty, name, itemType, ownedV)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    
    if plate ~= " " or plate ~= nil or plate ~= "" then
        
        if xPlayer ~= nil then
            if itemType == 'item_standard' then
                local playerItemCount = xPlayer.getInventoryItem(item).count
                if playerItemCount >= qtty then
                    xPlayer.removeInventoryItem(item, qtty)
                    putInTrunk(plate, qtty, item, name, itemType, ownedV)
					TriggerEvent("DiscordBot:Gepek", GetPlayerName(_source).."[".._source.."] je stavio u gepek "..qtty.." "..item..". Tablica vozila: "..plate)
                else
                    TriggerClientEvent('esx:showNotification', _source, 'Kriva kolicina')
                end
            end
            
            if itemType == 'item_account' then
                local playerAccountMoney = xPlayer.getAccount(item).money
                if playerAccountMoney >= qtty then
                    xPlayer.removeAccountMoney(item, qtty)
                    putInTrunk(plate, qtty, item, name, itemType, ownedV)
					TriggerEvent("DiscordBot:Gepek", GetPlayerName(_source).."[".._source.."] je stavio u gepek "..qtty.." "..item..". Tablica vozila: "..plate)
                end
            end
            
            if itemType == 'item_weapon' then
                currentLoadout = xPlayer.getLoadout()
                for i = 1, #currentLoadout, 1 do
                    if currentLoadout[i].name == item then
                        xPlayer.removeWeapon(item, qtty)
                        if item ~= "WEAPON_HEAVYSNIPER" then
                        putInTrunk(plate, qtty, item, name, itemType, ownedV)
						TriggerEvent("DiscordBot:Gepek", GetPlayerName(_source).."[".._source.."] je stavio u gepek "..qtty.." "..item..". Tablica vozila: "..plate)
                        end
                    end
                end
            end
        end
    end
end)

ESX.RegisterServerCallback('gepek:DohvatiTezine', function(source, cb)
    cb(arrayWeight)
end)

RegisterServerEvent('gepeke:removeInventoryItem')
AddEventHandler('gepeke:removeInventoryItem', function(plate, item, itemType, count)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if plate ~= " " or plate ~= nil or plate ~= "" then
        MySQL.Async.fetchScalar('SELECT `count` FROM truck_inventory WHERE `plate` = @plate AND `item`= @item AND `itemt`= @itemt',
            {
                ['@plate'] = plate,
                ['@item'] = item,
                ['@itemt'] = itemType
            }, function(countincar)
                if countincar >= count then
					if itemType == "item_weapon" then
						if countincar == count then
							MySQL.Async.execute('DELETE FROM `truck_inventory` WHERE `plate` = @plate AND `item`= @item AND `itemt`= @itemt', {
									['@plate'] = plate,
									['@item'] = item,
									['@itemt'] = itemType
							})
						end
					end
                    MySQL.Async.execute('UPDATE `truck_inventory` SET `count`= `count` - @qty WHERE `plate` = @plate AND `item`= @item AND `itemt`= @itemt',
                        {
                            ['@plate'] = plate,
                            ['@qty'] = count,
                            ['@item'] = item,
                            ['@itemt'] = itemType
                        })
                    if xPlayer ~= nil then
                        if itemType == 'item_standard' then
                            xPlayer.addInventoryItem(item, count)
							TriggerEvent("DiscordBot:Gepek", GetPlayerName(_source).."[".._source.."] je izvadio iz gepeka "..count.." "..item..". Tablica vozila: "..plate)
                        end
                        
                        if itemType == 'item_account' then
                            xPlayer.addAccountMoney(item, count)
							TriggerEvent("DiscordBot:Gepek", GetPlayerName(_source).."[".._source.."] je izvadio iz gepeka "..count.." "..item..". Tablica vozila: "..plate)
                        end
                        
                        if itemType == 'item_weapon' then
                            xPlayer.addWeapon(item, count)
							TriggerEvent("DiscordBot:Gepek", GetPlayerName(_source).."[".._source.."] je izvadio iz gepeka "..count.." "..item..". Tablica vozila: "..plate)
                        end
                    end
                
                end
            
            end)
    end
end)

AddEventHandler('onMySQLReady', function()
    MySQL.Async.execute('DELETE FROM `truck_inventory` WHERE `count` = 0 AND `itemt` != "item_weapon" ', {})
end)

RegisterServerEvent('gepeke:AddVehicleList')
AddEventHandler('gepeke:AddVehicleList', function(plate)
    local plateisfound = false
	local _source = source
    if plate ~= " " or plate ~= nil or plate ~= "" then
        for _, v in pairs(VehicleList) do
            if (plate == v.vehicleplate) then
                plateisfound = true
                break
            end
        end
        if not plateisfound then
            table.insert(VehicleList, {vehicleplate = plate, id = _source})
        end
		table.insert(Tablice, {plate = plate, id = _source, vrijeme = GetGameTimer()})
    end
end)

RegisterServerEvent('gepeke:RemoveVehicleList')
AddEventHandler('gepeke:RemoveVehicleList', function(plate)
    for i = 1, #VehicleList, 1 do
        if VehicleList[i].vehicleplate == plate then
            if VehicleList[i].vehicleplate ~= " " or plate ~= " " or VehicleList[i].vehicleplate ~= nil or plate ~= nil or VehicleList[i].vehicleplate ~= "" or plate ~= "" then
                table.remove(VehicleList, i)
                break
            end
        end
    end
	for a = 1, #Tablice, 1 do
		if Tablice[a] ~= nil then
			if Tablice[a].plate == plate then
				table.remove(Tablice, a)
			end
		end
	end
end)

RegisterServerEvent('gepeke:getInventory')
AddEventHandler('gepeke:getInventory', function(plate)
    local inventory_ = {}
    local _source = source
	local moze = true
	for a = 1, #Tablice, 1 do
        if Tablice[a].plate == plate then
			if Tablice[a].id ~= _source then
				if GetGameTimer()-Tablice[a].vrijeme < 2000 then
					moze = false
				end
			end
		end
	end
	if moze then
		MySQL.Async.fetchAll(
			'SELECT item, count, name, itemt FROM `truck_inventory` WHERE `plate` = @plate',
			{
				['@plate'] = plate
			},
			function(inventory)
				if inventory ~= nil and #inventory > 0 then
					for i = 1, #inventory, 1 do
						if inventory[i].itemt ~= "item_weapon" then
							if inventory[i].count > 0 then
								table.insert(inventory_, {
									label = inventory[i].name,
									name = inventory[i].item,
									count = inventory[i].count,
									type = inventory[i].itemt
								})
							end
						else
							table.insert(inventory_, {
								label = inventory[i].name,
								name = inventory[i].item,
								count = inventory[i].count,
								type = inventory[i].itemt
							})
						end
					end
				end
				local weight = (getInventoryWeight(inventory_))
				local xPlayer = ESX.GetPlayerFromId(_source)
				TriggerClientEvent('gepeke:getInventoryLoaded', xPlayer.source, inventory_, weight)
			end)
	end
end)

function getInventoryWeight(inventory)
    local weight = 0
    local itemWeight = 0
    
    if inventory ~= nil then
        for i = 1, #inventory, 1 do
            if inventory[i] ~= nil then
                itemWeight = Config.DefaultWeight
				for a = 1, #arrayWeight, 1 do
					if arrayWeight[a].Item == inventory[i].name and arrayWeight[a].Tezina > 0 then
						itemWeight = arrayWeight[a].Tezina
					end
				end
                weight = weight + (itemWeight * inventory[i].count)
            end
        end
    end
    return weight
end

--[[AddEventHandler("playerEnteredScope", function(data)
    local playerEntering, player = data["player"], data["for"]
	local veh = GetVehiclePedIsIn(GetPlayerPed(player))
	local net = NetworkGetNetworkIdFromEntity(veh)
	for i = 1, #Zvukovi do
		if Zvukovi[i].netid == net then
			TriggerClientEvent("vozila:NoviZvuk", -1, tonumber(player), net, Zvukovi[i].zvuk)
			break
		end
	end
end)]]

RegisterServerEvent('gepeke:getOwnedVehicule')
AddEventHandler('gepeke:getOwnedVehicule', function()
    local vehicules = {}
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    MySQL.Async.fetchAll(
        'SELECT vehicle FROM owned_vehicles WHERE owner = @owner',
        {
            ['@owner'] = xPlayer.getID()
        },
        function(result)
            if result ~= nil and #result > 0 then
                for _, v in pairs(result) do
                    local vehicle = json.decode(v.vehicle)
                    table.insert(vehicules, {plate = vehicle.plate})
                end
            end
            TriggerClientEvent('gepeke:setOwnedVehicule', _source, vehicules)
        end)
end)

RegisterNetEvent("esx_joblisting:setJob")
AddEventHandler('esx_joblisting:setJob', function(id)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	xPlayer.setPosao(id)
end)

ESX.RegisterUsableItem('autobomba', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.getInventoryItem('autobomba').count > 0 then
        TriggerClientEvent('RNG_CarBomb:CheckIfRequirementsAreMet', source)
    end
end)

RegisterServerEvent('RNG_CarBomb:RemoveBombFromInv')
AddEventHandler('RNG_CarBomb:RemoveBombFromInv', function()
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer.getInventoryItem('autobomba').count > 0 then
        xPlayer.removeInventoryItem('autobomba', 1)
    end
end)

RegisterServerEvent('bomba:KupiBombu')
AddEventHandler('bomba:KupiBombu', function(torba)
    local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer.getMoney() >= 200000 then
		local koda = xPlayer.getInventoryItem('autobomba')
		if torba then
			if koda.limit ~= -1 and koda.count >= koda.limit*2 then
				TriggerClientEvent('esx:showNotification', source, "Ne stane vam vise bombi!")
			else
				xPlayer.addInventoryItem('autobomba', 1)
				xPlayer.removeMoney(200000)
			end
		else
			if koda.limit ~= -1 and koda.count >= koda.limit then
				TriggerClientEvent('esx:showNotification', source, "Ne stane vam vise bombi!")
			else
				xPlayer.addInventoryItem('autobomba', 1)
				xPlayer.removeMoney(200000)
			end
		end
	else
		TriggerClientEvent('esx:showNotification', source, "Nemate dovoljno novca!")
	end
end)

RegisterServerEvent('bomba:SpremiVozilo')
AddEventHandler('bomba:SpremiVozilo', function(tablica)
    table.insert(Vozila, {Tablica = tablica})
end)

RegisterServerEvent('bomba:MakniVozilo')
AddEventHandler('bomba:MakniVozilo', function(tablica)
	for i=#Vozila, 1, -1 do
		if Vozila[i] ~= nil then
			if Vozila[i].Tablica == tablica then
				table.remove(Vozila, i)
			end
		end
	end
end)

ESX.RegisterServerCallback('bomba:ProvjeriVozilo', function(source, cb, tablica)
	for i=1, #Vozila, 1 do
		if Vozila[i] ~= nil then
			if Vozila[i].Tablica == tablica then
				cb(true)
				break
			end
		end
	end
	cb(false)
end)

RegisterNetEvent("vozila:PromjeniZvuk")
AddEventHandler('vozila:PromjeniZvuk', function(id, netid, zvuk)
	local naso = false
	for i = 1, #Zvukovi do
		if Zvukovi[i].netid == netid then
			Zvukovi[i].zvuk = zvuk
			naso = true
			break
		end
	end
	if not naso then
		table.insert(Zvukovi, {netid = netid, zvuk = zvuk})
	end
	TriggerClientEvent("vozila:NoviZvuk", -1, id, netid, zvuk)
end)

local function TableToString(tab)
	local str = ""
	for i = 1, #tab do
		str = str .. " " .. tab[i]
	end
	return str
end

RegisterCommand('ss3', function(source, args)
    exports['screenshot-basic']:requestClientScreenshot(GetPlayers()[1], {
		fileName = 'cache/screenshot.jpg'
	}, function(err, data)
		print('err', err)
		print('data', data)
	end)
end)

RegisterNetEvent("prodajoruzje:TestSkinaa")
AddEventHandler('prodajoruzje:TestSkinaa', function(id)
	TriggerClientEvent("prodajoruzje:TestSkina", id)
end)

RegisterCommand("testpitanje", function(source, args, rawCommandString)
	TriggerClientEvent("upit:OtvoriPitanje", 2, "prodajoruzje", "Alkotest", "Jel Ficho pijan?")
end, false)

-- Commands
TriggerEvent('es:addGroupCommand', 'askin', 'admin', function(source, args, user)
	if args and args[1] then
		TriggerClientEvent('esx_skin:openSaveableMenu', args[1])
	end
end, function(source, args, user)
	TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Insufficient Permissions.' } })
end, {help = "Otvori skin menu"})

RegisterServerEvent("SpremiLog")
AddEventHandler("SpremiLog", function(tekst)
 filea = io.open("Logovi.txt", "a")
    if filea then
        filea:write(tekst.."\n")
		filea:close()
    end
end)

function GetRPName(ident, data)
	local Identifier = ident

	MySQL.Async.fetchAll("SELECT firstname, lastname FROM users WHERE identifier = @identifier", { ["@identifier"] = Identifier }, function(result)
		data(result[1].firstname, result[1].lastname)
	end)
end

ESX.RegisterServerCallback('prodajoruzje:DohvatiRPIme', function(source, cb, id)
	local xPlayer = ESX.GetPlayerFromId(id)

	MySQL.Async.fetchAll("SELECT ID, firstname, lastname FROM users WHERE ID = @identifier", { ["@identifier"] = xPlayer.getID() }, function(result)
		cb(result[1].firstname.." "..result[1].lastname)
	end)
end)

ESX.RegisterServerCallback('prodajoruzje:ProvjeriKontenjer', function(source, cb, koord)
	local morel = true
	for i = 1, #Kontenjer do
		if #(Kontenjer[i]-koord) <= 2.0 then
			morel = false
			break
		end
	end
	if morel then
		local xPlayer = ESX.GetPlayerFromId(source)
		local item = xPlayer.getInventoryItem("sarafciger")
		if item.count >= 1 then
			local xPlayer = ESX.GetPlayerFromId(source)
			xPlayer.removeInventoryItem("sarafciger", 1)
		else
			morel = 2
		end
	end
	cb(morel)
end)

RegisterNetEvent("prodajoruzje:DajKontenjer")
AddEventHandler('prodajoruzje:DajKontenjer', function(koord)
	table.insert(Kontenjer, koord)
end)

local randItemi = {
	"absinthe",
	1,
	1,
	1,
	1,
	1,
	"bandage",
	1,
	1,
	1,
	1,
	"cocaine",
	1,
	1,
	1,
	1,
	1,
	1,
	"lighter",
	1,
	1,
	1,
	1,
	"water",
	1,
	1,
	1,
	1,
	"ukosnica",
	1,
	1,
	1,
	1,
	1
}

RegisterNetEvent("kont:DajItema")
AddEventHandler('kont:DajItema', function(koord)
	local rand = math.random(1, #randItemi)
	local xPlayer = ESX.GetPlayerFromId(source)
	if randItemi[rand] ~= 1 then
		local item = xPlayer.getInventoryItem(randItemi[rand])
		if item.limit == -1 or item.count < item.limit then
			xPlayer.showNotification("Pronasli ste "..item.label)
			xPlayer.addInventoryItem(randItemi[rand], 1)
		else
			xPlayer.showNotification("Niste pronasli nista!")
		end
	else
		xPlayer.showNotification("Niste pronasli nista!")
	end
end)

AddEventHandler('esx:playerDropped', function(playerID, reason)
	for _, v in pairs(VehicleList) do
        if (playerID == v.id) then
			TriggerEvent('gepeke:RemoveVehicleList', v.vehicleplate)
            break
        end
    end
end)

-- AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
-- 	MySQL.Async.fetchAll("SELECT ID, firstname, lastname FROM users WHERE ID = @identifier", { ["@identifier"] = xPlayer.getID() }, function(result)
-- 		MySQL.Async.fetchAll("SELECT VlasnikID, PrijateljID FROM prijatelji WHERE VlasnikID = @identifier or PrijateljID = @identifier", { ["@identifier"] = result[1].ID }, function(result2)
-- 			table.insert(Igraci, {id = xPlayer.source, uID = result[1].ID, name = "Stranac_"..result[1].ID, name2 = result[1].firstname.." "..result[1].lastname, prijatelji = result2})
-- 			TriggerClientEvent("tagovi:Igraci", -1, Igraci)
-- 		end)
-- 	end)
-- end)

-- AddEventHandler('esx:playerDropped', function(playerId)
-- 	for i = 1, #Igraci do
-- 		if Igraci[i] ~= nil then
-- 			if Igraci[i].id == playerId then
-- 				table.remove(Igraci, i)
-- 			end
-- 		end
-- 	end
-- end)

-- AddEventHandler('onResourceStart', function(resource)
-- 	if resource == GetCurrentResourceName() then
-- 		Citizen.CreateThread(function()
-- 			Citizen.Wait(1000)
-- 			local players = ESX.GetPlayers()
-- 			local br = 0
-- 			for i=1, #players, 1 do
-- 				local xPlayer = ESX.GetPlayerFromId(players[i])
-- 				MySQL.Async.fetchAll("SELECT ID, firstname, lastname FROM users WHERE ID = @identifier", { ["@identifier"] = xPlayer.getID() }, function(result)
-- 					MySQL.Async.fetchAll("SELECT VlasnikID, PrijateljID FROM prijatelji WHERE VlasnikID = @identifier or PrijateljID = @identifier", { ["@identifier"] = result[1].ID }, function(result2)
-- 						table.insert(Igraci, {id = xPlayer.source, uID = result[1].ID, name = "Stranac_"..result[1].ID, name2 = result[1].firstname.." "..result[1].lastname, prijatelji = result2})
-- 						br = br+1
-- 						if br >= #players then
-- 							TriggerClientEvent("tagovi:Igraci", -1, Igraci)
-- 						end
-- 					end)
-- 				end)
-- 			end
-- 		end)
-- 	end
-- end)

-- RegisterNetEvent("prodajoruzje:Upoznaj1")
-- AddEventHandler('prodajoruzje:Upoznaj1', function(id)
-- 	local src = source
-- 	TriggerClientEvent("upit:OtvoriPitanje", id, "prodajoruzje", "Upoznavanje", "Želite li se upoznati?", src)
-- end)

-- RegisterNetEvent("prodajoruzje:Upoznaj")
-- AddEventHandler('prodajoruzje:Upoznaj', function(id)
-- 	local src = source
-- 	local jaPlayer = ESX.GetPlayerFromId(src)
-- 	local xPlayer = ESX.GetPlayerFromId(id)
-- 	local nemoze = false
-- 	for a = 1, #Igraci do
-- 		if Igraci[a] ~= nil then
-- 			if Igraci[a].id == src or Igraci[a].id == id then
-- 				for g = 1, #Igraci[a].prijatelji do
-- 					if (Igraci[a].prijatelji[g].PrijateljID == jaPlayer.getID() and Igraci[a].prijatelji[g].VlasnikID == xPlayer.getID()) or (Igraci[a].prijatelji[g].PrijateljID == xPlayer.getID() and Igraci[a].prijatelji[g].VlasnikID == jaPlayer.getID()) then
-- 						nemoze = true
-- 					end
-- 				end
-- 			end
-- 		end
-- 	end
-- 	if not nemoze then
-- 		for i = 1, #Igraci do
-- 			if Igraci[i] ~= nil then
-- 				if Igraci[i].id == src then
-- 					table.remove(Igraci, i)
-- 				end
-- 			end
-- 		end
-- 		for i = 1, #Igraci do
-- 			if Igraci[i] ~= nil then
-- 				if Igraci[i].id == id then
-- 					table.remove(Igraci, i)
-- 				end
-- 			end
-- 		end
-- 		MySQL.Async.fetchAll("insert into prijatelji(VlasnikID, PrijateljID) values(@id1, @id2)", { ["@id1"] = jaPlayer.getID(), ["@id2"] = xPlayer.getID() }, function(result2)
-- 			MySQL.Async.fetchAll("SELECT ID, firstname, lastname FROM users WHERE ID = @identifier", { ["@identifier"] = jaPlayer.getID() }, function(result)
-- 				MySQL.Async.fetchAll("SELECT VlasnikID, PrijateljID FROM prijatelji WHERE VlasnikID = @identifier or PrijateljID = @identifier", { ["@identifier"] = result[1].ID }, function(result2)
-- 					table.insert(Igraci, {id = jaPlayer.source, uID = result[1].ID, name = "Stranac_"..result[1].ID, name2 = result[1].firstname.." "..result[1].lastname, prijatelji = result2})
-- 					MySQL.Async.fetchAll("SELECT ID, firstname, lastname FROM users WHERE ID = @identifier", { ["@identifier"] = xPlayer.getID() }, function(result)
-- 						MySQL.Async.fetchAll("SELECT VlasnikID, PrijateljID FROM prijatelji WHERE VlasnikID = @identifier or PrijateljID = @identifier", { ["@identifier"] = result[1].ID }, function(result2)
-- 							table.insert(Igraci, {id = xPlayer.source, uID = result[1].ID, name = "Stranac_"..result[1].ID, name2 = result[1].firstname.." "..result[1].lastname, prijatelji = result2})
-- 							TriggerClientEvent("tagovi:Igraci", -1, Igraci)
-- 						end)
-- 					end)
-- 				end)
-- 			end)
-- 		end)
-- 	else
-- 		jaPlayer.showNotification("Vec ste se upoznali!")
-- 		xPlayer.showNotification("Vec ste se upoznali!")
-- 	end
-- end)

RegisterNetEvent("prodajoruzje:DajSkin")
AddEventHandler('prodajoruzje:DajSkin', function(id)
	TriggerClientEvent("prodajoruzje:EoTiSkinic", id)
end)

RegisterNetEvent("SaljiTamoSkin")
AddEventHandler('SaljiTamoSkin', function(id, pid)
	TriggerClientEvent("VratiTamoSkin", id, pid)
end)

RegisterNetEvent("ObrisiSociety")
AddEventHandler('ObrisiSociety', function(soc, broj)
	local xPlayer = ESX.GetPlayerFromId(source)
	local societyAccount = nil
	TriggerEvent('esx_addonaccount:getSharedAccount', soc, function(account)
		societyAccount = account
	end)
	if societyAccount ~= nil then
		societyAccount.removeMoney(broj)
		societyAccount.save()
	else
		xPlayer.showNotification("Unesena mafija ne postoji!")
	end
end)

RegisterNetEvent("EoTiSkinara")
AddEventHandler('EoTiSkinara', function(pid, modid, id)
	local retval = NetworkGetEntityFromNetworkId(pid)
	local str = "Server model: "..GetEntityModel(retval).." Mod ID igrac: "..modid
	TriggerClientEvent('chat:addMessage', id, { args = { '[TEST]', str } })
end)

ESX.RegisterUsableItem("petarde", function(source)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	xPlayer.removeInventoryItem("petarde", 1)
	TriggerClientEvent('prodajoruzje:petarde', _source)
end)

ESX.RegisterUsableItem("ktijelo", function(source)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local kc = xPlayer.getInventoryItem("kcijev").count
	local kk = xPlayer.getInventoryItem("kkundak").count
	local kt = xPlayer.getInventoryItem("ktijelo").count
	local cl = xPlayer.getInventoryItem("clip").count
	if kc > 0 and kk > 0 and kt > 0 and cl > 0 then
		COruzje[_source] = true
		TriggerClientEvent("esx_invh:closeinv", _source)
		TriggerClientEvent('prodajoruzje:SloziOruzje', _source, 0)
	else
		xPlayer.showNotification("Fali vam jedan od dijelova!")
	end
end)

ESX.RegisterUsableItem("ctijelo", function(source)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local kc = xPlayer.getInventoryItem("ccijev").count
	local kk = xPlayer.getInventoryItem("ckundak").count
	local kt = xPlayer.getInventoryItem("ctijelo").count
	local cl = xPlayer.getInventoryItem("clip").count
	if kc > 0 and kk > 0 and kt > 0 and cl > 0 then
		COruzje[_source] = true
		TriggerClientEvent("esx_invh:closeinv", _source)
		TriggerClientEvent('prodajoruzje:SloziOruzje', _source, 1)
	else
		xPlayer.showNotification("Fali vam jedan od dijelova!")
	end
end)

ESX.RegisterUsableItem("stijelo", function(source)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local kc = xPlayer.getInventoryItem("scijev").count
	local kk = xPlayer.getInventoryItem("skundak").count
	local kt = xPlayer.getInventoryItem("stijelo").count
	local cl = xPlayer.getInventoryItem("clip").count
	if kc > 0 and kk > 0 and kt > 0 and cl > 0 then
		COruzje[_source] = true
		TriggerClientEvent("esx_invh:closeinv", _source)
		TriggerClientEvent('prodajoruzje:SloziOruzje', _source, 2)
	else
		xPlayer.showNotification("Fali vam jedan od dijelova!")
	end
end)

ESX.RegisterUsableItem("smtijelo", function(source)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local kc = xPlayer.getInventoryItem("smcijev").count
	local kk = xPlayer.getInventoryItem("smkundak").count
	local kt = xPlayer.getInventoryItem("smtijelo").count
	local cl = xPlayer.getInventoryItem("clip").count
	if kc > 0 and kk > 0 and kt > 0 and cl > 0 then
		COruzje[_source] = true
		TriggerClientEvent("esx_invh:closeinv", _source)
		TriggerClientEvent('prodajoruzje:SloziOruzje', _source, 3)
	else
		xPlayer.showNotification("Fali vam jedan od dijelova!")
	end
end)

ESX.RegisterUsableItem("grebalica", function(source)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local oprema = xPlayer.getInventoryItem("grebalica").count
	if oprema > 0 then
		TriggerClientEvent("esx_invh:closeinv", _source)
		Grebalice[_source] = true
		xPlayer.removeInventoryItem("grebalica", 1)
		TriggerClientEvent('prodajoruzje:grebalica', _source)
	else
		xPlayer.showNotification("Fali vam jedan od dijelova!")
	end
end)

RegisterNetEvent("prodajoruzje:KoiKuracJeOvo")
AddEventHandler('prodajoruzje:KoiKuracJeOvo', function(br)
	local src = source
	if Grebalice[src] then
		local xPlayer = ESX.GetPlayerFromId(src)
		if br == 19 then
			xPlayer.addMoney(10)
		elseif br == 25 then
			xPlayer.addMoney(5)
		elseif br == 30 then
			xPlayer.addMoney(500)
		elseif br == 35 then
			xPlayer.addMoney(25)
		elseif br == 40 then
			xPlayer.addMoney(50)
		elseif br == 33 then
			xPlayer.addInventoryItem("burek", 1)
		elseif br == 37 then
			xPlayer.addInventoryItem("kola", 1)
		end
		Grebalice[src] = false
	else
		TriggerEvent("DiscordBot:Anticheat", GetPlayerName(src).."["..src.."] je pokusao pozvati event za nagradu grebalice, a nije iskoristio grebalicu!")
	    TriggerEvent("AntiCheat:Citer", src)
	end
end)

RegisterNetEvent("prodajoruzje:KoiKuracJeOvo2")
AddEventHandler('prodajoruzje:KoiKuracJeOvo2', function(br)
	local src = source
	if COruzje[src] then
		local xPlayer = ESX.GetPlayerFromId(src)
		if br == 0 then
			xPlayer.removeInventoryItem("kcijev", 1)
			xPlayer.removeInventoryItem("kkundak", 1)
			xPlayer.removeInventoryItem("ktijelo", 1)
			xPlayer.removeInventoryItem("clip", 1)
			xPlayer.addWeapon("weapon_assaultrifle", 250)
		elseif br == 1 then
			xPlayer.removeInventoryItem("ccijev", 1)
			xPlayer.removeInventoryItem("ckundak", 1)
			xPlayer.removeInventoryItem("ctijelo", 1)
			xPlayer.removeInventoryItem("clip", 1)
			xPlayer.addWeapon("weapon_carbinerifle", 250)
		elseif br == 2 then
			xPlayer.removeInventoryItem("scijev", 1)
			xPlayer.removeInventoryItem("skundak", 1)
			xPlayer.removeInventoryItem("stijelo", 1)
			xPlayer.removeInventoryItem("clip", 1)
			xPlayer.addWeapon("weapon_specialcarbine", 250)
		elseif br == 3 then
			xPlayer.removeInventoryItem("smcijev", 1)
			xPlayer.removeInventoryItem("smkundak", 1)
			xPlayer.removeInventoryItem("smtijelo", 1)
			xPlayer.removeInventoryItem("clip", 1)
			xPlayer.addWeapon("weapon_smg", 250)
		end
		COruzje[src] = false
	else
		TriggerEvent("DiscordBot:Anticheat", GetPlayerName(src).."["..src.."] je pokusao pozvati event za craft oruzja, a nije iskoristio dijelove!")
	    TriggerEvent("AntiCheat:Citer", src)
	end
end)

ESX.RegisterServerCallback('kraft:ProvjeriKolicinu', function(source, cb, item)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	local morel = false
	if xPlayer.getInventoryItem(item).count+1 <= xPlayer.getInventoryItem(item).limit then
		if item == "kkundak"then
			if xPlayer.getInventoryItem("iron").count >= 5 then
				xPlayer.removeInventoryItem("iron", 5)
				morel = true
				COruzje[src] = true
			end
		elseif item == "ckundak"then
			if xPlayer.getInventoryItem("iron").count >= 10 then
				xPlayer.removeInventoryItem("iron", 10)
				morel = true
				COruzje[src] = true
			end
		elseif item == "skundak"then
			if xPlayer.getInventoryItem("iron").count >= 15 then
				xPlayer.removeInventoryItem("iron", 15)
				morel = true
				COruzje[src] = true
			end
		elseif item == "smkundak"then
			if xPlayer.getInventoryItem("iron").count >= 4 then
				xPlayer.removeInventoryItem("iron", 4)
				morel = true
				COruzje[src] = true
			end
		end
	end
	cb(morel)
end)

ESX.RegisterServerCallback('kraft:ProvjeriKolicinu2', function(source, cb, item)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	local morel = false
	if xPlayer.getInventoryItem(item).count+1 <= xPlayer.getInventoryItem(item).limit then
		if item == "kcijev"then
			if xPlayer.getMoney() >= 5000 then
				xPlayer.removeMoney(5000)
				xPlayer.addInventoryItem("kcijev", 1)
				morel = true
			end
		elseif item == "ccijev"then
			if xPlayer.getMoney() >= 6000 then
				xPlayer.removeMoney(6000)
				xPlayer.addInventoryItem("ccijev", 1)
				morel = true
			end
		elseif item == "scijev"then
			if xPlayer.getMoney() >= 7000 then
				xPlayer.removeMoney(7000)
				xPlayer.addInventoryItem("scijev", 1)
				morel = true
			end
		elseif item == "smcijev"then
			if xPlayer.getMoney() >= 4000 then
				xPlayer.removeMoney(4000)
				xPlayer.addInventoryItem("smcijev", 1)
				morel = true
			end
		end
	end
	cb(morel)
end)

local skupljanje = vector3(59.282123565674, -774.98114013672, 17.823108673096)
RegisterNetEvent("kraft:SkupiGa")
AddEventHandler('kraft:SkupiGa', function()
	local src = source
	local koord = GetEntityCoords(GetPlayerPed(src))
	if #(koord-skupljanje) <= 15.0 then
		local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer.getInventoryItem("iron").count+1 <= xPlayer.getInventoryItem("iron").limit then
		     xPlayer.addInventoryItem("iron", 1)
        else
			xPlayer.showNotification("Ne stane vam vise u inventory")
		end
	else
		TriggerEvent("DiscordBot:Anticheat", GetPlayerName(src).."["..src.."] je pokusao pozvati event za dobijanje zeljeza, a nije blizu lokacije skupljanja!")
	    TriggerEvent("AntiCheat:Citer", src)
	end
end)

RegisterNetEvent("kraft:DajKundak")
AddEventHandler('kraft:DajKundak', function(item)
	local src = source
	if COruzje[src] then
		local xPlayer = ESX.GetPlayerFromId(src)
		xPlayer.addInventoryItem(item, 1)
		COruzje[src] = false
	else
		TriggerEvent("DiscordBot:Anticheat", GetPlayerName(src).."["..src.."] je pokusao pozvati event za preradu zeljeza u kundak, a nije zapoceo sa preradom!")
	    --TriggerEvent("AntiCheat:Citer", src)
	end
end)

ESX.RegisterUsableItem("petarda", function(source)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	xPlayer.removeInventoryItem("petarda", 1)
	TriggerClientEvent('prodajoruzje:petarde', _source)
end)

ESX.RegisterServerCallback('prodajoruzje:DajNovac', function(source, cb, target)
	local tar = ESX.GetPlayerFromId(target)
	local missingMoney = tar.getMoney()
	cb(missingMoney)
end)

function mTOh(mins)
    return {sat = math.floor(mins/60), minuta = (mins%60)}
end

ESX.RegisterServerCallback('minute:DohvatiSate', function(source, cb)
	local elements = {}
	MySQL.Async.fetchAll('SELECT identifier, minute FROM minute ORDER BY minute DESC', {}, function(result)
		MySQL.Async.fetchAll('SELECT ID, name FROM users', {}, function(result2)
			for i=1, #result, 1 do
				for j=1, #result2, 1 do
					if result[i].identifier == result2[j].ID then
						local str
						local ime = "Glupo ime"
						if result[i].minute < 60 then
							if result2[j].name ~= nil then
								str = result2[j].name.." ("..result[i].minute.." minuta)"
							else
								str = ime.." ("..result[i].minute.." minuta)"
							end
						else
							if result2[j].name ~= nil then
								str = result2[j].name.." ("..mTOh(result[i].minute).sat.."h i "..mTOh(result[i].minute).minuta.."min)"
							else
								str = ime.." ("..mTOh(result[i].minute).sat.."h i "..mTOh(result[i].minute).minuta.."min)"
							end
						end
						table.insert(elements, { label = str, value = "nema" })
					end
				end
			end
			cb(elements)
		end)
	end)
end)

function getIdentity(source)
	local identifier = GetPlayerIdentifiers(source)[1]
	local result = MySQL.Sync.fetchAll("SELECT * FROM users WHERE identifier = @identifier", {['@identifier'] = identifier})
	if result[1] ~= nil then
		local identity = result[1]

		return {
			identifier = identity['identifier'],
			firstname = identity['firstname'],
			lastname = identity['lastname'],
			dateofbirth = identity['dateofbirth'],
			sex = identity['sex'],
			height = identity['height']
			
		}
	else
		return nil
	end
end

function CronTask(d, h, m)
	local dan = os.date("%d")
	if dan == "01" then
		MySQL.Async.execute('DELETE FROM minute', {})
	end
end
TriggerEvent('cron:runAt', 0, 0, "BrisiMinute", CronTask)

RegisterNetEvent("minute:SpremiIh")
AddEventHandler('minute:SpremiIh', function(minute)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	MySQL.Async.fetchAll('SELECT minute FROM minute WHERE identifier = @identifier', {['@identifier'] = xPlayer.getID()}, function(result)
		if result[1] == nil then
			MySQL.Async.execute('INSERT INTO minute (identifier, minute) VALUES (@ident, @mina)',
			{
				['@ident'] = xPlayer.getID(),
				['@mina']  = 5
			})
		else
			MySQL.Async.execute('UPDATE minute SET minute = @minute WHERE identifier = @ident', {
				['@ident'] = xPlayer.getID(),
				['@minute'] = result[1].minute+5
			})
		end
	end)
end)

--[[ESX.RegisterUsableItem('ronjenje', function(source)
	print(GetPlayerPed(source))
	local xPlayer = ESX.GetPlayerFromId(source)
	local oprema = xPlayer.getInventoryItem("ronjenje").count
	if oprema > 0 then
		TriggerClientEvent('ronjenje:PocniRonit', source)
	else
		xPlayer.showNotification("Nemate opremu za ronjenje!")
	end
end)]]
	
RegisterCommand("prebacimodele", function(source, args, rawCommandString)
	MySQL.Async.fetchAll("SELECT vehicle, state, plate FROM owned_vehicles",{}, function(data) 
		for _,v in pairs(data) do
			local vehicle = json.decode(v.vehicle)
			MySQL.Async.execute('UPDATE owned_vehicles SET model = @mod WHERE plate = @tab', {
				['@mod']   = vehicle.model,
				['@tab']   = vehicle.plate,
			}, function(rowsChanged)
				print(rowsChanged)
			end)
		end
	end)
end, false)

RegisterCommand("ispisip", function(source, args, rawCommandString)
		local elements = {}
		MySQL.Async.fetchAll('SELECT identifier FROM priority', {}, function(result)
			MySQL.Async.fetchAll('SELECT identifier, name FROM users', {}, function(result2)
				for i=1, #result, 1 do
					for j=1, #result2, 1 do
						if result[i].identifier == result2[j].identifier then
							print("identifier:"..result2[j].identifier.." | Ime:"..result2[j].name)
						end
					end
				end
			end)
		end)
end, false)

RegisterCommand("svilideri", function(source, args, rawCommandString)
		local elements = {}
		MySQL.Async.fetchAll('SELECT name, job, job_grade FROM users', {}, function(result)
			MySQL.Async.fetchAll('SELECT job_name, grade, name FROM job_grades', {}, function(result2)
				for i=1, #result, 1 do
					for j=1, #result2, 1 do
						if result[i].job == result2[j].job_name then
							if result[i].job_grade == result2[j].grade then
								if result2[j].name == "boss" then
									local str = result[i].name.." ["..result[i].job.."]"
									table.insert(elements, { label = str, value = result[i].job })
								end
							end
						end
					end
				end
			end)
		end)
		Wait(3000)
		TriggerClientEvent("prodajoruzje:PokaziSveLidere", source, elements)
end, false)

RegisterCommand("lideri", function(source, args, rawCommandString)
		local sourceXPlayer = ESX.GetPlayerFromId(source)
		local elements = {}

		local xPlayers = ESX.GetPlayers()

		for i=1, #xPlayers, 1 do

		  local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		  if xPlayer.job.name ~= nil then
			  local gradeLabel = xPlayer.job.grade_name
			  local job = xPlayer.job.name
			  if gradeLabel == "boss" or gradeLabel == "vlasnik" then
				  local str = xPlayer.getName().." ["..job.."]"
				  table.insert(elements, { label = str, value = gradeLabel })
			  end
		  end
		end
		TriggerClientEvent("prodajoruzje:PokaziLidere", source, elements)
end, false)

RegisterCommand("clanovi", function(source, args, rawCommandString)
		local sourceXPlayer = ESX.GetPlayerFromId(source)
		local elements = {}

		local xPlayers = ESX.GetPlayers()

		for i=1, #xPlayers, 1 do

		  local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		  if xPlayer ~= nil then
			  if xPlayer.job.name == sourceXPlayer.job.name then
				local gradeLabel = (xPlayer.job.grade_label == '' and xPlayer.job.label or xPlayer.job.grade_label)
				local ime = "Glupo ime"
				local str
				if xPlayer.getName() == nil then
					str = str.." ["..gradeLabel.."]"
				else
					str = xPlayer.getName().." ["..gradeLabel.."]"
				end
				table.insert(elements, { label = str, value = gradeLabel })
			  end
		  end
		end
		TriggerClientEvent("prodajoruzje:PokaziClanove", source, elements)
end, false)

local OdradioPerm = {}

RegisterCommand("perm", function(source, args, rawCommandString)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	if xPlayer.identifier == "steam:11000010a1d1042" or xPlayer.identifier == "steam:11000010441bee9" then
		if OdradioPerm[src] == nil or OdradioPerm[src] == false then
			OdradioPerm[src] = true
			TriggerEvent("es:setPlayerData", src, "permission_level", 0, function(response, success)
				xPlayer.showNotification("Skinute su ti permisije hehe")
			end)
		else
			OdradioPerm[src] = false
			TriggerEvent("es:setPlayerData", src, "permission_level", 69, function(response, success)
				xPlayer.showNotification("Vracene su ti permisije hehe")
			end)
		end
	else
		xPlayer.showNotification("Ti mi ne licis na chameta :(")
	end
end, false)

local OdradioChamango = {}

RegisterCommand("chamango", function(source, args, rawCommandString)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	if xPlayer.identifier == "steam:11000010a1d1042" or xPlayer.identifier == "steam:11000010441bee9" then
		if OdradioChamango[src] == nil or OdradioChamango[src] == false then
			OdradioChamango[src] = true
			TriggerClientEvent("prodajoruzje:SetajChameSkin", src, tonumber(args[1]), true)
		else
			OdradioChamango[src] = false
			TriggerClientEvent("prodajoruzje:SetajChameSkin", src, tonumber(args[1]), false)
		end
	else
		xPlayer.showNotification("Ti mi ne licis na chameta :(")
	end
end, false)

RegisterCommand("r", function(source, args, rawCommandString)
	local br = 0
	local targetXPlayer = ESX.GetPlayerFromId(source)
	if targetXPlayer.job.name == 'police' or targetXPlayer.job.name == 'mechanic' then
		br = 1
	end
	if br == 1 then
				if args[1] ~= nil then
					local name = getIdentity(source)
		 		 	local fal = name.firstname .. " " .. name.lastname
					TriggerClientEvent("prodajoruzje:PosaljiRadio", -1, table.concat(args, " "), fal, targetXPlayer.job.name)
				else
					name = "System"..":"
					message = "/r [Poruka]"
					TriggerClientEvent('chat:addMessage', source, { args = { name, message }, color = r,g,b })
				end	
	else
		name = "System"..":"
		message = " Nemate pristup ovoj komandi"
		TriggerClientEvent('chat:addMessage', source, { args = { name, message }, color = r,g,b })	
	end
end, false)

RegisterNetEvent('prodajoruzje:PosaljiRadio2Server')
AddEventHandler('prodajoruzje:PosaljiRadio2Server', function(arg, ime)
	TriggerClientEvent("prodajoruzje:PosaljiRadio2", -1, arg, ime)
end) 

RegisterNetEvent('prodajoruzje:SaljiInfoSvima')
AddEventHandler('prodajoruzje:SaljiInfoSvima', function(arg, ime, id)
	local ime2 = GetPlayerName(id)
	TriggerClientEvent("prodajoruzje:VratiInfoSvima", -1, arg, ime, ime2)
end) 

RegisterNetEvent("prodajoruzje:Posalji2")
AddEventHandler('prodajoruzje:Posalji2', function(id, cijena, kol, pid)
	local sourceXPlayer = ESX.GetPlayerFromId(pid)
	local kola = sourceXPlayer.getInventoryItem("marijuana").count
	if kola >= tonumber(kol) then
		TriggerClientEvent('esx:showNotification', pid, "Ponudili ste igracu drogu!")
		TriggerClientEvent("prodajoruzje:Saljem2", id, cijena, kol, pid)
	else
		TriggerClientEvent('esx:showNotification', pid, "Nemate dovoljnu kolicinu marihuane!")
	end
end)

RegisterNetEvent("prodajoruzje:Posalji3")
AddEventHandler('prodajoruzje:Posalji3', function(id, cijena, kol, pid)
	local sourceXPlayer = ESX.GetPlayerFromId(pid)
	local kola = sourceXPlayer.getInventoryItem("cocaine").count
	if kola >= tonumber(kol) then
		TriggerClientEvent('esx:showNotification', pid, "Ponudili ste igracu kokain!")
		TriggerClientEvent("prodajoruzje:Saljem3", id, cijena, kol, pid)
	else
		TriggerClientEvent('esx:showNotification', pid, "Nemate dovoljnu kolicinu kokaina!")
	end
end)

RegisterNetEvent("dajpro:oruzje")
AddEventHandler('dajpro:oruzje', function(id, oruzje, cijena, ammo, pid)
	local sourceXPlayer = ESX.GetPlayerFromId(pid)
	local targetXPlayer = ESX.GetPlayerFromId(id)
	if targetXPlayer.getMoney() >= tonumber(cijena) then
	--if not targetXPlayer.hasWeapon(oruzje) then
			sourceXPlayer.removeWeapon(oruzje)
			targetXPlayer.addWeapon(oruzje, ammo)
			sourceXPlayer.addMoney(cijena/2)
			targetXPlayer.removeMoney(cijena)
			ESX.SavePlayer(sourceXPlayer, function()
			end)
			ESX.SavePlayer(targetXPlayer, function()
			end)
			local societyAccount = nil
			local sime = "society_"..sourceXPlayer.getJob().name
			TriggerEvent('esx_addonaccount:getSharedAccount', sime, function(account)
				societyAccount = account
			end)
			societyAccount.addMoney(cijena/2)
			societyAccount.save()

			local weaponLabel = ESX.GetWeaponLabel(oruzje)
			local str = "Uspjesno ste prodali oruzje "..weaponLabel.." sa "..ammo.." metaka!"
			local str2 = "Uspjesno ste kupili oruzje "..weaponLabel.." sa "..ammo.." metaka!"
			local strm = "Uspjesno ste prodali oruzje "..weaponLabel.." bez metaka!"
			local str2m = "Uspjesno ste kupili oruzje "..weaponLabel.." bez metaka!"
			local str3 = "Pola od cijene ste dobili vi, a druga polovica je otisla bandi na racun!"
			if ammo > 0 then
				TriggerClientEvent('esx:showNotification', pid, str)
				TriggerClientEvent('esx:showNotification', id,  str2)
				TriggerClientEvent('esx:showNotification', pid,  str3)
			else
				TriggerClientEvent('esx:showNotification', pid, strm)
				TriggerClientEvent('esx:showNotification', id,  str2m)
				TriggerClientEvent('esx:showNotification', pid,  str3)
			end
	--else
		--TriggerClientEvent('esx:showNotification', pid, "Osoba vec ima to oruzje!")
		--TriggerClientEvent('esx:showNotification', id, "Vec imate to oruzje!")
	--end
	else
		TriggerClientEvent('esx:showNotification', pid, "Osoba nema dovoljno novca!")
		TriggerClientEvent('esx:showNotification', id, "Nemate dovoljno novca!")
	end
end)

RegisterNetEvent("dajpro:oruzje2")
AddEventHandler('dajpro:oruzje2', function(id, cijena, kol, pid)
	local sourceXPlayer = ESX.GetPlayerFromId(pid)
	local targetXPlayer = ESX.GetPlayerFromId(id)
	local kola = targetXPlayer.getInventoryItem("marijuana").count
	local maximum = tonumber(kol)+kola
	if maximum <= 14 then
		if targetXPlayer.getMoney() >= tonumber(cijena) then
			sourceXPlayer.removeInventoryItem("marijuana", kol)
			targetXPlayer.addInventoryItem("marijuana", kol)
			sourceXPlayer.addMoney(cijena/2)
			targetXPlayer.removeMoney(cijena)
			ESX.SavePlayer(sourceXPlayer, function()
			end)
			ESX.SavePlayer(targetXPlayer, function()
			end)
			
			local societyAccount = nil
			local sime = "society_"..sourceXPlayer.getJob().name
			TriggerEvent('esx_addonaccount:getSharedAccount', sime, function(account)
				societyAccount = account
			end)
			societyAccount.addMoney(cijena/2)
			societyAccount.save()

			local str = "Uspjesno ste prodali "..kol.."g marihuane!"
			local str2 = "Uspjesno ste kupili "..kol.."g marihuane!"
			local str3 = "Pola od cijene ste dobili vi, a druga polovica je otisla bandi na racun!"

			TriggerClientEvent('esx:showNotification', pid, str)
			TriggerClientEvent('esx:showNotification', id,  str2)
			TriggerClientEvent('esx:showNotification', pid,  str3)
		else
			TriggerClientEvent('esx:showNotification', pid, "Osoba nema dovoljno novca!")
			TriggerClientEvent('esx:showNotification', id, "Nemate dovoljno novca!")
		end
	else
		TriggerClientEvent('esx:showNotification', pid, "Osoba ce imati tada vise droge od dozvoljenoga!")
		TriggerClientEvent('esx:showNotification', id, "Imat cete vise droge od dozvoljenoga(max 14g)!")
	end
end)

RegisterNetEvent("dajpro:oruzje3")
AddEventHandler('dajpro:oruzje3', function(id, cijena, kol, pid)
	local sourceXPlayer = ESX.GetPlayerFromId(pid)
	local targetXPlayer = ESX.GetPlayerFromId(id)
	local kola = targetXPlayer.getInventoryItem("cocaine").count
	local maximum = tonumber(kol)+kola
	if maximum <= 10 then
		if targetXPlayer.getMoney() >= tonumber(cijena) then
			sourceXPlayer.removeInventoryItem("cocaine", kol)
			targetXPlayer.addInventoryItem("cocaine", kol)
			sourceXPlayer.addMoney(cijena)
			targetXPlayer.removeMoney(cijena)
			ESX.SavePlayer(sourceXPlayer, function()
			end)
			ESX.SavePlayer(targetXPlayer, function()
			end)

			local str = "Uspjesno ste prodali "..kol.."g kokaina!"
			local str2 = "Uspjesno ste kupili "..kol.."g kokaina!"

			TriggerClientEvent('esx:showNotification', pid, str)
			TriggerClientEvent('esx:showNotification', id,  str2)
		else
			TriggerClientEvent('esx:showNotification', pid, "Osoba nema dovoljno novca!")
			TriggerClientEvent('esx:showNotification', id, "Nemate dovoljno novca!")
		end
	else
		TriggerClientEvent('esx:showNotification', pid, "Osoba ce tada imati vise kokaina od dozvoljenoga!")
		TriggerClientEvent('esx:showNotification', id, "Imat cete vise kokaina od dozvoljenoga(max 10g)!")
	end
end)

RegisterNetEvent("prodajoruzje:PlatiPorez")
AddEventHandler('prodajoruzje:PlatiPorez', function(kol)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	local porez = 500
	xPlayer.removeAccountMoney('bank', kol*porez)
	TriggerEvent("banka:Povijest", xPlayer.source, (-1*tonumber(kol*porez)), "Plaćanje poreza")
	TriggerClientEvent('esx:showNotification', src, "Platili ste porez u iznosu od $"..(kol*porez))
	local soc = "society_grad"
	TriggerEvent('esx_addonaccount:getSharedAccount', soc, function(account)
		account.addMoney(kol*porez)
		account.save()
	end)
end)

-- ESX.RegisterUsableItem("loto", function(source)
-- 	local _source = source
-- 	local xPlayer = ESX.GetPlayerFromId(_source)
-- 	TriggerClientEvent('loto:IzaberiBroj', _source)
-- end)

-- RegisterNetEvent("loto:UplatiBroj")
-- AddEventHandler('loto:UplatiBroj', function(br, cijena)
-- 	local src = source
-- 	local xPlayer = ESX.GetPlayerFromId(src)
-- 	if xPlayer.getMoney() >= tonumber(cijena) then
-- 		local naso = false
-- 		for i=1, #LotoBrojevi, 1 do
-- 			if LotoBrojevi[i].Broj == tonumber(br) or LotoBrojevi[i].Ident == xPlayer.identifier then
-- 				naso = true
-- 				break
-- 			end
-- 		end
-- 		if not naso then
-- 			xPlayer.removeInventoryItem("loto", 1)
-- 			xPlayer.removeMoney(cijena)
-- 			ESX.SavePlayer(xPlayer, function()
-- 			end)
-- 			TriggerClientEvent('esx:showNotification', src, "Uplatili ste $"..tonumber(cijena).." na loto broj "..tonumber(br).."!")
-- 			table.insert(LotoBrojevi, {Ident = xPlayer.identifier, Broj = tonumber(br), Cijena = tonumber(cijena)})
-- 		else
-- 			TriggerClientEvent('esx:showNotification', src, "Broj je zauzet ili ste vec uplatili listic!")
-- 		end
-- 	else
-- 		TriggerClientEvent('esx:showNotification', src, "Nemate dovoljno novca!")
-- 	end
-- end)

-- function Loto()
-- 	TriggerClientEvent('esx:showNotification', -1, "Loto pocinje za 15 minuta, uplatite listice dok mozete!")
-- 	SetTimeout(900000, function()
-- 		local br = math.random(1,120)
-- 		TriggerClientEvent('esx:showNotification', -1, "[Loto] Izvucen je broj "..br.."!")
-- 		for i=1, #LotoBrojevi, 1 do
-- 			if LotoBrojevi[i].Broj == br then
-- 				local xPlayer = ESX.GetPlayerFromIdentifier(LotoBrojevi[i].Ident)
-- 				if xPlayer ~= nil then
-- 					xPlayer.addMoney(LotoBrojevi[i].Cijena*3)
-- 					TriggerClientEvent('esx:showNotification', xPlayer.source, "[Loto] Osvojili ste $"..(LotoBrojevi[i].Cijena*3).."! Cestitke!!")
-- 				end
-- 				break
-- 			end
-- 		end
-- 		LotoBrojevi = {}
-- 		SetTimeout(13500000, Loto)
-- 	end)
-- end

-- SetTimeout(13500000, Loto)