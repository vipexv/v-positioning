---@param action string The action you wish to target
---@param data any The data you wish to send along with this action
function UIMessage(action, data)
    SendNUIMessage({
        action = action,
        data = data
    })
end

function ToggleNuiFrame(shouldShow)
    SetNuiFocus(shouldShow, shouldShow)
    UIMessage('setVisible', shouldShow)
    Debug("(func) [ToggleNuiFrame] \n (param) shouldShow: ", shouldShow)
end

---@param coords vector3
---@return boolean
---@return table
function Get2DCoordFrom3DCoord(coords)
    if not coords then return false, {} end
    local onScreen, x, y = GetScreenCoordFromWorldCoord(coords.x, coords.y, coords.z)
    return onScreen, { left = tostring(x * 100) .. "%", top = tostring(y * 100) .. "%" }
end

function ShowFloatingText(coords, msg)
    AddTextEntry('floatingTextNotification', msg)
    SetFloatingHelpTextWorldPosition(1, coords)
    SetFloatingHelpTextStyle(1, 1, 2, -1, 3, 0)
    BeginTextCommandDisplayHelp('floatingTextNotification')
    EndTextCommandDisplayHelp(2, false, false, -1)
end

-- Feel free to edit this to actually use your notification system, for now it jut prints it to the console.
Notify = function(text)
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandThefeedPostTicker(false, true)
end

function MakeInstructionalScaleform(keysTable)
    local scaleform = RequestScaleformMovie("instructional_buttons")
    while not HasScaleformMovieLoaded(scaleform) do
        Wait(10)
    end
    BeginScaleformMovieMethod(scaleform, "CLEAR_ALL")
    EndScaleformMovieMethod()

    BeginScaleformMovieMethod(scaleform, "SET_CLEAR_SPACE")
    ScaleformMovieMethodAddParamInt(200)
    EndScaleformMovieMethod()

    for btnIndex, keyData in ipairs(keysTable) do
        local btn = GetControlInstructionalButton(0, keyData[2], true)

        BeginScaleformMovieMethod(scaleform, "SET_DATA_SLOT")
        ScaleformMovieMethodAddParamInt(btnIndex - 1)
        ScaleformMovieMethodAddParamPlayerNameString(btn)
        BeginTextCommandScaleformString("STRING")
        AddTextComponentSubstringKeyboardDisplay(keyData[1])
        EndTextCommandScaleformString()
        EndScaleformMovieMethod()
    end

    BeginScaleformMovieMethod(scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
    EndScaleformMovieMethod()

    BeginScaleformMovieMethod(scaleform, "SET_BACKGROUND_COLOUR")
    ScaleformMovieMethodAddParamInt(0)
    ScaleformMovieMethodAddParamInt(0)
    ScaleformMovieMethodAddParamInt(0)
    ScaleformMovieMethodAddParamInt(80)
    EndScaleformMovieMethod()

    return scaleform
end
