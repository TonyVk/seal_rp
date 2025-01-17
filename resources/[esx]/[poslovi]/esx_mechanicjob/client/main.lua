local HasAlreadyEnteredMarker, LastZone = false, nil
local CurrentAction, CurrentActionMsg, CurrentActionData = nil, '', {}
local CurrentlyTowedVehicle, Blips, NPCOnJob, NPCTargetTowable, NPCTargetTowableZone = nil, {}, false, nil, nil
local NPCHasSpawnedTowable, NPCLastCancel, NPCHasBeenNextToTowable, NPCTargetDeleterZone = false, GetGameTimer() - 5 * 60000, false, false
local isDead, isBusy = false, false
local PostavioEUP = false
local Zabranio = false

local Cijena = {}

ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	ESX.PlayerData = ESX.GetPlayerData()
end)

function SelectRandomTowable()
	local index = GetRandomIntInRange(1,  #Config.Towables)

	for k,v in pairs(Config.Zones) do
		if v.Pos.x == Config.Towables[index].x and v.Pos.y == Config.Towables[index].y and v.Pos.z == Config.Towables[index].z then
			return k
		end
	end
end

function OtvoriListuZaposlenih()
	ESX.TriggerServerCallback('esx_policejob:dohvatiZaposlene', function(datae)
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'police_bossa', {
			title    = 'Lista zaposlenih',
			align    = 'top-left',
			elements = datae
		}, function(data, menu)
			local user = data.current.value
			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'lista_akc', {
				title    = 'Boss menu',
				align    = 'top-left',
				elements = {
					{label = "Rank", value = 'rank'},
					{label = "Otpusti", value = 'otpusti'}
			}}, function(data3, menu3)
				if data3.current.value == 'rank' then
					ESX.TriggerServerCallback('esx_policejob:dohvatiRankove', function(data2)
						ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'lista_rankova', {
							title    = "Odaberite rank",
							align    = 'top-left',
							elements = data2
						}, function(data2, menu2)
							local action = data2.current.value
							TriggerServerEvent("policija:PostaviRank", user, ESX.PlayerData.job.id, action)
							menu2.close()
						end, function(data2, menu2)
							menu2.close()
						end)
					end, ESX.PlayerData.job.name)
				elseif data3.current.value == 'otpusti' then
					TriggerServerEvent("policija:OtpustiIgraca", user)
					menu3.close()
					menu.close()
					ESX.UI.Menu.CloseAll()
					OtvoriBossMenu()
				end
			end, function(data3, menu3)
				menu3.close()
			end)
		end, function(data, menu)
			menu.close()
		end)
	end, ESX.PlayerData.job.id)
end

RegisterNUICallback(
    "zatvoriupit",
    function(data, cb)
		local br = data.br
		local args = data.args
		if br == 1 then
			TriggerServerEvent("mehanicar:Zaposli2", args.posao, args.id)
		end
    end
)

function OtvoriZaposljavanje()
	ESX.TriggerServerCallback('policija:getOnlinePlayers', function(rad)
		ESX.UI.Menu.Open(
			'default', GetCurrentResourceName(), 'fdsfae',
			{
				title    = "Popis igraca",
				align    = 'bottom-right',
				elements = rad,
			},
			function(datalr2, menulr2)
				TriggerServerEvent("mehanicar:Zaposli", ESX.PlayerData.job.id, datalr2.current.value)
				menulr2.close()
				ESX.UI.Menu.CloseAll()
				OtvoriBossMenu()
			end,
			function(datalr2, menulr2)
				menulr2.close()
			end
		)
	end, ESX.PlayerData.job.id)
end

function OtvoriBossMenu()
	ESX.UI.Menu.CloseAll()
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'meh_boss', {
		title    = 'Lider menu',
		align    = 'top-left',
		elements = {
			{label = "Zaposlenici", value = 'zaposlenici'},
			{label = "Place", value = 'place'}
	}}, function(data, menu)
		if data.current.value == 'zaposlenici' then
			local elements = {
				{label = "Lista zaposlenika", value = 'lista'},
				{label = "Zaposli", value = 'zaposli'}
			}

			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'lista_zap', {
				title    = "Zaposlenici",
				align    = 'top-left',
				elements = elements
			}, function(data2, menu2)
				local action = data2.current.value

				if action == 'lista' then
					OtvoriListuZaposlenih()
				elseif action == 'zaposli' then
					OtvoriZaposljavanje()
				end
			end, function(data2, menu2)
				menu2.close()
			end)
		elseif data.current.value == 'place' then
			ESX.TriggerServerCallback('esx_policejob:dohvatiPlace', function(data2)
				ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'lista_rankovaplace', {
					title    = "Iznos placa po rankovima",
					align    = 'top-left',
					elements = data2
				}, function(data2, menu2)
					menu2.close()
				end, function(data2, menu2)
					menu2.close()
				end)
			end, ESX.PlayerData.job.name)
		end
	end, function(data, menu)
		menu.close()
		CurrentAction     = 'mechanic_actions_menu'
		CurrentActionMsg  = _U('open_actions')
		CurrentActionData = {}
	end)
end

function StartNPCJob()
	NPCOnJob = true

	NPCTargetTowableZone = SelectRandomTowable()
	local zone       = Config.Zones[NPCTargetTowableZone]

	Blips['NPCTargetTowableZone'] = AddBlipForCoord(zone.Pos.x,  zone.Pos.y,  zone.Pos.z)
	SetBlipRoute(Blips['NPCTargetTowableZone'], true)

	ESX.ShowNotification(_U('drive_to_indicated'))
end

function StopNPCJob(cancel)
	if Blips['NPCTargetTowableZone'] then
		RemoveBlip(Blips['NPCTargetTowableZone'])
		Blips['NPCTargetTowableZone'] = nil
	end

	if Blips['NPCDelivery'] then
		RemoveBlip(Blips['NPCDelivery'])
		Blips['NPCDelivery'] = nil
	end

	Config.Zones.VehicleDelivery.Type = -1

	NPCOnJob                = false
	NPCTargetTowable        = nil
	NPCTargetTowableZone    = nil
	NPCHasSpawnedTowable    = false
	NPCHasBeenNextToTowable = false

	if cancel then
		ESX.ShowNotification(_U('mission_canceled'))
	else
		--TriggerServerEvent('esx_mechanicjob:onNPCJobCompleted')
	end
end

