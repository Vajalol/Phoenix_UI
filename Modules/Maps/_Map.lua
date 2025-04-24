local Module = Phoenix_UI:NewModule("Maps.Map")

function Module:OnEnable()
    local db = Phoenix_UI.db.profile.maps

    if db then
        local Size = CreateFrame("Frame")
        Size:RegisterEvent("ADDON_LOADED")
        Size:RegisterEvent("PLAYER_LOGIN")
        Size:RegisterEvent("PLAYER_ENTERING_WORLD")
        Size:RegisterEvent("VARIABLES_LOADED")
        Size:SetScript("OnEvent", function(self, event, addonName)
            -- Only proceed if WorldMapFrame exists and is not forbidden
            if WorldMapFrame and not WorldMapFrame:IsForbidden() then
                -- Set initial alpha
                WorldMapFrame:SetAlpha(db.opacity or 1)
                
                -- Hook Show to maintain alpha
                hooksecurefunc(WorldMapFrame, "Show", function()
                    if not WorldMapFrame:IsForbidden() then
                        WorldMapFrame:SetAlpha(db.opacity or 1)
                    end
                end)
                
                -- Unregister events after successful setup
                self:UnregisterAllEvents()
            end
        end)
    end
end



