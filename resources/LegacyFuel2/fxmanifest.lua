fx_version 'bodacious'
game 'gta5'


server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'config.lua',
	'source/fuel_server.lua'
}

client_scripts {
	'config.lua',
	'source/fuel_client.lua'
}

exports {
	'GetFuel',
	'SetFuel'
}
