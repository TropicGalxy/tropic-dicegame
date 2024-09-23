QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateCallback('tropic-dicegame:checkBet', function(source, cb, betAmount)
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        cb(false)
        return
    end

    if Player.PlayerData.money['cash'] >= betAmount then
        cb(true) 
    else
        cb(false) 
    end
end)


RegisterNetEvent('tropic-dicegame:payPlayer', function(payout)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player then
        Player.Functions.AddMoney('cash', payout)
    end
end)

RegisterNetEvent('tropic-dicegame:playerLoss', function(betAmount)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player then
        Player.Functions.RemoveMoney('cash', betAmount)
    end
end)
