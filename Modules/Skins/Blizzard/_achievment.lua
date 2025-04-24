local Module = Phoenix_UI:NewModule("Skins.Achievment");

function Module:OnEnable()
    if (Phoenix_UI:Color()) then
        local f = CreateFrame("Frame")
        f:RegisterEvent("ADDON_LOADED")
        f:SetScript("OnEvent", function(self, event, name)
            if name == "Blizzard_AchievementUI" then
                Phoenix_UI:Skin(AchievementFrame, true)
                Phoenix_UI:Skin(AchievementFrame.Header, true)
                Phoenix_UI:Skin(AchievementFrame.Searchbox, true)
                Phoenix_UI:Skin(AchievementFrameSummary, true)
                Phoenix_UI:Skin(AchievementFrameTab1, true)
                Phoenix_UI:Skin(AchievementFrameTab2, true)
                Phoenix_UI:Skin(AchievementFrameTab3, true)
                AchievementFrame.Header.PointBorder:SetAlpha(0)
                select(8, AchievementFrame.Header:GetRegions()):SetVertexColor(1, 1, 1)
            end
        end)
    end
end



