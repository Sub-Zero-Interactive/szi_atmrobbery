ESX = nil

local hasStarted, startedHacking, cancontinue = false, false, false
local CurrentCoords, started = nil, nil
local phoneModel = Config.PhoneModel
local taken = 0
local PlayerPed = PlayerPedId()

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
		    	icon = "fas fa-dog",
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
			local atms = {
				-870868698,
				-1126237515,
				-1364697528,
				506770882,
			}
			exports["bt-target"]:AddTargetModel(atms, {
				options = {
					{
						event = "szi_atmrobbery:startHacker",
						icon = "fas fa-piggy-bank",
						label = "Rob ATM",
					},
				},
				job = {"all"},
				distance = 4.5
			})
		end
	end    
end)

function FinishHackings(success)
	TriggerServerEvent("szi_atmrobbery:hackSuccess",success)
	FinishHacking(success)
	startedHacking = false
	DeleteObject(prop)
end

function FinishHacking(success)
	TriggerEvent('mhacking:hide')
	if success and taken < Config.MaxTake then
		ClearPedTasks(PlayerPed)
		RequestAnimDict(Config.StealingDict)
		while not HasAnimDictLoaded(Config.StealingDict) do
			 Wait(10)
		end
		TaskPlayAnim(PlayerPed,Config.StealingDict,Config.StealingAnim,8.0,8.0,-1,1,0,false,false,false)
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
				hasStarted = false
				cancontinue = false
				taken = 0
				ClearPedTasks(PlayerPed)
			end
		end)
	else
		if not (taken < Config.MaxTake) then
		    ESX.ShowHelpNotification(_U('max_amount'))
		end
		ClearPedTasks(PlayerPed)
		cancontinue = false
		taken = 0
		Wait(2000)
		hasStarted = false
	end
end


function newPhoneProp()
	local x,y,z = table.unpack(GetEntityCoords(playerPed))
	local boneIndex = GetPedBoneIndex(PlayerPed, 28422)
	prop = CreateObject(phoneModel, x, y, z, true, true, true)
	AttachEntityToEntity(prop, playerPed, boneIndex, 0.12, 0.028, 0.001, 10.0, 175.0, 0.0, true, true, false, true, 1, true)
end

function StartHacking()
	if not startedHacking then
		startedHacking = true
	    ESX.TriggerServerCallback('szi_atmrobbery:canHack', function(CanHack)
		    if CanHack then
			    ClearPedTasks(PlayerPed)
			    newPhoneProp()
			    RequestAnimDict(Config.HackingDict)
			    while not HasAnimDictLoaded(Config.HackingDict) do
			      Wait(1)
			    end
			    TaskPlayAnim(PlayerPed,Config.HackingDict,Config.HackingAnim ,8.0,8.0,-1,1,0,false,false,false)
			    TriggerEvent("mhacking:show")
			    TriggerEvent("mhacking:start",5,30,FinishHackings)
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
