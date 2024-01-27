---@param data CoordData
RegisterNetEvent("positioning:client:entity:pos", function(serverId, data)
    local playerId = GetPlayerFromServerId(serverId)
    local playerPed = GetPlayerPed(playerId)
    local coords = data.coords
    local heading = data.heading

    if DoesEntityExist(playerPed) and playerPed ~= PlayerPedId() then
        SetEntityCoords(playerPed, coords.x, coords.y, coords.z, true, false, false, false)
        SetEntityHeading(playerPed, heading)
        Debug("(Entity Exists) Successfully synced.")
    end
end)
