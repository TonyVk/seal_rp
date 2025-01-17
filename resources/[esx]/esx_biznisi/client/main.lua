ESX                             = nil

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

local Biznisi = {}
local Blipovi = {}
local Cpovi = {}

local HasAlreadyEnteredMarker   = false
local LastStation               = nil
local LastPart                  = nil
local LastPartNum               = nil
local CurrentAction             = nil
local CurrentActionMsg          = ''
local CurrentActionData         = {}
local GUI                       = {}
local bizID 					= nil
GUI.Time                        = 0

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(100)
	end
	Wait(5000)
	ESX.TriggerServerCallback('biznis:DohvatiBiznise', function(biznis)
		Biznisi = biznis.biz
	end)
	Wait(1000)
	SpawnBlipove()
	SpawnCpove()
end)

function SpawnCpove()
	if #Cpovi > 0 then
		for i=1, #Cpovi, 1 do
		  	if Cpovi[i] ~= nil then
			  	if Cpovi[i].Spawnan then
					DeleteCheckpoint(Cpovi[i].ID)
					Cpovi[i].Spawnan = false
			  	end
		  	end
		end
	end
	Cpovi = {}
	for i=1, #Biznisi, 1 do
		if Biznisi[i] ~= nil and Biznisi[i].Coord ~= nil then
			local x,y,z = table.unpack(Biznisi[i].Coord)
			if (x ~= 0 and x ~= nil) and (y ~= 0 and y ~= nil) and (z ~= 0 and z ~= nil) then
				table.insert(Cpovi, {iID = i, bID = Biznisi[i].ID, Ime = "Biznis", ID = check, Koord = vector3(x, y, z), Spawnan = false, r = 50, g = 50, b = 204})
			end
		end
	end
end

RegisterNetEvent('es_admin:setPerm')
AddEventHandler('es_admin:setPerm', function()
	ESX.TriggerServerCallback('esx-races:DohvatiPermisiju', function(br)
		perm = br
	end)
end)

