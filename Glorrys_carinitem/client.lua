local vehicle = nil

RegisterNetEvent('glorrys_caritem:spawn', function(model)

    if vehicle and DoesEntityExist(vehicle) then
        lib.notify({
            title = 'Vehicle',
            description = 'Už máš spawnuté vozidlo',
            type = 'error'
        })
        return
    end

    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)

    local hash = joaat(model)

    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Wait(50)
    end

    vehicle = CreateVehicle(hash, coords.x, coords.y, coords.z, heading, true, true)

    SetEntityAsMissionEntity(vehicle, true, true)

    SetPedIntoVehicle(ped, vehicle, -1)

    SetModelAsNoLongerNeeded(hash)

    lib.notify({
        title = 'Vehicle',
        description = 'Auto spawnuto',
        type = 'success'
    })

end)


RegisterCommand("storevehicle", function()

    if not vehicle or not DoesEntityExist(vehicle) then
        return
    end

    local ped = PlayerPedId()
    local pedCoords = GetEntityCoords(ped)
    local vehCoords = GetEntityCoords(vehicle)

    if #(pedCoords - vehCoords) > 5.0 then

        lib.notify({
            title = 'Vehicle',
            description = 'Musíš být blízko vozidla',
            type = 'error'
        })

        return
    end

    local finished = lib.progressBar({
        duration = Glorrys.StoreTime,
        label = 'Schováváš vozidlo...',
        useWhileDead = false,
        canCancel = false,
        disable = {
            move = true,
            car = true
        }
    })

    if not finished then return end


    NetworkRequestControlOfEntity(vehicle)

    local timeout = 0
    while not NetworkHasControlOfEntity(vehicle) and timeout < 50 do
        Wait(10)
        timeout = timeout + 1
    end


    SetEntityAsMissionEntity(vehicle, true, true)
    DeleteVehicle(vehicle)

    vehicle = nil

    TriggerServerEvent('glorrys_caritem:returnVehicle')

    lib.notify({
        title = 'Vehicle',
        description = 'Vozidlo bylo schováno',
        type = 'success'
    })

end)


RegisterKeyMapping('storevehicle', 'Schovat vozidlo', 'keyboard', 'E')

CreateThread(function()

    while true do

        Wait(2000)

        if vehicle and DoesEntityExist(vehicle) then

            if GetPedInVehicleSeat(vehicle, -1) == 0 then

                if not vehicleEmptyTime then
                    vehicleEmptyTime = GetGameTimer()
                end

                if GetGameTimer() - vehicleEmptyTime > 5000 then

                    SetEntityAsMissionEntity(vehicle,true,true)
                    DeleteVehicle(vehicle)

                    vehicle = nil
                    vehicleEmptyTime = nil

                    TriggerServerEvent('glorrys_caritem:returnVehicle')

                    lib.notify({
                        title = 'Vehicle',
                        description = 'Vozidlo bylo smazáno',
                        type = 'inform'
                    })

                end

            else
                vehicleEmptyTime = nil
            end

        end

    end

end)