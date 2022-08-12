--[[
───────────────────────────────────────────────────────────────

	SEM_InteractionMenu (server.lua) - Created by Scott M
	Current Version: v1.7.1 (Sep 2021)
	
	Support: https://semdevelopment.com/discord
	
		!!! Change vaules in the 'config.lua' !!!
	DO NOT EDIT THIS IF YOU DON'T KNOW WHAT YOU ARE DOING
	
───────────────────────────────────────────────────────────────
]]

RegisterServerEvent('SEM_InteractionMenu:GlobalChat')
AddEventHandler('SEM_InteractionMenu:GlobalChat', function(Color, Prefix, Message)
	--TriggerClientEvent('chatMessage', -1, Prefix, Color, GetPlayerName(source)..' '..Message)
	TriggerClientEvent('chat:addMessage', -1, {
        template = '<div class="chat-message system"><b>^1{0}^0</b> >> {1}</div>',
        args = { Prefix..'^0', '^3'..GetPlayerName(source):gsub('~%a~', '')..'^0 '..Message}
    })
end)

RegisterServerEvent('SEM_InteractionMenu:CuffNear')
AddEventHandler('SEM_InteractionMenu:CuffNear', function(ID)
	local src = source
	local srcCoords = GetEntityCoords(GetPlayerPed(src))
	local tgtCoords = GetEntityCoords(GetPlayerPed(ID ))
	local allow = true
	local distance = #(tgtCoords - srcCoords)

	if ID == -1 or ID == '-1' then
		if source ~= '' then
			DropPlayer(source, '\n[SEM_InteractionMenu] Attempting to cuff all players')
		end

		print("ERROR CODE: TRY_ALL_CUFF --> ATTEMPTED TO CUFF EVERYONE. REQ BY: "..tostring(src).." REQ TARGET: "..tostring(ID))

		allow = false
	end

	if distance > Config.CommandDistance then
		allow = false
		print("ERROR CODE: TRY_CUFF_TOO_FAR --> ATTEMPTED TO CUFF SOMEONE FAR AWAY. REQ BY: "..tostring(src).." REQ TARGET: "..tostring(ID).." DIST: "..tostring(distance))
	end

	if ID ~= false and allow then
		TriggerClientEvent('SEM_InteractionMenu:CuffAnim',src,ID)
		TriggerClientEvent('SEM_InteractionMenu:Cuff', ID)
	end
end)


RegisterServerEvent('SEM_InteractionMenu:DragNear')
AddEventHandler('SEM_InteractionMenu:DragNear', function(ID)
	local src = source
	if ID == -1 or ID == '-1' then
		if src ~= '' then
			DropPlayer(src, '\n[SEM_InteractionMenu] Attempting to drag all players')
		end

		print("ERROR CODE: TRY_ALL_DRAG --> ATTEMPTED TO DRAG EVERYONE. REQ BY: "..tostring(src).." REQ TARGET: "..tostring(ID))

		return
	else
		if ID ~= false and ID ~= src then
			TriggerClientEvent('SEM_InteractionMenu:Drag', ID, src)
		else
			print("ERROR CODE: BAD_TGT_DRAG --> FAILED TO DRAG. REQ BY: "..tostring(src).." REQ TARGET: "..tostring(ID))
		end
	end


end)

RegisterServerEvent('SEM_InteractionMenu:SeatNear')
AddEventHandler('SEM_InteractionMenu:SeatNear', function(ID, Vehicle)
    TriggerClientEvent('SEM_InteractionMenu:Seat', ID, Vehicle)
end)

RegisterServerEvent('SEM_InteractionMenu:UnseatNear')
AddEventHandler('SEM_InteractionMenu:UnseatNear', function(ID, Vehicle)
    TriggerClientEvent('SEM_InteractionMenu:Unseat', ID, Vehicle)
end)

local recentJails = {}

function JailCooldown(src)
	recentJails[src] = true
	Citizen.SetTimeout(10000, function() recentJails[src] = nil end)
end

