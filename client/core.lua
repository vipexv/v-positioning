Script = {
    State = {
        isPositioning = false,
        clonedPed = nil
    }
}

local PositionThread = function()
    while Script.State.isPositioning do
        DisableControlAction(0, 30, true)
        DisableControlAction(0, 31, true)
        DisableControlAction(0, 32, true)
        DisableControlAction(0, 33, true)
        DisableControlAction(0, 34, true)
        DisableControlAction(0, 35, true)
        DisableControlAction(0, 38, true)
        DisableControlAction(0, 45, true)

        local clonedPed = Script.State.clonedPed

        if not clonedPed then return end

        if not DoesEntityExist(clonedPed) then
            Debug("Cloned PED doesn't exist.")
            return
        end

        local forwardVector = GetEntityForwardVector(clonedPed)

        local movementSpeed = 0.1

        local upVector = vec3(0, 0, 1)

        local rightVector = vec3(
            forwardVector.y * upVector.z - forwardVector.z * upVector.y,
            forwardVector.z * upVector.x - forwardVector.x * upVector.z,
            forwardVector.x * upVector.y - forwardVector.y * upVector.x
        )

        if IsDisabledControlPressed(0, 32) then -- W key
            local newPos = GetEntityCoords(clonedPed) + forwardVector * movementSpeed
            SetEntityCoordsNoOffset(clonedPed, newPos.x, newPos.y, newPos.z, true, true, true)
        end

        if IsDisabledControlPressed(0, 33) then -- S key
            local newPos = GetEntityCoords(clonedPed) - forwardVector * movementSpeed
            SetEntityCoordsNoOffset(clonedPed, newPos.x, newPos.y, newPos.z, true, true, true)
        end

        if IsDisabledControlPressed(0, 34) then -- A key
            local newPos = GetEntityCoords(clonedPed) - rightVector * movementSpeed
            SetEntityCoordsNoOffset(clonedPed, newPos.x, newPos.y, newPos.z, true, true, true)
        end

        if IsDisabledControlPressed(0, 35) then -- D key
            local newPos = GetEntityCoords(clonedPed) + rightVector * movementSpeed
            SetEntityCoordsNoOffset(clonedPed, newPos.x, newPos.y, newPos.z, true, true, true)
        end

        if IsDisabledControlPressed(0, 38) then                  -- E key
            local newHeading = GetEntityHeading(clonedPed) + 2.0 -- Adjust rotation speed as needed
            SetEntityHeading(clonedPed, newHeading)
        end

        if IsDisabledControlPressed(0, 45) then                  -- R key
            local newHeading = GetEntityHeading(clonedPed) - 2.0 -- Adjust rotation speed as needed
            SetEntityHeading(clonedPed, newHeading)
        end

        Wait(0)
    end
end

TogglePositioningMode = function()
    if Script.State.isPositioning then
        EnableAllControlActions(0)
        Script.State.isPositioning = false
        DeleteEntity(Script.State.clonedPed)
        return Debug("Player is already in the positioning mode.")
    end

    Script.State.isPositioning = true
    local srcPedId = PlayerPedId()
    local srcPedCoords = GetEntityCoords(srcPedId)

    local clonedPed = ClonePed(srcPedId, false, true, true)
    Script.State.clonedPed = clonedPed


    SetEntityAlpha(clonedPed, 150, false)
    SetBlockingOfNonTemporaryEvents(clonedPed, true)
    SetPedFleeAttributes(clonedPed, 0, false)
    SetEntityCoords(clonedPed, srcPedCoords.x, srcPedCoords.y, srcPedCoords.z, true, false, false, false)

    CreateThread(PositionThread)
end
