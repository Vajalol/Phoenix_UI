local Module = Phoenix_UI:NewModule("General.Core");

function Module:OnEnable()
    -- This is a master module for all General submodules
    -- It doesn't do anything by itself, but serves as a toggle point for all General features
    
    -- Log that the module was enabled
    if Phoenix_UI.debug then
        Phoenix_UI:Print("General.Core module enabled")
    end
end

function Module:OnDisable()
    -- Log that the module was disabled
    if Phoenix_UI.debug then
        Phoenix_UI:Print("General.Core module disabled")
    end
end
