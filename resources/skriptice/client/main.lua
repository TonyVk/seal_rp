local Keys = {
  ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
  ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
  ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
  ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
  ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
  ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
  ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
  ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
  ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

local ESX = nil
local PlayerData	= {}
local CurrentAction		= nil
local Valja = false
local perm = nil
local isDead = false
local NeKickaj = false
local prvispawn = false
local crouched = false
crouchKey = 26
local mp_pointing = false
local keyPressed = false
local showPlayerBlips = false
local ignorePlayerNameDistance = false
local playerNamesDist = 10
local UVozilu = false
local displayIDHeight = 1.5 --Height of ID above players head(starts at center body mass)
--Set Default Values for Colors
local red = 255
local green = 255
local blue = 255
local defaultScale = 0.5 -- Text scale
local color = { r = 230, g = 230, b = 230, a = 255 } -- Text color
local font = 0 -- Text font
local displayTime = 5000 -- Duration to display the text (in ms)
local distToDraw = 250 -- Min. distance to draw 
local pedDisplaying = {}
local UAnimaciji = false
local hostageAllowedWeapons = {
	"WEAPON_PISTOL",
	"WEAPON_COMBATPISTOL",
	--etc add guns you want
}
local holdingHostageInProgress = false
local holdingHostage = false
local beingHeldHostage = false
local takeHostageAnimNamePlaying = ""
local takeHostageAnimDictPlaying = ""
local takeHostageControlFlagPlaying = 0
local recoils = {
	[453432689] = 0.3, -- PISTOL
	[3219281620] = 0.3, -- PISTOL MK2
	[1593441988] = 0.2, -- COMBAT PISTOL
	[584646201] = 0.1, -- AP PISTOL
	[2578377531] = 0.6, -- PISTOL .50
	[324215364] = 0.2, -- MICRO SMG
	[736523883] = 0.1, -- SMG
	[2024373456] = 0.1, -- SMG MK2
	[4024951519] = 0.1, -- ASSAULT SMG
	[3220176749] = 0.2, -- ASSAULT RIFLE
	[961495388] = 0.2, -- ASSAULT RIFLE MK2
	[2210333304] = 0.1, -- CARBINE RIFLE
	[4208062921] = 0.1, -- CARBINE RIFLE MK2
	[2937143193] = 0.1, -- ADVANCED RIFLE
	[2634544996] = 0.1, -- MG
	[2144741730] = 0.1, -- COMBAT MG
	[3686625920] = 0.1, -- COMBAT MG MK2
	[487013001] = 0.4, -- PUMP SHOTGUN
	[1432025498] = 0.4, -- PUMP SHOTGUN MK2
	[2017895192] = 0.7, -- SAWNOFF SHOTGUN
	[3800352039] = 0.4, -- ASSAULT SHOTGUN
	[2640438543] = 0.2, -- BULLPUP SHOTGUN
	[911657153] = 0.1, -- STUN GUN
	[100416529] = 0.5, -- SNIPER RIFLE
	[205991906] = 0.7, -- HEAVY SNIPER
	[177293209] = 0.7, -- HEAVY SNIPER MK2
	[856002082] = 1.2, -- REMOTE SNIPER
	[2726580491] = 1.0, -- GRENADE LAUNCHER
	[1305664598] = 1.0, -- GRENADE LAUNCHER SMOKE
	[2982836145] = 0.0, -- RPG
	[1752584910] = 0.0, -- STINGER
	[1119849093] = 0.01, -- MINIGUN
	[3218215474] = 0.2, -- SNS PISTOL
	[2009644972] = 0.25, -- SNS PISTOL MK2
	[1627465347] = 0.1, -- GUSENBERG
	[3231910285] = 0.2, -- SPECIAL CARBINE
	[-1768145561] = 0.25, -- SPECIAL CARBINE MK2
	[3523564046] = 0.5, -- HEAVY PISTOL
	[2132975508] = 0.2, -- BULLPUP RIFLE
	[-2066285827] = 0.25, -- BULLPUP RIFLE MK2
	[137902532] = 0.4, -- VINTAGE PISTOL
	[-1746263880] = 0.4, -- DOUBLE ACTION REVOLVER
	[2828843422] = 0.7, -- MUSKET
	[984333226] = 0.2, -- HEAVY SHOTGUN
	[3342088282] = 0.3, -- MARKSMAN RIFLE
	[1785463520] = 0.35, -- MARKSMAN RIFLE MK2
	[1672152130] = 0, -- HOMING LAUNCHER
	[1198879012] = 0.9, -- FLARE GUN
	[171789620] = 0.2, -- COMBAT PDW
	[3696079510] = 0.9, -- MARKSMAN PISTOL
  	[1834241177] = 2.4, -- RAILGUN
	[3675956304] = 0.3, -- MACHINE PISTOL
	[3249783761] = 0.6, -- REVOLVER
	[-879347409] = 0.65, -- REVOLVER MK2
	[4019527611] = 0.7, -- DOUBLE BARREL SHOTGUN
	[1649403952] = 0.3, -- COMPACT RIFLE
	[317205821] = 0.2, -- AUTO SHOTGUN
	[125959754] = 0.5, -- COMPACT LAUNCHER
	[3173288789] = 0.1, -- MINI SMG		
}
local Slusa = false
local volume = GetProfileSetting(306) / 100
local previousVolume = volume
local ZadnjiPritisak = 0
local Upozorio = false
local open = false

INPUT_CONTEXT = 51
local isSentenced = false
local communityServiceFinished = false
local actionsRemaining = 0
local availableActions = {}
local disable_actions = false

local vassoumodel = "prop_tool_broom"
local vassour_net = nil

local spatulamodel = "bkr_prop_coke_spatula_04"
local spatula_net = nil

local pedInSameVehicleLast=false
local RVDvehicle = nil
local RVDlastVehicle
local RVDvehicleClass
local fCollisionDamageMult = 0.0
local fDeformationDamageMult = 0.0
local fEngineDamageMult = 0.0
local fBrakeForce = 1.0
local isBrakingForward = false
local isBrakingReverse = false

local healthEngineLast = 1000.0
local healthEngineCurrent = 1000.0
local healthEngineNew = 1000.0
local healthEngineDelta = 0.0
local healthEngineDeltaScaled = 0.0

local healthBodyLast = 1000.0
local healthBodyCurrent = 1000.0
local healthBodyNew = 1000.0
local healthBodyDelta = 0.0
local healthBodyDeltaScaled = 0.0

local healthPetrolTankLast = 1000.0
local healthPetrolTankCurrent = 1000.0
local healthPetrolTankNew = 1000.0
local healthPetrolTankDelta = 0.0
local healthPetrolTankDeltaScaled = 0.0
local tireBurstLuckyNumber

local Dozvoljeno = true

-------------------CARRY PEOPLE
local carryingBackInProgress = false
local carryAnimNamePlaying = ""
local carryAnimDictPlaying = ""
local carryControlFlagPlaying = 0

RegisterCommand("nosi",function(source, args)
	if not carryingBackInProgress then
		local player = PlayerPedId()	
		lib = 'missfinale_c2mcs_1'
		anim1 = 'fin_c2_mcs_1_camman'
		lib2 = 'nm'
		anim2 = 'firemans_carry'
		distans = 0.15
		distans2 = 0.27
		height = 0.63
		spin = 0.0		
		length = 100000
		controlFlagMe = 49
		controlFlagTarget = 33
		animFlagTarget = 1
		local closestPlayer = GetClosestPlayer(3)
		target = GetPlayerServerId(closestPlayer)
		if closestPlayer ~= -1 and closestPlayer ~= nil then
			carryingBackInProgress = true
			TriggerServerEvent('CarryPeople:sync', closestPlayer, lib,lib2, anim1, anim2, distans, distans2, height,target,length,spin,controlFlagMe,controlFlagTarget,animFlagTarget)
		else
			drawNativeNotification("Nema igraca u blizini!")
		end
	else
		carryingBackInProgress = false
		ClearPedSecondaryTask(PlayerPedId())
		DetachEntity(PlayerPedId(), true, false)
		local closestPlayer = GetClosestPlayer(3)
		target = GetPlayerServerId(closestPlayer)
		if target ~= 0 then 
			TriggerServerEvent("CarryPeople:stop",target)
		end
	end
end,false)

RegisterNetEvent('CarryPeople:syncTarget')
AddEventHandler('CarryPeople:syncTarget', function(target, animationLib, animation2, distans, distans2, height, length,spin,controlFlag)
	local playerPed = PlayerPedId()
	local targetPed = GetPlayerPed(GetPlayerFromServerId(target))
	carryingBackInProgress = true
	RequestAnimDict(animationLib)

	while not HasAnimDictLoaded(animationLib) do
		Citizen.Wait(10)
	end
	if spin == nil then spin = 180.0 end
	AttachEntityToEntity(PlayerPedId(), targetPed, 0, distans2, distans, height, 0.5, 0.5, spin, false, false, false, false, 2, false)
	if controlFlag == nil then controlFlag = 0 end
	TaskPlayAnim(playerPed, animationLib, animation2, 8.0, -8.0, length, controlFlag, 0, false, false, false)
	carryAnimNamePlaying = animation2
	carryAnimDictPlaying = animationLib
	carryControlFlagPlaying = controlFlag
end)

RegisterNetEvent('CarryPeople:syncMe')
AddEventHandler('CarryPeople:syncMe', function(animationLib, animation,length,controlFlag,animFlag)
	local playerPed = PlayerPedId()
	RequestAnimDict(animationLib)

	while not HasAnimDictLoaded(animationLib) do
		Citizen.Wait(10)
	end
	Wait(500)
	if controlFlag == nil then controlFlag = 0 end
	TaskPlayAnim(playerPed, animationLib, animation, 8.0, -8.0, length, controlFlag, 0, false, false, false)
	carryAnimNamePlaying = animation
	carryAnimDictPlaying = animationLib
	carryControlFlagPlaying = controlFlag
end)

RegisterNetEvent('CarryPeople:cl_stop')
AddEventHandler('CarryPeople:cl_stop', function()
	carryingBackInProgress = false
	ClearPedSecondaryTask(PlayerPedId())
	DetachEntity(PlayerPedId(), true, false)
end)

Citizen.CreateThread(function()
	while true do
		if carryingBackInProgress then 
			while not IsEntityPlayingAnim(PlayerPedId(), carryAnimDictPlaying, carryAnimNamePlaying, 3) do
				TaskPlayAnim(PlayerPedId(), carryAnimDictPlaying, carryAnimNamePlaying, 8.0, -8.0, 100000, carryControlFlagPlaying, 0, false, false, false)
				Citizen.Wait(0)
			end
		end
		Wait(150)
	end
end)

function GetPlayers()
    local players = {}

    for i = 0, 255 do
        if NetworkIsPlayerActive(i) then
            table.insert(players, i)
        end
    end

    return players
end

function GetClosestPlayer(radius)
    local players = GetPlayers()
    local closestDistance = -1
    local closestPlayer = -1
    local ply = PlayerPedId()
    local plyCoords = GetEntityCoords(ply, 0)

    for index,value in ipairs(players) do
        local target = GetPlayerPed(value)
        if(target ~= ply) then
            local targetCoords = GetEntityCoords(GetPlayerPed(value), 0)
            local distance = GetDistanceBetweenCoords(targetCoords['x'], targetCoords['y'], targetCoords['z'], plyCoords['x'], plyCoords['y'], plyCoords['z'], true)
            if(closestDistance == -1 or closestDistance > distance) then
                closestPlayer = value
                closestDistance = distance
            end
        end
    end
	--print("closest player is dist: " .. tostring(closestDistance))
	if closestDistance <= radius then
		return closestPlayer
	else
		return nil
	end
end

function drawNativeNotification(text)
	ESX.ShowNotification(text)
end

RegisterNetEvent('iens:Dozvoljeno')
AddEventHandler('iens:Dozvoljeno', function(br)
	Dozvoljeno = br
end)

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) 
            ESX = obj 
        end)
        Citizen.Wait(0)
    end
	--esx_getout
	--TriggerServerEvent("esx_getout:DajAdmina")
	ESX.TriggerServerCallback('esx-races:DohvatiPermisiju', function(br)
		perm = br
	end)
