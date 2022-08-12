function GetDistanceBetweenCoords(...)
    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
    --  This Script Has Been Optimized By @ATG#1541 | https://AntiCheat.gg  --
    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
    local args = table.pack(...)
    local set1, set2;
    local type1 = type(args[1]);
    if type1 == "number" then
        set1 = vector3(args[1], args[2], args[3])
        local type2 = type(args[4]);
        if type2 == "number" then
            set2 = vector3(args[4], args[5], args[6]);
        elseif type2 == "table" then
            set2 = vector3(args[4].x, args[4].y, args[4].z);
        elseif type2 == "vector3" then
            set2 = args[4];
        end
    elseif type1 == "table" then
        set1 = vector3(args[1].x, args[1].y, args[1].z)
        local type2 = type(args[2]);
        if type2 == "number" then
            set2 = vector3(args[2], args[3], args[4]);
        elseif type2 == "table" then
            set2 = vector3(args[2].x, args[2].y, args[2].z);
        elseif type2 == "vector3" then
            set2 = args[2];
        end
    elseif type1 == "vector3" then
        set1 = args[1];
        local type2 = type(args[2]);
        if type2 == "number" then
            set2 = vector3(args[2], args[3], args[4]);
        elseif type2 == "table" then
            set2 = vector3(args[2].x, args[2].y, args[2].z);
        elseif type2 == "vector3" then
            set2 = args[2];
        end
    end
    return #(set1 - set2)
end


	SEM_InteractionMenu (functions.lua) - Created by Scott M
	Current Version: v1.7.1 (Sep 2021)
	
	Support: https://semdevelopment.com/discord
	
		!!! Change vaules in the 'config.lua' !!!
	DO NOT EDIT THIS IF YOU DON'T KNOW WHAT YOU ARE DOING

─────────────────────────────────────────────────────────────────
]]



--General Functions
function Notify(Text)
    SetNotificationTextEntry('STRING')
    AddTextComponentString(Text)
    DrawNotification(true, true)
end

function NotifyHelp(Text)
    SetTextComponentFormat('STRING')
    AddTextComponentString(Text)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

function LoadAnimation(Dict)
    while not HasAnimDictLoaded(Dict) do
        RequestAnimDict(Dict)
        Citizen.Wait(5)
    end
end

function KeyboardInput(TextEntry, MaxStringLenght)
    AddTextEntry('FMMC_KEY_TIP1', TextEntry)
    DisplayOnscreenKeyboard(1, 'FMMC_KEY_TIP1', '', '', '', '', '', MaxStringLenght)
    BlockInput = true
    
    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
        Citizen.Wait(3)
    end
    
    if UpdateOnscreenKeyboard() ~= 2 then
        local Result = GetOnscreenKeyboardResult()
        Citizen.Wait(500)
        BlockInput = false
        return Result
    else
        Citizen.Wait(500)
        BlockInput = false
        return nil
    end
end

function GetClosestPlayer()
    local Ped = PlayerPedId()
    
    for _, Player in ipairs(GetActivePlayers()) do
        if GetPlayerPed(Player) ~= PlayerPedId() then
            local Ped2 = GetPlayerPed(Player)
            local x, y, z = table.unpack(GetEntityCoords(Ped))
            if (GetDistanceBetweenCoords(GetEntityCoords(Ped2), x, y, z) < 2) then
                return GetPlayerServerId(Player)
            end
        end
    end
    
    Notify('~r~No Player Nearby!')
    return false
end

function GetDistance(ID)
    local Ped = PlayerPedId()
    local Ped2 = GetPlayerPed(GetPlayerFromServerId(ID))
    if Ped2 ~= 0 then
        local x, y, z = table.unpack(GetEntityCoords(Ped))
        return GetDistanceBetweenCoords(GetEntityCoords(Ped2), x, y, z)
    else
        return 9999.99
    end
end