RegisterCommand("uredibiznise", function(source, args, raw)
    ESX.TriggerServerCallback('DajMiPermLevelCall', function(perm)
		if perm == 69 then
			print("koji kurac se desava")
			local elements = {}

			table.insert(elements, {label = "Novi biznis", value = "novi"})
			
			for i=1, #Biznisi, 1 do
				if Biznisi[i] ~= nil then
					table.insert(elements, {label = Biznisi[i].Label, value = Biznisi[i].ID})
				end
			end

			ESX.UI.Menu.Open(
				'default', GetCurrentResourceName(), 'ubiz',
				{
					title    = "Izaberite biznis",
					align    = 'top-left',
					elements = elements,
				},
				function(data, menu)
					if data.current.value == "novi" then
						ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'pimebiz', {
							title = "Upisite ime biznisa",
						}, function (datari, menuri)
							local pIme = datari.value	
							if pIme == nil then
								ESX.ShowNotification('Greska.')
							else
								local naso = 0
								for i=1, #Biznisi, 1 do
									if Biznisi[i] ~= nil and Biznisi[i].Ime == pIme then
										naso = 1
										break
									end
								end
								if naso == 0 then
									menuri.close()
									ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'plabelbiz', {
										title = "Upisite label biznisa",
									}, function (datari2, menuri2)
										local pLabel = datari2.value
										if pLabel == nil then
											ESX.ShowNotification('Greska.')
										else
											menuri2.close()
											ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'pcijbiz', {
												title = "Upisite cijenu biznisa",
											}, function (datari3, menuri3)
												local pCijena = datari3.value
												if pCijena == nil or pCijena <= 0 then
													ESX.ShowNotification('Greska.')
												else
													menuri3.close()
													menu.close()
													TriggerServerEvent("biznis:NapraviBiznis", pIme, pLabel, pCijena)
													ESX.ShowNotification("Uspjesno napravljen biznis")
													Wait(100)
													ExecuteCommand("uredibiznise")
												end
											end, function (datari3, menuri3)
												menuri3.close()
											end)
										end
									end, function (datari2, menuri2)
										menuri2.close()
									end)
								else
									ESX.ShowNotification("Biznis sa tim imenom vec postoji!")
								end
							end
						end, function (datari, menuri)
							menuri.close()
						end)
					else
						local bID = data.current.value
						menu.close()
						local id
						for i = 1, #Biznisi do
							if Biznisi[i].ID == bID then
								id = i
								break
							end
						end
						elements = {}
						table.insert(elements, {label = "Koordinate biznisa", value = "koord"})
						table.insert(elements, {label = "Port do biznisa", value = "port"})
						table.insert(elements, {label = "Posao biznisa", value = "posao"})
						table.insert(elements, {label = "Vlasnik biznisa", value = "vlasnik"})
						table.insert(elements, {label = "Label biznisa", value = "label"})
						table.insert(elements, {label = "Cijena biznisa", value = "cijena"})
						table.insert(elements, {label = "Obrisi biznis", value = "obrisi"})
						ESX.UI.Menu.Open(
							'default', GetCurrentResourceName(), 'ubiz',
							{
								title    = "Izaberite opciju",
								align    = 'top-left',
								elements = elements,
							},
							function(data2, menu2)
								if data2.current.value == "koord" then
									local koord = GetEntityCoords(PlayerPedId())
									TriggerServerEvent("biznis:PostaviKoord", bID, Biznisi[id].Ime, koord)
								elseif data2.current.value == "port" then
									local x,y,z = table.unpack(Biznisi[id].Coord)
									SetEntityCoords(PlayerPedId(), x,y,z)
								elseif data2.current.value == "posao" then
									elements = {}
									ESX.TriggerServerCallback('biznisi:DajPoslove', function(poslovi)
										elements = poslovi
										ESX.UI.Menu.Open(
										'default', GetCurrentResourceName(), 'ubizpos',
										{
											title    = "Izaberite posao",
											align    = 'top-left',
											elements = elements,
										},
										function(data3, menu3)
											local posao = data3.current.value
											TriggerServerEvent("biznis:PostaviPosao", bID, posao)
											ESX.ShowNotification("Uspjesno postavljen posao biznisa na "..data3.current.label)
											menu3.close()
										end,
										function(data3, menu3)
											menu3.close()
										end
									)
									end)
								elseif data2.current.value == "vlasnik" then
									ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'pvlbiz', {
										title = "Upisite ID igraca (0 da maknete vlasnika)",
									}, function (datari2, menuri2)
										local igrID = tonumber(datari2.value)
										if igrID == nil or igrID < 0 then
											ESX.ShowNotification('Greska.')
										else
											TriggerServerEvent("biznis:PostaviVlasnika", bID, Biznisi[id].Ime, igrID)
											menuri2.close()
										end
									end, function (datari2, menuri2)
										menuri2.close()
									end)
								elseif data2.current.value == "label" then
									ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'urlabelbiz', {
										title = "Upisite label biznisa",
									}, function (datari2, menuri2)
										local pLabel = datari2.value
										if pLabel == nil then
											ESX.ShowNotification('Greska.')
										else
											menuri2.close()
											TriggerServerEvent("biznis:PostaviLabel", bID, Biznisi[id].Ime, pLabel)
											ESX.ShowNotification("Uspjesno postavljen novi label biznisa!")
										end
									end, function (datari2, menuri2)
										menuri2.close()
									end)
								elseif data2.current.value == "cijena" then
									ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'urcijbiz', {
										title = "Upisite cijenu biznisa",
									}, function (datari2, menuri2)
										local pCijena = datari2.value
										if pCijena == nil or pCijena <= 0 then
											ESX.ShowNotification('Greska.')
										else
											menuri2.close()
											TriggerServerEvent("biznis:PostaviCijenu", bID, pCijena)
											ESX.ShowNotification("Uspjesno postavljena nova cijena biznisa!")
										end
									end, function (datari2, menuri2)
										menuri2.close()
									end)
								elseif data2.current.value == "obrisi" then
									TriggerServerEvent("biznis:ObrisiBiznis", bID, Biznisi[id].Ime)
									menu2.close()
									Wait(100)
                                	ExecuteCommand("uredibiznise")
								end
							end,
							function(data2, menu2)
								menu2.close()
							end
						)
					end
				end,
				function(data, menu)
					menu.close()
				end
			)
		else
			ESX.ShowNotification("Nemate pristup ovoj komandi!")
		end
	end)