end)

Citizen.CreateThread(function()
	while ESX == nil do
        Citizen.Wait(0)
    end
	while true do
        --This is the Application ID (Replace this with you own)
		SetDiscordAppId(693292673058078740)

        --Here you will have to put the image name for the "large" icon.
		SetDiscordRichPresenceAsset('logo')
        
        --(11-11-2018) New Natives:
		
        --Here you can add hover text for the "large" icon.
        SetDiscordRichPresenceAssetText('https://discord.gg/hugorp')
		SetDiscordRichPresenceAction(0, "Pridruzi se", "fivem://ip")
		while ESX == nil do
			Wait(0)
		end
		ESX.TriggerServerCallback('discord:DohvatiIgrace', function(br)
			local str = "Igraci: "..br.."/128"
			SetRichPresence(str)
		end)

        --It updates every one minute just in case.
		Citizen.Wait(300000)
	end
end)


local function isPedDrivingAVehicle()
	local ped = GetPlayerPed(-1)
	RVDvehicle = GetVehiclePedIsIn(ped, false)
	if IsPedInAnyVehicle(ped, false) then
		-- Check if ped is in driver seat
		if GetPedInVehicleSeat(RVDvehicle, -1) == ped then
			local class = GetVehicleClass(RVDvehicle)
			-- We don't want planes, helicopters, bicycles and trains
			if class ~= 15 and class ~= 16 and class ~=21 and class ~=13 then
				return true
			end
		end
	end
	return false
end

local function fscale(inputValue, originalMin, originalMax, newBegin, newEnd, curve)
	local OriginalRange = 0.0
	local NewRange = 0.0
	local zeroRefCurVal = 0.0
	local normalizedCurVal = 0.0
	local rangedValue = 0.0
	local invFlag = 0

	if (curve > 10.0) then curve = 10.0 end
	if (curve < -10.0) then curve = -10.0 end

	curve = (curve * -.1)
	curve = 10.0 ^ curve

	if (inputValue < originalMin) then
	  inputValue = originalMin
	end
	if inputValue > originalMax then
	  inputValue = originalMax
	end

	OriginalRange = originalMax - originalMin

	if (newEnd > newBegin) then
		NewRange = newEnd - newBegin
	else
	  NewRange = newBegin - newEnd
	  invFlag = 1
	end

	zeroRefCurVal = inputValue - originalMin
	normalizedCurVal  =  zeroRefCurVal / OriginalRange

	if (originalMin > originalMax ) then
	  return 0
	end

	if (invFlag == 0) then
		rangedValue =  ((normalizedCurVal ^ curve) * NewRange) + newBegin
	else
		rangedValue =  newBegin - ((normalizedCurVal ^ curve) * NewRange)
	end

	return rangedValue
end



local function tireBurstLottery()
	local tireBurstNumber = math.random(tireBurstMaxNumber)
	if tireBurstNumber == tireBurstLuckyNumber then
		-- We won the lottery, lets burst a tire.
		if GetVehicleTyresCanBurst(RVDvehicle) == false then return end
		local numWheels = GetVehicleNumberOfWheels(RVDvehicle)
		local affectedTire
		if numWheels == 2 then
			affectedTire = (math.random(2)-1)*4		-- wheel 0 or 4
		elseif numWheels == 4 then
			affectedTire = (math.random(4)-1)
			if affectedTire > 1 then affectedTire = affectedTire + 2 end	-- 0, 1, 4, 5
		elseif numWheels == 6 then
			affectedTire = (math.random(6)-1)
		else
			affectedTire = 0
		end
		SetVehicleTyreBurst(RVDvehicle, affectedTire, false, 1000.0)
		tireBurstLuckyNumber = math.random(tireBurstMaxNumber)			-- Select a new number to hit, just in case some numbers occur more often than others
	end
end


RegisterNetEvent('iens:repair')
AddEventHandler('iens:repair', function()
	local ped = GetPlayerPed(-1)
	RVDvehicle = GetVehiclePedIsIn(ped, false)
	SetVehicleUndriveable(RVDvehicle,false)
	SetVehicleFixed(RVDvehicle)
	healthBodyLast=1000.0
	healthEngineLast=1000.0
	healthPetrolTankLast=1000.0
	SetVehicleEngineOn(RVDvehicle, true, false )
end)

RegisterNetEvent('iens:notAllowed')
AddEventHandler('iens:notAllowed', function()
	notification("~r~You don't have permission to repair vehicles")
end)

RegisterNetEvent('markeri:OdradioSpawn')
AddEventHandler('markeri:OdradioSpawn', function()
	Wait(3000)
	TriggerServerEvent('esx_markeras:checkIfSentenced')
end)

