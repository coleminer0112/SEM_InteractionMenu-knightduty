Citizen.CreateThread(function()
    while PlayerPedId() < 1 do
        Wait(10)
    end
    TriggerServerEvent('SEM_InteractionMenu:PersistJail:Check')
end)