end, false)

function Draw3DText(x,y,z,textInput,fontId,scaleX,scaleY)
	local px,py,pz=table.unpack(GetGameplayCamCoords())
	local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)    
	local scale = (1/dist)*20
	local fov = (1/GetGameplayCamFov())*100
	local scale = scale*fov   
	SetTextScale(scaleX*scale, scaleY*scale)
	SetTextFont(fontId)
	SetTextProportional(1)
	SetTextColour(250, 250, 250, 255)		-- You can change the text color here
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

function SpawnBlipove()
	for i=1, #Biznisi, 1 do
		if Biznisi[i] ~= nil then
			local x,y,z = table.unpack(Biznisi[i].Coord)
			if x ~= 0 and x ~= nil then
				Blipovi[Biznisi[i].Ime] = AddBlipForCoord(x,y,z)

				SetBlipSprite (Blipovi[Biznisi[i].Ime], 378)
				SetBlipDisplay(Blipovi[Biznisi[i].Ime], 4)
				SetBlipScale  (Blipovi[Biznisi[i].Ime], 1.2)
				local label = "Nema"
				if Biznisi[i].Kupljen == false then
					SetBlipSprite (Blipovi[Biznisi[i].Ime], 375)
					label = "[Biznis] "..Biznisi[i].Label.." na prodaju!"
				else
					SetBlipSprite (Blipovi[Biznisi[i].Ime], 374)
					label = "[Biznis] "..Biznisi[i].Label
				end
				SetBlipColour(Blipovi[Biznisi[i].Ime], 3)
				SetBlipAsShortRange(Blipovi[Biznisi[i].Ime], true)

				BeginTextCommandSetBlipName("STRING")
				AddTextComponentString(label)
				EndTextCommandSetBlipName(Blipovi[Biznisi[i].Ime])
			end
		end
	end
end