function FillActionTable(last_action)

	while #availableActions < 5 do

		local service_does_not_exist = true

		local random_selection = Config.ServiceLocations[math.random(1,#Config.ServiceLocations)]

		for i = 1, #availableActions do
			if availableActions[i] ~= nil then
				if random_selection.coords.x == availableActions[i].coords.x and random_selection.coords.y == availableActions[i].coords.y and random_selection.coords.z == availableActions[i].coords.z then

					service_does_not_exist = false

				end
			end
		end

		if last_action ~= nil and random_selection.coords.x == last_action.coords.x and random_selection.coords.y == last_action.coords.y and random_selection.coords.z == last_action.coords.z then
			service_does_not_exist = false
		end

		if service_does_not_exist then
			table.insert(availableActions, random_selection)
		end

	end

end


RegisterNetEvent('esx_markeras:inCommunityService')
AddEventHandler('esx_markeras:inCommunityService', function(actions_remaining)
	if isSentenced then
		return
	end

	actionsRemaining = actions_remaining

	FillActionTable()
	print(":: Available Actions: " .. #availableActions)



	ApplyPrisonerSkin()
	ESX.Game.Teleport(PlayerPedId(), Config.ServiceLocation)
	isSentenced = true
	communityServiceFinished = false

	Citizen.CreateThread(function()
		while actionsRemaining > 0 and communityServiceFinished ~= true do
			Citizen.Wait(10000)
			if actionsRemaining > 0 then
				local playerPed = PlayerPedId()
				if IsPedInAnyVehicle(playerPed, false) then
					ClearPedTasksImmediately(playerPed)
				end
				local kord = GetEntityCoords(playerPed)
				if GetDistanceBetweenCoords(kord, Config.ServiceLocation.x, Config.ServiceLocation.y, Config.ServiceLocation.z, true) > 45 then
					ESX.Game.Teleport(playerPed, Config.ServiceLocation)
					TriggerEvent('chat:addMessage', { args = { _U('judge'), _U('escape_attempt') }, color = { 147, 196, 109 } })
				end
			end
		end
	end)
	PokreniPetlju()
end)

function PokreniPetlju()
	Citizen.CreateThread(function()
		while isSentenced do
			Citizen.Wait(1)

			if actionsRemaining > 0 then
				draw2dText( _U('remaining_msg', ESX.Math.Round(actionsRemaining)), { 0.175, 0.955 } )
				DrawAvailableActions()
				DisableViolentActions()

				local pCoords    = GetEntityCoords(PlayerPedId())

				for i = 1, #availableActions do
					if availableActions[i] ~= nil then
						local distance = GetDistanceBetweenCoords(pCoords, availableActions[i].coords, true)

						if distance < 1.5 then
							DisplayHelpText(_U('press_to_start'))


							if(IsControlJustReleased(1, 38))then
								tmp_action = availableActions[i]
								RemoveAction(tmp_action)
								FillActionTable(tmp_action)
								disable_actions = true

								TriggerServerEvent('esx_markeras:completeService')

								if (tmp_action.type == "cleaning") then
									local cSCoords = GetOffsetFromEntityInWorldCoords(GetPlayerPed(PlayerId()), 0.0, 0.0, -5.0)
									local vassouspawn = CreateObject(GetHashKey(vassoumodel), cSCoords.x, cSCoords.y, cSCoords.z, false, false, false)
									while not DoesEntityExist(vassouspawn) do
										Wait(50)
									end
									ESX.Streaming.RequestAnimDict("amb@world_human_janitor@male@idle_a", function()
											TaskPlayAnim(PlayerPedId(), "amb@world_human_janitor@male@idle_a", "idle_a", 8.0, -8.0, -1, 0, 0, false, false, false)
											AttachEntityToEntity(vassouspawn,GetPlayerPed(PlayerId()),GetPedBoneIndex(GetPlayerPed(PlayerId()), 28422),-0.005,0.0,0.0,360.0,360.0,0.0,1,1,0,1,0,1)
											vassour_net = vassouspawn
										end)

										ESX.SetTimeout(10000, function()
											disable_actions = false
											DetachEntity(vassour_net, 1, 1)
											DeleteEntity(vassour_net)
											ESX.Game.DeleteObject(vassouspawn)
											vassour_net = nil
											ClearPedTasks(PlayerPedId())
											ESX.TriggerServerCallback('esx_markeras:DohvatiMarkere', function(br)
												if br ~= nil then
													actionsRemaining = tonumber(br)
													if actionsRemaining == 0 then
														TriggerServerEvent("esx_markeras:finishCommunityService")
													end
												end
											end)
										end)

								end

								if (tmp_action.type == "gardening") then
									local cSCoords = GetOffsetFromEntityInWorldCoords(GetPlayerPed(PlayerId()), 0.0, 0.0, -5.0)
									local spatulaspawn = CreateObject(GetHashKey(spatulamodel), cSCoords.x, cSCoords.y, cSCoords.z, false, false, false)
									while not DoesEntityExist(spatulaspawn) do
										Wait(50)
									end
									TaskStartScenarioInPlace(PlayerPedId(), "world_human_gardener_plant", 0, false)
									AttachEntityToEntity(spatulaspawn,GetPlayerPed(PlayerId()),GetPedBoneIndex(GetPlayerPed(PlayerId()), 28422),-0.005,0.0,0.0,190.0,190.0,-50.0,1,1,0,1,0,1)
									spatula_net = spatulaspawn

									ESX.SetTimeout(14000, function()
										disable_actions = false
										DetachEntity(spatula_net, 1, 1)
										DeleteEntity(spatula_net)
										ESX.Game.DeleteObject(spatulaspawn)
										spatula_net = nil
										ClearPedTasks(PlayerPedId())
										ESX.TriggerServerCallback('esx_markeras:DohvatiMarkere', function(br)
											if br ~= nil then
												actionsRemaining = tonumber(br)
												if actionsRemaining == 0 then
													TriggerServerEvent("esx_markeras:finishCommunityService")
												end
											end
										end)
									end)
								end
							end
						end
					end
				end
			end
		end
		if communityServiceFinished then
			communityServiceFinished = false
			ESX.Game.Teleport(PlayerPedId(), Config.ReleaseLocation)
			isSentenced = false
			actionsRemaining = 0
			ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
				TriggerEvent('skinchanger:loadSkin', skin)
			end)
		end
	end)
end


RegisterNetEvent('esx_markeras:finishCommunityService')
AddEventHandler('esx_markeras:finishCommunityService', function(source)
	communityServiceFinished = true
	isSentenced = false
	actionsRemaining = 0
end)


function RemoveAction(action)

	local action_pos = -1

	for i=1, #availableActions do
		if availableActions[i] ~= nil then
			if action.coords.x == availableActions[i].coords.x and action.coords.y == availableActions[i].coords.y and action.coords.z == availableActions[i].coords.z then
				action_pos = i
			end
		end
	end

	if action_pos ~= -1 then
		table.remove(availableActions, action_pos)
	else
		print("User tried to remove an unavailable action")
	end

end

function DisplayHelpText(str)
	SetTextComponentFormat("STRING")
	AddTextComponentString(str)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end


function DrawAvailableActions()

	for i = 1, #availableActions do
--{ r = 50, g = 50, b = 204 }
		--DrawMarker(21, Config.ServiceLocations[i].coords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 255, 0, 0, 100, false, true, 2, true, false, false, true)
		if availableActions[i] ~= nil then
			DrawMarker(21, availableActions[i].coords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 50, 50, 204, 100, false, true, 2, true, false, false, false)
		end

		--DrawMarker(20, Config.ServiceLocations[i].coords, -1, 0.0, 0.0, 0, 0.0, 0.0, 1.0, 1.0, 1.0, 0, 162, 250, 80, true, true, 2, 0, 0, 0, 0)
	end

end






function DisableViolentActions()

	local playerPed = PlayerPedId()

	if disable_actions == true then
		DisableAllControlActions(0)
	end

	--RemoveAllPedWeapons(playerPed, true)

	DisableControlAction(2, 37, true) -- disable weapon wheel (Tab)
	DisablePlayerFiring(playerPed,true) -- Disables firing all together if they somehow bypass inzone Mouse Disable
    DisableControlAction(0, 106, true) -- Disable in-game mouse controls
    DisableControlAction(0, 140, true)
	DisableControlAction(0, 141, true)
	DisableControlAction(0, 142, true)

	if IsDisabledControlJustPressed(2, 37) then --if Tab is pressed, send error message
		SetCurrentPedWeapon(playerPed,GetHashKey("WEAPON_UNARMED"),true) -- if tab is pressed it will set them to unarmed (this is to cover the vehicle glitch until I sort that all out)
	end

	if IsDisabledControlJustPressed(0, 106) then --if LeftClick is pressed, send error message
		SetCurrentPedWeapon(playerPed,GetHashKey("WEAPON_UNARMED"),true) -- If they click it will set them to unarmed
	end

end


function ApplyPrisonerSkin()
	local playerPed = PlayerPedId()

	if DoesEntityExist(playerPed) then

		Citizen.CreateThread(function()

			TriggerEvent('skinchanger:getSkin', function(skin)
				if skin.sex == 0 then
					TriggerEvent('skinchanger:loadClothes', skin, Config.Uniforms['prison_wear'].male)
				else
					TriggerEvent('skinchanger:loadClothes', skin, Config.Uniforms['prison_wear'].female)
				end
			end)

			SetPedArmour(playerPed, 0)
			ClearPedBloodDamage(playerPed)
			ResetPedVisibleDamage(playerPed)
			ClearPedLastWeaponDamage(playerPed)
			ResetPedMovementClipset(playerPed, 0)

		end)
	end
end

function draw2dText(text, pos)
	SetTextFont(4)
	SetTextProportional(1)
	SetTextScale(0.45, 0.45)
	SetTextColour(255, 255, 255, 255)
	SetTextDropShadow(0, 0, 0, 0, 255)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()

	BeginTextCommandDisplayText('STRING')
	AddTextComponentSubstringPlayerName(text)
	EndTextCommandDisplayText(table.unpack(pos))
end

-- Open ID card
RegisterNetEvent('jsfour-idcard:open')
AddEventHandler('jsfour-idcard:open', function( data, type )
	open = true
	local MugShot = exports["MugShotBase64"]:GetMugShotBase64(PlayerPedId(), false)
	SendNUIMessage({
		action = "open",
		array  = data,
		slika = MugShot,
		type   = type
	})
	Citizen.CreateThread(function()
		local otvorioGa = false
		while not otvorioGa do
			Citizen.Wait(0)
			if open then
				if IsControlJustReleased(0, 322) or IsControlJustReleased(0, 177) then
					SendNUIMessage({
						action = "close"
					})
					open = false
					otvorioGa = true
				end
			else
				SendNUIMessage({
					action = "close"
				})
				open = false
				otvorioGa = true
			end
		end
	end)
end)

-- ### A menu (THIS IS AN EXAMPLE)
function openMenu()
	ESX.UI.Menu.Open(
	  'default', GetCurrentResourceName(), 'id_card_menu',
	  {
		  title    = 'ID menu',
		  elements = {
			  {label = 'Provjerite svoju osobnu', value = 'checkID'},
			  {label = 'Pokazite svoju osobnu', value = 'showID'},
			  {label = 'Provjerite svoju vozacku dozvolu', value = 'checkDriver'},
			  {label = 'Pokazite svoju vozacku dozvolu', value = 'showDriver'},
			  {label = 'Provjerite svoju dozvolu za oruzje', value = 'checkFirearms'},
			  {label = 'Pokazite svoju dozvolu za oruzje', value = 'showFirearms'},
		  }
	  },
	  function(data, menu)
		  local val = data.current.value
		  
		  if val == 'checkID' then
			  TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(PlayerId()))
		  elseif val == 'checkDriver' then
			  TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(PlayerId()), 'driver')
		  elseif val == 'checkFirearms' then
			  TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(PlayerId()), 'weapon')
		  else
			  local player, distance = ESX.Game.GetClosestPlayer()
			  
			  if distance ~= -1 and distance <= 3.0 then
				  if val == 'showID' then
				  	TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(player))
				  elseif val == 'showDriver' then
			  		TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(player), 'driver')
				  elseif val == 'showFirearms' then
			  		TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(player), 'weapon')
				  end
			  else
				ESX.ShowNotification('Nema igraca u blizini')
			  end
		  end
	  end,
	  function(data, menu)
		  menu.close()
	  end
  	)
end

RegisterKeyMapping('dozvole', 'dozvole', 'keyboard', 'f5')
RegisterCommand('dozvole', function()
	openMenu()
end)

RegisterCommand("uzmitaoca",function()
	takeHostage()
end)

RegisterCommand("taoc",function()
	takeHostage()
end)

