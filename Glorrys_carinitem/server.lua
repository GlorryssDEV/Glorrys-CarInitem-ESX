local ESX = exports.es_extended:getSharedObject()

local activeVehicle = {}

for vehicle,item in pairs(Glorrys.Vehicles) do

    ESX.RegisterUsableItem(item,function(source)

        local xPlayer = ESX.GetPlayerFromId(source)
        if not xPlayer then return end

        if activeVehicle[source] then

            TriggerClientEvent('ox_lib:notify',source,{
                title = 'Glorrys Development',
                description = 'You already have a spawned vehicle',
                type = 'error'
            })

            return
        end

        xPlayer.removeInventoryItem(item,1)

        activeVehicle[source] = item

        TriggerClientEvent('glorrys_caritem:spawn',source,vehicle)

    end)

end


RegisterNetEvent('glorrys_caritem:returnVehicle',function()

    local src = source

    local item = activeVehicle[src]
    if not item then return end

    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    xPlayer.addInventoryItem(item,1)

    activeVehicle[src] = nil

end)


AddEventHandler('playerDropped',function()

    local src = source

    activeVehicle[src] = nil

end)
