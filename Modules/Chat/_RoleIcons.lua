--- Role Icons Module (Disabled)
--- This module has been disabled and all functionality removed.
local Module = Phoenix_UI:NewModule("Chat.RoleIcons");

function Module:OnEnable()
    -- This module has been disabled and all functionality removed.
    -- Remove the database flag to avoid confusion
    if Phoenix_UI.db and Phoenix_UI.db.profile and Phoenix_UI.db.profile.chat then
        Phoenix_UI.db.profile.chat.roleicons = false
    end
    
    if Phoenix_UI.debug then
        print("|cffFF7D0APhoenix UI:|r Role icons feature has been disabled.")
    end
end
