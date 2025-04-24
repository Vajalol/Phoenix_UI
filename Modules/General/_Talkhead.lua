local Module = Phoenix_UI:NewModule("General.Talkhead");

function Module:OnEnable()
    local db = Phoenix_UI.db.profile.general.cosmetic.talkinghead
    if not db then
        hooksecurefunc(TalkingHeadFrame, "PlayCurrent", function()
            TalkingHeadFrame:Hide()
        end)
    end
end



