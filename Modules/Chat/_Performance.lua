-- Chat Performance Module (Disabled)
-- This module has been disabled to fix texture rendering issues
local Module = Phoenix_UI:NewModule("Chat.Performance");

function Module:OnEnable()
    -- Module disabled to fix texture rendering issues
    if Phoenix_UI.debug then
        print("|cffFF7D0APhoenix UI:|r Chat performance module has been disabled to fix texture rendering.")
    end
    
    -- Initialize the database settings to ensure they exist but are disabled
    local db = Phoenix_UI.db and Phoenix_UI.db.profile and Phoenix_UI.db.profile.chat
    if db and not db.performance then
        db.performance = {
            enabled = false,
            trimOldMessages = false,
            compressHistory = false,
            virtualScrolling = false,
            throttleUpdates = false
        }
    elseif db and db.performance then
        db.performance.enabled = false
        db.performance.virtualScrolling = false
    end
end
