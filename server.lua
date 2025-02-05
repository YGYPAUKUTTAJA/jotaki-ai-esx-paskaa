ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

-- Kun pelaaja aloittaa ryöstön
RegisterServerEvent('robbery:start')
AddEventHandler('robbery:start', function(target)
    local xPlayer = ESX.GetPlayerFromId(source)
    local robberyData = Config.Robbery[target]

    -- Tarkistetaan, että riittävästi poliiseja on paikalla
    if robberyData.policeRequired > GetPoliceCount() then
        TriggerClientEvent('esx:showNotification', xPlayer.source, 'Ei tarpeeksi poliiseja!')
        return
    end

    -- Tarkistetaan, onko ryöstö mahdollista (esim. aikarajoitus)
    if (os.time() - robberyData.lastRobbed) < robberyData.timerBeforeNewRob then
        TriggerClientEvent('esx:showNotification', xPlayer.source, 'Tule myöhemmin takaisin!')
        return
    end

    -- Päivitetään viimeisin ryöstö-aika
    robberyData.lastRobbed = os.time()

    -- Lähetetään ilmoitus poliiseille tai kaikille
    if robberyData.notifyTarget == 'police' then
        TriggerClientEvent('robbery:sendNotification', -1, 'Poliisit, ryöstö tapahtumassa: ' .. robberyData.name, robberyData.notifyMethod)
    elseif robberyData.notifyTarget == 'others' then
        TriggerClientEvent('robbery:sendNotification', -1, 'Ryöstö käynnissä: ' .. robberyData.name, robberyData.notifyMethod)
    end

    -- Lähetetään pelaajalle viesti
    TriggerClientEvent('esx:showNotification', xPlayer.source, 'Aloitit ryöstön: ' .. robberyData.name)
end)

-- Haetaan poliisien määrä
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