RegisterServerEvent('SEM_InteractionMenu:Jail')
AddEventHandler('SEM_InteractionMenu:Jail', function(ID, Time, Reason)
	local src = tonumber(source)
	local allow = true

	if recentJails[src] then
		TriggerClientEvent('chat:addMessage', source, {
			template = '<div class="chat-message system"><b>^1{0}^0</b> >> {1}</div>',
			args = { "[SYSTEM]^0", '^1Too Many Jail/Hospital Requests in a short time.'}
		})
		allow = false
	end

	if ID == -1 or ID == '-1' then
		allow = false
		if src ~= 0 then
			TriggerEvent('knight-serverlogs:internal:logevent',{webhook = 'flags', color = 'red', title = '❗ ATTEMPTED TO JAIL ALL PLAYERS', msg = 'Attempted to trigger Hospital event on -1 (all players)', src = source})
			DropPlayer(source, '\n[SEM_InteractionMenu] Attempting to jail all players')
		end

		print("ERROR CODE: TRY_ALL_JAIL --> ATTEMPTED TO JAIL EVERYONE. REQ BY: "..tostring(src).." REQ TARGET: "..tostring(ID))

		return
	end

	if Time > Config.MaxJailTime and not IsPlayerAceAllowed(source, 'sem_intmenu.overridelimits') then
		allow = false
		return
	end

	if allow then
		JailCooldown(src)
		TriggerClientEvent('SEM_InteractionMenu:JailPlayer', ID, Time)
		TriggerClientEvent('chat:addMessage', -1, {
			template = '<div class="chat-message system"><div style="text-align:center"><b>^1{0}^0</b></div><br>{1}<br>{2}<br>{3}<br>{4}</div>',
			args = { "^1JUDGE^0", '^3Inmate Name:^0 '..GetPlayerName(ID):gsub('~%a~', ''), '^3Serving:^0 ' .. Time .. ' month(s)', '^3Charges:^0 '..Reason, '^3Processed by: ^0'..GetPlayerName(source):gsub('~%a~', '')}
		})
		TriggerEvent('SEM_InteractionMenu:PersistJail:Start', ID, Time)
	end

end)

RegisterServerEvent('SEM_InteractionMenu:Unjail')
AddEventHandler('SEM_InteractionMenu:Unjail', function(ID)
	if IsPlayerAceAllowed(source, "sem_intmenu.unjail") then
		TriggerClientEvent('SEM_InteractionMenu:UnjailPlayer', ID)
	end
end)

RegisterServerEvent('SEM_InteractionMenu:Backup')
AddEventHandler('SEM_InteractionMenu:Backup', function(Code, StreetName, Coords)
	TriggerClientEvent('SEM_InteractionMenu:CallBackup', -1, Code, StreetName, Coords)
end)

RegisterServerEvent('SEM_InteractionMenu:Ads')
AddEventHandler('SEM_InteractionMenu:Ads', function(Text, Name, Loc, File)
	TriggerClientEvent('SEM_InteractionMenu:SyncAds', -1, '['..GetPlayerName(source):gsub('~%a~','')..'] '..Text, Name, Loc, File, source)
end)

BACList = {}
RegisterServerEvent('SEM_InteractionMenu:BACSet')
AddEventHandler('SEM_InteractionMenu:BACSet', function(BACLevel)
	BACList[source] = BACLevel
end)

RegisterServerEvent('SEM_InteractionMenu:BACTest')
AddEventHandler('SEM_InteractionMenu:BACTest', function(ID)
	local BACLevel = BACList[ID]
	TriggerClientEvent('SEM_InteractionMenu:BACResult', source, BACLevel)
end)

Inventories = {}
RegisterServerEvent('SEM_InteractionMenu:InventorySet')
AddEventHandler('SEM_InteractionMenu:InventorySet', function(Items)
	Inventories[source] = Items
end)

RegisterServerEvent('SEM_InteractionMenu:InventorySearch')
AddEventHandler('SEM_InteractionMenu:InventorySearch', function(ID)
	local Inventory = Inventories[ID]

	TriggerClientEvent('SEM_InteractionMenu:InventoryResult', source, Inventory)
end)

