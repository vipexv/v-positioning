---@param ped any
---@param data CoordData
RegisterNetEvent("positioning:server:entity:pos", function(ped, data)
    if not ped or not source or not data then return end

    TriggerClientEvent('positioning:client:entity:pos', -1, source, data)
end)
