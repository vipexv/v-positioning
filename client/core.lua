Script = {
    State = {
        isPositioning = false,
        cachedCoords = nil,
        clonedPed = nil
    }
}

CONTROLS = {
    backspace = 194,
    prev = 188,
    exit = 194,
}

local keysTable = {
    { 'Exit',   194 },
    { 'Rotate', 140 },
    { 'Up',     44 },
    { 'Down',   38 },
}

-- Function to end the positioning thread
EndThread = function()
    EnableAllControlActions(0)
    Script.State.isPositioning = false
    local cachedCoords = Script.State.cachedCoords
    local cloneCoords = GetEntityCoords(Script.State.clonedPed)
    local aboveGround, groundZ = GetGroundZAndNormalFor_3dCoord(cloneCoords.x, cloneCoords.y, cloneCoords.z)

    if not aboveGround and cachedCoords then
        Notify("(ERROR) Attempted to teleport below the map.")
        SetEntityAlpha(Script.State.clonedPed, 255, false)
        FreezeEntityPosition(Script.State.clonedPed, false)
        SetEntityCoordsNoOffset(PlayerPedId(), cachedCoords.x, cachedCoords.y, cachedCoords.z, true, false, false)
        return
    end

    SetEntityAlpha(Script.State.clonedPed, 255, false)
    FreezeEntityPosition(Script.State.clonedPed, false)
    SetEntityCoordsNoOffset(PlayerPedId(), cloneCoords.x, cloneCoords.y, cloneCoords.z, true, false, false)


    local data = {
        coords = cloneCoords,
        heading = GetEntityHeading(Script.State.clonedPed)
    }

    TriggerServerEvent("positioning:server:entity:pos", PlayerPedId(), data)
end

-- Function to handle positioning logic
PositionThread = function()
    while Script.State.isPositioning do
        DisableControlActions()

        local scaleForm = MakeInstructionalScaleform(keysTable)
        DrawScaleformMovieFullscreen(scaleForm, 255, 255, 255, 255, 0)

        local clonedPed = Script.State.clonedPed
        if not clonedPed or not DoesEntityExist(clonedPed) then
            Debug("Cloned PED doesn't exist.")
            return
        end

        local forwardVector, rightVector = CalculateMovementVectors(clonedPed)

        HandleControlInputs(clonedPed, forwardVector, rightVector)

        local clonedPedCoords = GetEntityCoords(clonedPed)
        local cachedCoords = Script.State.cachedCoords
        local distance = #(clonedPedCoords - cachedCoords)

        if distance > Config.MaxDistance and cachedCoords then
            Notify("Max distance exceeded.")
            ClearPedTasksImmediately(Script.State.clonedPed)
            SetEntityAlpha(Script.State.clonedPed, 255, false)
            FreezeEntityPosition(Script.State.clonedPed, false)
            SetEntityCoords(Script.State.clonedPed, cachedCoords.x, cachedCoords.y, cachedCoords.z, true, false, false,
                false)
            Script.State.isPositioning = false
        end

        Wait(0)
    end
end

-- Function to disable control actions
DisableControlActions = function()
    local disabledActions = { 23, 24, 25, 30, 31, 32, 33, 34, 35, 38, 44, 45, 140, 176 }
    for _, action in ipairs(disabledActions) do
        DisableControlAction(0, action, true)
    end
end

-- Function to calculate movement vectors
CalculateMovementVectors = function(clonedPed)
    local forwardVector = GetEntityForwardVector(clonedPed)
    local upVector = vec3(0, 0, 1)
    local rightVector = vec3(
        forwardVector.y * upVector.z - forwardVector.z * upVector.y,
        forwardVector.z * upVector.x - forwardVector.x * upVector.z,
        forwardVector.x * upVector.y - forwardVector.y * upVector.x
    )
    return forwardVector, rightVector
end

-- Function to handle control inputs
HandleControlInputs = function(clonedPed, forwardVector, rightVector)
    local movementSpeed = 0.1

    -- Handle W key
    if IsDisabledControlPressed(0, 32) then
        local newPos = GetEntityCoords(clonedPed) + forwardVector * movementSpeed
        SetEntityCoordsNoOffset(clonedPed, newPos.x, newPos.y, newPos.z, true, false, false)
    end

    -- Handle S key
    if IsDisabledControlPressed(0, 33) then
        local newPos = GetEntityCoords(clonedPed) - forwardVector * movementSpeed
        SetEntityCoordsNoOffset(clonedPed, newPos.x, newPos.y, newPos.z, true, false, false)
    end

    -- Handle A key
    if IsDisabledControlPressed(0, 34) then
        local newPos = GetEntityCoords(clonedPed) - rightVector * movementSpeed
        SetEntityCoordsNoOffset(clonedPed, newPos.x, newPos.y, newPos.z, true, false, false)
    end

    -- Handle D key
    if IsDisabledControlPressed(0, 35) then
        local newPos = GetEntityCoords(clonedPed) + rightVector * movementSpeed
        SetEntityCoordsNoOffset(clonedPed, newPos.x, newPos.y, newPos.z, true, false, false)
    end

    -- Handle E key
    if IsDisabledControlPressed(0, 38) then
        local currPos = GetEntityCoords(clonedPed)
        SetEntityCoordsNoOffset(clonedPed, currPos.x, currPos.y, currPos.z + 0.2, true, false, false)
    end

    -- Handle Q key
    if IsDisabledControlPressed(0, 44) then
        local currPos = GetEntityCoords(clonedPed)
        SetEntityCoordsNoOffset(clonedPed, currPos.x, currPos.y, currPos.z - 0.2, true, false, false)
    end

    -- Handle R key
    if IsDisabledControlPressed(0, 45) then
        local newHeading = GetEntityHeading(clonedPed) - 2.0
        SetEntityHeading(clonedPed, newHeading)
    end

    -- Handle Enter key
    if IsDisabledControlPressed(0, 176) then
        EndThread()
    end
end

-- Function to move the ped
MovePed = function(ped, direction, speed)
    local newPos = GetEntityCoords(ped) + direction * speed
    SetEntityCoordsNoOffset(ped, newPos.x, newPos.y, newPos.z, true, false, false)
end

-- Function to toggle positioning mode
TogglePositioningMode = function()
    if Script.State.isPositioning then
        return EndThread()
    end

    Script.State.isPositioning = true
    local srcPedId = PlayerPedId()
    local srcPedCoords = GetEntityCoords(srcPedId)

    Script.State.clonedPed = srcPedId
    Script.State.cachedCoords = srcPedCoords

    SetEntityAlpha(srcPedId, 150, false)
    FreezeEntityPosition(srcPedId, true)

    CreateThread(PositionThread)
end
