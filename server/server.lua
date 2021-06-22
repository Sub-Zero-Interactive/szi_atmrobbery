--[[
Copyright (C) 2021 Sub-Zero Interactive

All rights reserved.

Permission is hereby granted, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software with 'All rights reserved'. Even if 'All rights reserved' is very clear :

  You shall not sell and/or resell this software
  The rights to use, copy, modify and merge
  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
--]]
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

Citizen.CreateThread(function()
        local vRaw = LoadResourceFile(GetCurrentResourceName(), 'version.json')
        if vRaw then
            local v = json.decode(vRaw)
            PerformHttpRequest('https://raw.githubusercontent.com/Sub-Zero-Interactive/szi_atmrobbery/main/version.json', function(code, res, headers)
                if code == 200 then
                    local rv = json.decode(res)
                    if rv.version == v.version then
                        if rv.commit ~= v.commit then 
                            print(([[
^1----------------------------------------------------------------------
^1WARNING: YOUR SZI_ATMROBBERY IS OUTDATED!
^1COMMIT UPDATE: ^5%s AVAILABLE
^1DOWNLOAD:^5 https://github.com/Sub-Zero-Interactive/szi_atmrobbery
^1CHANGELOG:^5 %s
^1-----------------------------------------------------------------------
^0]]):format(rv.commit, rv.changelog))
                        else
                            print(([[
^8-------------------------------------------------------
^2Your szi_atmrobbery is the latest version!
^5Version:^0 %s
^5COMMIT:^0 %s
^5CHANGELOG:^0 %s
^8-------------------------------------------------------
^0]]):format( rv.version, rv.commit, rv.changelog))
                        end
                    else
                        print(([[
^1----------------------------------------------------------------------
^1URGENT: YOUR SZI_ATMROBBERY IS OUTDATATED!!!
^1COMMIT UPDATE: ^5%s AVAILABLE
^1DOWNLOAD:^5 https://github.com/Sub-Zero-Interactive/szi_atmrobbery
^1CHANGELOG:^5 %s
^1-----------------------------------------------------------------------
^0]]):format(rv.commit, rv.changelog))
                    end
                else
                    print('[^1ERROR^0] szi_atmrobbery unable to check version!')
                end
            end,'GET'
        )
    end
end)
