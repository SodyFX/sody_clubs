fx_version 'adamant'

game 'gta5'

description 'Sody Clubs'

version '1.0.1'

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    '@es_extended/locale.lua',
    'locales/en.lua',
	'config.lua',
	'server.lua',
}

client_scripts {
    '@es_extended/locale.lua',
    'locales/en.lua',
	'config.lua',
	'client.lua',
}