--LEO Functions
function ToggleRadar()
    if Config.Radar ~= 0 then
        if IsPedInAnyVehicle(PlayerPedId()) then
            if GetVehicleClass(GetVehiclePedIsIn(PlayerPedId())) == 18 then
                if GetPedInVehicleSeat(GetVehiclePedIsIn(PlayerPedId()) == -1) then
                    _MenuPool:CloseAllMenus()
                    if Config.Radar == 1 then
                        TriggerEvent('wk:openRemote')
                    elseif Config.Radar == 2 then
                        TriggerEvent('wk:radarRC')
                    end
                else
                    Notify('~o~You need to be in the driver seat')
                end
            else
                Notify('~o~You need to be in a police vehicle')
            end
        else
            Notify('~o~You need to be in a vehicle')
        end
    end
end

function EnableShield()
    ShieldActive = true
    local Ped = PlayerPedId()
    local PedPos = GetEntityCoords(Ped, false)
    
    if IsPedInAnyVehicle(PlayerPedId(), true) then
        Notify('~r~You cannot be in a vehicle when getting your shield out!')
        ShieldActive = false
        return
    end
    
    RequestAnimDict('combat@gestures@gang@pistol_1h@beckon')
    while not HasAnimDictLoaded('combat@gestures@gang@pistol_1h@beckon') do
        Citizen.Wait(100)
    end
    
    TaskPlayAnim(Ped, 'combat@gestures@gang@pistol_1h@beckon', '0', 8.0, -8.0, -1, (2 + 16 + 32), 0.0, 0, 0, 0)
    
    RequestModel(GetHashKey('prop_ballistic_shield'))
    while not HasModelLoaded(GetHashKey('prop_ballistic_shield')) do
        Citizen.Wait(100)
    end

    local shield = CreateObject(GetHashKey('prop_ballistic_shield'), PedPos.x, PedPos.y, PedPos.z, 1, 1, 1)
    shieldEntity = shield
    AttachEntityToEntity(shieldEntity, Ped, GetEntityBoneIndexByName(Ped, 'IK_L_Hand'), 0.0, -0.05, -0.10, -30.0, 180.0, 40.0, 0, 0, 1, 0, 0, 1)
    SetWeaponAnimationOverride(Ped, 'Gang1H')
    
    if HasPedGotWeapon(Ped, 'weapon_combatpistol', 0) or GetSelectedPedWeapon(Ped) == 'weapon_combatpistol' then
        SetCurrentPedWeapon(Ped, 'weapon_combatpistol', 1)
        HadPistol = true
    else
        GiveWeaponToPed(Ped, 'weapon_combatpistol', 300, 0, 1)
        SetCurrentPedWeapon(Ped, 'weapon_combatpistol', 1)
        HadPistol = false
    end
    SetEnableHandcuffs(Ped, true)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(3)
        
        if ShieldActive == true then
            DisableControlAction(1, 23, true)--F | Enter Vehicle
            DisableControlAction(1, 75, true)--F | Exit Vehicle
        else
            Citizen.Wait(1000)
        end
    end
end)

function DisableShield()
    local Ped = PlayerPedId()
    DeleteEntity(shieldEntity)
    ClearPedTasksImmediately(Ped)
    SetWeaponAnimationOverride(Ped, 'Default')
    SetCurrentPedWeapon(Ped, 'weapon_unarmed', 1)
    
    if not HadPistol then
        RemoveWeaponFromPed(Ped, 'weapon_combatpistol')
    end
    SetEnableHandcuffs(Ped, false)
    HadPistol = false
    ShieldActive = false
end



--Civ Functions
function Ad(Text, Name, Loc, File, ID)
    SetNotificationTextEntry('STRING')
    AddTextComponentString(Text)
    EndTextCommandThefeedPostMessagetext(Loc, File, true, 1, Name, '~b~Advertisement #' .. ID)
    DrawNotification(false, true)
end



