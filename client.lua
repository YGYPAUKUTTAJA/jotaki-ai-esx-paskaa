ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local robberyInProgress = false
local robberyData = nil

-- L�hetet��n ilmoitus peliin
RegisterNetEvent('robbery:sendNotification')
AddEventHandler('robbery:sendNotification', function(message)
    SendNotification(Config.Dispatch, message)  -- K�ytet��n Config.Dispatchia
end)

-- L�hetet��n ry�st�n ajan ilmoitus Ox Libill�
function SendRobberyTimeRemaining(robberyData)
    local timeRemaining = robberyData.secondsRemaining
    local minutes = math.floor(timeRemaining / 60)
    local seconds = timeRemaining % 60
    local message = string.format("Aikaa j�ljell�: %02d:%02d", minutes, seconds)

    if Config.Dispatch == 'ox' then
        -- K�ytet��n Ox Libin ilmoitusta ajan n�ytt�miseen
        exports['ox_lib']:notify({
            title = "Ry�st� k�ynniss�",
            description = message,
            type = 'inform',  -- Ilmoituksen tyyppi
            duration = 1000  -- Ajan p�ivitys intervalissa
        })
    end
end

-- Ilmoituksen l�hetys riippuen siit�, mik� dispatch-j�rjestelm� on valittu
function SendNotification(dispatchMethod, message)
    if dispatchMethod == 'ox' then
        -- K�ytet��n Ox Libin ilmoitusta
        exports['ox_lib']:notify({
            title = "Rikosilmoitus",
            description = message,
            type = 'inform',  -- Tyyppi voi olla: 'inform', 'error', 'success'
            duration = 5000  -- Kesto ms
        })
    elseif dispatchMethod == 'cd_dispatch' then
        TriggerEvent('cd_dispatch:sendMessage', message)  -- cd_dispatch ilmoitus
    elseif dispatchMethod == 'op' then
        TriggerEvent('op:sendMessage', message)  -- op ilmoitus
    elseif dispatchMethod == 'ps' then
        TriggerEvent('ps_notify:sendMessage', message)  -- ps ilmoitus
    else
        print("Tuntematon dispatch-metodi: " .. dispatchMethod)
    end
end

-- Interaktio ry�st�n aloittamiseksi
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        -- DEBUG: Tarkistetaan, onko Config ja Config.Robbery olemassa
        if Config then
            if Config.Robbery then
                -- Tarkistetaan ry�st�paikat
                for target, data in pairs(Config.Robbery) do
                    local playerPed = PlayerPedId()
                    local playerCoords = GetEntityCoords(playerPed)
                    local dist = Vdist(playerCoords, data.position.x, data.position.y, data.position.z)

                    -- Jos pelaaja on tarpeeksi l�hell� ja painaa E
                    if dist <= data.maxDistance then
                        DrawText3D(data.position.x, data.position.y, data.position.z, "[E] Aloita ry�st� - " .. data.name)

                        if IsControlJustPressed(0, 38) then -- E-nappi
                            -- Tarkistetaan, onko ry�st� k�ynniss�
                            if not robberyInProgress then
                                robberyInProgress = true
                                robberyData = data
                                TriggerServerEvent('robbery:start', target)
                            end
                        end
                    end
                end
            else
                print("Config.Robbery on nil")
            end
        else
            print("Config on nil")
        end

        -- Jos ry�st� on k�ynniss�, p�ivitet��n aika
        if robberyInProgress and robberyData then
            if robberyData.secondsRemaining > 0 then
                robberyData.secondsRemaining = robberyData.secondsRemaining - 1
                SendRobberyTimeRemaining(robberyData)
            else
                robberyInProgress = false
                TriggerServerEvent('robbery:complete', robberyData.name)
            end
        end
    end
end)

-- Piirt�� 3D tekstin
function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    SetTextScale(0.35, 0.35)
    SetTextFont(0)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 255)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(_x, _y)
    local factor = (string.len(text)) / 370
    DrawRect(_x, _y + 0.015, 0.015 + factor, 0.03, 0, 0, 0, 75)
end
