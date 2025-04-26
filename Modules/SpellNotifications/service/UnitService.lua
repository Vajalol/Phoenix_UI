local _, SpellNotifications = ...

-- Determine if we should ignore this event
function SpellNotifications:ShouldIgnoreEvent(sourceGUID, destinationGUID)
    local playerGUID = UnitGUID("player")
    local petGUID = UnitGUID("pet")
    
    -- Only process events that originate from the player or player's pet
    return not (sourceGUID == playerGUID or sourceGUID == petGUID)
end

-- Determine if we should ignore this dispel event
function SpellNotifications:ShouldIgnoreDispelEvent(sourceGUID, targetGUID)
    local playerGUID = UnitGUID("player")
    local petGUID = UnitGUID("pet")
    local targetPlayerGUID = UnitGUID("target")
    
    -- Only process dispel events that originate from the player or player's pet
    if sourceGUID ~= playerGUID and sourceGUID ~= petGUID then
        return true
    end
    
    -- Ignore dispel events on the player's target
    if targetGUID == targetPlayerGUID then
        return true
    end
    
    return false
end 