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
local CurrentCoords, started = nil, nil
local phoneModel = Config.PhoneModel
local taken = 0

DeleteObject(prop)
Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(100)
	end
end)

AddEventHandler('onClientResourceStart', function (resourceName)
	if (GetCurrentResourceName() ~= resourceName) then return end
	for k,v in pairs(Config.AtmModels) do 
	    if Config.FivemTarget then
	        exports["fivem-target"]:AddTargetModel({
	    	    name = "robbery",
	    	    label = "ATM Robbery",
	    	    icon = "fas fa-piggy-bank",
	    	    model = GetHashKey(v.prop),
	    	    interactDist = 2.0,
	    	    onInteract = StartHacking,
	    	    options = {
	    	        {
	    		        name = "rob",
	    		        label = "Rob ATM"
	    	        }
	    	    },
	    	vars = {}
	        })
	    else
			local atms = {}
	        for k,v in pairs(Config.AtmModels) do 
		        table.insert(atms,GetHashKey(v.prop))
	 	    end
		    Wait(5)
		    exports["bt-target"]:AddTargetModel(atms, {
		    	options = {
		    		{
		    			event = "szi_atmrobbery:startHacker",
		    			icon = "fas fa-piggy-bank",
		    			label = "Rob ATM",
		    		}
		    	},
		    	job = {"all"},
		    	distance = 1.5
		    })
	    end
	end    
end)

function FinishHackings(success)
	DeleteObject(prop)
	TriggerServerEvent("szi_atmrobbery:hackSuccess",success)
	FinishHacking(success)
	Cooldown(true)
end

function FinishHacking(success)
	TriggerEvent('mhacking:hide')
	if success and taken < Config.MaxTake then
		ClearPedTasks(PlayerPedId())
		RequestAnimDict(Config.StealingDict)
		while not HasAnimDictLoaded(Config.StealingDict) do
			 Wait(10)
		end
		TaskPlayAnim(PlayerPedId(),Config.StealingDict,Config.StealingAnim,1.0,1.0,-1,1,0,false,false,false)
		cancontinue = true
		ESX.ShowHelpNotification(_U('press_stop'))
		exports['mythic_progbar']:Progress({
			name = "using",
			duration = Config.RobTime * 1000,
			label = 'Robbing ATM',
			useWhileDead = false,
			canCancel = true,
			controlDisables = {
				disableMovement = true,
				disableCarMovement = true,
				disableMouse = false,
				disableCombat = true,
			}
		}, function(cancelled)
			if not cancelled then
				TriggerServerEvent("szi_atmrobbery:success")
				taken = taken + 1
				FinishHacking(true)
			else
				ClearPedTasks(PlayerPedId())
				cancontinue = false
				taken = 0
				Cooldown(true)
			end
		end)
	else
		if not (taken < Config.MaxTake) then
		    ESX.ShowHelpNotification(_U('max_amount'))
		end
		ClearPedTasks(PlayerPedId())
		cancontinue = false
		taken = 0
		Cooldown(true)
	end
end


function newPhoneProp()
	local x,y,z = table.unpack(GetEntityCoords(PlayerPedId()))
	local boneIndex = GetPedBoneIndex(PlayerPedId(), 28422)
	prop = CreateObject(phoneModel, x, y, z, true, true, true)
	AttachEntityToEntity(prop, PlayerPedId(), boneIndex, 0.12, 0.028, 0.001, 10.0, 175.0, 0.0, true, true, false, true, 1, true)
end

function StartHacking()
	if not startedHacking then
		startedHacking = true
	    ESX.TriggerServerCallback('szi_atmrobbery:canHack', function(CanHack)
		    if CanHack then
                local chance = math.random(Config.MinChance, Config.MaxChance
				local pos = GetEntityCoords(PlayerPedId(),  true)
                local s1, s2 = GetStreetNameAtCoord( pos.x, pos.y, pos.z, Citizen.PointerValueInt(), Citizen.PointerValueInt() )
                local street1 = GetStreetNameFromHashKey(s1)
                local street2 = GetStreetNameFromHashKey(s2)
			    ClearPedTasks(PlayerPedId())
			    newPhoneProp()
			    RequestAnimDict(Config.HackingDict)
			    while not HasAnimDictLoaded(Config.HackingDict) do
			        Wait(1)
			    end
			    TaskPlayAnim(PlayerPedId(),Config.HackingDict,Config.HackingAnim ,8.0,8.0,-1,1,0,false,false,false)
			    TriggerEvent("mhacking:show")
			    TriggerEvent("mhacking:start",5,30,FinishHackings)
                if chance <= Config.Chance then
				    TriggerServerEvent('szi_atmrobbery:notifyPolice', street1, street2, pos)
                end
		    else
			    ESX.ShowHelpNotification(_U('cant_hack'), false, true, 2000)
			    Wait(2000)
			    hasStarted = false
			    startedHacking = false
		    end
	    end)
    end
end

RegisterNetEvent("szi_atmrobbery:startHacker")
AddEventHandler("szi_atmrobbery:startHacker", function()
	StartHacking()
end)

RegisterNetEvent('szi_atmrobbery:notifyPolice')
AddEventHandler('szi_atmrobbery:notifyPolice', function(msg)
    exports['mythic_notify']:DoHudText('error', msg)
end)

RegisterNetEvent('szi_atmrobbery:blip')
AddEventHandler('szi_atmrobbery:blip', function(x,y,z)
    Blip = AddBlipForCoord(x,y,z)
    SetBlipSprite(Blip,  500)
    SetBlipColour(Blip,  1)
    SetBlipAlpha(Blip,  250)
    SetBlipDisplay(Blip, 4)
    SetBlipScale(Blip, 1.2)
    SetBlipFlashes(Blip, true)
    SetBlipAsShortRange(Blip,  true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString('Robbery In Progress | ATM')
    EndTextCommandSetBlipName(Blip)
    Wait(Config.BlipTimer * 1000)
    RemoveBlip(Blip)
end)

function Cooldown(hasStarted)
    local timer = Config.CooldownTime
    while hasStarted == true do
        Citizen.Wait(1000)
        if timer > 0 then
            timer = timer -1
        end

        if timer == 1 then
			hasStarted = false
			startedHacking = false
            break
        end
    end
end
