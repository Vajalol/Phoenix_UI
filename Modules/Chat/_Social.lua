-- Chat Social Module (Disabled)
-- This module has been disabled to fix texture rendering issues
local Module = Phoenix_UI:NewModule("Chat.Social");

function Module:OnEnable()
    -- Module disabled to fix texture rendering issues
    if Phoenix_UI.debug then
        print("|cffFF7D0APhoenix UI:|r Chat social module has been disabled to fix emoji texture rendering.")
    end
    
    -- Initialize the database settings to ensure they exist but are disabled
    local db = Phoenix_UI.db and Phoenix_UI.db.profile and Phoenix_UI.db.profile.chat
    if db and not db.social then
        db.social = {
            enabled = false,
            enhancedStatuses = false,
            guildRanks = false,
            friendNotes = false,
            inlineTooltips = false
        }
    elseif db and db.social then
        db.social.enabled = false
    end
    
    -- No message filters or hooks are registered in this disabled version
end
