game 'rdr3'
fx_version 'adamant'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
author 'Emolitt'

lua54 'yes'

client_scripts {
    'client/models/*.lua',
    'client/client.lua',
    'client/utils.lua',
}

server_scripts {
    'server/server.lua',
    'server/utils.lua',
    'server/gpt.lua'
}

shared_scripts {
    'Config.lua',
    'shared/Logger.lua',
    'shared/rumors.lua'
}