function setUniform(job, playerPed)
	TriggerEvent('skinchanger:getSkin', function(skin)
		if skin.sex == 0 then
			if Config.Uniforms[job].EUP == false or Config.Uniforms[job].EUP == nil then
				if Config.Uniforms[job].male and PostavioEUP == false then
					TriggerEvent('skinchanger:loadClothes', skin, Config.Uniforms[job].male)
				end
			else
				local jobic = "EUP"..job
				local outfit = Config.Uniforms[jobic].male
				local ped = playerPed

				RequestModel(outfit.ped)

				while not HasModelLoaded(outfit.ped) do
					Wait(0)
				end

				if GetEntityModel(ped) ~= GetHashKey(outfit.ped) then
					SetPlayerModel(PlayerId(), outfit.ped)
				end
				SetModelAsNoLongerNeeded(outfit.ped)
				ped = PlayerPedId()

				for _, comp in ipairs(outfit.components) do
				   SetPedComponentVariation(ped, comp[1], comp[2] - 1, comp[3] - 1, 0)
				end

				for _, comp in ipairs(outfit.props) do
					if comp[2] == 0 then
						ClearPedProp(ped, comp[1])
					else
						SetPedPropIndex(ped, comp[1], comp[2] - 1, comp[3] - 1, true)
					end
				end
				PostavioEUP = true
			end
		else
			if Config.Uniforms[job].EUP == false or Config.Uniforms[job].EUP == nil then
				if Config.Uniforms[job].female  and PostavioEUP == false then
					TriggerEvent('skinchanger:loadClothes', skin, Config.Uniforms[job].female)
				end
			else
				local jobic = "EUP"..job
				local outfit = Config.Uniforms[jobic].female
				local ped = playerPed

				RequestModel(outfit.ped)

				while not HasModelLoaded(outfit.ped) do
					Wait(0)
				end

				if GetEntityModel(ped) ~= GetHashKey(outfit.ped) then
					SetPlayerModel(PlayerId(), outfit.ped)
				end
				SetModelAsNoLongerNeeded(outfit.ped)
				ped = PlayerPedId()

				for _, comp in ipairs(outfit.components) do
				   SetPedComponentVariation(ped, comp[1], comp[2] - 1, comp[3] - 1, 0)
				end

				for _, comp in ipairs(outfit.props) do
					if comp[2] == 0 then
						ClearPedProp(ped, comp[1])
					else
						SetPedPropIndex(ped, comp[1], comp[2] - 1, comp[3] - 1, true)
					end
				end
				PostavioEUP = true
			end
		end
	end)
end

function OpenMechanicActionsMenu()
	local elements = {
		{label = _U('vehicle_list'),   value = 'vehicle_list'},
		{label = _U('work_wear'),      value = 'cloakroom'},
		{label = _U('civ_wear'),       value = 'cloakroom2'},
		{label = _U('deposit_stock'),  value = 'put_stock'},
		{label = "Pregled narudzbi",   value = 'pregled_nar'},
		--{label = "Uzmi sarafciger ($500)",    value = 'saraf'}
	}

	if ESX.PlayerData.job.grade > 0 then
		table.insert(elements, {label = _U('withdraw_stock'), value = 'get_stock'})
	end
	if Config.EnablePlayerManagement and ESX.PlayerData.job and (ESX.PlayerData.job.grade_name == 'boss' or ESX.PlayerData.job.grade_name == 'vlasnik') then
		table.insert(elements, {label = _U('boss_actions'), value = 'boss_actions'})
	end

	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'mechanic_actions', {
		title    = _U('mechanic'),
		align    = 'top-left',
		elements = elements
	}, function(data, menu)
		if data.current.value == 'vehicle_list' then
			if Config.EnableSocietyOwnedVehicles then

				local elements = {}

				ESX.TriggerServerCallback('esx_society:getVehiclesInGarage', function(vehicles)
					for i=1, #vehicles, 1 do
						table.insert(elements, {
							label = GetDisplayNameFromVehicleModel(vehicles[i].model) .. ' [' .. vehicles[i].plate .. ']',
							value = vehicles[i]
						})
					end

					ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_spawner', {
						title    = _U('service_vehicle'),
						align    = 'top-left',
						elements = elements
					}, function(data, menu)
						menu.close()
						local vehicleProps = data.current.value

						ESX.Game.SpawnVehicle(vehicleProps.model, Config.Zones.VehicleSpawnPoint.Pos, 270.0, function(vehicle)
							ESX.Game.SetVehicleProperties(vehicle, vehicleProps)
							local playerPed = PlayerPedId()
							TaskWarpPedIntoVehicle(playerPed,  vehicle,  -1)
						end)

						TriggerServerEvent('esx_society:removeVehicleFromGarage', 'mechanic', vehicleProps)
					end, function(data, menu)
						menu.close()
					end)
				end, 'mechanic')

			else

				local elements = {
					{label = _U('flat_bed'),  value = 'flatbed'},
					{label = _U('tow_truck'), value = 'towtruck2'},
					--{label = "Nissan Titan", value = 'nissantitan17'}
				}

				if Config.EnablePlayerManagement and ESX.PlayerData.job and (ESX.PlayerData.job.grade_name == 'boss' or ESX.PlayerData.job.grade_name == 'chief' or ESX.PlayerData.job.grade_name == 'vlasnik' or ESX.PlayerData.job.grade_name == 'experimente') then
					table.insert(elements, {label = 'SlamVan', value = 'slamvan3'})
				end

				ESX.UI.Menu.CloseAll()

				ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'spawn_vehicle', {
					title    = _U('service_vehicle'),
					align    = 'top-left',
					elements = elements
				}, function(data, menu)
					if Config.MaxInService == -1 then
						ESX.Game.SpawnVehicle(data.current.value, Config.Zones.VehicleSpawnPoint.Pos, 90.0, function(vehicle)
							local playerPed = PlayerPedId()
							TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
							if data.current.value == "nissantitan17" then
								SetVehicleExtra(vehicle, 1, true)
							end
						end)
					else
						ESX.TriggerServerCallback('esx_service:enableService', function(canTakeService, maxInService, inServiceCount)
							if canTakeService then
								ESX.Game.SpawnVehicle(data.current.value, Config.Zones.VehicleSpawnPoint.Pos, 90.0, function(vehicle)
									local playerPed = PlayerPedId()
									TaskWarpPedIntoVehicle(playerPed,  vehicle, -1)
								end)
							else
								ESX.ShowNotification(_U('service_full') .. inServiceCount .. '/' .. maxInService)
							end
						end, 'mechanic')
					end

					menu.close()
				end, function(data, menu)
					menu.close()
					OpenMechanicActionsMenu()
				end)

			end
		elseif data.current.value == 'cloakroom' then
			menu.close()
			local grade = ESX.PlayerData.job.grade_name
			local val = grade.."_wear"
			setUniform(val, PlayerPedId())
			exports["rp-radio"]:SetRadio(true)
			exports["rp-radio"]:GivePlayerAccessToFrequency(4)
		elseif data.current.value == 'cloakroom2' then
			menu.close()
			ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
				TriggerEvent('skinchanger:loadSkin', skin)
			end)
			exports["rp-radio"]:SetRadio(false)
			exports["rp-radio"]:RemovePlayerAccessToFrequency(4)
			PostavioEUP = false
		elseif data.current.value == 'put_stock' then
			OpenPutStocksMenu()
		elseif data.current.value == 'pregled_nar' then
			OpenNarudzbeMenu()
		elseif data.current.value == 'get_stock' then
			OpenGetStocksMenu()
		elseif data.current.value == 'boss_actions' then
			OtvoriBossMenu()
		elseif data.current.value == 'racuni' then
			OpenNeplaceneRacune()
		elseif data.current.value == 'saraf' then
			TriggerServerEvent("meh:UzmiSarafciger")
		end
	end, function(data, menu)
		menu.close()

		CurrentAction     = 'mechanic_actions_menu'
		CurrentActionMsg  = _U('open_actions')
		CurrentActionData = {}
	end)
