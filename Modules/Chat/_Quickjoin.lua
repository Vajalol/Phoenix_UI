local Module = Phoenix_UI:NewModule("Chat.Quickjoin");

function Module:OnEnable()
    local db = Phoenix_UI.db.profile.chat.quickjoin
    if (db) then
        QuickJoinToastButton:Show()
        QuickJoinToastButton.Show = function()
            QuickJoinToastButton:SetPoint("TOPLEFT", ChatFrame1, "TOPLEFT", 50, 40)
        end
    else
        QuickJoinToastButton:Hide()
        QuickJoinToastButton.Show = function()
        end
    end
end



