local Module = Phoenix_UI:NewModule("Skins.Frames");

function Module:OnEnable()
    if (Phoenix_UI:Color()) then
        Phoenix_UI:Skin(GameMenuFrame, true)
        Phoenix_UI:Skin(GameMenuFrame.Header, true)
        Phoenix_UI:Skin(GameMenuFrame.Border, true)
        Phoenix_UI:Skin(StaticPopup1, true)
        Phoenix_UI:Skin(StaticPopup1.Border, true)
        Phoenix_UI:Skin(StaticPopup2, true)
        Phoenix_UI:Skin(StaticPopup2.Border, true)
        Phoenix_UI:Skin(StaticPopup3, true)
        Phoenix_UI:Skin(StaticPopup3.Border, true)
        Phoenix_UI:Skin(EditModeManagerFrame, true)
        Phoenix_UI:Skin(EditModeManagerFrame.Border, true)
        Phoenix_UI:Skin(VehicleSeatIndicator, true)
        Phoenix_UI:Skin(ReportFrame, true)
        Phoenix_UI:Skin(ReportFrame.Border, true)
        Phoenix_UI:Skin(ReadyStatus.Border, true)
        Phoenix_UI:Skin(LFGDungeonReadyStatus.Border, true)
        Phoenix_UI:Skin(LFGDungeonReadyDialog, true)
        Phoenix_UI:Skin(LFGDungeonReadyDialog.Border, true)
        Phoenix_UI:Skin(PVPMatchScoreboard.Content, true)
        Phoenix_UI:Skin(QueueStatusFrame, true)
        Phoenix_UI:Skin(QueueStatusFrame.NineSlice, true)
        Phoenix_UI:Skin(LFGListInviteDialog, true)
        Phoenix_UI:Skin(LFGListInviteDialog.Border, true)

        PVPMatchScoreboard:HookScript("OnShow", function()
            Phoenix_UI:Skin(PVPMatchScoreboard, true)
        end)

        -- Tabs
        Phoenix_UI:Skin(PVPScoreboardTab1, true)
        Phoenix_UI:Skin(PVPScoreboardTab2, true)
        Phoenix_UI:Skin(PVPScoreboardTab3, true)
    end
end