--Vehicle Functions
function SpawnVehicle(Veh, Name, Livery, Extras)
    local Ped = PlayerPedId()
    if (DoesEntityExist(Ped) and not IsEntityDead(Ped)) then
        local pos = GetEntityCoords(Ped)
        if (IsPedSittingInAnyVehicle(Ped)) then
            local Vehicle = GetVehiclePedIsIn(Ped, false)
            if (GetPedInVehicleSeat(Vehicle, -1) == Ped) then
                SetEntityAsMissionEntity(Vehicle, true, true)
                DeleteVehicle(Vehicle)
            end
        end
    end
    
    local WaitTime = 0
    local Model = GetHashKey(Veh)
    RequestModel(Model)
    while not HasModelLoaded(Model) do
        CancelEvent()
        RequestModel(Model)
        Citizen.Wait(100)
        
        WaitTime = WaitTime + 1
        
        if WaitTime == 600 then
            CancelEvent()
            Notify('~r~Unable to load vehicle, please contact development!')
            return
        end
    end
    local x, y, z = table.unpack(GetEntityCoords(PlayerPedId(), false))
    local Vehicle = CreateVehicle(Model, x + 2, y + 2, z + 1, GetEntityHeading(PlayerPedId()), true, false)
    SetPedIntoVehicle(PlayerPedId(), Vehicle, -1)
    SetVehicleDirtLevel(Vehicle, 0)
    SetVehicleModKit(Vehicle, 0)
    SetVehicleMod(Vehicle, 23, -1, false)
    SetModelAsNoLongerNeeded(Model)
    if Livery then
        SetVehicleLivery(Vehicle, Livery)
    end
    if Extras then
        for extraId = 0, 30 do
            if DoesExtraExist(Vehicle, extraId) then
                SetVehicleExtra(Vehicle, extraId, true)
            end
        end
        for _, extra in pairs(Extras) do
            SetVehicleExtra(Vehicle, extra, false)
        end
    end
    
    if Name then
        Notify('~b~Vehicle Spawned: ~g~' .. Name)
    else
        Notify('~b~Vehicle Spawned!')
    end
end

function DeleteVehicle(entity)
    Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(entity))
end



--Ped Functions
function LoadPed(Hash)
    Citizen.CreateThread(function()
        local Model = GetHashKey(Hash)
        RequestModel(Model)
        
        while not HasModelLoaded(Model) do
            Wait(3)
        end
        
        if HasModelLoaded(Model) then
            SetPlayerModel(PlayerId(), Model)
        else
            Notify('The model could not load - please contact development.')
        end
    end)
end



--Weapon Functions
function GiveWeapon(Hash)
    GiveWeaponToPed(PlayerPedId(), GetHashKey(Hash), 999, false)
end

function AddWeaponComponent(WeaponHash, Component)
    if HasPedGotWeapon(PlayerPedId(), GetHashKey(WeaponHash), false) then
        GiveWeaponComponentToPed(PlayerPedId(), GetHashKey(WeaponHash), GetHashKey(Component))
    end
end



--Prop Functions
function SpawnProp(Object, Name)
    local Player = PlayerPedId()
    local Coords = GetEntityCoords(Player)
    local Heading = GetEntityHeading(Player)
    
    RequestModel(Object)
    while not HasModelLoaded(Object) do
        Citizen.Wait(3)
    end
    
    local OffsetCoords = GetOffsetFromEntityInWorldCoords(Player, 0.0, 0.75, 0.0)
    local Prop = CreateObjectNoOffset(Object, OffsetCoords, false, true, false)
    SetEntityHeading(Prop, Heading)
    PlaceObjectOnGroundProperly(Prop)
    SetEntityCollision(Prop, false, true)
    SetEntityAlpha(Prop, 100)
    FreezeEntityPosition(Prop, true)
    SetModelAsNoLongerNeeded(Object)
    
    Notify('Press ~g~E ~w~to place\nPress ~r~R ~w~to cancel')
    
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(3)
            
            local OffsetCoords = GetOffsetFromEntityInWorldCoords(Player, 0.0, 0.75, 0.0)
            local Heading = GetEntityHeading(Player)
            
            SetEntityCoordsNoOffset(Prop, OffsetCoords)
            SetEntityHeading(Prop, Heading)
            PlaceObjectOnGroundProperly(Prop)
            DisableControlAction(1, 38, true)--E
            DisableControlAction(1, 140, true)--R
            DisableControlAction(0, 22, true)-- Jump
            
            
            if IsDisabledControlJustPressed(1, 38) then --E
                local PropCoords = GetEntityCoords(Prop)
                local PropHeading = GetEntityHeading(Prop)
                DeleteObject(Prop)
                
                RequestModel(Object)
                while not HasModelLoaded(Object) do
                    Citizen.Wait(3)
                end
                
                local Prop = CreateObjectNoOffset(Object, PropCoords, true, true, true)
                SetEntityHeading(Prop, PropHeading)
                PlaceObjectOnGroundProperly(Prop)
                FreezeEntityPosition(Prop, true)
                SetEntityInvincible(Prop, true)
                SetModelAsNoLongerNeeded(Object)
                return
            end
            
            if IsDisabledControlJustPressed(1, 140) then --R
                DeleteObject(Prop)
                return
            end
        end
    end)
