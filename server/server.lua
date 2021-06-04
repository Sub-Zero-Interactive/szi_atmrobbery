ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('szi_atmrobbery:canHack', function(source, cb, pos)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xPlayers = ESX.GetPlayers()
	local itemcount = 0
	local police = 0

	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		if xPlayer.getJob().name == 'police' then
			police = police + 1
		end
	end

	for k,v in pairs(Config.RequiredItems) do
        local item =  xPlayer.getInventoryItem(v.name)
	    if (item) and (item.count >= v.quantity) then
	    	itemcount = itemcount + 1
	    end
	end
    
	if (itemcount == #(Config.RequiredItems)) and (police >= Config.PoliceRequired) then
	    cb(true)
	    itemcount = 0
	else
	    cb(false)
	    itemcount = 0
		if police < Config.PoliceRequired then
			TriggerClientEvent('esx:showNotification', source, _U('min_police', Config.PoliceRequired))
		end
	end
end)

RegisterNetEvent("szi_atmrobbery:success")
AddEventHandler('szi_atmrobbery:success', function(pos)
	local xPlayer = ESX.GetPlayerFromId(source)
	for k,v in pairs(Config.Rewards) do
        if (v.name ~= "money") and (v.name ~= "bank") and (v.name ~= "black_money") then
		    if xPlayer.canCarryItem(v.name, v.amount) then
    	    	xPlayer.addInventoryItem(v.name, v.amount)
	    	else
   	     	xPlayer.showNotification(_U('no_room'))
	    	end
        elseif (v.name == "bank") or (v.name == "black_money") then
            xPlayer.addAccountMoney(v.name, v.amount)
		elseif (v.name == "money") then
            xPlayer.addMoney(v.amount)
        end
	end
end)

RegisterNetEvent("szi_atmrobbery:hackSuccess")
AddEventHandler('szi_atmrobbery:hackSuccess', function(success)
	local xPlayer = ESX.GetPlayerFromId(source)
	if success then
		for k,v in pairs(Config.RemoveItems) do
   		 	xPlayer.removeInventoryItem(v.name, 1)
		end
	end
end)

RegisterNetEvent('szi_atmrobbery:notifyPolice')
AddEventHandler('szi_atmrobbery:notifyPolice', function(street1, street2, pos)
    local xPlayers = ESX.GetPlayers()
    local startedHacking = true

    if startedHacking == true then
		for i=1, #xPlayers, 1 do
			local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
            if xPlayer.job.name == 'police' then
                TriggerClientEvent('szi_atmrobbery:blip', xPlayers[i], pos.x, pos.y, pos.z)
                TriggerClientEvent('szi_atmrobbery:notifyPolice', xPlayers[i], 'Robbery In Progress : ATM | ' .. street1 .. " | " .. street2 .. ' ')
			end
		end
	end
end)