-- Display markers
Citizen.CreateThread(function()
  local waitara = 500
  while true do
    Citizen.Wait(waitara)
	local naso = 0
	
	if CurrentAction ~= nil then
	  waitara = 0
	  naso = 1

	  local x,y,z = table.unpack(Biznisi[bizID].Coord)
	  Draw3DText( x, y, z  -1.400, Biznisi[bizID].Label, 4, 0.1, 0.1)
	  if not Biznisi[bizID].Kupljen then
		Draw3DText( x, y, z  -1.600, "Biznis na prodaju ($"..Biznisi[bizID].Cijena..")", 4, 0.1, 0.1)
	  else
		Draw3DText( x, y, z  -1.600, "Vlasnik: "..Biznisi[bizID].VlasnikIme, 4, 0.1, 0.1)
	  end
	  Draw3DText( x, y, z  -1.800, "Tjedna zarada: $"..Biznisi[bizID].Tjedan, 4, 0.1, 0.1)

      SetTextComponentFormat('STRING')
      AddTextComponentString(CurrentActionMsg)
      DisplayHelpTextFromStringLabel(0, 0, 1, -1)

      if IsControlPressed(0,  Keys['E']) and (GetGameTimer() - GUI.Time) > 150 then

        if CurrentAction == 'menu_biznis' then
          OpenBiznisMenu(CurrentActionData.ime)
        end

        CurrentAction = nil
        GUI.Time      = GetGameTimer()

      end

    end

	local playerPed = GetPlayerPed(-1)
    local coords    = GetEntityCoords(playerPed)
	
	local isInMarker     = false
	local currentStation = nil
    local currentPart    = nil
    local currentPartNum = nil
	-- for i=1, #Biznisi, 1 do
	-- 	if Biznisi[i] ~= nil and Biznisi[i].Coord ~= nil then
	-- 		local x,y,z = table.unpack(Biznisi[i].Coord)
	-- 		if (x ~= 0 and x ~= nil) and (y ~= 0 and y ~= nil) and (z ~= 0 and z ~= nil) then
	-- 			if GetDistanceBetweenCoords(coords, x, y, z, true) < 50.0 then
	-- 				waitara = 0
	-- 				naso = 1
	-- 				DrawMarker(1, x, y, z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.5, 1.5, 1.0, 50, 50, 204, 100, false, true, 2, false, false, false, false)
	-- 				Draw3DText( x, y, z  -1.400, Biznisi[i].Label, 4, 0.1, 0.1)
	-- 				if not Biznisi[i].Kupljen then
	-- 					Draw3DText( x, y, z  -1.600, "Firma na prodaju!", 4, 0.1, 0.1)
	-- 				else
	-- 					Draw3DText( x, y, z  -1.600, "Vlasnik: "..Biznisi[i].VlasnikIme, 4, 0.1, 0.1)
	-- 				end
	-- 				Draw3DText( x, y, z  -1.800, "Tjedna zarada: $"..Biznisi[i].Tjedan, 4, 0.1, 0.1)
	-- 			end
	-- 			if GetDistanceBetweenCoords(coords, x, y, z, true) < 1.5 then
	-- 				isInMarker     = true
	-- 				currentStation = Biznisi[i].ID
	-- 				currentPart    = 'Biznis'
	-- 				currentPartNum = i
	-- 			end
	-- 		end
	-- 	end
	-- end

	if #Cpovi > 0 then
		for i=1, #Cpovi, 1 do
		  if Cpovi[i] ~= nil then
			if #(coords-Cpovi[i].Koord) > 100 then
			  if Cpovi[i].Spawnan then
				DeleteCheckpoint(Cpovi[i].ID)
				Cpovi[i].Spawnan = false
			  end
			else
			  if Cpovi[i].Spawnan == false then
				local kord = Cpovi[i].Koord
				local range = 2.0
				local check = CreateCheckpoint(47, kord.x, kord.y, kord.z, 0, 0, 0, range, Cpovi[i].r, Cpovi[i].g, Cpovi[i].b, 100)
				SetCheckpointCylinderHeight(check, range, range, range)
				Cpovi[i].ID = check
				Cpovi[i].Spawnan = true
			  end
			end
		  end
		end
		for i=1, #Cpovi, 1 do
		  if Cpovi[i] ~= nil and Cpovi[i].Spawnan then
			if #(coords-Cpovi[i].Koord) < 1.5 then
				if Cpovi[i].Ime == "Biznis" then
					isInMarker     = true
					bizID = Cpovi[i].iID
					currentStation = Cpovi[i].bID
					currentPart    = 'Biznis'
					currentPartNum = i
					break
				end
			end
		  end
		end
	end

	local hasExited = false

	if isInMarker and not HasAlreadyEnteredMarker or (isInMarker and (LastStation ~= currentStation or LastPart ~= currentPart or LastPartNum ~= currentPartNum) ) then
		waitara = 0
		naso = 1
		if
			(LastStation ~= nil and LastPart ~= nil and LastPartNum ~= nil) and
			(LastStation ~= currentStation or LastPart ~= currentPart or LastPartNum ~= currentPartNum)
		then
			TriggerEvent('biznis:hasExitedMarker', LastStation, LastPart, LastPartNum)
			hasExited = true
		end

		HasAlreadyEnteredMarker = true
		LastStation             = currentStation
		LastPart                = currentPart
		LastPartNum             = currentPartNum

		TriggerEvent('biznis:hasEnteredMarker', currentStation, currentPart, currentPartNum)
	end

	if not hasExited and not isInMarker and HasAlreadyEnteredMarker then
		waitara = 0
		naso = 1
		HasAlreadyEnteredMarker = false

		TriggerEvent('biznis:hasExitedMarker', LastStation, LastPart, LastPartNum)
	end
	if naso == 0 then
		waitara = 500
	end
  end
end)

RegisterNUICallback(
    "zatvoriupit",
    function(data, cb)
		local br = data.br
		local args = data.args
		if br == 1 then
			if args.kupi then
				TriggerServerEvent("biznis:KupiBiznis", args.id, args.ime)
				HasAlreadyEnteredMarker = false
			else
				TriggerServerEvent("biznis:PrihvatiPonudu", args.orgIgr, args.id, args.cijena)
			end
		else
			if args.cijena then
				TriggerServerEvent("biznis:OdbijPonudu", args.orgIgr)
			else
				HasAlreadyEnteredMarker = false
			end
		end
    end
)