function takeHostage()
	ClearPedSecondaryTask(GetPlayerPed(-1))
	DetachEntity(GetPlayerPed(-1), true, false)
	for i=1, #hostageAllowedWeapons do
		if HasPedGotWeapon(GetPlayerPed(-1), GetHashKey(hostageAllowedWeapons[i]), false) then
			if GetAmmoInPedWeapon(GetPlayerPed(-1), GetHashKey(hostageAllowedWeapons[i])) > 0 then
				canTakeHostage = true 
				foundWeapon = GetHashKey(hostageAllowedWeapons[i])
				break
			end 					
		end
	end

	if not canTakeHostage then 
		drawNativeNotification("Treba vam pistolj sa municijom da mozete uzeti taoca!")
	end

	if not holdingHostageInProgress and canTakeHostage then		
		local player = PlayerPedId()	
		--lib = 'misssagrab_inoffice'
		--anim1 = 'hostage_loop'
		--lib2 = 'misssagrab_inoffice'
		--anim2 = 'hostage_loop_mrk'
		lib = 'anim@gangops@hostage@'
		anim1 = 'perp_idle'
		lib2 = 'anim@gangops@hostage@'
		anim2 = 'victim_idle'
		distans = 0.11 --Higher = closer to camera
		distans2 = -0.24 --higher = left
		height = 0.0
		spin = 0.0		
		length = 100000
		controlFlagMe = 49
		controlFlagTarget = 49
		animFlagTarget = 50
		attachFlag = true 
		local closestPlayer = GetClosestPlayer(2)
		target = GetPlayerServerId(closestPlayer)
		if closestPlayer ~= -1 and closestPlayer ~= nil then
			SetCurrentPedWeapon(GetPlayerPed(-1), foundWeapon, true)
			holdingHostageInProgress = true
			holdingHostage = true 
			TriggerServerEvent('cmg3_animations:sync', closestPlayer, lib,lib2, anim1, anim2, distans, distans2, height,target,length,spin,controlFlagMe,controlFlagTarget,animFlagTarget,attachFlag)
		else
			drawNativeNotification("Nema nikoga blizu vas!")
		end 
	end
	canTakeHostage = false 
end 

RegisterNetEvent('cmg3_animations:syncTarget')
AddEventHandler('cmg3_animations:syncTarget', function(target, animationLib, animation2, distans, distans2, height, length,spin,controlFlag,animFlagTarget,attach)
	local playerPed = GetPlayerPed(-1)
	local targetPed = GetPlayerPed(GetPlayerFromServerId(target))
	if holdingHostageInProgress then 
		holdingHostageInProgress = false 
	else 
		holdingHostageInProgress = true
	end
	beingHeldHostage = true 
	RequestAnimDict(animationLib)

	while not HasAnimDictLoaded(animationLib) do
		Citizen.Wait(10)
	end
	if spin == nil then spin = 180.0 end
	if attach then 
		AttachEntityToEntity(GetPlayerPed(-1), targetPed, 0, distans2, distans, height, 0.5, 0.5, spin, false, false, false, false, 2, false)
	else 
	end
	
	if controlFlag == nil then controlFlag = 0 end
	
	if animation2 == "victim_fail" then 
		SetEntityHealth(GetPlayerPed(-1),0)
		DetachEntity(GetPlayerPed(-1), true, false)
		TaskPlayAnim(playerPed, animationLib, animation2, 8.0, -8.0, length, controlFlag, 0, false, false, false)
		beingHeldHostage = false 
		holdingHostageInProgress = false 
	elseif animation2 == "shoved_back" then 
		holdingHostageInProgress = false 
		DetachEntity(GetPlayerPed(-1), true, false)
		TaskPlayAnim(playerPed, animationLib, animation2, 8.0, -8.0, length, controlFlag, 0, false, false, false)
		beingHeldHostage = false 
	else
		TaskPlayAnim(playerPed, animationLib, animation2, 8.0, -8.0, length, controlFlag, 0, false, false, false)	
	end
	takeHostageAnimNamePlaying = animation2
	takeHostageAnimDictPlaying = animationLib
	takeHostageControlFlagPlaying = controlFlag
end)

RegisterNetEvent('cmg3_animations:syncMe')
AddEventHandler('cmg3_animations:syncMe', function(animationLib, animation,length,controlFlag,animFlag)
	local playerPed = GetPlayerPed(-1)
	ClearPedSecondaryTask(GetPlayerPed(-1))
	RequestAnimDict(animationLib)
	while not HasAnimDictLoaded(animationLib) do
		Citizen.Wait(10)
	end
	if controlFlag == nil then controlFlag = 0 end
	TaskPlayAnim(playerPed, animationLib, animation, 8.0, -8.0, length, controlFlag, 0, false, false, false)
	takeHostageAnimNamePlaying = animation
	takeHostageAnimDictPlaying = animationLib
	takeHostageControlFlagPlaying = controlFlag
	if animation == "perp_fail" then 
		SetPedShootsAtCoord(GetPlayerPed(-1), 0.0, 0.0, 0.0, 0)
		holdingHostageInProgress = false 
	end
	if animation == "shove_var_a" then 
		Wait(900)
		ClearPedSecondaryTask(GetPlayerPed(-1))
		holdingHostageInProgress = false 
	end
end)

RegisterNetEvent('cmg3_animations:cl_stop')
AddEventHandler('cmg3_animations:cl_stop', function()
	holdingHostageInProgress = false
	beingHeldHostage = false 
	holdingHostage = false 
	ClearPedSecondaryTask(GetPlayerPed(-1))
	DetachEntity(GetPlayerPed(-1), true, false)
end)

RegisterKeyMapping('cucni', 'cucni', 'keyboard', 'C')
RegisterCommand('cucni', function()
	if not UVozilu then
		if not isDead then 
			if not IsPauseMenuActive() then 
				local ped = PlayerPedId()
				if not IsPedReloading(ped) then 
					ESX.Streaming.RequestAnimSet("move_ped_crouched")
					ESX.Streaming.RequestAnimSet("MOVE_M@TOUGH_GUY@")		
					if ( crouched ) then 
						ResetPedMovementClipset( ped )
						ResetPedStrafeClipset(ped)
						SetPedMovementClipset( ped,"MOVE_M@TOUGH_GUY@", 0.5)
						crouched = false
					elseif ( not crouched ) then
						SetPedMovementClipset( ped, "move_ped_crouched", 0.55 )
						SetPedStrafeClipset(ped, "move_ped_crouched_strafing")
						crouched = true 
					end 
				end
			end
		end
	end
end)

Citizen.CreateThread(function()
	local waitara = 500
	while true do
		if not UVozilu then
			waitara = 0
			if not isDead then 
				DisableControlAction(0, crouchKey, true)
			else
				if crouched then
					crouched = false
				end
			end
		else
			waitara = 500
		end
		Citizen.Wait(waitara)
	end
end)

Citizen.CreateThread(function()
	while true do
		local waitara = 500
		if holdingHostage or beingHeldHostage then 
			waitara = 0
			while not IsEntityPlayingAnim(GetPlayerPed(-1), takeHostageAnimDictPlaying, takeHostageAnimNamePlaying, 3) do
				TaskPlayAnim(GetPlayerPed(-1), takeHostageAnimDictPlaying, takeHostageAnimNamePlaying, 8.0, -8.0, 100000, takeHostageControlFlagPlaying, 0, false, false, false)
				Citizen.Wait(0)
			end
		end
		if not UVozilu then
			waitara = 0
			if IsPedArmed(PlayerPedId(), 6) then
				DisableControlAction(1, 140, true)
				DisableControlAction(1, 141, true)
				DisableControlAction(1, 142, true)
			end
		end
		Citizen.Wait(waitara)
	end
end)

function GetPlayers()
    local players = {}

	for _, i in ipairs(GetActivePlayers()) do
        table.insert(players, i)
    end

    return players
end

function GetClosestPlayer(radius)
    local players = GetPlayers()
    local closestDistance = -1
    local closestPlayer = -1
    local ply = GetPlayerPed(-1)
    local plyCoords = GetEntityCoords(ply, 0)

    for index,value in ipairs(players) do
        local target = GetPlayerPed(value)
        if(target ~= ply) then
            local targetCoords = GetEntityCoords(GetPlayerPed(value), 0)
            local distance = GetDistanceBetweenCoords(targetCoords['x'], targetCoords['y'], targetCoords['z'], plyCoords['x'], plyCoords['y'], plyCoords['z'], true)
            if(closestDistance == -1 or closestDistance > distance) then
                closestPlayer = value
                closestDistance = distance
            end
        end
    end
	--print("closest player is dist: " .. tostring(closestDistance))
	if closestDistance <= radius then
		return closestPlayer
	else
		return nil
	end
end

function releaseHostage()
	local player = PlayerPedId()	
	lib = 'reaction@shove'
	anim1 = 'shove_var_a'
	lib2 = 'reaction@shove'
	anim2 = 'shoved_back'
	distans = 0.11 --Higher = closer to camera
	distans2 = -0.24 --higher = left
	height = 0.0
	spin = 0.0		
	length = 100000
	controlFlagMe = 120
	controlFlagTarget = 0
	animFlagTarget = 1
	attachFlag = false
	local closestPlayer = GetClosestPlayer(2)
	target = GetPlayerServerId(closestPlayer)
	if closestPlayer ~= 0 then
		TriggerServerEvent('cmg3_animations:sync', closestPlayer, lib,lib2, anim1, anim2, distans, distans2, height,target,length,spin,controlFlagMe,controlFlagTarget,animFlagTarget,attachFlag)
	end
end 

function killHostage()
	local player = PlayerPedId()	
	lib = 'anim@gangops@hostage@'
	anim1 = 'perp_fail'
	lib2 = 'anim@gangops@hostage@'
	anim2 = 'victim_fail'
	distans = 0.11 --Higher = closer to camera
	distans2 = -0.24 --higher = left
	height = 0.0
	spin = 0.0		
	length = 0.2
	controlFlagMe = 168
	controlFlagTarget = 0
	animFlagTarget = 1
	attachFlag = false
	local closestPlayer = GetClosestPlayer(2)
	target = GetPlayerServerId(closestPlayer)
	if target ~= 0 then
		TriggerServerEvent('cmg3_animations:sync', closestPlayer, lib,lib2, anim1, anim2, distans, distans2, height,target,length,spin,controlFlagMe,controlFlagTarget,animFlagTarget,attachFlag)
	end	
end 

