-- Chat Organize Module (Disabled)
-- This module has been disabled to fix texture rendering issues
local Module = Phoenix_UI:NewModule("Chat.Organize");

function Module:OnEnable()
    -- Module disabled to fix texture rendering issues
    if Phoenix_UI.debug then
        print("|cffFF7D0APhoenix UI:|r Chat organization module has been disabled to fix texture rendering.")
    end
end
