ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

-- Kun pelaaja aloittaa ry�st�n
RegisterServerEvent('robbery:start')
AddEventHandler('robbery:start', function(target)
    local xPlayer = ESX.GetPlayerFromId(source)
    local robberyData = Config.Robbery[target]

    -- Tarkistetaan, ett� riitt�v�sti poliiseja on paikalla
    if robberyData.policeRequired > GetPoliceCount() then
        TriggerClientEvent('esx:showNotification', xPlayer.source, 'Ei tarpeeksi poliiseja!')
        return
    end

    -- Tarkistetaan, onko ry�st� mahdollista (esim. aikarajoitus)
    if (os.time() - robberyData.lastRobbed) < robberyData.timerBeforeNewRob then
        TriggerClientEvent('esx:showNotification', xPlayer.source, 'Tule my�hemmin takaisin!')
        return
    end

    -- P�ivitet��n viimeisin ry�st�-aika
    robberyData.lastRobbed = os.time()

    -- L�hetet��n ilmoitus poliiseille tai kaikille
    if robberyData.notifyTarget == 'police' then
        TriggerClientEvent('robbery:sendNotification', -1, 'Poliisit, ry�st� tapahtumassa: ' .. robberyData.name, robberyData.notifyMethod)
    elseif robberyData.notifyTarget == 'others' then
        TriggerClientEvent('robbery:sendNotification', -1, 'Ry�st� k�ynniss�: ' .. robberyData.name, robberyData.notifyMethod)
    end

    -- L�hetet��n pelaajalle viesti
    TriggerClientEvent('esx:showNotification', xPlayer.source, 'Aloitit ry�st�n: ' .. robberyData.name)
end)

-- Haetaan poliisien m��r�
function GetPoliceCount()
    local count = 0
    for _, playerId in ipairs(ESX.GetPlayers()) do
        local xPlayer = ESX.GetPlayerFromId(playerId)
        if xPlayer.job.name == 'police' then
            count = count + 1
        end
    end
    return count
end
