-- Persistence Module for SEM_InteractionMenu
-- Made by Knight.#0001
-- DO NOT USE WITHOUT PERMISSION

if Config.Persistence then
    PERSISTENT_JAIL_LIST = {}


    function GetLicense(id)
        local ids = GetPlayerIdentifiers(id)
        local license = false
        if ids then
            for _,ident in ipairs(ids) do
                if string.find(ident,"license:") then
                    license = ident
                    break
                end
            end
        end
        return license
    end

    function InitPurgeList()
        local purged = 0
        for k,v in pairs(PERSISTENT_JAIL_LIST) do
            if v.lastseen < (os.time() - 604800) then
                PERSISTENT_JAIL_LIST[k] = nil
                purged = purged + 1
            end
        end
        UpdateList()
        print("[Persistence] Purged "..tostring(purged).." Jail Sentences from inactive players.")
    end

    function InitReadFile()
        local data = LoadResourceFile(GetCurrentResourceName(), 'jail_list.json')
        if data then
            local data_parsed = json.decode(data)
            if type(data_parsed) == "table" then
                PERSISTENT_JAIL_LIST = data_parsed
                InitPurgeList()
                return
            end
        end
        -- If that didn't work, just make the file for when we need it.
        SaveResourceFile(GetCurrentResourceName(), 'jail_list.json', json.encode(PERSISTENT_JAIL_LIST), -1)
    end


    function UpdateList()
        SaveResourceFile(GetCurrentResourceName(), 'jail_list.json', json.encode(PERSISTENT_JAIL_LIST), -1)
    end


    AddEventHandler('SEM_InteractionMenu:PersistJail:Start', function(id,time)
        if time >= 60 then
            print("[Persistence] Adding Jail Time for "..tostring(id).." to list.")
            local license = GetLicense(id)
            if license then
                PERSISTENT_JAIL_LIST[license] = {time = time, paused = false, originaltime = time, lastseen = os.time()}
                UpdateList()
                print("[Persistence] [SUCCESS] Added Time for "..tostring(id).." to list.")
            else
                print("[Persistence] [ERROR] Could not add Time for "..tostring(id).." to list.")
            end
        end
    end)


    AddEventHandler('playerDropped', function(reason)
        local id = source
        local license = GetLicense(id)
        if license then
            if PERSISTENT_JAIL_LIST[license] then
                PERSISTENT_JAIL_LIST[license].paused = true
                UpdateList()
                print("[Persistence] Paused Sentence Time for "..tostring(id))
            end
        end
    end)


    AddEventHandler('SEM_InteractionMenu:Unjail', function(id)
        if IsPlayerAceAllowed(source, "sem_intmenu.unjail") then
            local license = GetLicense(id)
            if license then
                if PERSISTENT_JAIL_LIST[license] then
                    PERSISTENT_JAIL_LIST[license] = nil
                    UpdateList()
                end
            end
        end
    end)


    RegisterNetEvent('SEM_InteractionMenu:PersistJail:Check')
    AddEventHandler('SEM_InteractionMenu:PersistJail:Check', function()
        local id = source
        local license = GetLicense(id)
        if license then
            if PERSISTENT_JAIL_LIST[license] then
                TriggerClientEvent('SEM_InteractionMenu:JailPlayer', id, PERSISTENT_JAIL_LIST[license].time, PERSISTENT_JAIL_LIST[license].originaltime)
                PERSISTENT_JAIL_LIST[license].paused = false
                PERSISTENT_JAIL_LIST[license].lastseen = os.time()
                print("[Persistence] Resuming Jail Time for "..tostring(id))
            end
        end
    end)


    Citizen.CreateThread(function()
        while true do
            Wait(60000)
            local curtime = os.time()
            local total = 0
            local activ = 0
            for k,v in pairs(PERSISTENT_JAIL_LIST) do
                total = total + 1
                if not v.paused then
                    activ = activ + 1
                    if v.time <= 60 then
                        PERSISTENT_JAIL_LIST[k] = nil
                    else
                        PERSISTENT_JAIL_LIST[k].time = (v.time - 60)
                        PERSISTENT_JAIL_LIST[k].lastseen = curtime
                    end
                end
            end
            if total > 0 then print("[Persistence] Incomplete Sentences: "..tostring(total).." | Currently Serving Time: "..tostring(activ)) end
            UpdateList()
        end
    end)


    InitReadFile()
end