function OpenBiznisMenu(ime)
	local elements = {}
	ESX.UI.Menu.CloseAll()
	
	local Kupljen = false
	local Posao = nil
	local bCijena = 0
	local bIme = nil
	for i=1, #Biznisi, 1 do
		if Biznisi[i] ~= nil and Biznisi[i].ID == ime then
			if Biznisi[i].Kupljen == true then
				Posao = Biznisi[i].Posao
				Kupljen = true
			end
			bCijena = Biznisi[i].Cijena
			bIme = Biznisi[i].Ime
			break
		end
	end
	local mere = false
	if Kupljen == true then
		ESX.TriggerServerCallback('biznis:JelVlasnik', function(vlasnik)
			if vlasnik then
				table.insert(elements, {label = "Stanje sefa", value = 'stanje'})
				table.insert(elements, {label = "Uzmi iz sefa", value = 'sef'})
				table.insert(elements, {label = "Radnici", value = 'radnici'})
				table.insert(elements, {label = "Prodaj drzavi ($"..math.ceil(bCijena/2)..")", value = 'prodaj'})
				table.insert(elements, {label = "Prodaj igracu", value = 'prodaj2'})
			else
				table.insert(elements, {label = "Ovaj biznis nije tvoj!", value = 'error'})
			end
			mere = true
		end, ime)
	else
		TriggerEvent("upit:OtvoriPitanje", GetCurrentResourceName(), "Biznis", "Zelite li kupiti biznis za $"..bCijena.."?", {kupi = true, id = ime, ime = bIme})
		mere = 2
	end
	while mere == false do
		Wait(100)
	end
	if mere == true then
		ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'biznis',
		{
			title    = "Biznis",
			align    = 'top-left',
			elements = elements,
			},

			function(data, menu)

			menu.close()

			if data.current.value == 'stanje' then
				TriggerServerEvent("biznis:DajStanje", ime)
			end

			if data.current.value == 'sef' then
				ESX.UI.Menu.Open(
					'dialog', GetCurrentResourceName(), 'biznis_daj_lovu',
					{
						title = "Unesite koliko novca zelite podici"
					},
					function(data3, menu3)

					local count = tonumber(data3.value)

					if count == nil then
						ESX.ShowNotification("Kriva vrijednost!")
					else
						menu3.close()
						TriggerServerEvent("biznis:UzmiIzSefa", ime, count)
					end
					end,
					function(data3, menu3)
						menu3.close()
					end
				)
			end
			
			if data.current.value == 'radnici' then
				ESX.TriggerServerCallback('biznis:DohvatiRadnike', function(radnici)
					local elements = {
						head = { "Ime radnika", "Broj odradjenih tura" },
						rows = {}
					}
					for i=1, #radnici, 1 do
						if radnici[i].Posao == Posao then
							table.insert(elements.rows, {
								data = radnici[i],
								cols = {
									radnici[i].Ime,
									radnici[i].Ture
								}
							})
						end
					end

					ESX.UI.Menu.Open('list', GetCurrentResourceName(), 'biznis_radnici', elements, function(data2, menu2)

					end, function(data2, menu2)
						menu2.close()
					end)
				end)
			end

			if data.current.value == 'prodaj' then
				ESX.UI.Menu.CloseAll()
				TriggerServerEvent("biznis:ProdajBiznis", ime, bIme)
			end

			if data.current.value == 'prodaj2' then
				ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'cijprpaa', {
					title = "Upisite cijenu",
				}, function (datar, menur)
					local cij = tonumber(datar.value)
					if cij == nil or cij <= 0 then
						ESX.ShowNotification('Greska.')
					else
						menur.close()
						local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
						if closestPlayer ~= -1 and closestDistance <= 3.0 then
							TriggerServerEvent("biznis:PonudiIgracu", ime, cij, GetPlayerServerId(closestPlayer))
							ESX.UI.Menu.CloseAll()
						else
							ESX.ShowNotification("Nema igraca u blizini!")
						end
					end
				end, function (datar, menur)
					menur.close()
				end)
			end
			
			if data.current.value == "error" then
				ExecuteCommand("discord")
			end
			
			CurrentAction     = 'menu_biznis'
			CurrentActionMsg  = "Pritisnite E da otvorite biznis menu!"
			CurrentActionData = { ime = ime }

			end,
			function(data, menu)

			menu.close()

			CurrentAction     = 'menu_biznis'
			CurrentActionMsg  = "Pritisnite E da otvorite biznis menu!"
			CurrentActionData = { ime = ime }
			end
		)
	end