RegisterServerEvent('SEM_InteractionMenu:Hospitalize')
AddEventHandler('SEM_InteractionMenu:Hospitalize', function(ID, Time, Location, Reason)
	local allow = true
	local src = tonumber(source)

	if recentJails[src] then
		TriggerClientEvent('chat:addMessage', source, {
			template = '<div class="chat-message system"><b>^1{0}^0</b> >> {1}</div>',
			args = { "[SYSTEM]^0", '^1Too Many Jail/Hospital Requests in a short time.'}
		})
		allow = false
	end

	if ID == -1 or ID == '-1' then
		allow = false
		if source ~= '' then
			TriggerEvent('knight-serverlogs:internal:logevent',{webhook = 'flags', color = 'red', title = '❗ ATTEMPTED TO HOSPITAL ALL PLAYERS', msg = 'Attempted to trigger Hospital event on -1 (all players)', src = source})
			DropPlayer(source, '\n[SEM_InteractionMenu] Attempting to hospitalize all players')
		end

		print("ERROR CODE: TRY_ALL_HOSPITAL --> ATTEMPTED TO HOSPITALIZE EVERYONE. REQ BY: "..tostring(src).." REQ TARGET: "..tostring(ID))
		return
	end

	if Time > Config.MaxHospitalTime and not IsPlayerAceAllowed(source, 'sem_intmenu.overridelimits') then
		allow = false
		return
	end

	if allow then
		JailCooldown(src)
		TriggerClientEvent('SEM_InteractionMenu:HospitalizePlayer', ID, Time, Location)
		--TriggerClientEvent('chatMessage', -1, 'Doctor', {86, 96, 252}, GetPlayerName(ID) .. ' has been Hospitalized for ' .. Time .. ' months(s)')
		TriggerClientEvent('chat:addMessage', -1, {
			template = '<div class="chat-message system"><b>^1{0}^0</b><br>{1}<br>{2}<br>{3}<br>{4}</div>',
			args = { "^5HOSPITAL^0", '^5Patient Name:^0 '..GetPlayerName(ID):gsub('~%a~',''), '^5Recovery Time:^0 ' .. Time .. ' month(s)', '^5Condition:^0 '..Reason, '^5Admitted by: ^0'..GetPlayerName(source):gsub('~%a~', '')}
		})
	end

end)

RegisterServerEvent('SEM_InteractionMenu:Unhospitalize')
AddEventHandler('SEM_InteractionMenu:Unhospitalize', function(ID)
	if IsPlayerAceAllowed(source, "sem_intmenu.unhospital") then
		TriggerClientEvent('SEM_InteractionMenu:UnhospitalizePlayer', ID)
	end
end)

RegisterServerEvent('SEM_InteractionMenu:LEOPerms')
AddEventHandler('SEM_InteractionMenu:LEOPerms', function()
    if IsPlayerAceAllowed(source, 'sem_intmenu.leo') then
		TriggerClientEvent('SEM_InteractionMenu:LEOPermsResult', source, true)
	else
		TriggerClientEvent('SEM_InteractionMenu:LEOPermsResult', source, false)
	end
end)

RegisterServerEvent('SEM_InteractionMenu:FirePerms')
AddEventHandler('SEM_InteractionMenu:FirePerms', function()
    if IsPlayerAceAllowed(source, 'sem_intmenu.fire') then
		TriggerClientEvent('SEM_InteractionMenu:FirePermsResult', source, true)
	else
		TriggerClientEvent('SEM_InteractionMenu:FirePermsResult', source, false)
	end
end)

RegisterServerEvent('SEM_InteractionMenu:UnjailPerms')
AddEventHandler('SEM_InteractionMenu:UnjailPerms', function()
    if IsPlayerAceAllowed(source, 'sem_intmenu.unjail') then
		TriggerClientEvent('SEM_InteractionMenu:UnjailPermsResult', source, true)
	else
		TriggerClientEvent('SEM_InteractionMenu:UnjailPermsResult', source, false)
	end
end)

RegisterServerEvent('SEM_InteractionMenu:UnhospitalPerms')
AddEventHandler('SEM_InteractionMenu:UnhospitalPerms', function()
    if IsPlayerAceAllowed(source, 'sem_intmenu.unhospital') then
		TriggerClientEvent('SEM_InteractionMenu:UnhospitalPermsResult', source, true)
	else
		TriggerClientEvent('SEM_InteractionMenu:UnhospitalPermsResult', source, false)
	end
end)