RegisterNetEvent('baseevents:enteredVehicle')
AddEventHandler('baseevents:enteredVehicle', function(currentVehicle, currentSeat, modelName, netId)
	UVozilu = true
	if currentSeat == -1 then
		Citizen.CreateThread(function()
			while UVozilu do
				Citizen.Wait(0)
				if Dozvoljeno then
					if Config.torqueMultiplierEnabled or Config.sundayDriver or Config.limpMode then
						if pedInSameVehicleLast and RVDvehicle ~= nil then
							local factor = 1.0
							if Config.torqueMultiplierEnabled and healthEngineNew < 900 then
								factor = (healthEngineNew+200.0) / 1100
							end
							if Config.sundayDriver and GetVehicleClass(RVDvehicle) ~= 14 then -- Not for boats
								local accelerator = GetControlValue(2,71)
								local brake = GetControlValue(2,72)
								local speed = GetEntitySpeedVector(RVDvehicle, true)['y']
								-- Change Braking force
								local brk = fBrakeForce
								if speed >= 1.0 then
									-- Going forward
									if accelerator > 127 then
										-- Forward and accelerating
										local acc = fscale(accelerator, 127.0, 254.0, 0.1, 1.0, 10.0-(Config.sundayDriverAcceleratorCurve*2.0))
										factor = factor * acc
									end
									if brake > 127 then
										-- Forward and braking
										isBrakingForward = true
										brk = fscale(brake, 127.0, 254.0, 0.01, fBrakeForce, 10.0-(Config.sundayDriverBrakeCurve*2.0))
									end
								elseif speed <= -1.0 then
									-- Going reverse
									if brake > 127 then
										-- Reversing and accelerating (using the brake)
										local rev = fscale(brake, 127.0, 254.0, 0.1, 1.0, 10.0-(Config.sundayDriverAcceleratorCurve*2.0))
										factor = factor * rev
									end
									if accelerator > 127 then
										-- Reversing and braking (Using the accelerator)
										isBrakingReverse = true
										brk = fscale(accelerator, 127.0, 254.0, 0.01, fBrakeForce, 10.0-(Config.sundayDriverBrakeCurve*2.0))
									end
								else
									-- Stopped or almost stopped or sliding sideways
									local entitySpeed = GetEntitySpeed(RVDvehicle)
									if entitySpeed < 1 then
										-- Not sliding sideways
										if isBrakingForward == true then
											--Stopped or going slightly forward while braking
											DisableControlAction(2,72,true) -- Disable Brake until user lets go of brake
											SetVehicleForwardSpeed(RVDvehicle,speed*0.98)
											SetVehicleBrakeLights(RVDvehicle,true)
										end
										if isBrakingReverse == true then
											--Stopped or going slightly in reverse while braking
											DisableControlAction(2,71,true) -- Disable reverse Brake until user lets go of reverse brake (Accelerator)
											SetVehicleForwardSpeed(RVDvehicle,speed*0.98)
											SetVehicleBrakeLights(RVDvehicle,true)
										end
										if isBrakingForward == true and GetDisabledControlNormal(2,72) == 0 then
											-- We let go of the brake
											isBrakingForward=false
										end
										if isBrakingReverse == true and GetDisabledControlNormal(2,71) == 0 then
											-- We let go of the reverse brake (Accelerator)
											isBrakingReverse=false
										end
									end
								end
								if brk > fBrakeForce - 0.02 then brk = fBrakeForce end -- Make sure we can brake max.
								SetVehicleHandlingFloat(RVDvehicle, 'CHandlingData', 'fBrakeForce', brk)  -- Set new Brake Force multiplier
							end
							if Config.limpMode == true and healthEngineNew < Config.engineSafeGuard + 5 then
								factor = Config.limpModeMultiplier
							end
							SetVehicleEngineTorqueMultiplier(RVDvehicle, factor)
						end
					end
					if Config.preventVehicleFlip then
						local roll = GetEntityRoll(RVDvehicle)
						if (roll > 75.0 or roll < -75.0) and GetEntitySpeed(RVDvehicle) < 2 then
							DisableControlAction(2,59,true) -- Disable left/right
							DisableControlAction(2,60,true) -- Disable up/down
						end
					end
				end
			end
		end)
		
		Citizen.CreateThread(function()
			while UVozilu do
				Citizen.Wait(50)
				if Dozvoljeno then
					local ped = GetPlayerPed(-1)
					if isPedDrivingAVehicle() then
						RVDvehicle = GetVehiclePedIsIn(ped, false)
						RVDvehicleClass = GetVehicleClass(RVDvehicle)
						healthEngineCurrent = GetVehicleEngineHealth(RVDvehicle)
						if healthEngineCurrent == 1000 then healthEngineLast = 1000.0 end
						healthEngineNew = healthEngineCurrent
						healthEngineDelta = healthEngineLast - healthEngineCurrent
						healthEngineDeltaScaled = healthEngineDelta * Config.damageFactorEngine * Config.classDamageMultiplier[RVDvehicleClass]
		
						healthBodyCurrent = GetVehicleBodyHealth(RVDvehicle)
						if healthBodyCurrent == 1000 then healthBodyLast = 1000.0 end
						healthBodyNew = healthBodyCurrent
						healthBodyDelta = healthBodyLast - healthBodyCurrent
						healthBodyDeltaScaled = healthBodyDelta * Config.damageFactorBody * Config.classDamageMultiplier[RVDvehicleClass]
		
						healthPetrolTankCurrent = GetVehiclePetrolTankHealth(RVDvehicle)
						if Config.compatibilityMode and healthPetrolTankCurrent < 1 then
							--	SetVehiclePetrolTankHealth(RVDvehicle, healthPetrolTankLast)
							--	healthPetrolTankCurrent = healthPetrolTankLast
							healthPetrolTankLast = healthPetrolTankCurrent
						end
						if healthPetrolTankCurrent == 1000 then healthPetrolTankLast = 1000.0 end
						healthPetrolTankNew = healthPetrolTankCurrent
						healthPetrolTankDelta = healthPetrolTankLast-healthPetrolTankCurrent
						healthPetrolTankDeltaScaled = healthPetrolTankDelta * Config.damageFactorPetrolTank * Config.classDamageMultiplier[RVDvehicleClass]
		
						if healthEngineCurrent > Config.engineSafeGuard+1 then
							SetVehicleUndriveable(RVDvehicle,false)
						end
		
						if healthEngineCurrent <= Config.engineSafeGuard+1 and Config.limpMode == false then
							SetVehicleUndriveable(RVDvehicle,true)
						end
		
						-- If ped spawned a new RVDvehicle while in a RVDvehicle or teleported from one RVDvehicle to another, handle as if we just entered the car
						if RVDvehicle ~= RVDlastVehicle then
							pedInSameVehicleLast = false
						end
		
		
						if pedInSameVehicleLast == true then
							-- Damage happened while in the car = can be multiplied
		
							-- Only do calculations if any damage is present on the car. Prevents weird behavior when fixing using trainer or other script
							if healthEngineCurrent ~= 1000.0 or healthBodyCurrent ~= 1000.0 or healthPetrolTankCurrent ~= 1000.0 then
		
								-- Combine the delta values (Get the largest of the three)
								local healthEngineCombinedDelta = math.max(healthEngineDeltaScaled, healthBodyDeltaScaled, healthPetrolTankDeltaScaled)
		
								-- If huge damage, scale back a bit
								if healthEngineCombinedDelta > (healthEngineCurrent - Config.engineSafeGuard) then
									healthEngineCombinedDelta = healthEngineCombinedDelta * 0.7
								end
		
								-- If complete damage, but not catastrophic (ie. explosion territory) pull back a bit, to give a couple of seconds og engine runtime before dying
								if healthEngineCombinedDelta > healthEngineCurrent then
									healthEngineCombinedDelta = healthEngineCurrent - (Config.cascadingFailureThreshold / 5)
								end
		
		
								------- Calculate new value
		
								healthEngineNew = healthEngineLast - healthEngineCombinedDelta
		
		
								------- Sanity Check on new values and further manipulations
		
								-- If somewhat damaged, slowly degrade until slightly before cascading failure sets in, then stop
		
								if healthEngineNew > (Config.cascadingFailureThreshold + 5) and healthEngineNew < Config.degradingFailureThreshold then
									healthEngineNew = healthEngineNew-(0.038 * Config.degradingHealthSpeedFactor)
								end
		
								-- If Damage is near catastrophic, cascade the failure
								if healthEngineNew < Config.cascadingFailureThreshold then
									healthEngineNew = healthEngineNew-(0.1 * Config.cascadingFailureSpeedFactor)
								end
		
								-- Prevent Engine going to or below zero. Ensures you can reenter a damaged car.
								if healthEngineNew < Config.engineSafeGuard then
									healthEngineNew = Config.engineSafeGuard
								end
		
								-- Prevent Explosions
								if Config.compatibilityMode == false and healthPetrolTankCurrent < 750 then
									healthPetrolTankNew = 750.0
								end
		
								-- Prevent negative body damage.
								if healthBodyNew < 0  then
									healthBodyNew = 0.0
								end
							end
						else
							-- Just got in the RVDvehicle. Damage can not be multiplied this round
							-- Set RVDvehicle handling data
							fDeformationDamageMult = GetVehicleHandlingFloat(RVDvehicle, 'CHandlingData', 'fDeformationDamageMult')
							fBrakeForce = GetVehicleHandlingFloat(RVDvehicle, 'CHandlingData', 'fBrakeForce')
							local newFDeformationDamageMult = fDeformationDamageMult ^ Config.deformationExponent	-- Pull the handling file value closer to 1
							if Config.deformationMultiplier ~= -1 then SetVehicleHandlingFloat(RVDvehicle, 'CHandlingData', 'fDeformationDamageMult', newFDeformationDamageMult * Config.deformationMultiplier) end  -- Multiply by our factor
							if Config.weaponsDamageMultiplier ~= -1 then SetVehicleHandlingFloat(RVDvehicle, 'CHandlingData', 'fWeaponDamageMult', Config.weaponsDamageMultiplier/Config.damageFactorBody) end -- Set weaponsDamageMultiplier and compensate for damageFactorBody
		
							--Get the CollisionDamageMultiplier
							fCollisionDamageMult = GetVehicleHandlingFloat(RVDvehicle, 'CHandlingData', 'fCollisionDamageMult')
							--Modify it by pulling all number a towards 1.0
							local newFCollisionDamageMultiplier = fCollisionDamageMult ^ Config.collisionDamageExponent	-- Pull the handling file value closer to 1
							SetVehicleHandlingFloat(RVDvehicle, 'CHandlingData', 'fCollisionDamageMult', newFCollisionDamageMultiplier)
		
							--Get the EngineDamageMultiplier
							fEngineDamageMult = GetVehicleHandlingFloat(RVDvehicle, 'CHandlingData', 'fEngineDamageMult')
							--Modify it by pulling all number a towards 1.0
							local newFEngineDamageMult = fEngineDamageMult ^ Config.engineDamageExponent	-- Pull the handling file value closer to 1
							SetVehicleHandlingFloat(RVDvehicle, 'CHandlingData', 'fEngineDamageMult', newFEngineDamageMult)
		
							-- If body damage catastrophic, reset somewhat so we can get new damage to multiply
							if healthBodyCurrent < Config.cascadingFailureThreshold then
								healthBodyNew = Config.cascadingFailureThreshold
							end
							pedInSameVehicleLast = true
						end
		
						-- set the actual new values
						if healthEngineNew ~= healthEngineCurrent then
							SetVehicleEngineHealth(RVDvehicle, healthEngineNew)
						end
						if healthBodyNew ~= healthBodyCurrent then SetVehicleBodyHealth(RVDvehicle, healthBodyNew) end
						if healthPetrolTankNew ~= healthPetrolTankCurrent then SetVehiclePetrolTankHealth(RVDvehicle, healthPetrolTankNew) end
		
						-- Store current values, so we can calculate delta next time around
						healthEngineLast = healthEngineNew
						healthBodyLast = healthBodyNew
						healthPetrolTankLast = healthPetrolTankNew
						RVDlastVehicle=RVDvehicle
						if Config.randomTireBurstInterval ~= 0 and GetEntitySpeed(RVDvehicle) > 10 then tireBurstLottery() end
					else
						if pedInSameVehicleLast == true then
							-- We just got out of the vehicle
							RVDlastVehicle = GetVehiclePedIsIn(ped, true)	
							if RVDlastVehicle ~= 0 then			
								if Config.deformationMultiplier ~= -1 then SetVehicleHandlingFloat(RVDlastVehicle, 'CHandlingData', 'fDeformationDamageMult', fDeformationDamageMult) end -- Restore deformation multiplier
								SetVehicleHandlingFloat(RVDlastVehicle, 'CHandlingData', 'fBrakeForce', fBrakeForce)  -- Restore Brake Force multiplier
								if Config.weaponsDamageMultiplier ~= -1 then SetVehicleHandlingFloat(RVDlastVehicle, 'CHandlingData', 'fWeaponDamageMult', Config.weaponsDamageMultiplier) end	-- Since we are out of the vehicle, we should no longer compensate for bodyDamageFactor
								SetVehicleHandlingFloat(RVDlastVehicle, 'CHandlingData', 'fCollisionDamageMult', fCollisionDamageMult) -- Restore the original CollisionDamageMultiplier
								SetVehicleHandlingFloat(RVDlastVehicle, 'CHandlingData', 'fEngineDamageMult', fEngineDamageMult) -- Restore the original EngineDamageMultiplier
							end
						end
						pedInSameVehicleLast = false
					end
				end
			end
		end)
	end
end)

