fx_version 'bodacious'
game 'gta5'

dependencies {'es_extended'}

shared_scripts {
    '@es_extended/locale.lua',
    'locales/*.lua',
    'config.lua',
    'lib/octree.lua',
    'lib/growth.lua',
    'lib/cropstate.lua',
}
client_scripts {
    'lib/debug.lua',
    'cl_uteknark.lua',
}
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'sv_uteknark.lua',
}
