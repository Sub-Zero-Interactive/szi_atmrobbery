--[[
Copyright (C) 2021 Sub-Zero Interactive

All rights reserved.

Permission is hereby granted, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software with 'All rights reserved'. Even if 'All rights reserved' is very clear :

  You shall not sell and/or resell this software
  The rights to use, modify and merge
  The above copyright notice and this permission notice shall be included in all copies and files of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
--]]
TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)

QBCore.Functions.CreateCallback('szi_atmrobbery:canHack', function(source, cb, pos)
	local xPlayer = QBCore.Functions.GetPlayer(source)
	local xPlayers = QBCore.Functions.GetPlayers()
	local itemcount = 0
	local police = 0

	for i=1, #xPlayers, 1 do
		local xPlayer = QBCore.Functions.GetPlayer(xPlayers[i])
		if xPlayer.PlayerData.job.name == 'police' then
			police = police + 1
		end
	end

	for k,v in pairs(Config.RequiredItems) do
        local item =  xPlayer.Functions.GetItemByName(v.name)
	    if (item) and (item.amount >= v.quantity) then
	    	itemcount = itemcount + 1
	    end
	end
    
	if (itemcount == #(Config.RequiredItems)) and (police >= GetOptions("PoliceRequired")) then
	    cb(true)
	    itemcount = 0
	else
	    cb(false)
	    itemcount = 0
		if police < GetOptions("PoliceRequired") then
			TriggerClientEvent('QBCore:Notify', source, "There Needs to be Atleast".. GetOptions("PoliceRequired").. " Police Online!")
		end
	end
end)

RegisterNetEvent("szi_atmrobbery:success")
AddEventHandler('szi_atmrobbery:success', function(pos)
	local xPlayer = QBCore.Functions.GetPlayer(source)
	local v = Config.Rewards[math.random(1, #(Config.Rewards))]
        if (v.name ~= "cash") and (v.name ~= "bank") and (v.name ~= "black_money") then
					 xPlayer.Functions.AddItem(v.name, v.amount)
					 TriggerClientEvent('QBCore:Notify', source, "Stole ".. v.amount .. " ".. v.label, "success")
        elseif (v.name == "bank") or (v.name == "black_money") then
					TriggerClientEvent('QBCore:Notify', source, "Stole $".. v.amount, "success")
           xPlayer.Functions.AddMoney(v.name, v.amount)
		elseif (v.name == "cash") then
					xPlayer.Functions.AddMoney("cash", v.amount)
					TriggerClientEvent('QBCore:Notify', source, "Stole $".. v.amount, "success")
        end
end)

RegisterNetEvent("szi_atmrobbery:hackSuccess")
AddEventHandler('szi_atmrobbery:hackSuccess', function(success)
	local xPlayer = QBCore.Functions.GetPlayer(source)
	if success then
		for k,v in pairs(Config.RemoveItems) do
			xPlayer.Functions.RemoveItem(v.name, 1)
		end
	end
end)

RegisterNetEvent('szi_atmrobbery:notifyPolice')
AddEventHandler('szi_atmrobbery:notifyPolice', function(street1, street2, pos)
	local xPlayers = QBCore.Functions.GetPlayers()
    	local startedHacking = true

  	if startedHacking == true then
		for i=1, #xPlayers, 1 do
			local xPlayer = QBCore.Functions.GetPlayer(xPlayers[i])
      if xPlayer.PlayerData.job.name == 'police' then
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