RegisterNetEvent('baseevents:leftVehicle')
AddEventHandler('baseevents:leftVehicle', function(currentVehicle, currentSeat, modelName, netId)
	UVozilu = false
end)

function drawNativeNotification(text)
    SetTextComponentFormat('STRING')
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

RegisterCommand("k", function(source, args, rawCommandString)
	PredajSe()
end, false)

function PredajSe()
    local player = GetPlayerPed( -1 )
	if ( DoesEntityExist( player ) and not IsEntityDead( player )) then 
        loadAnimDict( "random@arrests" )
		loadAnimDict( "random@arrests@busted" )
		if ( IsEntityPlayingAnim( player, "random@arrests@busted", "idle_a", 3 ) ) then 
			TaskPlayAnim( player, "random@arrests@busted", "exit", 8.0, 1.0, -1, 2, 0, 0, 0, 0 )
			Wait (3000)
            TaskPlayAnim( player, "random@arrests", "kneeling_arrest_get_up", 8.0, 1.0, -1, 128, 0, 0, 0, 0 )
			UAnimaciji = false
        else
            TaskPlayAnim( player, "random@arrests", "idle_2_hands_up", 8.0, 1.0, -1, 2, 0, 0, 0, 0 )
			Wait (4000)
            TaskPlayAnim( player, "random@arrests", "kneeling_arrest_idle", 8.0, 1.0, -1, 2, 0, 0, 0, 0 )
			Wait (500)
			TaskPlayAnim( player, "random@arrests@busted", "enter", 8.0, 1.0, -1, 2, 0, 0, 0, 0 )
			Wait (1000)
			TaskPlayAnim( player, "random@arrests@busted", "idle_a", 8.0, 1.0, -1, 9, 0, 0, 0, 0 )
			UAnimaciji = true
			Citizen.CreateThread(function()
				while UAnimaciji do
					Citizen.Wait(0)
					if IsEntityPlayingAnim(GetPlayerPed(PlayerId()), "random@arrests@busted", "idle_a", 3) then
						DisableControlAction(1, 140, true)
						DisableControlAction(1, 141, true)
						DisableControlAction(1, 142, true)
						DisableControlAction(0,21,true)
					end
				end
			end)
        end     
    end
end

function loadAnimDict( dict )
    while ( not HasAnimDictLoaded( dict ) ) do
        RequestAnimDict( dict )
        Citizen.Wait( 5 )
    end
end 

-- --------------------------------------------
-- Functions
-- --------------------------------------------

-- OBJ : draw text in 3d
-- PARAMETERS :
--      - coords : world coordinates to where you want to draw the text
--      - text : the text to display
local function DrawText3D2(coords, text)
    local camCoords = GetGameplayCamCoord()
    local dist = #(coords - camCoords)
    
    -- Experimental math to scale the text down
    local scale = 200 / (GetGameplayCamFov() * dist)

    --if onScreen then

        -- Format the text
        SetTextColour(color.r, color.g, color.b, color.a)
        SetTextScale(0.0, defaultScale * scale)
        SetTextDropshadow(0, 0, 0, 0, 55)
        SetTextDropShadow()
        SetTextCentre(true)

        -- Diplay the text
        BeginTextCommandDisplayText("STRING")
        AddTextComponentSubstringPlayerName(text)
        SetDrawOrigin(coords, 0)
        EndTextCommandDisplayText(0.0, 0.0)
        ClearDrawOrigin()

    --end
end

-- OBJ : handle the drawing of text above a ped head
-- PARAMETERS :
--      - coords : world coordinates to where you want to draw the text
--      - text : the text to display
local function Display(ped, text, koord)

    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local dist = #(playerCoords - koord)

    if dist <= distToDraw then

        pedDisplaying[ped] = (pedDisplaying[ped] or 1) + 1

        -- Timer
        local display = true

        Citizen.CreateThread(function()
            Wait(displayTime)
            display = false
        end)

        -- Display
        local offset = 0.8 + pedDisplaying[ped] * 0.1
        while display do
            if HasEntityClearLosToEntity(playerPed, ped, 17 ) then
                local x, y, z = table.unpack(GetEntityCoords(ped))
                z = z + offset
                DrawText3D2(vector3(x, y, z), text)
            end
            Wait(0)
        end

        pedDisplaying[ped] = pedDisplaying[ped] - 1

    end
end

-- --------------------------------------------
-- Event
-- --------------------------------------------

RegisterNetEvent('3dme:shareDisplay')
AddEventHandler('3dme:shareDisplay', function(text, serverId, koord)
    local ped = GetPlayerPed(GetPlayerFromServerId(serverId))
    Display(ped, text, koord)
end)

function DrawText3D(x,y,z, text) 
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)

    local scale = (1/dist)*2
    local fov = (1/GetGameplayCamFov())*100
    local scale = scale*fov
    
    if onScreen then
        SetTextScale(0.0*scale, 0.55*scale)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextColour(red, green, blue, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
		World3dToScreen2d(x,y,z, 0) --Added Here
        DrawText(_x,_y)
    end
end

local function startPointing()
    local ped = GetPlayerPed(-1)
    RequestAnimDict("anim@mp_point")
    while not HasAnimDictLoaded("anim@mp_point") do
        Wait(0)
    end
    SetPedCurrentWeaponVisible(ped, 0, 1, 1, 1)
    SetPedConfigFlag(ped, 36, 1)
    Citizen.InvokeNative(0x2D537BA194896636, ped, "task_mp_pointing", 0.5, 0, "anim@mp_point", 24)
    RemoveAnimDict("anim@mp_point")
end

local function stopPointing()
    local ped = GetPlayerPed(-1)
    Citizen.InvokeNative(0xD01015C7316AE176, ped, "Stop")
    if not IsPedInjured(ped) then
        ClearPedSecondaryTask(ped)
    end
    if not IsPedInAnyVehicle(ped, 1) then
        SetPedCurrentWeaponVisible(ped, 1, 1, 1, 1)
    end
    SetPedConfigFlag(ped, 36, 0)
    ClearPedSecondaryTask(PlayerPedId())
end

local once = true
local oldval = false
local oldvalped = false

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
  PlayerData.job = job
end)

RegisterNetEvent('esx_repairkit:onUse')
AddEventHandler('esx_repairkit:onUse', function()
	local playerPed		= GetPlayerPed(-1)
	local coords		= GetEntityCoords(playerPed)

	if IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 5.0) then
		local vehicle = nil

		if IsPedInAnyVehicle(playerPed, false) then
			vehicle = GetVehiclePedIsIn(playerPed, false)
		else
			vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71)
		end

		if DoesEntityExist(vehicle) then
			if Config.IgnoreAbort then
				TriggerServerEvent('esx_repairkit:removeKit')
			end
			TaskStartScenarioInPlace(playerPed, "PROP_HUMAN_BUM_BIN", 0, true)

			Citizen.CreateThread(function()
				ThreadID = GetIdOfThisThread()
				CurrentAction = 'repair'

				Citizen.Wait(Config.RepairTime * 1000)

				if CurrentAction ~= nil then
					SetVehicleFixed(vehicle)
					SetVehicleDeformationFixed(vehicle)
					SetVehicleUndriveable(vehicle, false)
					SetVehicleEngineOn(vehicle, true, true)
					ClearPedTasksImmediately(playerPed)

					ESX.ShowNotification(_U('finished_repair'))
				end

				if not Config.IgnoreAbort then
					TriggerServerEvent('esx_repairkit:removeKit')
				end

				CurrentAction = nil
				TerminateThisThread()
			end)
		end

		Citizen.CreateThread(function()
			Citizen.Wait(0)

			if CurrentAction ~= nil then
				SetTextComponentFormat('STRING')
				AddTextComponentString(_U('abort_hint'))
				DisplayHelpTextFromStringLabel(0, 0, 1, -1)

				if IsControlJustReleased(0, Keys["X"]) then
					TerminateThread(ThreadID)
					ESX.ShowNotification(_U('aborted_repair'))
					CurrentAction = nil
				end
			end

		end)
	else
		ESX.ShowNotification(_U('no_vehicle_nearby'))
	end
