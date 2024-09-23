Config = {
    NPCs = {
        {
            coords = vector3(52.79, -1911.13, 20.65),
            model = "g_m_y_ballaorig_01",
            animation = "WORLD_HUMAN_DRUG_DEALER",
            targetable = true,  -- this is pretty much so you can make the illusion there are people playing together without being able to interact with them
            blip = {
                enabled = true,      -- enable or disable blip for this NPC
                sprite = 280,        -- blip icon
                color = 50,           -- blip color
                scale = 0.8,         -- blip scale
                label = "Dice Game",  -- blip label
            }
        }
    },
    minBet = 10,
    maxBet = 1000,
    maxRolls = 4, -- max rolls before it automatically calls a 50/50 chance of winning to prevent the game going forever
    animation = {
        dict = "anim@mp_player_intcelebrationmale@wank",
        clip = "wank",
        duration = 2000
    },
    enableJumped = true, -- enable/disable the ability to get jumped after winning
    jumpedChance = 40, -- percent chance to get jumped after you win
    rollDelay = 3000
}