end

function DeleteProp(Object)
    local Hash = GetHashKey(Object)
    local x, y, z = table.unpack(GetEntityCoords(PlayerPedId(), true))
    if DoesObjectOfTypeExistAtCoords(x, y, z, 1.5, Hash, true) then
        local Prop = GetClosestObjectOfType(x, y, z, 1.5, Hash, false, false, false)
        DeleteObject(Prop)
        Notify('~r~Prop Removed!')
    end
end

function DeleteEntity(Entity)
    Citizen.InvokeNative(0xAE3CBE5BF394C9C9, Citizen.PointerValueIntInitialized(Entity))
end



--Emote Functions
function PlayEmote(Emote, Name)
    if not DoesEntityExist(PlayerPedId()) then
        return
    end
    
    if IsPedInAnyVehicle(PlayerPedId()) then
        Notify('~r~Please exit the vehicle to use this emote!')
        return
    end
    
    TaskStartScenarioInPlace(PlayerPedId(), Emote, 0, true)
    Notify('~b~Playing Emote: ~g~' .. Name)
    EmotePlaying = true
end

function CancelEmote()
    ClearPedTasks(PlayerPedId())
    Notify('~r~Stopping Emote')
    EmotePlaying = false
end







--Menu Restrictions
function LEORestrict()
    if Config.LEOAccess == 0 then
        return false
    elseif Config.LEOAccess == 1 then
        return true
    elseif Config.LEOAccess == 2 then
        local Ped = GetEntityModel(PlayerPedId())
        
        for _, LEOPeds in pairs(Config.LEOUniforms) do
            local AllowedPed = GetHashKey(LEOPeds.spawncode)
            
            if Ped == AllowedPed then
                return true
            end
        end
    elseif Config.LEOAccess == 3 then
        return LEOOnduty
    elseif Config.LEOAccess == 4 then
        return LEOAce
    elseif Config.LEOAccess == 5 then
        return LEOOnduty
    else
        return true
    end
end



function FireRestrict()
    if Config.FireAccess == 0 then
        return false
    elseif Config.FireAccess == 1 then
        return true
    elseif Config.FireAccess == 2 then
        local Ped = GetEntityModel(PlayerPedId())
        
        for _, FirePeds in pairs(Config.FireUniforms) do
            local AllowedPed = GetHashKey(FirePeds.spawncode)
            
            if Ped == AllowedPed then
                return true
            end
        end
    elseif Config.FireAccess == 3 then
        return FireOnduty
    elseif Config.FireAccess == 4 then
        return FireAce
    elseif Config.FireAccess == 5 then
        return FireOnduty
    else
        return true
    end
end



function CivRestrict()
    if Config.CivAccess == 0 then
        return false
    elseif Config.CivAccess == 1 then
        return true
    else
        return true
    end
end



function VehicleRestrict()
    if Config.VehicleAccess == 0 then
        return false
    elseif Config.VehicleAccess == 1 then
        return true
    elseif Config.VehicleAccess == 2 then
        if IsPedInAnyVehicle(GetPlayerPed(PlayerId()), false) then
            return true
        else
            return false
        end
    else
        return true
    end
end



function EmoteRestrict()
    if Config.EmoteAccess == 0 then
        return false
    elseif Config.EmoteAccess == 1 then
        return true
    else
        return true
    end
end
