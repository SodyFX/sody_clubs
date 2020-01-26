Config              = {
	Locale = "en"
}

Config.DrawDistance = 50.0
Config.MarkerType = 25
Config.MarkerSize = { x = 1.5, y = 1.5, z = 0.5 }
Config.MarkerColor = { r = 113, g = 204, b = 81 }
Config.ClubBlipPre = "Club House: " --Prefix to Blip Name on map
Config.PayInterval = 28 * 60000 -- Adjust '28' to set payout time in minutes
Config.EnableClubBankPay = true -- Enables Pay to come out of club's bank instead of thin air
Config.EnableESXIdentity = true -- Shows characer first/lastname instead of Steam name in member menu
Config.GarageScript = "eden_garage" -- 'eden_garage' (for eden_garage/esx_drp_garage) or 'esx_advancedgarage' supported

Config.ClubBlips = { -- Only shown to club members
	lmc = { -- Must match Database name
		BlipSprite = 226,
		BlipPos = {x= 985.49, y= -108.34, z= 73.34},
		BlipColor = 5,
	},
}

Config.Clubs = {
	lmc = { -- Must match Database name
		Garage = { -- Vehicle Garage
			x = 967.06, y = -121.28, z = 73.35, h = 136.05
		},

		Perms = {
			StorageRankMin = 1,
			StorageRankMinPriv = 3
		},

		Zones = {

			ChangingRoom = {
				Pos   = {x =  981.05, y = -97.98, z = 73.85},
				Size  = {x = 0.7, y = 0.7, z = 0.5},
				Color = {r = 20, g = 250, b = 20},
				Marker= 25,
				Blip  = false,
				Name  = _U('lockertitle'),
				Type  = "changingroom",
				Hint  = _U('changing_room'),
			},

			Storage1 = {
				Pos   = {x = 972.25, y = -98.99, z = 73.85},
				Size  = {x = 0.7, y = 0.7, z = 0.5},
				Color = {r = 150, g = 5, b = 5},
				Marker= 25,
				Blip  = false,
				Name  = _U('storage'),
				Type  = "storagepub", -- Public storage, available to all members
				Hint  = _U('storage_info'),
			},

			Storage2 = {
				Pos   = {x = 976.58, y = -103.58, z = 73.85},
				Size  = {x = 0.7, y = 0.7, z = 0.5},
				Color = {r = 150, g = 5, b = 5},
				Marker= 25,
				Blip  = false,
				Name  = _U('storage'),
				Type  = "storagepriv", -- Private Storage, requires StorageRankMin
				Hint  = _U('storage_info'),
			},

			--[[
			Teleporter1 = { -- If using an IPL as clubhouse
				Pos   = {x = 1930.01, y = 4635.41, z = 39.47},
				PosDest   = {x = 1120.96, y = -3152.21, z = -38.05},
				PosDestH   = 1.02,
				Size  = {x = 0.7, y = 0.7, z = 0.5},
				Color = {r = 0, g = 100, b = 255},
				Marker= 25,
				Blip  = false,
				Name  = _U('lmcteleporter1'),
				Type  = "teleport",
				Hint  = _U('lmcteleporter1_info'),
			},

			Teleporter2 = { -- If using an IPL as clubhouse
				Pos   = {x = 1120.96, y = -3152.21, z = -38.05},
				PosDest   = {x = 1930.01, y = 4635.41, z = 39.47},
				PosDestH   = 357.25,
				Size  = {x = 0.7, y = 0.7, z = 0.5},
				Color = {r = 0, g = 100, b = 255},
				Marker= 25,
				Blip  = false,
				Name  = _U('lmcteleporter2'),
				Type  = "teleport",
				Hint  = _U('lmcteleporter2_info'),
			},

			GarageTeleporter1 = { -- If using an IPL as clubhouse
				Pos   = {x = 1927.92, y = 4603.3, z = 38.16},
				PosDest   = {x = 1109.06, y = -3162.71, z = -38.53},
				PosDestH   = 0.3,
				Size  = {x = 1.5, y = 1.5, z = 0.5},
				Color = {r = 0, g = 200, b = 5},
				Marker= 1,
				Blip  = false,
				Name  = _U('lmcgteleporter1'),
				Type  = "gteleport",
				Hint  = _U('lmcgteleporter1_info'),
			},

			GarageTeleporter2 = { -- If using an IPL as clubhouse
				Pos   = {x = 1109.06, y = -3162.71, z = -38.53},
				PosDest   = {x = 1927.92, y = 4603.3, z = 38.16},
				PosDestH   = 199.53,
				Size  = {x = 1.5, y = 1.5, z = 0.5},
				Color = {r = 0, g = 200, b = 5},
				Marker= 1,
				Blip  = false,
				Name  = _U('lmcgteleporter2'),
				Type  = "gteleport",
				Hint  = _U('lmcgteleporter2_info'),
			},
			]]--

			Owner = { -- Owner menu location
				Pos   = {x = 986.60, y = -92.51, z = 73.85},
				Size  = {x = 0.7, y = 0.7, z = 0.5},
				Color = {r = 113, g = 204, b = 81},
				Marker= 25,
				Blip  = false,
				Name  = _U('lmcmenu'),
				Type  = "owner",
				Hint  = _U('lmcmenu_info'),
			},
		},
	},
}