end

function OpenNarudzbeMenu()
	local elements = {}

	ESX.TriggerServerCallback('meh:DohvatiNarudzbe', function(nar)
		if nar ~= 0 then
			for i=1, #nar, 1 do
				local stiglo = "Ne ("..(10-nar[i].min).." min)"
				if nar[i].min >= 10 then
					stiglo = "Da"
				end
				table.insert(elements, {
					label = nar[i].tablica.." | Stigli dijelovi: "..stiglo,
					value = nar[i].broj
				})
			end

			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'nar_meh', {
				title    = "Narudzbe",
				align    = 'top-left',
				elements = elements
			}, function(data, menu)
				local broj = data.current.value
				ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'nar_meh2', {
					title    = "Izaberite radnju",
					align    = 'top-left',
					elements = {
						{label = "Nazovi vlasnika", value = "nazovi"},
						{label = "Posalji poruku vlasniku", value = "poruka"}
					}
				}, function(data2, menu2)
					if data2.current.value == "nazovi" then
						TriggerEvent("mobitel:Nazovi", broj)
					else
						TriggerEvent("mobitel:PosaljiPoruku", broj)
					end
					menu2.close()
				end, function(data2, menu2)
					menu2.close()
				end)
			end, function(data, menu)
				menu.close()
			end)
		else
			ESX.ShowNotification("Nema narudzbi.")
		end
	end)
end

RegisterNetEvent('esx_meha:PucajCijenu')
AddEventHandler('esx_meha:PucajCijenu', function(model, cijena)
	if Cijena[model] ~= nil then
		Cijena[model] = Cijena[model]+cijena
	else
		Cijena[model] = cijena
	end
end)

function OpenNeplaceneRacune()
	local elements = {}

	ESX.TriggerServerCallback('esx_billing:getMBills', function(bills)
		for k,bill in ipairs(bills) do
			table.insert(elements, {
				label = ('%s - <span style="color:red;">%s</span>'):format(bill.firstname.." "..bill.lastname.."("..bill.name..")", _U('armory_item', ESX.Math.GroupDigits(bill.amount))),
			})
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'billing', {
			title    = "Neplaceni racuni",
			align    = 'top-left',
			elements = elements
		}, nil, function(data, menu)
			menu.close()
		end)
	end)
end

function OpenUnpaidBillsMenu(player)
	local elements = {}

	ESX.TriggerServerCallback('esx_billing:getMechanicBills', function(bills)
		for k,bill in ipairs(bills) do
			table.insert(elements, {
				label = ('<span style="color:red;">%s</span>'):format(_U('armory_item', ESX.Math.GroupDigits(bill.amount))),
			})
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'billing', {
			title    = "Neplaceni racuni ("..GetPlayerName(player)..")",
			align    = 'top-left',
			elements = elements
		}, nil, function(data, menu)
			menu.close()
		end)
	end, GetPlayerServerId(player))
end

