RegisterCommand(("show-nui-%s"):format(GetCurrentResourceName()), function()
    ToggleNuiFrame(true)
    Debug("[command:show-nui] ToggleNuiFrame called and set to true.")
end, false)

RegisterCommand("animPos", function(_source, args, _rawCommand)
    TogglePositioningMode()
end, false)
