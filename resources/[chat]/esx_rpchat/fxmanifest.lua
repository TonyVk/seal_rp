fx_version 'bodacious'
game 'gta5'


description 'ESX RP Chat'

version '1.3.1'

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'@es_extended/locale.lua',
	'locales/sv.lua',
	'locales/en.lua',
	'locales/fi.lua',
	'locales/fr.lua',
	'locales/hr.lua',
	'locales/cs.lua',
	'config.lua',
	'server/main.lua'
}

client_scripts {
	'@es_extended/locale.lua',
	'locales/sv.lua',
	'locales/en.lua',
	'locales/fi.lua',
	'locales/hr.lua',
	'locales/fr.lua',
	'locales/cs.lua',
	'config.lua',
	'client/main.lua'
}

dependency 'es_extended'