function OpenMobileMechanicActionsMenu()
	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'mobile_mechanic_actions', {
		title    = _U('mechanic'),
		align    = 'top-left',
		elements = {
			{label = _U('billing'),       value = 'billing'},
			--{label = _U('hijack'),        value = 'hijack_vehicle'},
			{label = _U('repair'),        value = 'fix_vehicle'},
			{label = _U('clean'),         value = 'clean_vehicle'},
			{label = _U('imp_veh'),       value = 'del_vehicle'},
			{label = _U('flat_bed'),      value = 'dep_vehicle'},
			{label = "Guraj vozilo",      value = 'guraj'}
			--{label = _U('place_objects'), value = 'object_spawner'}
	}}, function(data, menu)
		if isBusy then return end

		if data.current.value == 'billing' then
			ESX.UI.Menu.Open(
				'default', GetCurrentResourceName(), 'izborplacanja',
				{
					title    = "Izbor placanja",
					elements = {
						--{label = "Placanje tuninga", value = 'tuning'},
						{label = "Placanje popravka", value = 'popravak'},
						{label = "Placanje ciscenja", value = 'ciscenje'},
						{label = "Provjeri neplacene racune", value = 'unpaid_bills'}
					}
				},
				function(data2, menu2)
					if data2.current.value == 'tuning' then
						local closestVehicle, Distance = ESX.Game.GetClosestVehicle()
						local vehicleProps = ESX.Game.GetVehicleProperties(closestVehicle)
						local tablica = vehicleProps.plate
						if Distance < 5.0 then
							if Cijena[tablica] ~= nil then
								if tonumber(Cijena[tablica]) > 0 then
									local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
									if closestPlayer == -1 or closestDistance > 3.0 then
										ESX.ShowNotification(_U('no_players_nearby'))
									else
										menu2.close()
										ESX.ShowNotification("Dali ste racun u iznosu od "..Cijena[tablica])
										TriggerServerEvent("DiscordBot:Mehanicari", GetPlayerName(PlayerId()).." je dao racun(tuning) igracu "..GetPlayerName(closestPlayer).." od $"..Cijena[tablica])
										TriggerServerEvent('esx_billing:posaljiTuljana', GetPlayerServerId(closestPlayer), 'society_mechanic', _U('mechanic'), Cijena[tablica])
										Cijena[tablica] = nil
									end
								end
							end
						end
					end
					if data2.current.value == 'popravak' then
						local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
						if closestPlayer == -1 or closestDistance > 3.0 then
							ESX.ShowNotification("Nema igraca blizu")
						else
							menu2.close()
							ESX.ShowNotification("Dali ste racun u iznosu od 2000$")
							TriggerServerEvent("DiscordBot:Mehanicari", GetPlayerName(PlayerId()).." je dao racun(popravak) igracu "..GetPlayerName(closestPlayer).." od $2000")
							TriggerServerEvent('esx_billing:posaljiTuljana', GetPlayerServerId(closestPlayer), 'society_mechanic', _U('mechanic'), 2000)
						end
					end
					if data2.current.value == 'ciscenje' then
						local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
						if closestPlayer == -1 or closestDistance > 3.0 then
							ESX.ShowNotification(_U('no_players_nearby'))
						else
							menu2.close()
							ESX.ShowNotification("Dali ste racun u iznosu od 500$")
							TriggerServerEvent("DiscordBot:Mehanicari", GetPlayerName(PlayerId()).." je dao racun(ciscenje) igracu "..GetPlayerName(closestPlayer).." od $500")
							TriggerServerEvent('esx_billing:posaljiTuljana', GetPlayerServerId(closestPlayer), 'society_mechanic', _U('mechanic'), 500)
						end
					end
					if data2.current.value == 'unpaid_bills' then
						local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
						if closestPlayer == -1 or closestDistance > 3.0 then
							ESX.ShowNotification(_U('no_players_nearby'))
						else
							menu2.close()
							OpenUnpaidBillsMenu(closestPlayer)
						end
					end
					menu2.close()
				end,
				function(data2, menu2)
					menu2.close()
				end
			)
		elseif data.current.value == 'hijack_vehicle' then
			local playerPed = PlayerPedId()
			local vehicle   = ESX.Game.GetVehicleInDirection()
			local coords    = GetEntityCoords(playerPed)

			if IsPedSittingInAnyVehicle(playerPed) then
				ESX.ShowNotification(_U('inside_vehicle'))
				return
			end

			if DoesEntityExist(vehicle) then
				isBusy = true
				TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_WELDING', 0, true)
				Citizen.CreateThread(function()
					Citizen.Wait(10000)

					SetVehicleDoorsLocked(vehicle, 1)
					SetVehicleDoorsLockedForAllPlayers(vehicle, false)
					ClearPedTasksImmediately(playerPed)

					ESX.ShowNotification(_U('vehicle_unlocked'))
					isBusy = false
				end)
			else
				ESX.ShowNotification(_U('no_vehicle_nearby'))
			end
		elseif data.current.value == 'fix_vehicle' then
			local playerPed = PlayerPedId()
			local vehicle   = ESX.Game.GetVehicleInDirection()
			local coords    = GetEntityCoords(playerPed)

			if IsPedSittingInAnyVehicle(playerPed) then
				ESX.ShowNotification(_U('inside_vehicle'))
				return
			end

			if DoesEntityExist(vehicle) then
				isBusy = true
				TaskStartScenarioInPlace(playerPed, 'PROP_HUMAN_BUM_BIN', 0, true)
				Citizen.CreateThread(function()
					Citizen.Wait(20000)

					SetVehicleFixed(vehicle)
					SetVehicleDeformationFixed(vehicle)
					SetVehicleUndriveable(vehicle, false)
					SetVehicleEngineOn(vehicle, true, true)
					TriggerEvent("iens:repair")
					ClearPedTasksImmediately(playerPed)

					ESX.ShowNotification(_U('vehicle_repaired'))
					isBusy = false
				end)
			else
				ESX.ShowNotification(_U('no_vehicle_nearby'))
			end
		elseif data.current.value == 'clean_vehicle' then
			local playerPed = PlayerPedId()
			local vehicle   = ESX.Game.GetVehicleInDirection()
			local coords    = GetEntityCoords(playerPed)

			if IsPedSittingInAnyVehicle(playerPed) then
				ESX.ShowNotification(_U('inside_vehicle'))
				return
			end

			if DoesEntityExist(vehicle) then
				isBusy = true
				TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_MAID_CLEAN', 0, true)
				Citizen.CreateThread(function()
					Citizen.Wait(10000)

					SetVehicleDirtLevel(vehicle, 0)
					ClearPedTasksImmediately(playerPed)

					ESX.ShowNotification(_U('vehicle_cleaned'))
					isBusy = false
				end)
			else
				ESX.ShowNotification(_U('no_vehicle_nearby'))
			end
		elseif data.current.value == 'guraj' then
			local ped = PlayerPedId()
			local First = vector3(0.0, 0.0, 0.0)
			local Second = vector3(5.0, 5.0, 5.0)
			local Vehicle = {Coords = nil, Vehicle = nil, Dimension = nil, IsInFront = false, Distance = nil}
			if not IsPedInAnyVehicle(ped, false) then
				local closestVehicle, Distance = ESX.Game.GetClosestVehicle()
				if Distance < 6.0 then
					local Vehicle = {}
					local vehicleCoords = GetEntityCoords(closestVehicle)
					local dimension = GetModelDimensions(GetEntityModel(closestVehicle), First, Second)
					Vehicle.Coords = vehicleCoords
					Vehicle.Dimensions = dimension
					Vehicle.Vehicle = closestVehicle
					Vehicle.Distance = Distance
					if GetDistanceBetweenCoords(GetEntityCoords(closestVehicle) + GetEntityForwardVector(closestVehicle), GetEntityCoords(ped), true) > GetDistanceBetweenCoords(GetEntityCoords(closestVehicle) + GetEntityForwardVector(closestVehicle) * -1, GetEntityCoords(ped), true) then
						Vehicle.IsInFront = false
					else
						Vehicle.IsInFront = true
					end
					if Vehicle.Vehicle ~= nil then
						if IsVehicleSeatFree(Vehicle.Vehicle, -1) and not IsEntityAttachedToEntity(ped, Vehicle.Vehicle) then
							NetworkRequestControlOfEntity(Vehicle.Vehicle)
							local coords = GetEntityCoords(ped)
							if Vehicle.IsInFront then    
								AttachEntityToEntity(PlayerPedId(), Vehicle.Vehicle, GetPedBoneIndex(6286), 0.0, Vehicle.Dimensions.y * -1 + 0.1 , Vehicle.Dimensions.z + 1.0, 0.0, 0.0, 180.0, 0.0, false, false, true, false, true)
							else
								AttachEntityToEntity(PlayerPedId(), Vehicle.Vehicle, GetPedBoneIndex(6286), 0.0, Vehicle.Dimensions.y - 0.3, Vehicle.Dimensions.z  + 1.0, 0.0, 0.0, 0.0, 0.0, false, false, true, false, true)
							end

							ESX.Streaming.RequestAnimDict('missfinale_c2ig_11')
							TaskPlayAnim(ped, 'missfinale_c2ig_11', 'pushcar_offcliff_m', 2.0, -8.0, -1, 35, 0, 0, 0, 0)
							Citizen.Wait(200)

							ESX.ShowNotification("Da prestanete gurati vozilo pritisnite tipku X", 5000)
							local currentVehicle = Vehicle.Vehicle
							while true do
								Citizen.Wait(5)
								if IsControlPressed(0, 34) then
									TaskVehicleTempAction(PlayerPedId(), currentVehicle, 11, 1000)
								end

								if IsControlPressed(0, 35) then
									TaskVehicleTempAction(PlayerPedId(), currentVehicle, 10, 1000)
								end

								if Vehicle.IsInFront then
									SetVehicleForwardSpeed(currentVehicle, -1.0)
								else
									SetVehicleForwardSpeed(currentVehicle, 1.0)
								end

								if HasEntityCollidedWithAnything(currentVehicle) then
									SetVehicleOnGroundProperly(currentVehicle)
								end

								if IsControlJustPressed(0, 73) then
									DetachEntity(ped, false, false)
									StopAnimTask(ped, 'missfinale_c2ig_11', 'pushcar_offcliff_m', 2.0)
									FreezeEntityPosition(ped, false)
									break
								end
							end
							ESX.ShowNotification("Prestali ste gurati vozilo.")
							Vehicle = {Coords = nil, Vehicle = nil, Dimension = nil, IsInFront = false, Distance = nil}
						end
					end
				end
			end
		elseif data.current.value == 'del_vehicle' then
			local playerPed = PlayerPedId()

			if IsPedSittingInAnyVehicle(playerPed) then
				local vehicle = GetVehiclePedIsIn(playerPed, false)
				if GetPedInVehicleSeat(vehicle, -1) == playerPed then
					NetworkRequestControlOfEntity(vehicle)
					ESX.TriggerServerCallback('mafije:DohvatiKamion', function(odg)
						if odg ~= false then
							NetworkRequestControlOfEntity(NetToObj(odg.Obj1))
							NetworkRequestControlOfEntity(NetToObj(odg.Obj2))
							NetworkRequestControlOfEntity(NetToObj(odg.Obj3))
							ESX.Game.DeleteObject(NetToObj(odg.Obj1))
							ESX.Game.DeleteObject(NetToObj(odg.Obj2))
							ESX.Game.DeleteObject(NetToObj(odg.Obj3))
							ESX.Game.DeleteVehicle(vehicle)
							ESX.ShowNotification(_U('vehicle_impounded'))
						else
							ESX.ShowNotification(_U('vehicle_impounded'))
							ESX.Game.DeleteVehicle(vehicle)
						end
					end, VehToNet(vehicle))
				else
					ESX.ShowNotification(_U('must_seat_driver'))
				end
			else
				local vehicle = ESX.Game.GetVehicleInDirection()

				if DoesEntityExist(vehicle) then
					NetworkRequestControlOfEntity(vehicle)
					ESX.TriggerServerCallback('mafije:DohvatiKamion', function(odg)
						if odg ~= false then
							NetworkRequestControlOfEntity(NetToObj(odg.Obj1))
							NetworkRequestControlOfEntity(NetToObj(odg.Obj2))
							NetworkRequestControlOfEntity(NetToObj(odg.Obj3))
							ESX.Game.DeleteObject(NetToObj(odg.Obj1))
							ESX.Game.DeleteObject(NetToObj(odg.Obj2))
							ESX.Game.DeleteObject(NetToObj(odg.Obj3))
							ESX.Game.DeleteVehicle(vehicle)
							ESX.ShowNotification(_U('vehicle_impounded'))
						else
							ESX.ShowNotification(_U('vehicle_impounded'))
							ESX.Game.DeleteVehicle(vehicle)
						end
					end, VehToNet(vehicle))
				else
					ESX.ShowNotification(_U('must_near'))
				end
			end
		elseif data.current.value == 'dep_vehicle' then
			local playerPed = PlayerPedId()
			local vehicle = GetVehiclePedIsIn(playerPed, true)

			local towmodel = GetHashKey('flatbed')
			local isVehicleTow = IsVehicleModel(vehicle, towmodel)

			if isVehicleTow then
				local targetVehicle = ESX.Game.GetVehicleInDirection()

				if CurrentlyTowedVehicle == nil then
					if targetVehicle ~= 0 then
						if not IsPedInAnyVehicle(playerPed, true) then
							if vehicle ~= targetVehicle then
								
								local towPos = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, -1.9, 3.5)
								SetEntityCoords(targetVehicle, towPos, false, false, false, false)
								Citizen.Wait(2000)
								local targetPos = GetEntityCoords(targetVehicle, true)
								local attachPos = GetOffsetFromEntityGivenWorldCoords(vehicle, targetPos.x, targetPos.y, targetPos.z)
								AttachEntityToEntity(targetVehicle, vehicle, -1, attachPos.x, attachPos.y, attachPos.z, 0.0, 0.0, 0.0, false, false, false, false, 0, true)
							
								--AttachEntityToEntity(targetVehicle, vehicle, 20, -0.5, -5.0, 1.0, 0.0, 0.0, 0.0, false, false, false, false, 0, true)
								CurrentlyTowedVehicle = targetVehicle
								ESX.ShowNotification(_U('vehicle_success_attached'))

								if NPCOnJob then
									if NPCTargetTowable == targetVehicle then
										ESX.ShowNotification(_U('please_drop_off'))
										Config.Zones.VehicleDelivery.Type = 1

										if Blips['NPCTargetTowableZone'] then
											RemoveBlip(Blips['NPCTargetTowableZone'])
											Blips['NPCTargetTowableZone'] = nil
										end

										Blips['NPCDelivery'] = AddBlipForCoord(Config.Zones.VehicleDelivery.Pos.x, Config.Zones.VehicleDelivery.Pos.y, Config.Zones.VehicleDelivery.Pos.z)
										SetBlipRoute(Blips['NPCDelivery'], true)
									end
								end
							else
								ESX.ShowNotification(_U('cant_attach_own_tt'))
							end
						end
					else
						ESX.ShowNotification(_U('no_veh_att'))
					end
				else
					DetachEntity(CurrentlyTowedVehicle, true, true)
					local coords = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, -10.0, 0.0)
					
					SetEntityCoords(CurrentlyTowedVehicle, coords, false, false, false, false)
					SetVehicleOnGroundProperly(CurrentlyTowedVehicle)
				
					--AttachEntityToEntity(CurrentlyTowedVehicle, vehicle, 20, -0.5, -12.0, 1.0, 0.0, 0.0, 0.0, false, false, false, false, 20, true)
					--DetachEntity(CurrentlyTowedVehicle, true, true)

					if NPCOnJob then
						if NPCTargetDeleterZone then

							if CurrentlyTowedVehicle == NPCTargetTowable then
								ESX.Game.DeleteVehicle(NPCTargetTowable)
								TriggerServerEvent('esx_mechanicjob:onNPCJobMissionCompleted')
								StopNPCJob()
								NPCTargetDeleterZone = false
							else
								ESX.ShowNotification(_U('not_right_veh'))
							end

						else
							ESX.ShowNotification("Niste ostavili vozilo na pravom mjestu")
						end
					end

					CurrentlyTowedVehicle = nil
					ESX.ShowNotification(_U('veh_det_succ'))
				end
			else
				ESX.ShowNotification(_U('imp_flatbed'))
			end
		elseif data.current.value == 'object_spawner' then
			local playerPed = PlayerPedId()

			if IsPedSittingInAnyVehicle(playerPed) then
				ESX.ShowNotification(_U('inside_vehicle'))
				return
			end

			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'mobile_mechanic_actions_spawn', {
				title    = _U('objects'),
				align    = 'top-left',
				elements = {
					{label = _U('roadcone'), value = 'prop_roadcone02a'},
					{label = _U('toolbox'),  value = 'prop_toolchest_01'}
			}}, function(data2, menu2)
				local model   = data2.current.value
				local coords  = GetEntityCoords(playerPed)
				local forward = GetEntityForwardVector(playerPed)
				local x, y, z = table.unpack(coords + forward * 1.0)

				if model == 'prop_roadcone02a' then
					z = z - 2.0
				elseif model == 'prop_toolchest_01' then
					z = z - 2.0
				end

				ESX.Game.SpawnObject(model, {x = x, y = y, z = z}, function(obj)
					SetEntityHeading(obj, GetEntityHeading(playerPed))
					PlaceObjectOnGroundProperly(obj)
				end)
			end, function(data2, menu2)
				menu2.close()
			end)
		end
	end, function(data, menu)
		menu.close()
	end)
