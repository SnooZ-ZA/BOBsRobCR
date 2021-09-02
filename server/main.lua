ESX = nil

TriggerEvent("esx:getSharedObject", function(response)
    ESX = response
end)

ESX.RegisterServerCallback('esx_robcr:anycops',function(source, cb)
  local anycops = 0
  local playerList = ESX.GetPlayers()
  for i=1, #playerList, 1 do
    local _source = playerList[i]
    local xPlayer = ESX.GetPlayerFromId(_source)
    local playerjob = xPlayer.job.name
    if playerjob == 'police' then
      anycops = anycops + 1
    end
  end
  cb(anycops)
end)

RegisterServerEvent('esx_robcr:getMoney')
AddEventHandler('esx_robcr:getMoney', function()
local player = ESX.GetPlayerFromId(source)
    local luck = math.random(1, 3)
	local randomMoney = math.random(300, 600)
    local randomMoney2 = math.random(1001, 2000)
	if luck == 1 then

        player.addMoney(randomMoney)
		TriggerClientEvent('esx:showNotification', source, "~g~Success, You robbed the Till!")
        --sendNotification(source, 'Success, You robbed the Till', 'success', 2500)

    elseif luck == 2 then

        player.addMoney(randomMoney2)
		TriggerClientEvent('esx:showNotification', source, "~g~Success, You robbed the Till!")
        --sendNotification(source, 'Success, You robbed the Till', 'success', 2500)
    else
		player.addMoney(math.random(10, 20))
		TriggerClientEvent('esx:showNotification', source, "~r~There was only loose change!")
        --sendNotification(source, 'There was only loose change', 'error', 2000)
    end
end)

RegisterServerEvent('esx_robcr:fail')
AddEventHandler('esx_robcr:fail', function(ped)
	local xPlayers = ESX.GetPlayers()
	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		if xPlayer.job.name == 'police' then
			TriggerClientEvent('esx_robcr:callCops', xPlayers[i], ped)
		end
	end
end)

