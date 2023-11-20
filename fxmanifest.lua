fx_version "adamant"
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
game "rdr3"

description 'Thrasherrr | qbr-construction, Converted And Altered Danglr'

shared_scripts {
    '@ox_lib/init.lua',
    '@rsg-core/shared/locale.lua',
    --'locales/es.lua',
    --'locales/*.lua',
    'config.lua',
}
client_scripts {
	'client/client.lua',
}

server_scripts {
	'server/server.lua',
}

dependency {
    'rsg-core',
    'ox_lib',
}

lua54 'yes'

lua54 'yes'