end)

--esx_getout
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(100)
		local ped = PlayerPedId()
		if UVozilu then
			if Valja == false then
				local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)
				local hash = GetEntityModel(vehicle)
				local vehicleClass = GetVehicleClass(vehicle)
				PlayerData = ESX.GetPlayerData()
				if vehicleClass == 19 then
					if GetPedInVehicleSeat(vehicle, -1) == ped then
						if perm < 1 then
							ClearPedTasksImmediately(ped)
							TaskLeaveVehicle(ped,vehicle,0)
							ESX.ShowNotification("Ne mozete voziti vojna vozila!")
						else
							Valja = true
						end
					end
				elseif vehicleClass == 18 then
					if GetPedInVehicleSeat(vehicle, -1) == ped then
						if PlayerData.job.name ~= 'police' and PlayerData.job.name ~= 'ambulance' and PlayerData.job.name ~= 'mechanic' and PlayerData.job.name ~= 'hitman' and PlayerData.job.name ~= 'sipa' and perm < 1 and hash ~= GetHashKey("firetruk") and hash ~= GetHashKey("lamg") then
							ClearPedTasksImmediately(ped)
							TaskLeaveVehicle(ped,vehicle,0)
							ESX.ShowNotification("Ne mozete voziti sluzbena vozila!")
						else
							Valja = true
						end
					end
				else
					Valja = true
				end
			end
		else
			if Valja == true then
				Valja = false
			end
		end
	end
end)

--PvP
AddEventHandler("playerSpawned", function()
    NetworkSetFriendlyFireOption(true)
    SetCanAttackFriendly(PlayerPedId(), true, true)
	--TriggerServerEvent("esx_getout:DajAdmina")
	if not prvispawn then
		SendNUIMessage({
			prikazi = true,
			id = GetPlayerServerId(PlayerId())
		})
		ESX.TriggerServerCallback('esx-races:DohvatiPermisiju', function(br)
			perm = br
		end)
		TriggerServerEvent("skriptice:SpremiLogin")
		prvispawn = true
	end
	isDead = false
end)

local scopedWeapons = 
{
    100416529,  -- WEAPON_SNIPERRIFLE
    205991906,  -- WEAPON_HEAVYSNIPER
    3342088282, -- WEAPON_MARKSMANRIFLE
    177293209,   -- WEAPON_HEAVYSNIPER MKII
    1785463520  -- WEAPON_MARKSMANRIFLE_MK2
}

function HashInTable( hash )
    for k, v in pairs( scopedWeapons ) do 
        if ( hash == v ) then 
            return true 
        end 
    end 

    return false 
end 

function ManageReticle()
    local ped = GetPlayerPed( -1 )
    local _, hash = GetCurrentPedWeapon( ped, true )
        if not HashInTable( hash ) then 
            HideHudComponentThisFrame( 14 )
		end 
end 

RegisterCommand('+pokazi', function()
    if not mp_pointing then
		startPointing()
		mp_pointing = true
	else
		stopPointing()
		mp_pointing = false
	end
end, false)
RegisterKeyMapping('+pokazi', 'Pokazi prstom', 'keyboard', 'b')

