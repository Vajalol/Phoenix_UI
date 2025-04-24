local Module = Phoenix_UI:NewModule("Skins.TimeManager");

function Module:OnEnable()
    if (Phoenix_UI:Color()) then
        local f = CreateFrame("Frame")
        f:RegisterEvent("ADDON_LOADED")
        f:SetScript("OnEvent", function(self, event, name)
            if name == "Blizzard_TimeManager" then
                Phoenix_UI:Skin(TimeManagerFrame, true)
                Phoenix_UI:Skin(TimeManagerFrame.NineSlice, true)
                Phoenix_UI:Skin(TimeManagerFrameInset, true)
                Phoenix_UI:Skin(TimeManagerFrameInset.NineSlice, true)
                Phoenix_UI:Skin({ StopwatchFrameBackgroundLeft }, true, true)
            end
        end)
    end
end



