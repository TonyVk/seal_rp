ESX                             = nil
local hasAlreadyEnteredMarker = false
local lastZone                = nil
local CurrentAction           = nil
local CurrentActionMsg        = ''
local runspeed = 1.20 --(Change the run speed here !!! MAXIMUM IS 1.49 !!! )
local onDrugs = false
local locations = {}
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
local spawned = false
local displayed = false
local menuOpen = false
local process = true
local Droge = {}

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
    ESX.TriggerServerCallback('droge:DohvatiDroge', function(vr)
		Droge = vr
	end)
end)

RegisterNetEvent('droge:VratiDroge')
AddEventHandler('droge:VratiDroge', function(vr)
	Droge = vr
    if spawned then
        locations = {}
    end
    spawned = false
end)

RegisterCommand("uredidroge", function(source, args, raw)
	ESX.TriggerServerCallback('DajMiPermLevelCall', function(perm)
		if perm == 69 then
			ESX.UI.Menu.CloseAll()
			local elements = {
				{label = "Heroin", value = "heroin"}
			}

			ESX.UI.Menu.Open(
				'default', GetCurrentResourceName(), 'udr',
				{
					title    = "Izaberite drogu",
					align    = 'top-left',
					elements = elements,
				},
				function(data, menu)
					if data.current.value == "heroin" then
                        elements = {
                            {label = "Postavite koordinate skupljanja", value = 1},
                            {label = "Postavite koordinate prerade", value = 2}
                        }
            
                        ESX.UI.Menu.Open(
                            'default', GetCurrentResourceName(), 'udkor',
                            {
                                title    = "Izaberite opciju",
                                align    = 'top-left',
                                elements = elements,
                            },
                            function(data2, menu2)
                                local koord = GetEntityCoords(PlayerPedId())
                                TriggerServerEvent("droge:PostaviKoord", 1, data2.current.value, koord-vector3(0.0, 0.0, 1.0))
                                menu2.close()
                                menu.close()
                            end,
                            function(data2, menu2)
                                menu2.close()
                                menu.close()
                            end
                        )
                    end
				end,
				function(data, menu)
					menu.close()
				end
			)
		end
	end)
end, false)

-- Useitem thread
RegisterNetEvent('esx_koristiHeroin:useItem')
AddEventHandler('esx_koristiHeroin:useItem', function(itemName)
	if onDrugs == false then
		ESX.UI.Menu.CloseAll()

		if itemName == 'heroin' then
			onDrugs = true
			local lib, anim = 'anim@mp_player_intcelebrationmale@face_palm', 'face_palm'
			local playerPed = PlayerPedId()
			ESX.ShowNotification('Osjecate kako vam zivci pocinju raditi protiv vas...')
			TriggerServerEvent("esx_koristiHeroin:removeItem", "heroin")
			local playerPed = PlayerPedId()
			SetEntityHealth(playerPed, 150)
			SetPedArmour(playerPed, 25)
			SetRunSprintMultiplierForPlayer(PlayerId(), 0.5)
			ESX.Streaming.RequestAnimDict(lib, function()
				TaskPlayAnim(playerPed, lib, anim, 8.0, -8.0, -1, 32, 0, false, false, false)

				Citizen.Wait(500)
				while IsEntityPlayingAnim(playerPed, lib, anim, 3) do
					Citizen.Wait(0)
					DisableAllControlActions(0)
				end

				TriggerEvent('esx_koristiHeroin:runMan')
			end)
		end
	else
		ESX.ShowNotification("Vec ste pod utjecajom droge!")
	end
end)

AddEventHandler('esx:onPlayerDeath', function(data)
	if onDrugs == true then
		DoScreenFadeOut(1000)
		Citizen.Wait(1000)
		DoScreenFadeIn(1000)
		ClearTimecycleModifier()
		ResetPedMovementClipset(GetPlayerPed(-1), 0)
		SetRunSprintMultiplierForPlayer(PlayerId(),0.5)
		ClearAllPedProps(GetPlayerPed(-1), true)
		SetPedMotionBlur(GetPlayerPed(-1), false)
		ESX.ShowNotification('Utjecaj droge popusta')
    onDrugs = false
	end
end)

