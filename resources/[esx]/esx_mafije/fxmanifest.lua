fx_version 'bodacious'
game 'gta5'


description 'ESX Cartel Job'

version '1.0.1'

server_scripts {
  '@es_extended/locale.lua',
  'locales/br.lua',
  'locales/en.lua',
  'locales/fr.lua',
  'locales/es.lua',
  'locales/hr.lua',
  '@oxmysql/lib/MySQL.lua',
  'config.lua',
  '@es_extended/locales/hr.lua',
  '@es_extended/config.lua',
  '@es_extended/config.weapons.lua',
  'server/main.lua'
}

client_scripts {
  '@es_extended/locale.lua',
  'locales/br.lua',
  'locales/en.lua',
  'locales/fr.lua',
  'locales/es.lua',
  'locales/hr.lua',
  'config.lua',
  'client/main.lua'
}