end

function OpenGetStocksMenu()
	ESX.TriggerServerCallback('esx_mechanicjob:getStockItems', function(items)
		local elements = {}

		for i=1, #items, 1 do
			table.insert(elements, {
				label = 'x' .. items[i].count .. ' ' .. items[i].label,
				value = items[i].name
			})
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stocks_menu', {
			title    = _U('mechanic_stock'),
			align    = 'top-left',
			elements = elements
		}, function(data, menu)
			local itemName = data.current.value

			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_get_item_count', {
				title = _U('quantity')
			}, function(data2, menu2)
				local count = tonumber(data2.value)

				if count == nil then
					print("ovaj?")
					ESX.ShowNotification(_U('invalid_quantity'))
				else
					menu2.close()
					menu.close()
					TriggerServerEvent('esx_mechanicjob:getStockItem', itemName, count)

					Citizen.Wait(1000)
					OpenGetStocksMenu()
				end
			end, function(data2, menu2)
				menu2.close()
			end)
		end, function(data, menu)
			menu.close()
		end)
	end)
end

function OpenPutStocksMenu()
	ESX.TriggerServerCallback('esx_mechanicjob:getPlayerInventory', function(inventory)
		local elements = {}

		for i=1, #inventory.items, 1 do
			local item = inventory.items[i]

			if item.count > 0 then
				table.insert(elements, {
					label = item.label .. ' x' .. item.count,
					type  = 'item_standard',
					value = item.name
				})
			end
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stocks_menu', {
			title    = _U('inventory'),
			align    = 'top-left',
			elements = elements
		}, function(data, menu)
			local itemName = data.current.value

			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_put_item_count', {
				title = _U('quantity')
			}, function(data2, menu2)
				local count = tonumber(data2.value)

				if count == nil then
				ESX.ShowNotification(_U('quantity_invalid'))
				else
				for i=1, #inventory.items, 1 do

				  local item = inventory.items[i]

				  if itemName == item.name then
					if item.count >= count then
						menu2.close()
						menu.close()
						TriggerServerEvent('esx_mechanicjob:putStockItems', itemName, count)
						OpenPutStocksMenu()
					else
						ESX.ShowNotification("Nemate toliko "..itemName)
					end
				  end

				end
				end
			end, function(data2, menu2)
				menu2.close()
			end)
		end, function(data, menu)
			menu.close()
		end)
	end)