end

AddEventHandler('biznis:hasEnteredMarker', function(station, part, partNum)
  if part == 'Biznis' then
    CurrentAction     = 'menu_biznis'
    CurrentActionMsg  = "Pritisnite E da otvorite biznis menu!"
    CurrentActionData = { ime = station }
  end
end)

AddEventHandler('biznis:hasExitedMarker', function(station, part, partNum)
  ESX.UI.Menu.CloseAll()
  CurrentAction = nil
end)

RegisterNetEvent('biznis:KreirajBlip')
AddEventHandler('biznis:KreirajBlip', function(co, biz)
	local x,y,z = table.unpack(co)
	if Blipovi[biz] ~= nil then
		RemoveBlip(Blipovi[biz])
		Blipovi[biz] = nil
	end
	
	if x ~= 0 and x ~= nil then
		Blipovi[biz] = AddBlipForCoord(x,y,z)

		SetBlipSprite (Blipovi[biz], 378)
		SetBlipDisplay(Blipovi[biz], 4)
		SetBlipScale  (Blipovi[biz], 1.2)
		local label = "Nema"
		for j=1, #Biznisi, 1 do
			if Biznisi[j] ~= nil and Biznisi[j].Ime == biz then
				if Biznisi[j].Kupljen == false then
					SetBlipSprite (Blipovi[biz], 375)
					label = "[Biznis] "..Biznisi[j].Label.." na prodaju!"
				else
					SetBlipSprite (Blipovi[biz], 374)
					label = "[Biznis] "..Biznisi[j].Label
				end
			end
		end
		SetBlipColour(Blipovi[biz], 3)
		SetBlipAsShortRange(Blipovi[biz], true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(label)
		EndTextCommandSetBlipName(Blipovi[biz])
	end
end)

RegisterNetEvent('biznis:UpdateBlip')
AddEventHandler('biznis:UpdateBlip', function(biz)
	local x,y,z = 0,0,0
	for j=1, #Biznisi, 1 do
		if Biznisi[j] ~= nil and Biznisi[j].Ime == biz then
			x,y,z = table.unpack(Biznisi[j].Coord)
		end
	end
	if Blipovi[biz] ~= nil then
		RemoveBlip(Blipovi[biz])
		Blipovi[biz] = nil
	end
	
	if x ~= 0 and x ~= nil then
		Blipovi[biz] = AddBlipForCoord(x,y,z)

		SetBlipSprite (Blipovi[biz], 378)
		SetBlipDisplay(Blipovi[biz], 4)
		SetBlipScale  (Blipovi[biz], 1.2)
		local label = "Nema"
		for j=1, #Biznisi, 1 do
			if Biznisi[j] ~= nil and Biznisi[j].Ime == biz then
				if Biznisi[j].Kupljen == false then
					SetBlipSprite (Blipovi[biz], 375)
					label = "[Biznis] "..Biznisi[j].Label.." na prodaju!"
				else
					SetBlipSprite (Blipovi[biz], 374)
					label = "[Biznis] "..Biznisi[j].Label
				end
			end
		end
		SetBlipColour(Blipovi[biz], 3)
		SetBlipAsShortRange(Blipovi[biz], true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(label)
		EndTextCommandSetBlipName(Blipovi[biz])
	end
end)

RegisterNetEvent('biznis:UpdateBiznise')
AddEventHandler('biznis:UpdateBiznise', function(biz)
	Biznisi = biz
	SpawnCpove()
end)