local Module = Phoenix_UI:NewModule("General.Release");

function Module:OnEnable()
    local db = Phoenix_UI.db.profile.general
    if (db.automation.release) then
        local frame = CreateFrame("Frame")
        frame:RegisterEvent("PLAYER_DEAD")
        frame:SetScript("OnEvent", function(self, event) RepopMe() end)
    end
end



