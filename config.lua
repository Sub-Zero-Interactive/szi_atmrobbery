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
    --     name = 'phone' -- Uncomment these 3 lines to remove the item after hacking the atm
    -- }
}

Config.Rewards = {
    {
        name = 'money', -- Choices are money, bank, black_money or an item 
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

Config.Dependencies = {
    {
        FivemTarget = false -- Set to 'true' if you are using fivem-target or 'false' for bt-target
    },
    {
        MythicNotify = false -- Set to 'true' if you are using mythic_notify
    },
    {
        Mhacking = false, -- Set to 'true' if you are using mhacking
        HackTime = 10000 -- This is how long it takes to wait to "hack" the atm in ms, only used if Mhacking is false
    }
}

Config.Options = {
    {
        PoliceRequired = 1, -- Amount of Police required to hack an ATM
        BlipTimer = 45, -- Blip timer  until removed in seconds
        PhoneModel = -1038739674, -- The Phone model prop when hacking
        CooldownTime = 300, -- Cooldown in Seconds before someone can rob an ATM
        MaxChance = 100, -- Max number the chance can go up to (default 100)
        Chance = 100, -- The % Chance of notifying police when a robbery is started (25 = 25%)
        MinChance = 1, -- Minimum number the chance can be (Keep at 1 unless you know what you are doing)
        RobTime = 10, -- How long it takes to rob the atm per cycle in seconds
        MaxTake = 3 -- The amount of times the "Cycle" can happen (links with reward ammount)
    }
}

Config.Animations = {
    {
        name = "Hacking",
        dictionary = "cellphone@",
        animation = "cellphone_horizontal_base"
    },
    {
        name = "Stealing",
        dictionary = "anim@heists@prison_heistig1_p1_guard_checks_bus",
        animation = "loop"       
    }
}

GetDependency = function(Dependency)
    for k,v in pairs(Config.Dependencies) do
        if v[Dependency] then
            return v[Dependency]
        end
    end
end

GetOptions = function(Option)
    for k,v in pairs(Config.Options) do
        if v[Option] then
            return v[Option]
        end
    end
end