Citizen.CreateThread(function()
	while ESX == nil do
		Wait(1)
		SendNUIMessage({
			prikazi = true,
			id = GetPlayerServerId(PlayerId())
		})
		ESX.TriggerServerCallback('esx-races:DohvatiPermisiju', function(br)
			perm = br
		end)
		prvispawn = true
	end
	local waitara = 500
	while true do
		Citizen.Wait(waitara)
		local naso = 0
		--print(weapon) -- To get the weapon hash by pressing F8 in game
		
		if once then
            once = false
        end
		
		if holdingHostage then
			naso = 1
			waitara = 0
			if IsEntityDead(GetPlayerPed(-1)) then	
				holdingHostage = false
				holdingHostageInProgress = false 
				local closestPlayer = GetClosestPlayer(2)
				target = GetPlayerServerId(closestPlayer)
				TriggerServerEvent("cmg3_animations:stop",target)
				Wait(100)
				releaseHostage()
			end 
			DisableControlAction(0,24,true) -- disable attack
			DisableControlAction(0,25,true) -- disable aim
			DisableControlAction(0,47,true) -- disable weapon
			DisableControlAction(0,58,true) -- disable weapon
			DisablePlayerFiring(GetPlayerPed(-1),true)
			local playerCoords = GetEntityCoords(GetPlayerPed(-1))
			DrawText3D(playerCoords.x,playerCoords.y,playerCoords.z,"Pritisnite [G] da pustite taoca ili [H] da ga ubijete")
			if IsDisabledControlJustPressed(0,47) then --release	
				holdingHostage = false
				holdingHostageInProgress = false 
				local closestPlayer = GetClosestPlayer(2)
				target = GetPlayerServerId(closestPlayer)
				TriggerServerEvent("cmg3_animations:stop",target)
				Wait(100)
				releaseHostage()
			elseif IsDisabledControlJustPressed(0,74) then --kill 			
				holdingHostage = false
				holdingHostageInProgress = false 		
				local closestPlayer = GetClosestPlayer(2)
				target = GetPlayerServerId(closestPlayer)
				TriggerServerEvent("cmg3_animations:stop",target)				
				killHostage()
			end
		end
		if beingHeldHostage then 
			naso = 1
			waitara = 0
			DisableControlAction(0,21,true) -- disable sprint
			DisableControlAction(0,24,true) -- disable attack
			DisableControlAction(0,25,true) -- disable aim
			DisableControlAction(0,47,true) -- disable weapon
			DisableControlAction(0,58,true) -- disable weapon
			DisableControlAction(0,263,true) -- disable melee
			DisableControlAction(0,264,true) -- disable melee
			DisableControlAction(0,257,true) -- disable melee
			DisableControlAction(0,140,true) -- disable melee
			DisableControlAction(0,141,true) -- disable melee
			DisableControlAction(0,142,true) -- disable melee
			DisableControlAction(0,143,true) -- disable melee
			DisableControlAction(0,75,true) -- disable exit vehicle
			DisableControlAction(27,75,true) -- disable exit vehicle  
			DisableControlAction(0,22,true) -- disable jump
			DisableControlAction(0,32,true) -- disable move up
			DisableControlAction(0,268,true)
			DisableControlAction(0,33,true) -- disable move down
			DisableControlAction(0,269,true)
			DisableControlAction(0,34,true) -- disable move left
			DisableControlAction(0,270,true)
			DisableControlAction(0,35,true) -- disable move right
			DisableControlAction(0,271,true)
		end
		if mp_pointing then
			if IsTaskMoveNetworkActive(PlayerPedId()) then
				naso = 1
				waitara = 1
				if not IsPedOnFoot(PlayerPedId()) then
					stopPointing()
				else
					local ped = GetPlayerPed(-1)
					local camPitch = GetGameplayCamRelativePitch()
					if camPitch < -70.0 then
						camPitch = -70.0
					elseif camPitch > 42.0 then
						camPitch = 42.0
					end
					camPitch = (camPitch + 70.0) / 112.0

					local camHeading = GetGameplayCamRelativeHeading()
					local cosCamHeading = Cos(camHeading)
					local sinCamHeading = Sin(camHeading)
					if camHeading < -180.0 then
						camHeading = -180.0
					elseif camHeading > 180.0 then
						camHeading = 180.0
					end
					camHeading = (camHeading + 180.0) / 360.0

					local blocked = 0
					local nn = 0

					local coords = GetOffsetFromEntityInWorldCoords(ped, (cosCamHeading * -0.2) - (sinCamHeading * (0.4 * camHeading + 0.3)), (sinCamHeading * -0.2) + (cosCamHeading * (0.4 * camHeading + 0.3)), 0.6)
					local ray = Cast_3dRayPointToPoint(coords.x, coords.y, coords.z - 0.2, coords.x, coords.y, coords.z + 0.2, 0.4, 95, ped, 7);
					nn,blocked,coords,coords = GetRaycastResult(ray)

					Citizen.InvokeNative(0xD5BB4025AE449A4E, ped, "Pitch", camPitch)
					Citizen.InvokeNative(0xD5BB4025AE449A4E, ped, "Heading", camHeading * -1.0 + 1.0)
					Citizen.InvokeNative(0xB0A6CFD2C69C1088, ped, "isBlocked", blocked)
					Citizen.InvokeNative(0xB0A6CFD2C69C1088, ped, "isFirstPerson", Citizen.InvokeNative(0xEE778F8C7E1142E2, Citizen.InvokeNative(0x19CAFA3C87F7C2FF)) == 4)

				end
			end
		end
		local ped = GetPlayerPed( -1 )
		local weapon = GetSelectedPedWeapon(ped)
		if weapon == GetHashKey("WEAPON_FIREEXTINGUISHER") then		
			if IsPedShooting(ped) then
				SetPedInfiniteAmmo(ped, true, GetHashKey("WEAPON_FIREEXTINGUISHER"))
			end
		end
		-- Disable melee while aiming (may be not working)
		if IsPedArmed(ped, 6) then
			naso = 1
			waitara = 0
			if IsPedShooting(ped) then
				if not IsPedDoingDriveby(ped) then
					local _,wep = GetCurrentPedWeapon(ped)
					_,cAmmo = GetAmmoInClip(ped, wep)
					if recoils[wep] and recoils[wep] ~= 0 then
						tv = 0
						repeat 
							Wait(0)
							p = GetGameplayCamRelativePitch()
							if GetFollowPedCamViewMode() ~= 4 then
								SetGameplayCamRelativePitch(p+0.1, 0.2)
							end
							tv = tv+0.1
						until tv >= recoils[wep]
					end
				end
				-- Disable ammo HUD
				local weapon = GetSelectedPedWeapon(ped)
				--DisplayAmmoThisFrame(false)
				
				-- Shakycam
				
				-- Pistol
				if weapon == GetHashKey("WEAPON_STUNGUN") then
					
						ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.01)
					
				
				elseif weapon == GetHashKey("WEAPON_FLAREGUN") then	
					
						ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.01)
					
				
				
				elseif weapon == GetHashKey("WEAPON_SNSPISTOL") then		
					
						ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.02)
					
				
				
				elseif weapon == GetHashKey("WEAPON_SNSPISTOL_MK2") then		
					
						ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.025)
					
				
				
				elseif weapon == GetHashKey("WEAPON_PISTOL") then		
					
						ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.025)
					
				
				
				elseif weapon == GetHashKey("WEAPON_PISTOL_MK2") then
					
						ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.03)
					
				
				
				elseif weapon == GetHashKey("WEAPON_APPISTOL") then
					
						ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.05)
					
				
				
				elseif weapon == GetHashKey("WEAPON_COMBATPISTOL") then		
					
						ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.03)
					
				
				
				elseif weapon == GetHashKey("WEAPON_PISTOL50") then
					
						ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.05)
					
				
				
				elseif weapon == GetHashKey("WEAPON_HEAVYPISTOL") then		
					
						ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.03)
					
				
				
				elseif weapon == GetHashKey("WEAPON_VINTAGEPISTOL") then		
					
						ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.025)
					
				
				
				elseif weapon == GetHashKey("WEAPON_MARKSMANPISTOL") then		
					
						ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.03)
					
				
				
				elseif weapon == GetHashKey("WEAPON_REVOLVER") then	
					
						ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.045)
					
				
				
				elseif weapon == GetHashKey("WEAPON_REVOLVER_MK2") then	
					
						ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.055)
					
				
				
				elseif weapon == GetHashKey("WEAPON_DOUBLEACTION") then	
					
						ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.025)
					
				
				-- SMG
				
				elseif weapon == GetHashKey("WEAPON_MICROSMG") then	
					
						ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.035)
					
				
				
				elseif weapon == GetHashKey("WEAPON_COMBATPDW") then			
					
						ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.045)
					
				
				
				elseif weapon == GetHashKey("WEAPON_SMG") then
					
						ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.045)
					
				
				
				elseif weapon == GetHashKey("WEAPON_SMG_MK2") then	
					
						ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.055)
					
				
				
				elseif weapon == GetHashKey("WEAPON_ASSAULTSMG") then	
					
						ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.050)
					
				
				
				elseif weapon == GetHashKey("WEAPON_MACHINEPISTOL") then		
					
						ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.035)
					
				
				
				elseif weapon == GetHashKey("WEAPON_MINISMG") then
					
						ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.035)
					
				
				
				elseif weapon == GetHashKey("WEAPON_MG") then
					
						ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.07)
					
				
				
				elseif weapon == GetHashKey("WEAPON_COMBATMG") then		
					
						ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.08)
					
				
				
				elseif weapon == GetHashKey("WEAPON_COMBATMG_MK2") then			
					
						ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.085)
					
				
				
				-- Rifles
				
				elseif weapon == GetHashKey("WEAPON_ASSAULTRIFLE") then			
					
						ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.07)
					
				
				
				elseif weapon == GetHashKey("WEAPON_ASSAULTRIFLE_MK2") then			
					
						ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.075)
					
				
				
				elseif weapon == GetHashKey("WEAPON_CARBINERIFLE") then	
					
						ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.06)
					
				
				
				elseif weapon == GetHashKey("WEAPON_CARBINERIFLE_MK2") then			
					
						ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.065)
					
				
				
				elseif weapon == GetHashKey("WEAPON_ADVANCEDRIFLE") then		
					
						ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.06)
					
				
				
				elseif weapon == GetHashKey("WEAPON_GUSENBERG") then		
					
						ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.05)
					
				
				
				elseif weapon == GetHashKey("WEAPON_SPECIALCARBINE") then		
					
						ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.06)
					
				
				
				elseif weapon == GetHashKey("WEAPON_SPECIALCARBINE_MK2") then		
					
						ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.075)
					
				
				
				elseif weapon == GetHashKey("WEAPON_BULLPUPRIFLE") then			
					
						ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.05)
					
				
				
				elseif weapon == GetHashKey("WEAPON_BULLPUPRIFLE_MK2") then			
					
						ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.065)
					
				
				
				elseif weapon == GetHashKey("WEAPON_COMPACTRIFLE") then		
					
						ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.05)
					
				
				
				-- Shotgun
				
				elseif weapon == GetHashKey("WEAPON_PUMPSHOTGUN") then
					
						ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.07)
					
				
				
				elseif weapon == GetHashKey("WEAPON_PUMPSHOTGUN_MK2") then
					
						ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.085)
					
				
				
				elseif weapon == GetHashKey("WEAPON_SAWNOFFSHOTGUN") then
					
						ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.06)
					
				
				
				elseif weapon == GetHashKey("WEAPON_ASSAULTSHOTGUN") then	
					
						ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.12)
					
				
				
				elseif weapon == GetHashKey("WEAPON_BULLPUPSHOTGUN") then		
					
						ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.08)
					
				
				
				elseif weapon == GetHashKey("WEAPON_DBSHOTGUN") then	
					
						ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.05)
					
				
				
				elseif weapon == GetHashKey("WEAPON_AUTOSHOTGUN") then	
					
						ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.08)
					
				
				
				elseif weapon == GetHashKey("WEAPON_MUSKET") then
					
						ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.04)
					
				
				
				elseif weapon == GetHashKey("WEAPON_HEAVYSHOTGUN") then	
					
						ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.13)
					
				
				
				-- Sniper
				
				elseif weapon == GetHashKey("WEAPON_SNIPERRIFLE") then
					
						ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.2)
					
				
				
				elseif weapon == GetHashKey("WEAPON_HEAVYSNIPER") then	
					
						ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.3)
					
				
				
				elseif weapon == GetHashKey("WEAPON_HEAVYSNIPER_MK2") then
					
						ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.35)
					
				
				
				elseif weapon == GetHashKey("WEAPON_MARKSMANRIFLE") then			
					
						ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.1)
					
				
				
				elseif weapon == GetHashKey("WEAPON_MARKSMANRIFLE_MK2") then			
					
						ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.1)
					
				
				
				-- Launcher
				
				elseif weapon == GetHashKey("WEAPON_GRENADELAUNCHER") then		
					
						ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.08)
					
				
				
				elseif weapon == GetHashKey("WEAPON_RPG") then
					
						ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.9)
					
				
				
				elseif weapon == GetHashKey("WEAPON_HOMINGLAUNCHER") then		
					
						ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.9)
					
				
				
				elseif weapon == GetHashKey("WEAPON_MINIGUN") then	
					
						ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.20)
					
				
				
				elseif weapon == GetHashKey("WEAPON_RAILGUN") then	
					
						ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 1.0)
						
					
				
				
				elseif weapon == GetHashKey("WEAPON_COMPACTLAUNCHER") then		
					
						ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.08)
					
				
				
				elseif weapon == GetHashKey("WEAPON_FIREWORK") then	
					
						ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.5)
				end
			end
		end
		if naso == 0 then
			waitara = 500
		end
	end
end)

local loka1 = vector3(-1382.0578613281, -614.68621826172, 31.497901916504)
local loka2 = vector3(370.29565429688, 277.03662109375, 91.189918518066)
--radio u klubu
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(5000)
		local kord = GetEntityCoords(PlayerPedId())
		if #(loka1-kord) <= 16.5 or #(loka2-kord) <= 16.5 then
			if Slusa == false then
				SendNUIMessage({
					pusti = true
				})
				SendNUIMessage({
					zvukic = true,
					vol = volume
				})
				Slusa = true
				Citizen.CreateThread(function()
					while Slusa do
						Citizen.Wait(1000)
						volume = GetProfileSetting(306)/10
						if previousVolume ~= volume then
							SendNUIMessage({
								zvukic = true,
								vol = volume
							})
							previousVolume = volume
						end
					end
				end)
			end
		else
			if Slusa == true then
				SendNUIMessage({
					zaustavi = true
				})
				Slusa = false
			end
		end
	end
end)

-- recoil script by bluethefurry / Blumlaut https://forum.fivem.net/t/betterrecoil-better-3rd-person-recoil-for-fivem/82894
-- I just added some missing weapons because of the doomsday update adding some MK2.
-- I can't manage to make negative hashes works, if someone make it works, please let me know =)

RegisterNetEvent("NeKickaj")
AddEventHandler("NeKickaj", function(br)
	NeKickaj = br
end)

AddEventHandler('esx:onPlayerDeath', function(data)
	isDead = true
end)

-- AFK Kick Time Limit (in seconds)
secondsUntilKick = 600

-- Warn players if 3/4 of the Time Limit ran up
kickWarning = true

-- CODE --

Citizen.CreateThread(function()
	while true do
		Wait(1000)
		playerPed = GetPlayerPed(-1)
		if playerPed then
			currentPos = GetEntityCoords(playerPed, true)
			ZadnjiPritisak = GetTimeSinceLastInput(0)
			if NeKickaj == false then
				if perm == 0 then
					if not isDead then
						if kickWarning and (ZadnjiPritisak > math.ceil(300000) and ZadnjiPritisak < math.ceil(301000)) then
							TriggerEvent("chatMessage", "WARNING", {255, 0, 0}, "^1Biti cete kickani za 5 minuta zbog toga sto ste AFK!")
							Upozorio = true
						end
						if ZadnjiPritisak >= 600000 then
							TriggerServerEvent("kickForBeingAnAFKDouchebag")
						end
						if currentPos == prevPos then
							if time > 0 then
								if kickWarning and time == math.ceil(secondsUntilKick / 4) then
									TriggerEvent("chatMessage", "WARNING", {255, 0, 0}, "^1Biti cete kickani za " .. time .. " sekundi zbog toga sto ste AFK!")
								end

								time = time - 1
							else
								TriggerServerEvent("kickForBeingAnAFKDouchebag")
							end
						else
							time = secondsUntilKick
						end
					end
				end
			end

			prevPos = currentPos
		end
	end
end)

RegisterNetEvent('es_admin:setPerm')
AddEventHandler('es_admin:setPerm', function()
	ESX.TriggerServerCallback('esx-races:DohvatiPermisiju', function(br)
		perm = br
	end)
end)