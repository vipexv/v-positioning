RegisterCommand(Config.CommandName, function(_source, args, _rawCommand)
    if IsPedSittingInAnyVehicle(PlayerPedId()) then return Notify("Not Accessible while in a vehicle!") end

    TogglePositioningMode()
end, false)