-- Cocaine effect (Run really fast)
RegisterNetEvent('esx_koristiHeroin:runMan')
AddEventHandler('esx_koristiHeroin:runMan', function()
    RequestAnimSet("move_m@hurry_butch@b")
    while not HasAnimSetLoaded("move_m@hurry_butch@b") do
        Citizen.Wait(0)
    end
	count = 0
    DoScreenFadeOut(1000)
    Citizen.Wait(1000)
    SetPedMotionBlur(GetPlayerPed(-1), true)
    SetTimecycleModifier("spectator5")
    SetPedMovementClipset(GetPlayerPed(-1), "move_m@hurry_butch@b", true)
	SetRunSprintMultiplierForPlayer(PlayerId(), 0.5)
    DoScreenFadeIn(1000)
	repeat
		Citizen.Wait(10000)
		count = count  + 1
	until count == 8
    DoScreenFadeOut(1000)
    Citizen.Wait(1000)
    DoScreenFadeIn(1000)
    ClearTimecycleModifier()
    ResetPedMovementClipset(GetPlayerPed(-1), 0)
	SetRunSprintMultiplierForPlayer(PlayerId(),1.0)
    ClearAllPedProps(GetPlayerPed(-1), true)
    SetPedMotionBlur(GetPlayerPed(-1), false)
    ESX.ShowNotification('Utjecaj droge popusta...')
    onDrugs = false
end)

Citizen.CreateThread( function()
	Citizen.Wait(10000)
	while true do
	    Citizen.Wait(1000)
        for i=1, #Droge, 1 do
            if Droge[i].vrsta == 1 and Droge[i].branje ~= nil then
                if #(GetEntityCoords(PlayerPedId())-Droge[i].branje) <= 200 then
                    if spawned == false then
                        TriggerEvent('Heroin:start')
                        TriggerEvent('Heroin:start')
                        TriggerEvent('Heroin:start')
                        TriggerEvent('Heroin:start')
                        TriggerEvent('Heroin:start')
                        TriggerEvent('Heroin:start')
                        TriggerEvent('Heroin:start')
                        TriggerEvent('Heroin:start')
                        TriggerEvent('Heroin:start')
                        TriggerEvent('Heroin:start')
                        TriggerEvent('Heroin:start')
                        spawned = true
                    end
                else
                    if spawned then
                        locations = {}
                    end
                    spawned = false
                end
            end
        end
	end
end)
			
AddEventHandler('heroin:hasEnteredMarker', function(zone)
	
end)

AddEventHandler('heroin:hasExitedMarker', function(zone)
	ESX.UI.Menu.CloseAll()    
    CurrentAction = nil
    CurrentActionMsg = ''
end)

Citizen.CreateThread(function()
	local waitara = 500
    while true do
        Citizen.Wait(waitara)
        local naso2 = 0
        local kordic = GetEntityCoords(PlayerPedId())
        
        local isInMarker  = false
        local currentZone = nil

        if isInMarker and not hasAlreadyEnteredMarker then
            hasAlreadyEnteredMarker = true
            lastZone                = currentZone
            TriggerEvent('heroin:hasEnteredMarker', currentZone)
        end

        if not isInMarker and hasAlreadyEnteredMarker then
            hasAlreadyEnteredMarker = false
            TriggerEvent('heroin:hasExitedMarker', lastZone)
        end
        if ESX ~= nil then
            for k in pairs(locations) do
                if #(locations[k]-kordic) < 150 then
                --if GetDistanceBetweenCoords(locations[k].x, locations[k].y, locations[k].z, GetEntityCoords(GetPlayerPed(-1))) < 150 then
                    waitara = 0
                    naso2 = 1
                    DrawMarker(3, locations[k], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0, 200, 0, 110, 0, 1, 0, 0)	
                    if #(locations[k]-kordic) < 1.0 then
                    --if GetDistanceBetweenCoords(locations[k].x, locations[k].y, locations[k].z, GetEntityCoords(GetPlayerPed(-1)), false) < 1.0 then
                        TriggerEvent('Heroin:new', k)
                        TaskStartScenarioInPlace(PlayerPedId(), 'world_human_gardener_plant', 0, false)
                        Citizen.Wait(2000)
                        ClearPedTasks(PlayerPedId())
                        ClearPedTasksImmediately(PlayerPedId())
                        local torba = 0
                        TriggerEvent('skinchanger:getSkin', function(skin)
                            torba = skin['bags_1']
                        end)
                        if torba == 40 or torba == 41 or torba == 44 or torba == 45 then
                            TriggerServerEvent('Heroin:get', true)
                        else
                            TriggerServerEvent('Heroin:get', false)
                        end
                    end
                
                end
            end
            for i=1, #Droge, 1 do
                if Droge[i].vrsta == 1 and Droge[i].prerada ~= nil then
                    if #(Droge[i].prerada-kordic) < 150 then
                        waitara = 0
                        naso2 = 1
                        DrawMarker(1, Droge[i].prerada, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.3, 1.3, 1.0, 0, 200, 0, 110, 0, 1, 0, 0)	
                        if #(Droge[i].prerada-kordic) < 2 then
                            Draw3DText( Droge[i].prerada.x, Droge[i].prerada.y, Droge[i].prerada.z, "~w~Proizvodnja Heroina~y~\nPritisnite [~b~E~y~] da krenete sa proizvodnjom heroina",4,0.15,0.1)
                            if IsControlJustReleased(0, Keys['E']) then
                                Citizen.CreateThread(function()
                                    Process()
                                end)
                            end
                        end
                        if (#(Droge[i].prerada-kordic) < 5) and (#(Droge[i].prerada-kordic) > 3) then
                            process = false
                        end
                    end
                end
            end
        end
        if CurrentAction ~= nil then
            SetTextComponentFormat('STRING')
            AddTextComponentString(CurrentActionMsg)
            DisplayHelpTextFromStringLabel(0, 0, 1, -1)
            if IsControlJustPressed(0, 38) then
                if CurrentAction == 'prodaj' then
                    CurrentAction = nil
                    TriggerServerEvent("heroin:ProdajHeroin")
                end
            end
        end
        if naso2 == 0 then
            waitara = 500
        end
    end
end)

function Draw3DText(x,y,z,textInput,fontId,scaleX,scaleY)
         local px,py,pz=table.unpack(GetGameplayCamCoords())
         local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)    
         local scale = (1/dist)*20
         local fov = (1/GetGameplayCamFov())*100
         local scale = scale*fov   
         SetTextScale(scaleX*scale, scaleY*scale)
         SetTextFont(fontId)
         SetTextProportional(1)
		 if inDist then
			SetTextColour(0, 190, 0, 220)		-- You can change the text color here
		 else
		 	SetTextColour(220, 0, 0, 220)		-- You can change the text color here
		 end
         SetTextDropshadow(1, 1, 1, 1, 255)
         SetTextEdge(2, 0, 0, 0, 150)
         SetTextDropShadow()
         SetTextOutline()
         SetTextEntry("STRING")
         SetTextCentre(1)
         AddTextComponentString(textInput)
         SetDrawOrigin(x,y,z+2, 0)
         DrawText(0.0, 0.0)
         ClearDrawOrigin()
