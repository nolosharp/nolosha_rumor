Config = {
    DevMode = false, -- If true, rumor range will be increased.
    --FakeRumors = false, -- If true, fake static rumors will be used instead of generating new ones.
    Debug = false, -- If true, debug messages will be printed.

    minRumor = 1, -- Minimum number of rumors to display at the same time.
    maxRumor = 3, -- Maximum number of rumors to display at the same time.

    rumorDuration = 60, -- Duration of a rumor display in seconds.

    rumorValidity = 20 * 60, -- Duration of a rumor validity in seconds.
    rumorAskingDelay = 5 * 60, -- Delay in seconds between two rumors asking for one character.

    crossAreaChance = 0.2, -- Chance of a rumor to spread to another area. (1 = 100%; 0 = 0%)

    talkControl = 0x760A9C6F, -- Control to press to talk to a NPC. [G]

    price = 1, -- Price of a rumor.

    Npcs = {
        { -- Valentine
            --id = "valentine",
            model = "u_m_m_nbxshadydealer_01",
            coords = {x = -217.3, y = 809.95, z = 123.56, h = 302.43},
            spreading = {
                center =  {x = -217.3, y = 809.95, z = 124.56},
                radius = 100.0
            }
        },
        { -- Emerald
            --id = "Emerald",
            model = "u_m_m_nbxshadydealer_01",
            coords = {x = 1383.54, y = 213.73, z = 91.06, h = 34.86},
            spreading = {
                center =  {x = 1375.98, y = 302.3, z = 87.74},
                radius = 100.0
            }
        },
        { -- Blackwater
            --id = "blackwater",
            model = "u_m_m_nbxshadydealer_01",
            coords = {x = -815.7, y = -1353.13, z = 42.30, h = 88.54},
            spreading = {
                center =  {x = -815.7, y = -1353.13, z = 43.63},
                radius = 100.0
            }
        },
        { -- Armadillo
            --id = "armadillo",
            model = "u_m_m_nbxshadydealer_01",
            coords = {x = -3703.85, y = -2637.83, z = -13.85, h = 202.21},
            spreading = {
                center =  {x = -3661.34, y = -2599.2, z = -10.07},
                radius = 100.0
            }
        }
    }
}