Config              = {}
Config.DrawDistance = 100.0
Config.MaxDelivery	= 10
Config.TruckPrice	= 0
Config.Locale       = 'en'

Config.Trucks = {
	"mower"
}

Config.Cloakroom = {
	CloakRoom = {
		Pos   = vector3(-1348.412109375, 142.57148742676, 55.43796157837),
		Size  = {x = 3.0, y = 3.0, z = 1.0},
		Color = {r = 204, g = 204, b = 0},
		Type  = 1,
		Id = 1
	}
}

Config.ZaposliSe = {
	Pos   = vector3(-1348.4431152344, 142.61796569824, 56.437965393066),
	Heading = 128.30,
	Size  = {x = 3.0, y = 3.0, z = 3.0},
	Color = {r = 101, g = 65, b = 104},
	Type  = 29,
	Sprite = 358,
	BColor = 5
}

Config.Zones = {
	VehicleSpawner = {
		Pos   = vector3(-1352.2934570312, 124.50176239014, 55.238651275634),
		Heading = 4.99,
		Size  = {x = 3.0, y = 3.0, z = 1.0},
		Color = {r = 204, g = 204, b = 0},
		Type  = 1
	},

	VehicleSpawnPoint = {
		Pos   = vector3(-1351.6215820312, 136.58317565918, 55.699272155762),
		Size  = {x = 3.0, y = 3.0, z = 1.0},
		Type  = -1
	}
}

Config.Uniforms = {
	EUP = true,
	uniforma = { 
		male = {
			['tshirt_1'] = 59,  ['tshirt_2'] = 0,
			['torso_1'] = 89,   ['torso_2'] = 1,
			['decals_1'] = 0,   ['decals_2'] = 0,
			['arms'] = 31,
			['pants_1'] = 36,   ['pants_2'] = 0,
			['shoes'] = 35,
			['helmet_1'] = 5,  ['helmet_2'] = 0,
			['glasses_1'] = 19,  ['glasses_2'] = 0
		},
		female = {
			['tshirt_1'] = 36,  ['tshirt_2'] = 0,
			['torso_1'] = 0,   ['torso_2'] = 11,
			['decals_1'] = 0,   ['decals_2'] = 0,
			['arms'] = 68,
			['pants_1'] = 30,   ['pants_2'] = 2,
			['shoes'] = 26,
			['helmet_1'] = 19,  ['helmet_2'] = 0,
			['glasses_1'] = 15,  ['glasses_2'] = 0
		}
	},
	EUPuniforma = { 
		male = {
			ped = 'mp_m_freemode_01',
			props = {
				{ 0, 0, 0 },
				{ 1, 0, 0 },
				{ 2, 0, 0 },
				{ 6, 0, 0 },
			},
			components = {
				{ 1, 1, 1 },
				{ 11, 72, 1 },
				{ 3, 65, 1 },
				{ 10, 1, 1 },
				{ 8, 16, 1 },
				{ 4, 54, 1 },
				{ 6, 28, 1 },
				{ 7, 1, 1 },
				{ 9, 1, 1 },
				{ 5, 1, 1 },
			}
		},
		female = {
			ped = 'mp_f_freemode_01',
			props = {
				{ 0, 0, 0 },
				{ 1, 14, 1 },
				{ 2, 0, 0 },
				{ 6, 0, 0 },
			},
			components = {
				{ 1, 1, 1 },
				{ 11, 68, 1 },
				{ 3, 76, 1 },
				{ 10, 1, 1 },
				{ 8, 15, 1 },
				{ 4, 56, 1 },
				{ 6, 27, 1 },
				{ 7, 1, 1 },
				{ 9, 1, 1 },
				{ 5, 1, 1 },
			}
		}
	}
}