end

function Process()
	ESX.Streaming.RequestAnimDict("mini@repair", function()
            TaskPlayAnim(PlayerPedId(), "mini@repair", "fixing_a_ped", 8.0, -8.0, -1, 32, 0, false, false, false)
	end)
	process = true
	local making = true
	while making and process do
		TriggerEvent('esx:showNotification', '~g~Pocetak ~g~proizvodnje ~w~heroina')
		local torba = 0
		TriggerEvent('skinchanger:getSkin', function(skin)
			torba = skin['bags_1']
		end)
		Citizen.Wait(5000)
		ESX.TriggerServerCallback('Heroin:process', function(output)
			making = output
		end, torba)
	end
end

RegisterNetEvent('Heroin:start')
AddEventHandler('Heroin:start', function()
	local set = false
    local kord = nil
	Citizen.Wait(10)
	for i=1, #Droge, 1 do
        if Droge[i].vrsta == 1 and Droge[i].branje ~= nil then
            kord = Droge[i].branje
            break
        end
    end
    if kord ~= nil then
        local x,y,z = table.unpack(kord)
        local rnX = x + math.random(-40, 40)
        local rnY = y + math.random(-40, 40)
        
        local u, Z = GetGroundZFor_3dCoord(rnX ,rnY ,300.0,0)

        local vect = vector3(rnX, rnY, Z+0.3)
        table.insert(locations, vect);
    end
end)

RegisterNetEvent('Heroin:new')
AddEventHandler('Heroin:new', function(id)
	local set = false
    local kord = nil
	Citizen.Wait(10)
	for i=1, #Droge, 1 do
        if Droge[i].vrsta == 1 and Droge[i].branje ~= nil then
            kord = Droge[i].branje
            break
        end
    end
    if kord ~= nil then
        local x,y,z = table.unpack(kord)
        local rnX = x + math.random(-40, 40)
        local rnY = y + math.random(-40, 40)
        
        local u, Z = GetGroundZFor_3dCoord(rnX ,rnY ,300.0,0)
        
        local vect = vector3(rnX, rnY, Z+0.3)
        locations[id] = vect
        ClearPedTasks(PlayerPedId())
    end
end)

RegisterNetEvent('Heroin:message')
AddEventHandler('Heroin:message', function(message)
	ESX.ShowNotification(message)
end)
			
function DisplayHelpText(str)
	SetTextComponentFormat("STRING")
	AddTextComponentString(str)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end