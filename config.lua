Config = {}

Config.Locale = 'en'

Config.RequiredItems = {
    {
        name = 'phone', -- Item required to hack the atm's
        quantity = 1
    }
}


Config.RemoveItems = {
    -- {
    --     name = 'phone' -- Uncomment these 3 lines to remove the phone after hacking the atm
    -- }--,
}

Config.Rewards = {
    {
        name = 'money', -- Choices are money, bank, black_money or an item name
        amount = math.random(100, 1000) -- The random amount you take per cycle (MaxTake is how many times it cycles max)
    }
}

Config.AtmModels = {
    {
        prop = 'prop_atm_01'
    },
    {
        prop = 'prop_atm_02'
    },
    {
        prop = 'prop_atm_03'
    },
    {
        prop = 'prop_fleeca_atm'
    }
}

Config.FivemTarget = false -- set to 'true' if you are using fivem-target or 'false' for bt-target

Config.PhoneModel = -1038739674 -- The Phone model prop when hacking
Config.PoliceRequired = 1 -- Amount of Police required to hack an ATM
Config.CooldownTime =  300 -- Cooldown in Seconds before someone can rob an ATM

Config.MaxChance = 100 -- Max number the chance can go up to (default 100)
Config.Chance =  15 -- The % Chance of notifying police when a robbery is started (25 = 25%)
Config.MinChance =  1 -- Minimum number the chance can be (Keep at 1 unless you know what you are doing)

Config.BlipTimer = 45-- Blip timer  until removed in seconds

Config.MaxTake = 3 -- The amount of times the "Cycle" can happen (links with reward ammount)
Config.RobTime = 10 -- How long it takes to rob the atm per cycle in seconds

Config.HackingDict = 'cellphone@' 
Config.HackingAnim = 'cellphone_horizontal_base'

Config.StealingDict = 'anim@heists@prison_heistig1_p1_guard_checks_bus'
Config.StealingAnim = 'loop'
