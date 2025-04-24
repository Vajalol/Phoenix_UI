local Module = Phoenix_UI:NewModule("UnitFrames.Text");

function Module:OnEnable()
    local db = Phoenix_UI.db.profile.unitframes.hitindicator
    if not (db) then
        PlayerFrame:HookScript("OnEvent", function()
            PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HitIndicator.HitText:Hide()
        end)
        PetHitIndicator:SetText(nil)
        PetHitIndicator.SetText = function() end
    end
end



