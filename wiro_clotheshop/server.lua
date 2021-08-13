TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('wiro_clotheshop:balance')
AddEventHandler('wiro_clotheshop:balance', function(olmazsasikin)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
    if xPlayer.getMoney() > Config.fiyat then
        xPlayer.removeMoney(Config.fiyat)
    else
        TriggerClientEvent('skinchanger:loadSkin', _source, olmazsasikin)
        TriggerClientEvent('wiro_notify:show', _source, "error", "Yeterli Paranız Yok")
    end
end)

RegisterServerEvent('wiro_clotheshop:savegobrr')
AddEventHandler('wiro_clotheshop:savegobrr', function(skin)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
    MySQL.Async.insert("UPDATE users SET skin = @sikin WHERE identifier = @identifier", { 
        ['@identifier'] = xPlayer.identifier,
        ['@sikin'] = json.encode(skin)
    })
end)