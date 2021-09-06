ESX        = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

searching  = false
cachedCR = {}
Config = {}
Config.CopsRequired = 0

local oPlayer = false
local InVehicle = false
local playerpos = false

Citizen.CreateThread(function()
    while(true) do
		oPlayer = PlayerPedId()
        InVehicle = IsPedInAnyVehicle(oPlayer, true)
		playerpos = GetEntityCoords(oPlayer)
        Citizen.Wait(500)
    end
end)

closestCR = {
	"p_till_01_s",
    "prop_till_01",
    "prop_till_01_dam",
	"prop_till_02",
	"prop_till_03"
}
Citizen.CreateThread(function ()

    while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end
	ESX.PlayerData = ESX.GetPlayerData()

	TriggerEvent('skinchanger:getSkin', function(skin)
		playerGender = skin.sex
	end)

    ESXLoaded = true
end)

Citizen.CreateThread(function()

    if ESX.IsPlayerLoaded() then
		ESX.PlayerData = ESX.GetPlayerData()
	end
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    ESX.PlayerData.job = job
end)

RegisterNetEvent("esx:playerLoaded")
AddEventHandler("esx:playerLoaded", function(response)
	ESX.PlayerData = response
end)

Citizen.CreateThread(function()
    Citizen.Wait(100)
    while true do
        
        local sleep = 1000
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        
        for i = 1, #closestCR do
            local x = GetClosestObjectOfType(playerCoords, 1.0, GetHashKey(closestCR[i]), false, false, false)
            local entity = nil
            if DoesEntityExist(x) then
                sleep  = 5
                entity = x
                cr   = GetEntityCoords(entity)
				drawText3D(cr.x, cr.y, cr.z + 0.3, '⚙️')		
                while IsControlPressed(0, 38) do
                drawText3D(cr.x, cr.y, cr.z + 0.2, 'Press [~g~H~s~] to rob the Till ~s~')
				break
				end	
                if IsControlJustReleased(0, 74) then
				ESX.TriggerServerCallback('esx_robcr:anycops', function(anycops)
				if anycops >= Config.CopsRequired then
                    if not cachedCR[entity] then
					
							local luck = math.random(1, 5)
							if luck == 3 then
								local ped = PlayerId(-1)
								TriggerServerEvent('esx_robcr:fail', ped)
								ESX.ShowNotification("~r~You were seen on CCTV!")
								local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", 1)
							SetCamCoord(cam, cr.x, cr.y, cr.z + 3.0, 0)
							SetCamRot(cam, -90.0, -10.0, 270.05, 2)
							RenderScriptCams(1, 0, 0, 1, 1)
							SetTimecycleModifier("scanline_cam_cheap")
							SetTimecycleModifierStrength(2.0)
							Wait(5000)
							DestroyCam(createdCamera, 0)
							RenderScriptCams(0, 0, 1, 1, 1)
							createdCamera = 0
							ClearTimecycleModifier("scanline_cam_cheap")
							SetFocusEntity(GetPlayerPed(PlayerId()))
							else
								searching = true
								SetEntityHeading(oPlayer,GetHeadingFromVector_2d(cr.x-playerpos.x,cr.y-playerpos.y))
								exports.rprogress:Custom({
								Async = true,
								x = 0.5,
								y = 0.5,
								From = 0,
								To = 100,
								Duration = 10000,
								Radius = 60,
								Stroke = 10,
								MaxAngle = 360,
								Rotation = 0,
								Easing = "easeLinear",
								Label = "BREAKING",
								LabelPosition = "right",
								Color = "rgba(255, 255, 255, 1.0)",
								BGColor = "rgba(107, 109, 110, 0.95)",
								Animation = {
								scenario = "WORLD_HUMAN_WELDING", -- https://pastebin.com/6mrYTdQv
								--animationDictionary = "missheistfbisetup1", -- https://alexguirre.github.io/animations-list/
								--animationName = "unlock_loop_janitor",
								},
								DisableControls = {
								Mouse = false,
								Player = true,
								Vehicle = true
								},
								})
								Citizen.Wait(10000)
								cachedCR[entity] = true
								TriggerServerEvent('esx_robcr:getMoney')
								ClearPedTasks(PlayerPedId())
								searching = false
							end
                    
					else
						ESX.ShowNotification("You have already robbed here!")
                    end
				else
				ESX.ShowNotification("Not enough police!")	
                end
				end)
                end
                break
            else
                sleep = 1000
            end
        end
        Citizen.Wait(sleep)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if searching then
            DisableControlAction(0, 73)
			DisableControlAction(0, 47)
        end
    end
end)

RegisterNetEvent('esx_robcr:callCops')
AddEventHandler('esx_robcr:callCops', function(ped)
    local mugshot, mugshotStr = ESX.Game.GetPedMugshot(GetPlayerPed(ped))
	ESX.ShowAdvancedNotification('CCTV', 'Store Holdup!', 'We have sent a photo of the robber taken by the CCTV!', mugshotStr, 4)
    UnregisterPedheadshot(mugshot)
    local Atm = AddBlipForCoord(playerpos.x, playerpos.y, playerpos.z)
    SetBlipSprite(Atm , 161)
    SetBlipScale(Atm , 2.0)
    SetBlipColour(Atm, 1)
    PulseBlip(Atm)
	Wait(30*1000)
    RemoveBlip(Atm)
end)