end

RegisterNetEvent('esx_mechanicjob:onHijack')
AddEventHandler('esx_mechanicjob:onHijack', function()
	local playerPed = PlayerPedId()
	local coords    = GetEntityCoords(playerPed)

	if IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 5.0) then
		local vehicle

		if IsPedInAnyVehicle(playerPed, false) then
			vehicle = GetVehiclePedIsIn(playerPed, false)
		else
			vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71)
		end

		local chance = math.random(100)
		local alarm  = math.random(100)

		if DoesEntityExist(vehicle) then
			if alarm <= 33 then
				SetVehicleAlarm(vehicle, true)
				StartVehicleAlarm(vehicle)
			end

			TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_WELDING', 0, true)

			Citizen.CreateThread(function()
				Citizen.Wait(10000)
				if chance <= 66 then
					SetVehicleDoorsLocked(vehicle, 1)
					SetVehicleDoorsLockedForAllPlayers(vehicle, false)
					ClearPedTasksImmediately(playerPed)
					ESX.ShowNotification(_U('veh_unlocked'))
				else
					ESX.ShowNotification(_U('hijack_failed'))
					ClearPedTasksImmediately(playerPed)
				end
			end)
		end
	end
end)

RegisterNetEvent('esx_mechanicjob:onCarokit')
AddEventHandler('esx_mechanicjob:onCarokit', function()
	local playerPed = PlayerPedId()
	local coords    = GetEntityCoords(playerPed)

	if IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 5.0) then
		local vehicle

		if IsPedInAnyVehicle(playerPed, false) then
			vehicle = GetVehiclePedIsIn(playerPed, false)
		else
			vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71)
		end

		if DoesEntityExist(vehicle) then
			TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_HAMMERING', 0, true)
			Citizen.CreateThread(function()
				Citizen.Wait(10000)
				SetVehicleFixed(vehicle)
				SetVehicleDeformationFixed(vehicle)
				ClearPedTasksImmediately(playerPed)
				ESX.ShowNotification(_U('body_repaired'))
			end)
		end
	end
