fx_version 'bodacious'

game 'gta5'

description 'ESX Vehicle Shop'

version '1.1.0'

ui_page "index.html"

files {
	"index.html",
	"assets/plugins/bootstrap-3.3.7-dist/css/bootstrap.css",
	"assets/plugins/jquery/jquery-3.2.1.min.js",
	"assets/plugins/bootstrap-3.3.7-dist/js/bootstrap.min.js",
	"slike/*.png"
}

server_scripts {
	'@async/async.lua',
	'@oxmysql/lib/MySQL.lua',
	'@es_extended/locale.lua',
	'locales/br.lua',
	'locales/en.lua',
	'locales/hr.lua',
	'locales/fi.lua',
	'locales/fr.lua',
	'locales/sv.lua',
	'locales/pl.lua',
	'locales/cs.lua',
	'config.lua',
	'server/main.lua'
}

client_scripts {
	'@es_extended/locale.lua',
	'locales/br.lua',
	'locales/en.lua',
	'locales/hr.lua',
	'locales/fi.lua',
	'locales/fr.lua',
	'locales/sv.lua',
	'locales/pl.lua',
	'locales/cs.lua',
	'config.lua',
	'client/utils.lua',
	'client/main.lua'
}

dependency 'es_extended'

export 'GeneratePlate'