Config.Objekti = {
	{x = -1336.6204833984, y = 130.82232666016, z = 54.283576965332}, 
	{x = -1324.103881836, y = 115.27574157714, z = 54.167377471924}, 
	{x = -1319.4246826172, y = 97.489234924316, z = 53.423778533936}, 
	{x = -1304.8073730468, y = 87.645217895508, z = 52.510105133056}, 
	{x = -1287.1822509766, y = 100.08847045898, z = 52.88620376587}, 
	{x = -1276.1564941406, y = 115.06087493896, z = 54.580352783204}, 
	{x = -1261.0874023438, y = 132.91331481934, z = 55.940868377686}, 
	{x = -1237.5656738282, y = 118.4698791504, z = 54.785709381104}, 
	{x = -1226.0162353516, y = 94.592765808106, z = 54.358806610108}, 
	{x = -1237.4927978516, y = 69.403785705566, z = 50.174758911132}, 
	{x = -1254.2172851562, y = 48.475540161132, z = 47.812454223632}, 
	{x = -1269.3270263672, y = 29.308032989502, z = 46.243701934814}, 
	{x = -1289.2399902344, y = 23.951700210572, z = 48.285945892334}, 
	{x = -1241.6400146484, y = 20.061225891114, z = 45.199825286866}, 
	{x = -1194.5032958984, y = -6.3355832099914, z = 44.81364440918}, 
	{x = -1168.7250976562, y = -22.788251876832, z = 43.329811096192}, 
	{x = -1149.7358398438, y = -41.018283843994, z = 42.90950012207}, 
	{x = -1123.8868408204, y = -20.715253829956, z = 46.3662109375}, 
	{x = -1111.8679199218, y = 11.486560821534, z = 47.725761413574}, 
	{x = -1106.6242675782, y = 56.203281402588, z = 50.537822723388}, 
	{x = -1130.4426269532, y = 92.263931274414, z = 54.815578460694}, 
	{x = -1144.4881591796, y = 130.2903289795, z = 58.19034576416}, 
	{x = -1124.1652832032, y = 146.08227539062, z = 59.36003112793}, 
	{x = -1117.3946533204, y = 168.95635986328, z = 60.45259475708}, 
	{x = -1121.6223144532, y = 190.30805969238, z = 61.90784072876} 
}
Config.Objekti2 = {
	{x = -1340.8360595703, y = 122.5864944458, z = 56.472503662109}, 
	{x = -1335.3958740234, y = 116.36293792725, z = 56.489608764648}, 
	{x = -1327.4965820312, y = 117.74568939209, z = 56.813373565674}, 
	{x = -1330.9373779297, y = 122.06237030029, z = 56.90673828125}, 
	{x = -1322.4855957031, y = 125.36070251465, z = 57.051265716553}, 
	{x = -1322.9356689453, y = 132.54005432129, z = 57.43505859375}, 
	{x = -1323.9942626953, y = 140.48606872559, z = 57.764072418213}, 
	{x = -1327.4072265625, y = 145.92317199707, z = 57.874546051025}, 
	{x = -1333.1715087891, y = 146.74209594727, z = 57.542579650879}, 
	{x = -1332.7352294922, y = 141.78025817871, z = 57.353126525879}, 
	{x = -1333.8048095703, y = 135.71786499023, z = 57.189304351807}, 
	{x = -1337.7548828125, y = 132.244140625, z = 56.808479309082}, 
	{x = -1338.6282958984, y = 138.75270080566, z = 57.022064208984}, 
	{x = -1341.5385742188, y = 146.89161682129, z = 56.989379882812}, 
	{x = -1336.4505615234, y = 154.22508239746, z = 57.684051513672}, 
	{x = -1330.5523681641, y = 153.68112182617, z = 57.893730163574}, 
	{x = -1325.3665771484, y = 148.96789550781, z = 57.927440643311}, 
	{x = -1322.6055908203, y = 142.88842773438, z = 57.86735534668}, 
	{x = -1319.4289550781, y = 136.61790466309, z = 57.758365631104}, 
	{x = -1316.3063964844, y = 129.74449157715, z = 57.562858581543}, 
	{x = -1312.0617675781, y = 126.07726287842, z = 57.449367523193}, 
	{x = -1312.5, y = 117.32327270508, z = 56.8385887146}, 
	{x = -1307.5041503906, y = 132.05476379395, z = 57.963298797607}, 
}