end)

RegisterNetEvent('esx_mechanicjob:onFixkit')
AddEventHandler('esx_mechanicjob:onFixkit', function()
	local playerPed = PlayerPedId()
	local coords    = GetEntityCoords(playerPed)

	if IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 5.0) then
		local vehicle

		if IsPedInAnyVehicle(playerPed, false) then
			vehicle = GetVehiclePedIsIn(playerPed, false)
		else
			vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71)
		end

		if DoesEntityExist(vehicle) then
			TaskStartScenarioInPlace(playerPed, 'PROP_HUMAN_BUM_BIN', 0, true)
			Citizen.CreateThread(function()
				Citizen.Wait(20000)
				SetVehicleFixed(vehicle)
				SetVehicleDeformationFixed(vehicle)
				SetVehicleUndriveable(vehicle, false)
				ClearPedTasksImmediately(playerPed)
				ESX.ShowNotification(_U('veh_repaired'))
			end)
		end
	end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)

AddEventHandler('esx_mechanicjob:hasEnteredMarker', function(zone)
	if zone == 'NPCJobTargetTowable' then

	elseif zone =='VehicleDelivery' then
		NPCTargetDeleterZone = true
	elseif zone == 'MechanicActions' then
		CurrentAction     = 'mechanic_actions_menu'
		CurrentActionMsg  = _U('open_actions')
		CurrentActionData = {}
	elseif zone == 'VehicleDeleter' then
		local playerPed = PlayerPedId()

		if IsPedInAnyVehicle(playerPed, false) then
			local vehicle = GetVehiclePedIsIn(playerPed,  false)

			CurrentAction     = 'delete_vehicle'
			CurrentActionMsg  = _U('veh_stored')
			CurrentActionData = {vehicle = vehicle}
		end
	end
end)

AddEventHandler('esx_mechanicjob:hasExitedMarker', function(zone)
	if zone =='VehicleDelivery' then
		NPCTargetDeleterZone = false
	end

	CurrentAction = nil
	ESX.UI.Menu.CloseAll()
end)

AddEventHandler('esx_mechanicjob:hasEnteredEntityZone', function(entity)
	local playerPed = PlayerPedId()

	if ESX.PlayerData.job and ESX.PlayerData.job.name == 'mechanic' and not IsPedInAnyVehicle(playerPed, false) then
		CurrentAction     = 'remove_entity'
		CurrentActionMsg  = _U('press_remove_obj')
		CurrentActionData = {entity = entity}
	end
end)

AddEventHandler('esx_mechanicjob:hasExitedEntityZone', function(entity)
	if CurrentAction == 'remove_entity' then
		CurrentAction = nil
	end
end)

RegisterNetEvent('esx_phone:loaded')
AddEventHandler('esx_phone:loaded', function(phoneNumber, contacts)
	local specialContact = {
		name       = _U('mechanic'),
		number     = 'mechanic',
		base64Icon = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAALEwAACxMBAJqcGAAAA4BJREFUWIXtll9oU3cUx7/nJA02aSSlFouWMnXVB0ejU3wcRteHjv1puoc9rA978cUi2IqgRYWIZkMwrahUGfgkFMEZUdg6C+u21z1o3fbgqigVi7NzUtNcmsac40Npltz7S3rvUHzxQODec87vfD+/e0/O/QFv7Q0beV3QeXqmgV74/7H7fZJvuLwv8q/Xeux1gUrNBpN/nmtavdaqDqBK8VT2RDyV2VHmF1lvLERSBtCVynzYmcp+A9WqT9kcVKX4gHUehF0CEVY+1jYTTIwvt7YSIQnCTvsSUYz6gX5uDt7MP7KOKuQAgxmqQ+neUA+I1B1AiXi5X6ZAvKrabirmVYFwAMRT2RMg7F9SyKspvk73hfrtbkMPyIhA5FVqi0iBiEZMMQdAui/8E4GPv0oAJkpc6Q3+6goAAGpWBxNQmTLFmgL3jSJNgQdGv4pMts2EKm7ICJB/aG0xNdz74VEk13UYCx1/twPR8JjDT8wttyLZtkoAxSb8ZDCz0gdfKxWkFURf2v9qTYH7SK7rQIDn0P3nA0ehixvfwZwE0X9vBE/mW8piohhl1WH18UQBhYnre8N/L8b8xQvlx4ACbB4NnzaeRYDnKm0EALCMLXy84hwuTCXL/ExoB1E7qcK/8NCLIq5HcTT0i6u8TYbXUM1cAyyveVq8Xls7XhYrvY/4n3gC8C+dsmAzL1YUiyfWxvHzsy/w/dNd+KjhW2yvv/RfXr7x9QDcmo1he2RBiCCI1Q8jVj9szPNixVfgz+UiIGyDSrcoRu2J16d3I6e1VYvNSQjXpnucAcEPUOkGYZs/l4uUhowt/3kqu1UIv9n90fAY9jT3YBlbRvFTD4fw++wHjhiTRL/bG75t0jI2ITcHb5om4Xgmhv57xpGOg3d/NIqryOR7z+r+MC6qBJB/ZB2t9Om1D5lFm843G/3E3HI7Yh1xDRAfzLQr5EClBf/HBHK462TG2J0OABXeyWDPZ8VqxmBWYscpyghwtTd4EKpDTjCZdCNmzFM9k+4LHXIFACJN94Z6FiFEpKDQw9HndWsEuhnADVMhAUaYJBp9XrcGQKJ4qFE9k+6r2+MG3k5N8VQ22TVglbX2ZwOzX2VvNKr91zmY6S7N6zqZicVT2WNLyVSehESaBhxnOALfMeYX+K/S2yv7wmMAlvwyuR7FxQUyf0fgc/jztfkJr7XeGgC8BJJgWNV8ImT+AAAAAElFTkSuQmCC'
	}

	TriggerEvent('esx_phone:addSpecialContact', specialContact.name, specialContact.number, specialContact.base64Icon)
end)

