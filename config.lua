Config = {}

-- DEBUG AND EXTRAS --
Config.Prints = true -- Used for Debug Prints
Config.StuckPropCommand = true -- Enables command for stuck props
Config.DisableSprintJump = true -- Enable to disable sprint / jump while carrying plank
Config.Keys = "G"

-- PAYMENTS / DROP COUNTER --
Config.Moneytype = 'cash' -- Set to cash or bank
Config.PayPerDrop = 1.50 -- Pay is 1.50 cents per drop
Config.DropCount = 10 -- Max drops before they must collect paycheck
Config.PlaceTime = 4 -- How long the progressbar to place wood is - In Seconds

-- MINIGAME CONFIG --
Config.Circle = 3 -- Circles required to complete
Config.Time = 12 -- How long each circle is

-- NPC LOCATIONS --
Config.JobNpc = {
	[1] = { ["Model"] = "mp_u_m_m_fos_dockworker_01", ["Pos"] = vector3(1300.1058, -1310.373, 76.621063), ["Heading"] = 14.66,    ["Name"] = "Rhodes" }, --Rhodes
}

-- LOCATION OF JOB SITES --
Config.Locations = {
	["Rhodes"] = {
		["Location"] = vector3(1300.1058, -1310.373, 76.621063), -- Location for NPC
		["BrickLocations"] = { -- Pickup Brick Locations
			[1] = { coords = vector3(1297.1773, -1312.67, 76.697563)  },
		},
		["DropLocations"] = { -- Drop Brick Locations
			[1]  = { coords = vector3(1289.1163, -1316.464, 77.281967) }, 
			[2]  = { coords = vector3(1291.295, -1313.816, 76.552925)  },
			[3]  = { coords = vector3(1293.9219, -1310.631, 76.551483) },
			[4]  = { coords = vector3(1297.1784, -1306.84, 76.549316)  },
			[5]  = { coords = vector3(1300.6899, -1302.84, 76.48796)   },
			[6]  = { coords = vector3(1284.4409, -1316.272, 76.899848) },
			[7]  = { coords = vector3(1279.798, -1312.426, 76.895294)  },
			[8]  = { coords = vector3(1278.6407, -1307.741, 76.617935) },
			[9]  = { coords = vector3(1281.7565, -1303.905, 76.534027) },
			[10] = { coords = vector3(1286.6417, -1298.037, 76.576446) },
		},
	},
}
