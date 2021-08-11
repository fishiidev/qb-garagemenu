RegisterNetEvent('qb-garages:putingarage')
AddEventHandler('qb-garages:putingarage', function()
    local ped = PlayerPedId()
    coordA = GetEntityCoords(ped, 1)
    coordB = GetOffsetFromEntityInWorldCoords(ped, 0.0, 100.0, 0.0)
    curVeh = getVehicleInDirection(coordA, coordB)
    local plate = GetVehicleNumberPlateText(curVeh)
    QBCore.Functions.TriggerCallback('qb-garage:server:checkVehicleOwner', function(owned)
        Citizen.Wait(1000)
        if owned then
            local fuck = GetCurrentGarage()
            if fuck ~= nil then
                QBCore.Functions.TriggerCallback("qb-garage:server:GetUserVehicles", function(result)
                    local bodyDamage = math.ceil(GetVehicleBodyHealth(curVeh))
                    local engineDamage = math.ceil(GetVehicleEngineHealth(curVeh))
                    local totalFuel = exports['LegacyFuel']:GetFuel(curVeh)
                    local passenger = GetVehicleMaxNumberOfPassengers(curVeh)
                    TriggerServerEvent('qb-garage:server:updateVehicleStatus', totalFuel, engineDamage, bodyDamage, plate, fuck)
                    TriggerServerEvent('qb-garage:server:updateVehicleState', 1, plate, fuck)
                    QBCore.Functions.DeleteVehicle(curVeh)
                    QBCore.Functions.Notify("Vehicle Parked In", "primary", 4500)
                end, fuck)
            else
                QBCore.Functions.Notify("Can't find current garage, sir.", "error", 3500)
            end
        else
            QBCore.Functions.Notify("Nobody owns this vehicle", "error", 3500)
        end
    end, plate)
end)

RegisterNetEvent('qb-garages:takeout')
AddEventHandler('qb-garages:takeout', function()
    local fuck = GetCurrentGarage() or GetDepotsDist()
    if fuck ~= nil then
        TriggerServerEvent('qb-garages:list_vehicles', fuck)
    else
        QBCore.Functions.Notify("Can't find current garage, sir.", "error", 3500)
    end
end)

RegisterNetEvent('qb-garages:takeoutveh')
AddEventHandler('qb-garages:takeoutveh', function(type)
        for k, v in pairs(type) do
            enginePercent = round(v.engine / 10, 0)
            bodyPercent = round(v.body / 10, 0)
            currentFuel = v.fuel
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            local heading = GetEntityHeading(ped)
            local forward = GetEntityForwardVector(PlayerPedId())
            local x, y, z = table.unpack(coords + forward)
            local spawnpoint = vector4(x, y, z, heading-85)
            print(GetCurrentGarage())
            Citizen.Wait(1000)
            QBCore.Functions.SpawnVehicle(v.vehicle, function(veh)
                QBCore.Functions.TriggerCallback('qb-garage:server:GetVehicleProperties', function(properties)
                    QBCore.Functions.SetVehicleProperties(veh, properties)
                    SetVehicleNumberPlateText(veh, v.plate)
                    exports['LegacyFuel']:SetFuel(veh, v.fuel)
                    doCarDamage(veh, v)
                    SetEntityAsMissionEntity(veh, true, true)
                    TriggerServerEvent('qb-garage:server:updateVehicleState', 0, v.plate, v.garage)
                    QBCore.Functions.Notify("Vehicle Off:Engine " .. enginePercent .. "% Body: " .. bodyPercent.. "% Fuel: "..currentFuel.. "%", "primary", 4500)
                    TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(veh))
                    SetVehicleEngineOn(veh, false, false)
                end, v.plate)
            end, spawnpoint, true)
        end
end)