-- Pop NPC mission vehicle when inside area
Citizen.CreateThread(function()
	local waitara = 500
	while true do
		Citizen.Wait(waitara)
		local naso = 0
		if ESX.PlayerData.job and ESX.PlayerData.job.name == 'mechanic' then
			if NPCTargetTowableZone and not NPCHasSpawnedTowable then
				waitara = 10
				naso = 1
				local coords = GetEntityCoords(PlayerPedId())
				local zone   = Config.Zones[NPCTargetTowableZone]

				if GetDistanceBetweenCoords(coords, zone.Pos.x, zone.Pos.y, zone.Pos.z, true) < Config.NPCSpawnDistance then
					local model = Config.Vehicles[GetRandomIntInRange(1,  #Config.Vehicles)]

					ESX.Game.SpawnVehicle(model, zone.Pos, 0, function(vehicle)
						NPCTargetTowable = vehicle
					end)

					NPCHasSpawnedTowable = true
				end
			end

			if NPCTargetTowableZone and NPCHasSpawnedTowable and not NPCHasBeenNextToTowable then
				waitara = 10
				naso = 1
				local coords = GetEntityCoords(PlayerPedId())
				local zone   = Config.Zones[NPCTargetTowableZone]

				if GetDistanceBetweenCoords(coords, zone.Pos.x, zone.Pos.y, zone.Pos.z, true) < Config.NPCNextToDistance then
					ESX.ShowNotification(_U('please_tow'))
					NPCHasBeenNextToTowable = true
				end
			end
			if naso == 0 then
				waitara = 500
			end
		else
			waitara = 2000
		end
	end
end)

-- Create Blips
Citizen.CreateThread(function()
	local blip = AddBlipForCoord(Config.Zones.MechanicActions.Pos.x, Config.Zones.MechanicActions.Pos.y, Config.Zones.MechanicActions.Pos.z)

	SetBlipSprite (blip, 446)
	SetBlipDisplay(blip, 4)
	SetBlipScale  (blip, 1.0)
	SetBlipColour (blip, 5)
	SetBlipAsShortRange(blip, true)

	BeginTextCommandSetBlipName('STRING')
	AddTextComponentSubstringPlayerName(_U('mechanic'))
	EndTextCommandSetBlipName(blip)
end)

-- Display markers
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if ESX.PlayerData.job and ESX.PlayerData.job.name == 'mechanic' then
			local coords, letSleep = GetEntityCoords(PlayerPedId()), true

			for k,v in pairs(Config.Zones) do
				if v.Type ~= -1 and GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < Config.DrawDistance then
					DrawMarker(v.Type, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, v.Color.r, v.Color.g, v.Color.b, 100, false, true, 2, false, nil, nil, false)
					letSleep = false
				end
			end

			if letSleep then
				Citizen.Wait(500)
			end
		else
			Citizen.Wait(500)
		end
	end
end)

-- Enter / Exit marker events
Citizen.CreateThread(function()
	local waitara = 500
	while true do
		Citizen.Wait(waitara)

		if ESX.PlayerData.job and ESX.PlayerData.job.name == 'mechanic' then
			local coords = GetEntityCoords(PlayerPedId())
			local isInMarker  = false
			local currentZone = nil
			local naso = 0

			for k,v in pairs(Config.Zones) do
				if(GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < v.Size.x) then
					isInMarker  = true
					currentZone = k
					naso = 1
					waitara = 10
				end
			end

			if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then
				HasAlreadyEnteredMarker = true
				LastZone                = currentZone
				TriggerEvent('esx_mechanicjob:hasEnteredMarker', currentZone)
			end

			if not isInMarker and HasAlreadyEnteredMarker then
				HasAlreadyEnteredMarker = false
				TriggerEvent('esx_mechanicjob:hasExitedMarker', LastZone)
			end
			if naso == 0 then
				waitara = 500
			end
		else
			waitara = 500
		end
	end
end)

RegisterCommand('+akcijemeh', function()
    if ESX.PlayerData.job and ESX.PlayerData.job.name == 'mechanic' and not isDead and not ESX.UI.Menu.IsOpen('default', GetCurrentResourceName(), 'mobile_mechanic_actions') and not Zabranio then
		OpenMobileMechanicActionsMenu()
	end
end, false)
RegisterKeyMapping('+akcijemeh', 'Otvori menu', 'keyboard', 'f6')

RegisterCommand('+npcmeh', function()
    if ESX.PlayerData.job and ESX.PlayerData.job.name == 'mechanic' and not isDead then
		if NPCOnJob then
			if GetGameTimer() - NPCLastCancel > 5 * 60000 then
				StopNPCJob(true)
				NPCLastCancel = GetGameTimer()
			else
				ESX.ShowNotification(_U('wait_five'))
			end
		else
			local playerPed = PlayerPedId()

			if IsPedInAnyVehicle(playerPed, false) and IsVehicleModel(GetVehiclePedIsIn(playerPed, false), GetHashKey('flatbed')) then
				StartNPCJob()
			end
		end
	end
end, false)
RegisterKeyMapping('+npcmeh', 'Mehanicar - pokreni NPC posao', 'keyboard', 'DELETE')

-- Key Controls
Citizen.CreateThread(function()
	local waitara = 2000
	while true do
		Citizen.Wait(waitara)
		if ESX.PlayerData.job and ESX.PlayerData.job.name == 'mechanic' then
			if CurrentAction then
				waitara = 0
				ESX.ShowHelpNotification(CurrentActionMsg)

				if IsControlJustReleased(0, 38) then

					if CurrentAction == 'mechanic_actions_menu' then
						OpenMechanicActionsMenu()
					elseif CurrentAction == 'delete_vehicle' then

						if Config.EnableSocietyOwnedVehicles then

							local vehicleProps = ESX.Game.GetVehicleProperties(CurrentActionData.vehicle)
							TriggerServerEvent('esx_society:putVehicleInGarage', 'mechanic', vehicleProps)

						else

							if
								GetEntityModel(vehicle) == GetHashKey('flatbed')   or
								GetEntityModel(vehicle) == GetHashKey('towtruck2') or
								GetEntityModel(vehicle) == GetHashKey('slamvan3')
							then
								TriggerServerEvent('esx_service:disableService', 'mechanic')
							end

						end

						ESX.Game.DeleteVehicle(CurrentActionData.vehicle)

					elseif CurrentAction == 'remove_entity' then
						DeleteEntity(CurrentActionData.entity)
					end

					CurrentAction = nil
				end
			else
				waitara = 2000
			end
		else
			waitara = 2000
		end
	end
end)

AddEventHandler('esx:onPlayerDeath', function(data)
	isDead = true
end)

AddEventHandler('playerSpawned', function(spawn)
	isDead = false
end)

RegisterNetEvent('mafije:ZabraniF6')
AddEventHandler('mafije:ZabraniF6', function(br)
	Zabranio = br
end)