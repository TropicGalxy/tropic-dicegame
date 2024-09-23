fx_version 'cerulean'
game 'gta5'

lua54 'yes'
author 'TropicGalxy'
description 'a simple way to gamble'
version '1.1.0'

shared_scripts {
    '@qb-core/shared/locale.lua',
    'config.lua'
}

client_scripts {
    '@ox_lib/init.lua',
    'client.lua'
}

server_scripts {
    'server.lua'
}

dependencies {
    'qb-core',
    'ox_lib',
    'ox_target'
}