RegisterNetEvent('qb-garages:takeoutveh:depot')
AddEventHandler('qb-garages:takeoutveh:depot', function(type)
        for k, v in pairs(type) do
            enginePercent = round(v.engine / 10, 0)
            bodyPercent = round(v.body / 10, 0)
            currentFuel = v.fuel
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            local heading = GetEntityHeading(ped)
            local forward = GetEntityForwardVector(PlayerPedId())
            local x, y, z = table.unpack(coords + forward)
            local spawnpoint = vector4(x, y, z, heading-85)
            print(GetCurrentGarage())
            Citizen.Wait(1000)
            QBCore.Functions.SpawnVehicle(v.vehicle, function(veh)
                QBCore.Functions.TriggerCallback('qb-garage:server:GetVehicleProperties', function(properties)
                    QBCore.Functions.SetVehicleProperties(veh, properties)
                    SetVehicleNumberPlateText(veh, v.plate)
                    exports['LegacyFuel']:SetFuel(veh, v.fuel)
                    doCarDamage(veh, v)
                    SetEntityAsMissionEntity(veh, true, true)
                    TriggerServerEvent('qb-garage:server:updateVehicleState', 0, v.plate, v.garage)
                    QBCore.Functions.Notify("Vehicle Off:Engine " .. enginePercent .. "% Body: " .. bodyPercent.. "% Fuel: "..currentFuel.. "%", "primary", 4500)
                    TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(veh))
                    SetVehicleEngineOn(veh, false, false)
                    TriggerServerEvent('qb-garage:server:PayDepotPrice:menu', v.plate)
                end, v.plate)
            end, spawnpoint, true)
        end
end)

function GetCurrentGarage()
    local cock = PlayerPedId()
    local cockpos = GetEntityCoords(cock)
    for k, v in pairs(Garages) do
        local takeDist = #(cockpos - vector3(Garages[k].polyzone.x, Garages[k].polyzone.y, Garages[k].polyzone.z))
        if takeDist <= 25 then
            return k
        end
    end
end

function GetDepotsDist()
    local cock = PlayerPedId()
    local cockpos = GetEntityCoords(cock)
    for k, v in pairs(Depots) do
        local takeDist = #(cockpos - vector3(Depots[k].polyzone.x, Depots[k].polyzone.y, Depots[k].polyzone.z))
        if takeDist <= 10 then
            return k
        end
    end
end

function getVehicleInDirection(coordFrom, coordTo)
	local offset = 0
	local rayHandle
	local vehicle
	for i = 0, 100 do
		rayHandle = CastRayPointToPoint(coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z + offset, 10, PlayerPedId(), 0)	
		a, b, c, d, vehicle = GetRaycastResult(rayHandle)
		offset = offset - 1
		if vehicle ~= 0 then break end
	end
	local distance = Vdist2(coordFrom, GetEntityCoords(vehicle))
	if distance > 25 then vehicle = nil end
    return vehicle ~= nil and vehicle or 0
end

function round(num, numDecimalPlaces)
    return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end

function doCarDamage(currentVehicle, veh)
	smash = false
	damageOutside = false
	damageOutside2 = false
	local engine = veh.engine + 0.0
	local body = veh.body + 0.0
	if engine < 200.0 then
		engine = 200.0
    end

    if engine > 1000.0 then
        engine = 1000.0
    end

	if body < 150.0 then
		body = 150.0
	end
	if body < 900.0 then
		smash = true
	end

	if body < 800.0 then
		damageOutside = true
	end

	if body < 500.0 then
		damageOutside2 = true
	end

    Citizen.Wait(100)
    SetVehicleEngineHealth(currentVehicle, engine)
	if smash then
		SmashVehicleWindow(currentVehicle, 0)
		SmashVehicleWindow(currentVehicle, 1)
		SmashVehicleWindow(currentVehicle, 2)
		SmashVehicleWindow(currentVehicle, 3)
		SmashVehicleWindow(currentVehicle, 4)
	end
	if damageOutside then
		SetVehicleDoorBroken(currentVehicle, 1, true)
		SetVehicleDoorBroken(currentVehicle, 6, true)
		SetVehicleDoorBroken(currentVehicle, 4, true)
	end
	if damageOutside2 then
		SetVehicleTyreBurst(currentVehicle, 1, false, 990.0)
		SetVehicleTyreBurst(currentVehicle, 2, false, 990.0)
		SetVehicleTyreBurst(currentVehicle, 3, false, 990.0)
		SetVehicleTyreBurst(currentVehicle, 4, false, 990.0)
	end
	if body < 1000 then
		SetVehicleBodyHealth(currentVehicle, 985.1)
	end
end
