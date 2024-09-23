QBCore = exports['qb-core']:GetCoreObject()

local spawnedNPCs = {} 
local rollCounter = 0 

Citizen.CreateThread(function()
    for _, npc in pairs(Config.NPCs) do
        local pedHash = GetHashKey(npc.model)
        RequestModel(pedHash)
        while not HasModelLoaded(pedHash) do
            Wait(100)
        end

        local ped = CreatePed(4, pedHash, npc.coords.x, npc.coords.y, npc.coords.z, 0.0, false, true)
        TaskStartScenarioInPlace(ped, npc.animation, 0, true)

        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        SetPedFleeAttributes(ped, 0, 0)
        SetPedCombatAttributes(ped, 46, true)
        table.insert(spawnedNPCs, {ped = ped, animation = npc.animation})

        if npc.blip and npc.blip.enabled then
            local blip = AddBlipForCoord(npc.coords.x, npc.coords.y, npc.coords.z)
            SetBlipSprite(blip, npc.blip.sprite)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, npc.blip.scale)
            SetBlipColour(blip, npc.blip.color)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(npc.blip.label)
            EndTextCommandSetBlipName(blip)
        end

        if npc.targetable then
            exports.ox_target:addLocalEntity(ped, {
                {
                    name = "dice_gamble",
                    label = "Play Dice",
                    icon = "fas fa-dice",
                    distance = 2.0,
                    onSelect = function()
                        openBetMenu(ped)
                    end
                }
            })
        end
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        for _, npcData in pairs(spawnedNPCs) do
            if npcData and npcData.ped and DoesEntityExist(npcData.ped) then
                DeleteEntity(npcData.ped)
              else
           end
        end
        spawnedNPCs = {}
    end
end)

function openBetMenu(npcPed)
    local input = lib.inputDialog('Place Your Bet', {
        {type = 'number', label = 'Bet Amount', min = Config.minBet, max = Config.maxBet}
    })

    if input and input[1] then
        local betAmount = tonumber(input[1])

        if betAmount and betAmount >= Config.minBet and betAmount <= Config.maxBet then
            QBCore.Functions.TriggerCallback('tropic-dicegame:checkBet', function(canBet)
                if canBet then
                    startDiceGame(betAmount, npcPed)
                else
                    lib.notify({title = 'Not enough money!', type = 'error'})
                end
            end, betAmount)
        else
            lib.notify({title = 'Invalid Bet Amount!', type = 'error'})
        end
    else
        lib.notify({title = 'Bet was not placed!', type = 'error'})
    end
end


function rollDice()
    return math.random(2, 12)
end

function startDiceGame(betAmount, npcPed)
        rollCounter = rollCounter + 1 

    if rollCounter >= Config.maxRolls then
        local randomOutcome = math.random(1, 2)
        if randomOutcome == 1 then
            winGame(betAmount) 
        else
            loseGame(betAmount) 
        end
        return
    end

    playRollAnimation(PlayerPedId())
    Wait(Config.animation.duration)

    local playerRoll = rollDice()
    lib.notify({title = "You rolled a " .. playerRoll})

    if playerRoll == 7 or playerRoll == 11 then

        winGame(betAmount)
    else

        Wait(Config.rollDelay)
        npcRoll(betAmount, playerRoll, npcPed)
    end
end

function resetNPCsToAnimation()
    for _, npcData in pairs(spawnedNPCs) do
        TaskStartScenarioInPlace(npcData.ped, npcData.animation, 0, true)
    end
end

function npcRoll(betAmount, playerRoll, npcPed)

    playRollAnimation(npcPed)
    Wait(Config.animation.duration)

    local npcRoll = rollDice()
    lib.notify({title = "Opponent rolled a " .. npcRoll})

    if npcRoll == 7 or npcRoll == 11 then

        loseGame(betAmount)
    else

        Wait(Config.rollDelay)
        startDiceGame(betAmount, npcPed)
    end
end


function winGame(betAmount)
    rollCounter = 0 
    local payout = betAmount * 2
    TriggerServerEvent('tropic-dicegame:payPlayer', payout)
    lib.notify({title = "You won! $" .. payout .. "!", type = "success"})
    resetNPCsToAnimation()
 
    if Config.enableJumped then
    if math.random(1, 100) <= Config.jumpedChance then
        triggerNPCFight()
    end
        else
    end
end

function loseGame(betAmount)
    rollCounter = 0
    TriggerServerEvent('tropic-dicegame:playerLoss', betAmount)
    lib.notify({title = "You lost $" .. betAmount .. ".", type = "error"})
    resetNPCsToAnimation()
end


function triggerNPCFight()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local npcModels = {"g_m_y_ballaorig_01", "csb_ballasog"}

    for i = 1, 2 do
        local npcModel = GetHashKey(npcModels[math.random(1, #npcModels)])
        RequestModel(npcModel)
        while not HasModelLoaded(npcModel) do
            Wait(100)
        end

        local ped = CreatePed(4, npcModel, playerCoords.x + math.random(-5, 5), playerCoords.y + math.random(-5, 5), playerCoords.z, 0.0, true, true)
        TaskCombatPed(ped, playerPed, 0, 16)
    end
    lib.notify({title = "You're getting jumped!"})
end

function playRollAnimation(ped)
    RequestAnimDict(Config.animation.dict)
    while not HasAnimDictLoaded(Config.animation.dict) do
        Wait(100)
    end
    TaskPlayAnim(ped, Config.animation.dict, Config.animation.clip, 8.0, -8.0, Config.animation.duration, 0, 0, false, false, false)
end
