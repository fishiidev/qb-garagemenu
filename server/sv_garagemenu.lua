local garagevehs = {}
RegisterServerEvent("qb-garages:list_vehicles")
AddEventHandler("qb-garages:list_vehicles",function(gName)
    local src = source
    local user = QBCore.Functions.GetPlayer(src)
    local cunt = user.PlayerData
    local citizenid = cunt.citizenid
    local vehicle = vehicle
    local name = name
    if not citizenid then return end
    exports.ghmattimysql:execute("SELECT * FROM player_vehicles WHERE citizenid = @citizenid", {['citizenid'] = citizenid}, function(vehcheck)
        if vehcheck ~= nil then   
            for i = 1, #vehcheck do
                garagevehs[i] = {
                    state = vehcheck[i].state,
                    plate = vehcheck[i].plate,
                    name = vehcheck[i].vehicle:upper(),
                    garage = vehcheck[i].garage,
                }
                if gName == garagevehs[i].garage then
                    if garagevehs[i].state ~= 2 and garagevehs[i].state ~= 0 then
                        local vehname = vehcheck[i].vehicle:upper()
                        local plate = vehcheck[i].plate
                        local fuck = gName:upper()
                        TriggerClientEvent('nh-context:sendMenu', src, {
                            {
                                id = i,
                                header = vehname,
                                txt = plate,
                                params = {
                                    event = "qb-garages:takeoutveh",
                                    args = {
                                        vehicle = vehcheck[i]
                                    }
                                }
                            },
                        })
                    end
                elseif (garagevehs[i].state == 2 or vehcheck[i].depotprice > 0) and gName == "hayesdepot" then
                    local vehname = vehcheck[i].vehicle:upper()
                    local plate = vehcheck[i].plate
                    TriggerClientEvent('nh-context:sendMenu', src, {
                        {
                            id = i,
                            header = vehname,
                            txt = plate,
                            params = {
                                event = "qb-garages:takeoutveh:depot",
                                args = {
                                    vehicle = vehcheck[i]
                                }
                            }
                        },
                    })
                end
            end
        end
	end)
end)

RegisterServerEvent('qb-garage:server:PayDepotPrice:menu')
AddEventHandler('qb-garage:server:PayDepotPrice:menu', function(plate)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local bankBalance = Player.PlayerData.money["bank"]
    exports['ghmattimysql']:execute('SELECT * FROM player_vehicles WHERE plate = @plate', {['@plate'] = plate}, function(result)
        if result[1] ~= nil then
            if bankBalance >= result[1].depotprice then
                Player.Functions.RemoveMoney("bank", result[1].depotprice, "paid-depot")
                exports['ghmattimysql']:execute('UPDATE player_vehicles SET depotprice = @depotprice WHERE plate = @plate', {['@depotprice'] = 0, ['@plate'] = plate})
            end
        end
    end)
end)
