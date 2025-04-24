local Hide = Phoenix_UI:NewModule("ActionBars.Hide");

function Hide:OnEnable()
    local db = Phoenix_UI.db.profile.misc

    if db.repbar then
        StatusTrackingBarManager:HookScript("OnEvent", function()
            StatusTrackingBarManager:Hide()
        end)
    end
end



